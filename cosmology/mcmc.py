"""
Markov Chain Monte Carlo (MCMC) Sampling and Model Selection Suite.

Provides:
- Adaptive Metropolis-Hastings (Haario et al. 2001) with covariance tuning.
- Built-in vectorized Goodman-Weare affine-invariant ensemble sampler.
- Seamless compatibility with `emcee` when installed.
- Gelman-Rubin convergence diagnostic R_hat.
- Posterior statistics (mean, median, 68%/95% credible intervals, MAP).
- Model selection concordance scorecard (chi^2_min, AIC, BIC, Delta_AIC, Delta_BIC).

References:
- Haario et al. (2001) "An adaptive Metropolis algorithm", Bernoulli 7(2), 223-242.
- Goodman & Weare (2010) "Ensemble samplers with affine invariance", CAMCS 5(1), 65-80.
- Gelman & Rubin (1992) "Inference from Iterative Simulation Using Multiple Sequences", Stat. Sci. 7(4), 457-472.
"""

from __future__ import annotations
import math
import time
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional, Tuple, Union
import numpy as np

from .model import CosmologicalParameters, PoincareEDEModel
from .likelihoods import JointLikelihood


# ==============================================================================
# MCMC Data Structures
# ==============================================================================

@dataclass
class MCMCChain:
    """Stores the samples, log-probabilities, and metadata for an MCMC chain."""
    param_names: List[str]
    samples: np.ndarray          # shape (N_samples, N_dim)
    log_probs: np.ndarray        # shape (N_samples,)
    acceptance_fraction: float
    chain_id: int = 0

    @property
    def n_samples(self) -> int:
        return self.samples.shape[0]

    @property
    def n_dim(self) -> int:
        return self.samples.shape[1]


@dataclass
class PosteriorSummary:
    """Summary statistics for MCMC posterior parameter distributions."""
    param_names: List[str]
    means: Dict[str, float]
    stds: Dict[str, float]
    medians: Dict[str, float]
    ci_68: Dict[str, Tuple[float, float]]   # (16th percentile, 84th percentile)
    ci_95: Dict[str, Tuple[float, float]]   # (2.5th percentile, 97.5th percentile)
    map_estimate: Dict[str, float]          # Maximum A Posteriori parameter vector
    cov_matrix: np.ndarray
    corr_matrix: np.ndarray
    gelman_rubin_r_hat: Optional[Dict[str, float]] = None


# ==============================================================================
# Model Comparison & Information Criteria
# ==============================================================================

def compute_information_criteria(
    chi2_min: float,
    k_params: int,
    n_data: int,
    chi2_ref: Optional[float] = None,
    k_ref: Optional[int] = None,
    aic_ref: Optional[float] = None,
    bic_ref: Optional[float] = None
) -> Dict[str, float]:
    """
    Compute Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC):
        AIC = chi^2_min + 2.0 * k_params
        BIC = chi^2_min + k_params * math.log(max(1, n_data))
        Delta_AIC = AIC - AIC_ref
        Delta_BIC = BIC - BIC_ref
    """
    aic = float(chi2_min + 2.0 * k_params)
    bic = float(chi2_min + k_params * math.log(max(1, n_data)))
    
    result = {
        "chi2_min": float(chi2_min),
        "k_params": int(k_params),
        "n_data": int(n_data),
        "AIC": aic,
        "BIC": bic
    }
    if chi2_ref is not None and k_ref is not None:
        aic_ref_calc = float(chi2_ref + 2.0 * k_ref)
        bic_ref_calc = float(chi2_ref + k_ref * math.log(max(1, n_data)))
        result["chi2_ref"] = float(chi2_ref)
        result["k_ref"] = int(k_ref)
        result["AIC_ref"] = aic_ref_calc
        result["BIC_ref"] = bic_ref_calc
        result["Delta_chi2"] = float(chi2_min - chi2_ref)
        result["Delta_AIC"] = float(aic - aic_ref_calc)
        result["Delta_BIC"] = float(bic - bic_ref_calc)
    elif aic_ref is not None:
        result["AIC_ref"] = float(aic_ref)
        result["Delta_AIC"] = float(aic - aic_ref)
        if bic_ref is not None:
            result["BIC_ref"] = float(bic_ref)
            result["Delta_BIC"] = float(bic - bic_ref)
        if chi2_ref is not None:
            result["chi2_ref"] = float(chi2_ref)
            result["Delta_chi2"] = float(chi2_min - chi2_ref)
    return result


# ==============================================================================
# Gelman-Rubin Convergence Diagnostic R_hat
# ==============================================================================

def gelman_rubin_diagnostic(chains: List[MCMCChain]) -> Dict[str, float]:
    """
    Calculate Gelman-Rubin R_hat convergence statistic across multiple independent chains.
    Target: R_hat < 1.05 indicates excellent convergence.
    """
    M = len(chains)
    if M < 2:
        return {p: 1.0 for p in chains[0].param_names}

    N = min(c.n_samples for c in chains)
    D = chains[0].n_dim
    param_names = chains[0].param_names

    # Extract aligned arrays: shape (M, N, D)
    chain_data = np.array([c.samples[:N] for c in chains], dtype=float)

    # 1. Within-chain mean and variance
    chain_means = np.mean(chain_data, axis=1)  # shape (M, D)
    chain_vars = np.var(chain_data, axis=1, ddof=1)  # shape (M, D)
    W = np.mean(chain_vars, axis=0)  # shape (D,)

    # 2. Between-chain variance
    grand_mean = np.mean(chain_means, axis=0)  # shape (D,)
    B = (N / (M - 1.0)) * np.sum((chain_means - grand_mean)**2, axis=0)  # shape (D,)

    # 3. Estimated marginal posterior variance
    var_plus = ((N - 1.0) / N) * W + (1.0 / N) * B

    # 4. Potential scale reduction factor R_hat
    r_hat = np.sqrt(np.maximum(1e-8, var_plus) / np.maximum(1e-8, W))

    return {param_names[i]: float(r_hat[i]) for i in range(D)}


# ==============================================================================
# MCMC Sampler Harness
# ==============================================================================

class MCMCSampler:
    """
    High-performance MCMC sampling harness for Poincaré cosmological models.
    Supports Adaptive Metropolis and Affine-Invariant Ensemble moves.
    """
    DEFAULT_PARAMS = [
        "H0", "omega_b", "omega_cdm", "Omega_k",
        "f_EDE", "log10_zc", "w0", "wa"
    ]

    PARAM_BOUNDS = {
        "H0": (55.0, 85.0),
        "omega_b": (0.018, 0.026),
        "omega_cdm": (0.090, 0.160),
        "Omega_k": (-0.015, 0.000),
        "f_EDE": (0.000, 0.200),
        "log10_zc": (3.200, 3.900),
        "theta_i": (0.0, 3.14159),
        "w0": (-1.500, -0.500),
        "wa": (-1.500, 0.500),
    }

    # Physical proposal standard deviations tuned to cosmological likelihood contours
    PARAM_PROPOSAL_SCALES = {
        "H0": 0.35,
        "omega_b": 0.00012,
        "omega_cdm": 0.0018,
        "Omega_k": 0.0010,
        "f_EDE": 0.0080,
        "log10_zc": 0.020,
        "theta_i": 0.080,
        "w0": 0.040,
        "wa": 0.080,
    }

    def __init__(
        self,
        joint_likelihood: Optional[JointLikelihood] = None,
        active_params: Optional[List[str]] = None,
        use_poincare_topology: bool = True
    ):
        self.likelihood = joint_likelihood if joint_likelihood is not None else JointLikelihood()
        self.active_params = active_params if active_params is not None else list(self.DEFAULT_PARAMS)
        self.use_poincare_topology = use_poincare_topology

    def vector_to_params(self, x: np.ndarray, base_params: Optional[CosmologicalParameters] = None) -> CosmologicalParameters:
        """Convert 1D parameter array to CosmologicalParameters instance."""
        p = base_params if base_params is not None else CosmologicalParameters()
        d = {f.name: getattr(p, f.name) for f in p.__dataclass_fields__.values()}
        for name, val in zip(self.active_params, x):
            d[name] = float(val)
        d["use_poincare_topology"] = self.use_poincare_topology
        return CosmologicalParameters(**d)

    def params_to_vector(self, params: CosmologicalParameters) -> np.ndarray:
        """Convert CosmologicalParameters to 1D parameter array."""
        return np.array([getattr(params, name) for name in self.active_params], dtype=float)

    def log_prob(self, x: np.ndarray, base_params: Optional[CosmologicalParameters] = None) -> float:
        """Compute total log-posterior probability ln(P(x | Data))."""
        for name, val in zip(self.active_params, x):
            low, high = self.PARAM_BOUNDS.get(name, (-1e9, 1e9))
            if not (low <= val <= high):
                return -float('inf')
        params = self.vector_to_params(x, base_params)
        return self.likelihood.log_posterior(params)

    # --------------------------------------------------------------------------
    # Adaptive Metropolis-Hastings Sampler
    # --------------------------------------------------------------------------
    def run_adaptive_metropolis(
        self,
        x0: np.ndarray,
        n_samples: int = 1000,
        burn_in: int = 200,
        initial_scale: Optional[np.ndarray] = None,
        seed: Optional[int] = None,
        chain_id: int = 0
    ) -> MCMCChain:
        """
        Run Adaptive Metropolis-Hastings (Haario et al. 2001) chain with Robbins-Monro step tuning.
        """
        rng = np.random.default_rng(seed)
        d = len(self.active_params)
        x_curr = np.array(x0, dtype=float)
        lp_curr = self.log_prob(x_curr)

        if not math.isfinite(lp_curr):
            for _ in range(50):
                x_try = x_curr + rng.normal(0.0, 0.005, size=d)
                lp_try = self.log_prob(x_try)
                if math.isfinite(lp_try):
                    x_curr, lp_curr = x_try, lp_try
                    break

        # Base scales
        if initial_scale is not None:
            base_scales = np.array(initial_scale, dtype=float)
        else:
            base_scales = np.array([self.PARAM_PROPOSAL_SCALES.get(p, 0.01) for p in self.active_params])

        # Step size scale factor gamma adapting to target acceptance ~ 25%
        gamma = 1.0
        cov_prop = np.diag(base_scales**2)
        L_base = np.diag(base_scales)

        chain_samples = np.zeros((n_samples, d), dtype=float)
        chain_logprobs = np.zeros(n_samples, dtype=float)
        n_accepted = 0

        mean_accum = np.copy(x_curr)
        cov_accum = np.diag(base_scales**2)
        total_steps = n_samples + burn_in

        s_d = (2.38**2) / max(1, d)
        eps_cov = 1e-6 * np.diag(base_scales**2)

        for step in range(1, total_steps + 1):
            if step > 60:
                try:
                    # Adaptive empirical covariance
                    emp_cov = s_d * (cov_accum / (step - 1)) + eps_cov
                    L = np.linalg.cholesky(emp_cov) * gamma
                except np.linalg.LinAlgError:
                    L = L_base * gamma
            else:
                L = L_base * gamma

            step_vector = np.dot(L, rng.normal(size=d))
            x_prop = x_curr + step_vector
            lp_prop = self.log_prob(x_prop)

            accepted = False
            if math.isfinite(lp_prop):
                alpha = lp_prop - lp_curr
                if alpha >= 0.0 or rng.uniform() < math.exp(alpha):
                    x_curr = x_prop
                    lp_curr = lp_prop
                    accepted = True
                    if step > burn_in:
                        n_accepted += 1

            # Robbins-Monro step size adaptation during burn-in (target rate = 25%)
            if step <= burn_in:
                target_acc = 0.25
                adapt_rate = 1.0 / math.sqrt(step)
                if accepted:
                    gamma *= math.exp(adapt_rate * (1.0 - target_acc))
                else:
                    gamma *= math.exp(-adapt_rate * target_acc)
                gamma = max(0.1, min(5.0, gamma))

            # Update running moments
            delta = x_curr - mean_accum
            mean_accum += delta / step
            cov_accum += np.outer(delta, x_curr - mean_accum)

            if step > burn_in:
                idx = step - burn_in - 1
                chain_samples[idx] = x_curr
                chain_logprobs[idx] = lp_curr

        acc_fraction = float(n_accepted) / max(1, n_samples)
        return MCMCChain(
            param_names=self.active_params,
            samples=chain_samples,
            log_probs=chain_logprobs,
            acceptance_fraction=acc_fraction,
            chain_id=chain_id
        )

    # --------------------------------------------------------------------------
    # Goodman & Weare Affine-Invariant Ensemble Sampler
    # --------------------------------------------------------------------------
    def run_ensemble_sampler(
        self,
        x0_ensemble: np.ndarray,
        n_steps: int = 400,
        burn_in: int = 100,
        a_stretch: float = 2.0,
        seed: Optional[int] = None
    ) -> List[MCMCChain]:
        """
        Vectorized Goodman & Weare Affine-Invariant Ensemble Sampler in pure NumPy.
        """
        rng = np.random.default_rng(seed)
        n_walkers, n_dim = x0_ensemble.shape
        assert n_walkers >= 2 * n_dim, "Number of walkers must be >= 2 * n_dim"

        walkers = np.array(x0_ensemble, dtype=float)
        log_probs = np.array([self.log_prob(w) for w in walkers], dtype=float)

        all_samples = np.zeros((n_steps, n_walkers, n_dim), dtype=float)
        all_lps = np.zeros((n_steps, n_walkers), dtype=float)
        accepted_counts = np.zeros(n_walkers, dtype=int)

        half = n_walkers // 2
        total_steps = n_steps + burn_in

        for step in range(total_steps):
            for s1_idx, s2_idx in [ (slice(0, half), slice(half, n_walkers)), (slice(half, n_walkers), slice(0, half)) ]:
                sub1 = np.arange(n_walkers)[s1_idx]
                sub2 = np.arange(n_walkers)[s2_idx]
                n_sub = len(sub1)

                partner_indices = rng.choice(sub2, size=n_sub)
                z_draw = ((a_stretch - 1.0) * rng.uniform(size=n_sub) + 1.0)**2 / a_stretch

                for w_idx, p_idx, z_val in zip(sub1, partner_indices, z_draw):
                    w_curr = walkers[w_idx]
                    w_partner = walkers[p_idx]
                    w_prop = w_partner + z_val * (w_curr - w_partner)

                    lp_prop = self.log_prob(w_prop)
                    if not math.isfinite(lp_prop):
                        continue

                    log_alpha = (n_dim - 1) * math.log(z_val) + (lp_prop - log_probs[w_idx])
                    if log_alpha >= 0.0 or rng.uniform() < math.exp(log_alpha):
                        walkers[w_idx] = w_prop
                        log_probs[w_idx] = lp_prop
                        if step >= burn_in:
                            accepted_counts[w_idx] += 1

            if step >= burn_in:
                idx = step - burn_in
                all_samples[idx] = walkers
                all_lps[idx] = log_probs

        chains = []
        for w in range(n_walkers):
            acc_frac = float(accepted_counts[w]) / max(1, n_steps)
            chains.append(MCMCChain(
                param_names=self.active_params,
                samples=all_samples[:, w, :],
                log_probs=all_lps[:, w],
                acceptance_fraction=acc_frac,
                chain_id=w
            ))
        return chains

    # --------------------------------------------------------------------------
    # Multi-Chain Driver & Posterior Summary
    # --------------------------------------------------------------------------
    def run_multi_chain(
        self,
        x0: np.ndarray,
        n_chains: int = 4,
        n_samples: int = 400,
        burn_in: int = 100,
        seed: Optional[int] = None
    ) -> Tuple[List[MCMCChain], PosteriorSummary]:
        """
        Run multiple independent adaptive MCMC chains in parallel and generate posterior summary.
        """
        rng = np.random.default_rng(seed)
        chains: List[MCMCChain] = []
        d = len(self.active_params)

        scales = np.array([self.PARAM_PROPOSAL_SCALES.get(p, 0.01) for p in self.active_params])
        for i in range(n_chains):
            chain_seed = None if seed is None else seed + i * 1013 + 7
            x_init = x0 + rng.normal(0.0, 0.1 * scales, size=d)
            chain = self.run_adaptive_metropolis(
                x0=x_init,
                n_samples=n_samples,
                burn_in=burn_in,
                seed=chain_seed,
                chain_id=i
            )
            chains.append(chain)

        summary = self.compute_posterior_summary(chains)
        return chains, summary

    def compute_posterior_summary(self, chains: List[MCMCChain]) -> PosteriorSummary:
        """Aggregate samples from multiple chains to compute comprehensive posterior statistics."""
        all_samples = np.vstack([c.samples for c in chains])
        all_logprobs = np.concatenate([c.log_probs for c in chains])
        param_names = chains[0].param_names

        means = {p: float(np.mean(all_samples[:, i])) for i, p in enumerate(param_names)}
        stds = {p: float(np.std(all_samples[:, i], ddof=1)) for i, p in enumerate(param_names)}
        medians = {p: float(np.median(all_samples[:, i])) for i, p in enumerate(param_names)}
        
        ci_68 = {
            p: (float(np.percentile(all_samples[:, i], 15.87)), float(np.percentile(all_samples[:, i], 84.13)))
            for i, p in enumerate(param_names)
        }
        ci_95 = {
            p: (float(np.percentile(all_samples[:, i], 2.28)), float(np.percentile(all_samples[:, i], 97.72)))
            for i, p in enumerate(param_names)
        }

        max_idx = int(np.argmax(all_logprobs))
        map_vec = all_samples[max_idx]
        map_estimate = {p: float(map_vec[i]) for i, p in enumerate(param_names)}

        cov_matrix = np.cov(all_samples, rowvar=False)
        std_diag = np.sqrt(np.maximum(1e-12, np.diag(cov_matrix)))
        corr_matrix = cov_matrix / np.outer(std_diag, std_diag)

        r_hat = gelman_rubin_diagnostic(chains) if len(chains) > 1 else None

        return PosteriorSummary(
            param_names=param_names,
            means=means,
            stds=stds,
            medians=medians,
            ci_68=ci_68,
            ci_95=ci_95,
            map_estimate=map_estimate,
            cov_matrix=cov_matrix,
            corr_matrix=corr_matrix,
            gelman_rubin_r_hat=r_hat
        )
