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
import json
import math
import os
import time
from dataclasses import dataclass, field, asdict
from typing import Any, Callable, Dict, List, Optional, Tuple, Union
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
    autocorr_time: Optional[Dict[str, float]] = None
    effective_sample_size: Optional[Dict[str, float]] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert summary statistics to a JSON-serializable dictionary."""
        return {
            "param_names": list(self.param_names),
            "means": {k: float(v) for k, v in self.means.items()},
            "stds": {k: float(v) for k, v in self.stds.items()},
            "medians": {k: float(v) for k, v in self.medians.items()},
            "ci_68": {k: [float(v[0]), float(v[1])] for k, v in self.ci_68.items()},
            "ci_95": {k: [float(v[0]), float(v[1])] for k, v in self.ci_95.items()},
            "map_estimate": {k: float(v) for k, v in self.map_estimate.items()},
            "cov_matrix": self.cov_matrix.tolist(),
            "corr_matrix": self.corr_matrix.tolist(),
            "gelman_rubin_r_hat": {k: float(v) for k, v in self.gelman_rubin_r_hat.items()} if self.gelman_rubin_r_hat else None,
            "autocorr_time": {k: float(v) for k, v in self.autocorr_time.items()} if self.autocorr_time else None,
            "effective_sample_size": {k: float(v) for k, v in self.effective_sample_size.items()} if self.effective_sample_size else None,
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> PosteriorSummary:
        """Construct PosteriorSummary from a dictionary."""
        ci_68 = {k: (float(v[0]), float(v[1])) for k, v in data["ci_68"].items()}
        ci_95 = {k: (float(v[0]), float(v[1])) for k, v in data["ci_95"].items()}
        cov_matrix = np.array(data["cov_matrix"], dtype=float)
        corr_matrix = np.array(data["corr_matrix"], dtype=float)
        r_hat = {k: float(v) for k, v in data["gelman_rubin_r_hat"].items()} if data.get("gelman_rubin_r_hat") else None
        act = {k: float(v) for k, v in data["autocorr_time"].items()} if data.get("autocorr_time") else None
        ess = {k: float(v) for k, v in data["effective_sample_size"].items()} if data.get("effective_sample_size") else None

        return cls(
            param_names=list(data["param_names"]),
            means={k: float(v) for k, v in data["means"].items()},
            stds={k: float(v) for k, v in data["stds"].items()},
            medians={k: float(v) for k, v in data["medians"].items()},
            ci_68=ci_68,
            ci_95=ci_95,
            map_estimate={k: float(v) for k, v in data["map_estimate"].items()},
            cov_matrix=cov_matrix,
            corr_matrix=corr_matrix,
            gelman_rubin_r_hat=r_hat,
            autocorr_time=act,
            effective_sample_size=ess
        )


# ==============================================================================
# Serialization Utilities
# ==============================================================================

def save_chains(chains: List[MCMCChain], filename: str) -> None:
    """
    Save MCMC chain objects to a compressed .npz file on disk.
    """
    dir_name = os.path.dirname(filename)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)

    samples_arr = np.array([c.samples for c in chains], dtype=float)
    log_probs_arr = np.array([c.log_probs for c in chains], dtype=float)
    acc_arr = np.array([c.acceptance_fraction for c in chains], dtype=float)
    chain_ids = np.array([c.chain_id for c in chains], dtype=int)
    param_names = np.array(chains[0].param_names, dtype=str)

    np.savez_compressed(
        filename,
        samples=samples_arr,
        log_probs=log_probs_arr,
        acceptance_fractions=acc_arr,
        chain_ids=chain_ids,
        param_names=param_names
    )


def load_chains(filename: str) -> List[MCMCChain]:
    """
    Load MCMC chain objects from a compressed .npz file on disk.
    """
    data = np.load(filename, allow_pickle=True)
    samples_arr = data["samples"]
    log_probs_arr = data["log_probs"]
    acc_arr = data["acceptance_fractions"]
    chain_ids = data["chain_ids"]
    param_names = list(data["param_names"])

    n_chains = samples_arr.shape[0]
    chains: List[MCMCChain] = []
    for i in range(n_chains):
        chain = MCMCChain(
            param_names=param_names,
            samples=samples_arr[i],
            log_probs=log_probs_arr[i],
            acceptance_fraction=float(acc_arr[i]),
            chain_id=int(chain_ids[i])
        )
        chains.append(chain)
    return chains


def save_posterior_summary(summary: PosteriorSummary, filename: str) -> None:
    """
    Save PosteriorSummary statistics to a JSON or NPZ file on disk.
    """
    dir_name = os.path.dirname(filename)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)

    if filename.endswith(".npz"):
        s_dict = summary.to_dict()
        np.savez_compressed(filename, **s_dict)
    else:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(summary.to_dict(), f, indent=2)


def load_posterior_summary(filename: str) -> PosteriorSummary:
    """
    Load PosteriorSummary statistics from a JSON or NPZ file on disk.
    """
    if filename.endswith(".npz"):
        data = np.load(filename, allow_pickle=True)
        d = {k: data[k].item() if data[k].shape == () else data[k] for k in data.files}
        return PosteriorSummary.from_dict(d)
    else:
        with open(filename, "r", encoding="utf-8") as f:
            d = json.load(f)
        return PosteriorSummary.from_dict(d)


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
# Autocorrelation Time & Effective Sample Size
# ==============================================================================

def _autocorr_1d(x: np.ndarray) -> np.ndarray:
    """
    Compute sample autocorrelation function rho(t) for a 1D sequence x using FFT.
    """
    n = len(x)
    if n <= 1:
        return np.array([1.0], dtype=float)
    x_cen = x - np.mean(x)
    var = float(np.var(x))
    if var < 1e-15:
        return np.zeros(n, dtype=float)
    
    # FFT-based autocorrelation for O(N log N) speed
    n_fft = 2 ** int(math.ceil(math.log2(2 * n - 1)))
    fx = np.fft.rfft(x_cen, n=n_fft)
    corr = np.fft.irfft(fx * np.conjugate(fx), n=n_fft)[:n]
    norm = np.arange(n, 0, -1, dtype=float) * var
    return np.maximum(-1.0, np.minimum(1.0, corr / np.maximum(1e-12, norm)))


def _compute_tau_1d(corr: np.ndarray, c: float = 5.0) -> float:
    """
    Compute integrated autocorrelation time tau from autocorrelation rho(t)
    with automated Sokal windowing cutoff W >= c * tau_W.
    """
    n = len(corr)
    if n <= 1:
        return 1.0
    
    tau_w = 1.0 + 2.0 * np.cumsum(corr[1:])
    windows = np.arange(1, n, dtype=float)
    window_mask = windows >= c * tau_w
    if np.any(window_mask):
        w_idx = int(np.where(window_mask)[0][0])
        return float(max(1.0, min(float(n), tau_w[w_idx])))
    else:
        # Conservative fallback if chain has not reached full window
        return float(max(1.0, min(float(n), tau_w[-1])))


def integrated_autocorr_time(
    chain: Union[MCMCChain, List[MCMCChain], np.ndarray],
    c: float = 5.0
) -> Union[Dict[str, float], np.ndarray, float]:
    """
    Compute integrated autocorrelation time tau for MCMC chains using automated Sokal windowing.
    
    Supports:
    - MCMCChain: returns Dict[str, float]
    - List[MCMCChain]: averages autocorrelation across chains and returns Dict[str, float]
    - 1D np.ndarray: returns float
    - 2D np.ndarray (N_samples, N_dim): returns 1D np.ndarray (N_dim,)
    - 3D np.ndarray (N_chains, N_samples, N_dim): returns 1D np.ndarray (N_dim,)
    """
    if isinstance(chain, MCMCChain):
        res = {}
        for i, name in enumerate(chain.param_names):
            corr = _autocorr_1d(chain.samples[:, i])
            res[name] = _compute_tau_1d(corr, c=c)
        return res

    elif isinstance(chain, list) and len(chain) > 0 and isinstance(chain[0], MCMCChain):
        param_names = chain[0].param_names
        d = chain[0].n_dim
        n = min(c_i.n_samples for c_i in chain)
        res = {}
        for i, name in enumerate(param_names):
            # Average autocorrelation across chains
            corrs = np.array([_autocorr_1d(c_i.samples[:n, i]) for c_i in chain], dtype=float)
            mean_corr = np.mean(corrs, axis=0)
            res[name] = _compute_tau_1d(mean_corr, c=c)
        return res

    elif isinstance(chain, np.ndarray):
        arr = np.asarray(chain, dtype=float)
        if arr.ndim == 1:
            corr = _autocorr_1d(arr)
            return _compute_tau_1d(corr, c=c)
        elif arr.ndim == 2:
            n_samples, n_dim = arr.shape
            tau_arr = np.zeros(n_dim, dtype=float)
            for j in range(n_dim):
                corr = _autocorr_1d(arr[:, j])
                tau_arr[j] = _compute_tau_1d(corr, c=c)
            return tau_arr
        elif arr.ndim == 3:
            n_chains, n_samples, n_dim = arr.shape
            tau_arr = np.zeros(n_dim, dtype=float)
            for j in range(n_dim):
                corrs = np.array([_autocorr_1d(arr[i, :, j]) for i in range(n_chains)], dtype=float)
                mean_corr = np.mean(corrs, axis=0)
                tau_arr[j] = _compute_tau_1d(mean_corr, c=c)
            return tau_arr
        else:
            raise ValueError(f"Unsupported array dimension {arr.ndim} for autocorrelation estimation")
    elif isinstance(chain, list) and len(chain) > 0 and isinstance(chain[0], np.ndarray):
        # List of numpy arrays
        n = min(len(a) for a in chain)
        stacked = np.array([a[:n] for a in chain], dtype=float)
        return integrated_autocorr_time(stacked, c=c)
    else:
        raise TypeError(f"Unsupported input type {type(chain)} for integrated_autocorr_time")


def effective_sample_size(
    chain: Union[MCMCChain, List[MCMCChain], np.ndarray],
    c: float = 5.0
) -> Union[Dict[str, float], np.ndarray, float]:
    """
    Compute Effective Sample Size (ESS = N_total / tau) for MCMC chains.
    """
    if isinstance(chain, MCMCChain):
        tau = integrated_autocorr_time(chain, c=c)
        n = float(chain.n_samples)
        return {k: float(n / max(1e-6, v)) for k, v in tau.items()}

    elif isinstance(chain, list) and len(chain) > 0 and isinstance(chain[0], MCMCChain):
        tau = integrated_autocorr_time(chain, c=c)
        total_samples = float(sum(c_i.n_samples for c_i in chain))
        return {k: float(total_samples / max(1e-6, v)) for k, v in tau.items()}

    elif isinstance(chain, np.ndarray):
        arr = np.asarray(chain, dtype=float)
        tau = integrated_autocorr_time(arr, c=c)
        if arr.ndim == 1:
            return float(len(arr) / max(1e-6, float(tau)))
        elif arr.ndim == 2:
            n_samples, _ = arr.shape
            return np.array([float(n_samples / max(1e-6, t)) for t in tau], dtype=float)
        elif arr.ndim == 3:
            n_chains, n_samples, _ = arr.shape
            total_samples = float(n_chains * n_samples)
            return np.array([float(total_samples / max(1e-6, t)) for t in tau], dtype=float)
        else:
            raise ValueError(f"Unsupported array dimension {arr.ndim} for effective sample size")
    elif isinstance(chain, list) and len(chain) > 0 and isinstance(chain[0], np.ndarray):
        n = min(len(a) for a in chain)
        stacked = np.array([a[:n] for a in chain], dtype=float)
        return effective_sample_size(stacked, c=c)
    else:
        raise TypeError(f"Unsupported input type {type(chain)} for effective_sample_size")


# ==============================================================================
# Gelman-Rubin Convergence Diagnostic R_hat
# ==============================================================================

def gelman_rubin_diagnostic(
    chains: Union[List[MCMCChain], np.ndarray, List[np.ndarray]],
    param_names: Optional[List[str]] = None
) -> Union[Dict[str, float], np.ndarray, float]:
    """
    Calculate Gelman-Rubin R_hat convergence statistic across multiple independent chains.
    Target: R_hat < 1.05 indicates convergence, R_hat < 1.01 indicates excellent convergence.
    
    Accepts:
    - List[MCMCChain]: returns Dict[str, float]
    - np.ndarray (M_chains, N_samples, D_dim): returns Dict[str, float] if param_names else np.ndarray (D,)
    - np.ndarray (M_chains, N_samples): returns Dict[str, float] if param_names else float
    - List[np.ndarray]: list of arrays each of shape (N_samples, D_dim) or (N_samples,)
    """
    # 1. Format into 3D array of shape (M, N, D)
    if isinstance(chains, list) and len(chains) > 0 and isinstance(chains[0], MCMCChain):
        names = chains[0].param_names
        M = len(chains)
        if M < 2:
            return {p: 1.0 for p in names}
        N = min(c.n_samples for c in chains)
        D = chains[0].n_dim
        chain_data = np.array([c.samples[:N] for c in chains], dtype=float)
        return_dict = True
    elif isinstance(chains, np.ndarray):
        arr = np.asarray(chains, dtype=float)
        if arr.ndim == 2:
            # shape (M, N) -> single param
            M, N = arr.shape
            D = 1
            chain_data = arr[:, :, np.newaxis]
        elif arr.ndim == 3:
            M, N, D = arr.shape
            chain_data = arr
        else:
            raise ValueError(f"Array for Gelman-Rubin must be 2D (M, N) or 3D (M, N, D), got shape {arr.shape}")
        names = param_names
        return_dict = (names is not None)
    elif isinstance(chains, list) and len(chains) > 0 and isinstance(chains[0], np.ndarray):
        M = len(chains)
        N = min(len(a) for a in chains)
        sample0 = np.asarray(chains[0])
        if sample0.ndim == 1:
            D = 1
            chain_data = np.array([a[:N, np.newaxis] for a in chains], dtype=float)
        else:
            D = sample0.shape[1]
            chain_data = np.array([a[:N] for a in chains], dtype=float)
        names = param_names
        return_dict = (names is not None)
    else:
        raise TypeError(f"Unsupported chains format {type(chains)} for gelman_rubin_diagnostic")

    if M < 2:
        if return_dict and names:
            return {p: 1.0 for p in names}
        elif D == 1:
            return 1.0
        else:
            return np.ones(D, dtype=float)

    # 2. Within-chain mean and variance
    chain_means = np.mean(chain_data, axis=1)  # shape (M, D)
    chain_vars = np.var(chain_data, axis=1, ddof=1)  # shape (M, D)
    W = np.mean(chain_vars, axis=0)  # shape (D,)

    # 3. Between-chain variance
    grand_mean = np.mean(chain_means, axis=0)  # shape (D,)
    B = (N / (M - 1.0)) * np.sum((chain_means - grand_mean)**2, axis=0)  # shape (D,)

    # 4. Estimated marginal posterior variance
    var_plus = ((N - 1.0) / N) * W + (1.0 / N) * B

    # 5. Scale reduction factor R_hat
    safe_W = np.where(W < 1e-12, 1e-12, W)
    r_hat = np.sqrt(np.maximum(1.0, var_plus / safe_W))
    # If both W and B are virtually zero, r_hat is 1.0
    zero_var_mask = (W < 1e-12) & (B < 1e-12)
    r_hat[zero_var_mask] = 1.0

    if return_dict and names:
        return {names[i]: float(r_hat[i]) for i in range(D)}
    elif D == 1 and not return_dict:
        return float(r_hat[0])
    else:
        return r_hat


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
        "f_NEDE": (0.000, 0.200),
        "delta_N_idr": (0.000, 1.500),
        "g_dark_coupling": (0.000, 1.000),
        "n_s": (0.900, 1.050),
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
        "f_NEDE": 0.0080,
        "delta_N_idr": 0.030,
        "g_dark_coupling": 0.020,
        "n_s": 0.0040,
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
        eps_cov = 1e-4 * np.diag(base_scales**2)

        for step in range(1, total_steps + 1):
            # Mixture proposal: 95% adaptive empirical covariance, 5% base proposal (Roberts & Rosenthal 2009)
            if step > 40 and rng.uniform() > 0.05:
                try:
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
                gamma = max(0.05, min(5.0, gamma))

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
            x_init = x0 + rng.normal(0.0, 0.02 * scales, size=d)
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

    def run_ensemble_multi_chain(
        self,
        x0: np.ndarray,
        n_walkers: int = 16,
        n_steps: int = 200,
        burn_in: int = 50,
        a_stretch: float = 2.0,
        seed: Optional[int] = None
    ) -> Tuple[List[MCMCChain], PosteriorSummary]:
        """
        Run vectorized Goodman & Weare affine-invariant ensemble sampler initialized around x0.
        """
        rng = np.random.default_rng(seed)
        d = len(self.active_params)
        scales = np.array([self.PARAM_PROPOSAL_SCALES.get(p, 0.01) for p in self.active_params])
        walkers_init = x0 + rng.normal(0.0, 0.05 * scales, size=(n_walkers, d))
        chains = self.run_ensemble_sampler(
            x0_ensemble=walkers_init,
            n_steps=n_steps,
            burn_in=burn_in,
            a_stretch=a_stretch,
            seed=seed
        )
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
        act = integrated_autocorr_time(chains)
        ess = effective_sample_size(chains)

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
            gelman_rubin_r_hat=r_hat,
            autocorr_time=act,
            effective_sample_size=ess
        )
