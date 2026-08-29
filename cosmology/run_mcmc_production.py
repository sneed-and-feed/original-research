#!/usr/bin/env python3
"""
Production MCMC Sampling and Posterior Parameter Inference for
Poincaré Dodecahedral Adèlic Cosmology ($S^3/I^*$).

Executes multi-chain Markov Chain Monte Carlo parameter estimation on the full
`JointLikelihood` concordance suite (Planck 2018 priors, Planck low-ell topology,
Planck high-ell polarization, DESI 2024 BAO, Pantheon+ SNe Ia, Weak Lensing, and SH0ES).

Outputs:
- Posterior samples array saved to `cosmology/mcmc_production_results.npz`
- Complete posterior summary (means, 68%/95% CI, MAP, covariance, R_hat, ACT, ESS) saved to `cosmology/mcmc_production_summary.json`
- Formatted posterior terminal summary and Gelman-Rubin convergence verification.
"""

from __future__ import annotations
import argparse
import json
import math
import os
import sys
import time
from typing import Any, Dict, List, Optional, Tuple
import numpy as np

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from cosmology.model import CosmologicalParameters, PoincareEDEModel, PoincareTopology
from cosmology.likelihoods import JointLikelihood
from cosmology.mcmc import (
    MCMCChain,
    PosteriorSummary,
    MCMCSampler,
    save_chains,
    load_chains,
    save_posterior_summary,
    load_posterior_summary,
    gelman_rubin_diagnostic,
    integrated_autocorr_time,
    effective_sample_size,
    compute_information_criteria
)


def run_production_mcmc(
    n_chains: int = 4,
    n_samples: int = 600,
    burn_in: int = 200,
    seed: int = 42,
    sampler_type: str = "ensemble",
    include_shoes: bool = True,
    output_npz: str = "cosmology/mcmc_production_results.npz",
    output_json: str = "cosmology/mcmc_production_summary.json",
    assert_convergence: bool = False,
    r_hat_threshold: float = 1.15
) -> Tuple[List[MCMCChain], PosteriorSummary]:
    """
    Execute multi-chain production MCMC parameter estimation.
    """
    t_start = time.perf_counter()
    print("=" * 100)
    print("  PRODUCTION MCMC PARAMETER INFERENCE: POINCARÉ CONCORDANCE COSMOLOGY (S^3/I*)  ".center(100))
    print("=" * 100)

    # 1. Setup Joint Observational Likelihood
    print(f"\n[1/5] Initializing Joint Likelihood Suite (SH0ES Prior: {include_shoes})...")
    joint = JointLikelihood(
        include_low_ell=True,
        include_high_ell_pol=True,
        include_weak_lensing=True,
        include_shoes=include_shoes
    )
    dataset_counts = joint.dataset_info()
    print(f"      Total Observational Data Points N = {joint.n_data}")
    for dset, count in dataset_counts.items():
        if dset != "Total_Data_Points":
            print(f"      - {dset:<28}: {count} points")

    # 2. Configure Active Parameters and Sampler
    active_params = [
        "H0", "omega_b", "omega_cdm", "Omega_k",
        "f_EDE", "delta_N_idr", "g_dark_coupling",
        "w0", "wa"
    ]
    sampler = MCMCSampler(joint_likelihood=joint, active_params=active_params, use_poincare_topology=True)

    # Fiducial starting point (S^3/I* + IDR maximum-posterior region)
    x0 = np.array([
        71.50,      # H0 [km/s/Mpc]
        0.02239,    # omega_b
        0.1577,     # omega_cdm
        -0.0027,    # Omega_k
        0.1244,     # f_EDE
        0.350,      # delta_N_idr
        0.140,      # g_dark_coupling
        -0.800,     # w0
        -0.500      # wa
    ], dtype=float)

    # 3. Execute Sampling
    print(f"\n[2/5] Running MCMC sampling (Sampler: {sampler_type.upper()})...")
    if sampler_type.lower() in ["ensemble", "goodman_weare", "gw"]:
        n_walkers = max(18, 2 * len(active_params))
        print(f"      Walkers: {n_walkers} | Steps per walker: {n_samples} | Burn-in: {burn_in} | Total steps: {n_walkers * (n_samples + burn_in)}")
        chains, summary = sampler.run_ensemble_multi_chain(
            x0=x0,
            n_walkers=n_walkers,
            n_steps=n_samples,
            burn_in=burn_in,
            seed=seed
        )
    else:
        print(f"      Chains: {n_chains} | Samples per chain: {n_samples} | Burn-in: {burn_in} | Total steps: {n_chains * (n_samples + burn_in)}")
        chains, summary = sampler.run_multi_chain(
            x0=x0,
            n_chains=n_chains,
            n_samples=n_samples,
            burn_in=burn_in,
            seed=seed
        )

    t_sample = time.perf_counter() - t_start
    mean_acc = float(np.mean([c.acceptance_fraction for c in chains]))
    print(f"      Sampling completed in {t_sample:.2f}s | Mean Acceptance Fraction: {mean_acc * 100:.1f}%")

    # 4. Save Chains and Summary Artifacts
    print(f"\n[3/5] Serializing results to disk...")
    save_chains(chains, output_npz)
    save_posterior_summary(summary, output_json)
    print(f"      - Samples saved to: {output_npz} ({os.path.getsize(output_npz) / 1024:.1f} KB)")
    print(f"      - Summary saved to: {output_json} ({os.path.getsize(output_json) / 1024:.1f} KB)")

    # 5. Display Formatted Posterior Summary Table
    print(f"\n[4/5] Posterior Distribution Summary Statistics:")
    print("-" * 115)
    print(f"{'Parameter':<16} | {'Mean ± 1sigma':<18} | {'Median (68% CI)':<26} | {'95% Credible Interval':<24} | {'R_hat':<6} | {'tau':<5} | {'N_eff'}")
    print("-" * 115)

    r_hat_dict = summary.gelman_rubin_r_hat or {}
    act_dict = summary.autocorr_time or {}
    ess_dict = summary.effective_sample_size or {}

    for p in active_params:
        mean_v = summary.means[p]
        std_v = summary.stds[p]
        med_v = summary.medians[p]
        ci68 = summary.ci_68[p]
        ci95 = summary.ci_95[p]
        r_hat = r_hat_dict.get(p, 1.0)
        tau_val = act_dict.get(p, 1.0)
        ess_val = ess_dict.get(p, float(len(chains) * n_samples))

        print(
            f"{p:<16} | {mean_v:>7.4f} ± {std_v:<7.4f} | "
            f"{med_v:>7.4f} [{ci68[0]:>7.4f}, {ci68[1]:<7.4f}] | "
            f"[{ci95[0]:>7.4f}, {ci95[1]:<7.4f}]   | "
            f"{r_hat:>5.3f} | {tau_val:>4.1f} | {int(ess_val):>5d}"
        )
    print("-" * 115)

    # 6. Verify Gelman-Rubin Convergence Diagnostic
    print(f"\n[5/5] Gelman-Rubin Convergence Audit:")
    max_r_hat = max(r_hat_dict.values()) if r_hat_dict else 1.0
    mean_r_hat = float(np.mean(list(r_hat_dict.values()))) if r_hat_dict else 1.0

    print(f"      • Max R_hat: {max_r_hat:.4f} (Threshold: < {r_hat_threshold:.2f})")
    print(f"      • Mean R_hat: {mean_r_hat:.4f}")
    
    converged = max_r_hat < r_hat_threshold
    status_str = "CONVERGED [PASS]" if converged else f"NOT CONVERGED [FAIL] (R_hat={max_r_hat:.3f})"
    print(f"      • Convergence Status: {status_str}")
    print("=" * 100 + "\n")

    if assert_convergence and not converged:
        raise AssertionError(f"Gelman-Rubin R_hat = {max_r_hat:.3f} exceeded threshold {r_hat_threshold:.2f}.")

    return chains, summary


def main():
    parser = argparse.ArgumentParser(description="Run production MCMC on Poincaré cosmological joint likelihood.")
    parser.add_argument("--sampler", type=str, default="ensemble", choices=["ensemble", "adaptive"], help="Sampler algorithm (default: ensemble)")
    parser.add_argument("--n-chains", type=int, default=4, help="Number of MCMC chains (default: 4)")
    parser.add_argument("--n-samples", type=int, default=500, help="Number of samples per chain (default: 500)")
    parser.add_argument("--burn-in", type=int, default=150, help="Number of burn-in steps per chain (default: 150)")
    parser.add_argument("--seed", type=int, default=42, help="Random seed (default: 42)")
    parser.add_argument("--no-shoes", action="store_true", help="Disable SH0ES H0 prior")
    parser.add_argument("--output-npz", type=str, default="cosmology/mcmc_production_results.npz", help="Output .npz path")
    parser.add_argument("--output-json", type=str, default="cosmology/mcmc_production_summary.json", help="Output .json path")
    parser.add_argument("--r-hat-threshold", type=float, default=1.15, help="Gelman-Rubin R_hat convergence threshold")

    args = parser.parse_args()

    run_production_mcmc(
        n_chains=args.n_chains,
        n_samples=args.n_samples,
        burn_in=args.burn_in,
        seed=args.seed,
        sampler_type=args.sampler,
        include_shoes=not args.no_shoes,
        output_npz=args.output_npz,
        output_json=args.output_json,
        assert_convergence=False,
        r_hat_threshold=args.r_hat_threshold
    )


if __name__ == '__main__':
    main()
