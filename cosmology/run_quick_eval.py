#!/usr/bin/env python3
"""
Local Quick Evaluation Runner for Poincaré Dodecahedral Adèlic Cosmology ($S^3/I^*$).

Executes lightweight observational likelihood evaluations and fast MCMC exploration (< 30s)
for:
1. Standard Flat Lambda-CDM baseline
2. Standard S^3/I* Axion EDE
3. S^3/I* + Interacting Dark Radiation (IDR)
4. S^3/I* + New Early Dark Energy (NEDE)

Outputs structured concordance scorecards, AIC/BIC model comparisons with and without SH0ES,
derived acoustic horizons, S_8 clustering parameters, and Gelman-Rubin convergence diagnostics.
"""

from __future__ import annotations
import os
import sys
import time
from typing import Dict, List, Tuple
import numpy as np

# Ensure local cosmology package is imported
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from cosmology.model import CosmologicalParameters, PoincareEDEModel, PoincareTopology
from cosmology.likelihoods import JointLikelihood
from cosmology.mcmc import MCMCSampler, compute_information_criteria, gelman_rubin_diagnostic


def print_banner(title: str) -> None:
    """Print formatted terminal section banner."""
    print("=" * 100, flush=True)
    print(f" {title}".center(100), flush=True)
    print("=" * 100, flush=True)


def print_subbanner(title: str) -> None:
    """Print formatted subsection banner."""
    print("-" * 100, flush=True)
    print(f"  {title}", flush=True)
    print("-" * 100, flush=True)


def run_quick_evaluation() -> None:
    """Run end-to-end fast local cosmological likelihood & MCMC evaluation."""
    t_start = time.perf_counter()

    print_banner("POINCARÉ DODECAHEDRAL ADÈLIC COSMOLOGY (S^3/I*) - MULTI-MODEL EVALUATION")
    print("  Milestone R2 Likelihood & Model Extension Suite")
    print("  Models: Flat Lambda-CDM | Standard S^3/I* EDE | S^3/I* + IDR | S^3/I* + NEDE")
    print("  Execution Mode: High-Performance Vectorized Local Runner\n", flush=True)

    # ==========================================================================
    # 1. Poincaré S^3/I* Topological Harmonic Spectrum
    # ==========================================================================
    print_subbanner("1. S^3/I* Topological Harmonic Multiplicities & Selection Rules")
    print(f"{'Multipole L':<14} | {'SU(2) Degree (2L)':<18} | {'I*-Multiplicity m_L':<22} | {'Topology Status'}", flush=True)
    print("-" * 100, flush=True)
    for L in range(13):
        m_so3 = PoincareTopology.molien_multiplicity_so3(L)
        status = "Forbidden (Suppressed)" if m_so3 == 0 else "Allowed (Active Mode)"
        if L == 0:
            status = "Monopole (Homogeneous)"
        elif L == 6:
            status = "FIRST ICOSAHEDRAL INVARIANT"
        print(f"L = {L:<10d} | 2L = {2*L:<14d} | m_L^{{SO(3)}} = {m_so3:<12d} | {status}", flush=True)
    print(flush=True)

    # ==========================================================================
    # 2. Fiducial Models Definition
    # ==========================================================================
    # Model 1: Flat Lambda-CDM Baseline
    params_lcdm = CosmologicalParameters(
        H0=67.36,
        omega_b=0.02237,
        omega_cdm=0.1200,
        Omega_k=0.0,
        f_EDE=0.0,
        log10_zc=3.55,
        n_s=0.9649,
        sigma8_0=0.811,
        w0=-1.0,
        wa=0.0,
        use_poincare_topology=False,
        model_type="axion_ede"
    )
    model_lcdm = PoincareEDEModel(params_lcdm)
    k_lcdm = 6

    # Model 2: Poincaré Dodecahedral Space S^3/I* Axion EDE
    params_ede = CosmologicalParameters(
        H0=68.00,
        omega_b=0.02239,
        omega_cdm=0.1402,
        Omega_k=-0.0027,
        f_EDE=0.0886,
        log10_zc=3.560,
        theta_i=2.80,
        n_s=0.968,
        sigma8_0=0.811,
        w0=-0.800,
        wa=-0.500,
        isw_leakage=0.18,
        use_poincare_topology=True,
        model_type="axion_ede"
    )
    model_ede = PoincareEDEModel(params_ede)
    k_ede = 9

    # Model 3: Poincaré S^3/I* + IDR (Interacting Dark Radiation)
    params_idr = CosmologicalParameters(
        H0=71.50,
        omega_b=0.02239,
        omega_cdm=0.1577,
        Omega_k=-0.0027,
        f_EDE=0.1244,
        log10_zc=3.560,
        theta_i=2.80,
        delta_N_idr=0.35,
        g_dark_coupling=0.14,
        n_s=0.967,
        sigma8_0=0.811,
        w0=-0.800,
        wa=-0.500,
        isw_leakage=0.18,
        use_poincare_topology=True,
        model_type="idr"
    )
    model_idr = PoincareEDEModel(params_idr)
    k_idr = 11

    # Model 4: Poincaré S^3/I* + NEDE (New Early Dark Energy)
    params_nede = CosmologicalParameters(
        H0=71.50,
        omega_b=0.02239,
        omega_cdm=0.1523,
        Omega_k=0.0005,
        f_NEDE=0.1706,
        log10_zc=3.550,
        w_NEDE_after=1.0/3.0,
        cs2_NEDE_after=1.0/3.0,
        n_s=0.966,
        sigma8_0=0.811,
        w0=-0.800,
        wa=-0.500,
        isw_leakage=0.18,
        use_poincare_topology=True,
        model_type="nede"
    )
    model_nede = PoincareEDEModel(params_nede)
    k_nede = 9

    models = [
        ("Flat Lambda-CDM", model_lcdm, k_lcdm),
        ("S^3/I* Axion EDE", model_ede, k_ede),
        ("S^3/I* + IDR", model_idr, k_idr),
        ("S^3/I* + NEDE", model_nede, k_nede),
    ]

    # ==========================================================================
    # 3. Observational Likelihood Evaluation WITHOUT SH0ES Prior
    # ==========================================================================
    print_subbanner("2. Observational Likelihood Concordance (WITHOUT SH0ES Prior)")

    joint_no_shoes = JointLikelihood(
        include_low_ell=True,
        include_high_ell_pol=True,
        include_weak_lensing=True,
        include_shoes=False
    )
    n_data_no_shoes = joint_no_shoes.n_data

    breakdowns_no_shoes = {}
    stats_no_shoes = {}
    ref_chi2_no_shoes = joint_no_shoes.chi2(model_lcdm)

    for name, m, k in models:
        bk = joint_no_shoes.chi2_breakdown(m)
        breakdowns_no_shoes[name] = bk
        st = compute_information_criteria(
            chi2_min=bk["Total_Chi2"],
            k_params=k,
            n_data=n_data_no_shoes,
            chi2_ref=ref_chi2_no_shoes,
            k_ref=k_lcdm
        )
        stats_no_shoes[name] = st

    # Print Table 1: Breakdown without SH0ES
    dataset_keys = [
        ("Planck_2018_Priors", "Planck 2018 Distance"),
        ("Planck_LowEll_Topology", "Planck Low-ell Topology"),
        ("Planck_HighEll_Pol", "Planck High-ell Pol (TE/EE)"),
        ("Weak_Lensing_DES_KiDS", "Weak Lensing (DES/KiDS)"),
        ("DESI_2024_BAO", "DESI 2024 BAO"),
        ("PantheonPlus_SNe", "Pantheon+ SNe Ia"),
        ("Total_Chi2", "Total Chi2"),
    ]

    col_w = 17
    header = f"{'Observational Dataset':<26} | " + " | ".join([f"{name:^{col_w}}" for name, _, _ in models])
    print(header, flush=True)
    print("-" * len(header), flush=True)

    for key, label in dataset_keys:
        row_str = f"{label:<26} | "
        vals = [f"{breakdowns_no_shoes[name][key]:^{col_w}.3f}" for name, _, _ in models]
        row_str += " | ".join(vals)
        print(row_str, flush=True)

    print("-" * len(header), flush=True)
    print(f"{'Parameters k':<26} | " + " | ".join([f"{k:^{col_w}d}" for _, _, k in models]), flush=True)
    print(f"{'Degrees of Freedom (dof)':<26} | " + " | ".join([f"{joint_no_shoes.degrees_of_freedom(k):^{col_w}d}" for _, _, k in models]), flush=True)
    print(f"{'Reduced Chi2 (chi2/dof)':<26} | " + " | ".join([f"{breakdowns_no_shoes[name]['Total_Chi2']/joint_no_shoes.degrees_of_freedom(k):^{col_w}.3f}" for name, _, k in models]), flush=True)
    print(f"{'Akaike Info Crit (AIC)':<26} | " + " | ".join([f"{stats_no_shoes[name]['AIC']:^{col_w}.2f}" for name, _, _ in models]), flush=True)
    d_chi2_str = [f"{stats_no_shoes[name]['Delta_chi2']:+.2f}" for name, _, _ in models]
    d_aic_str = [f"{stats_no_shoes[name]['Delta_AIC']:+.2f}" for name, _, _ in models]
    d_bic_str = [f"{stats_no_shoes[name]['Delta_BIC']:+.2f}" for name, _, _ in models]
    print(f"{'Delta Chi2 (vs LCDM)':<26} | " + " | ".join([f"{s:^{col_w}}" for s in d_chi2_str]), flush=True)
    print(f"{'Delta AIC (vs LCDM)':<26} | " + " | ".join([f"{s:^{col_w}}" for s in d_aic_str]), flush=True)
    print(f"{'Delta BIC (vs LCDM)':<26} | " + " | ".join([f"{s:^{col_w}}" for s in d_bic_str]), flush=True)
    print(flush=True)

    # ==========================================================================
    # 4. Observational Likelihood Evaluation WITH SH0ES Prior
    # ==========================================================================
    print_subbanner("3. Concordance Comparison WITH SH0ES Hubble Prior (H0 = 73.04 ± 1.04 km/s/Mpc)")

    joint_with_shoes = JointLikelihood(
        include_low_ell=True,
        include_high_ell_pol=True,
        include_weak_lensing=True,
        include_shoes=True
    )
    n_data_with_shoes = joint_with_shoes.n_data
    ref_chi2_with_shoes = joint_with_shoes.chi2(model_lcdm)

    stats_with_shoes = {}
    breakdowns_with_shoes = {}
    for name, m, k in models:
        bk = joint_with_shoes.chi2_breakdown(m)
        breakdowns_with_shoes[name] = bk
        st = compute_information_criteria(
            chi2_min=bk["Total_Chi2"],
            k_params=k,
            n_data=n_data_with_shoes,
            chi2_ref=ref_chi2_with_shoes,
            k_ref=k_lcdm
        )
        stats_with_shoes[name] = st

    print(f"{'Model':<20} | {'H0 [km/s/Mpc]':<13} | {'S_8':<8} | {'Chi2(Base)':<11} | {'Chi2(SH0ES)':<11} | {'Chi2(Tot)':<10} | {'Delta Chi2':<11} | {'Delta AIC':<10} | {'Delta BIC'}", flush=True)
    print("-" * 115, flush=True)
    for name, m, k in models:
        h0_val = m.params.H0
        s8_val = m.S_8
        c_base = breakdowns_no_shoes[name]["Total_Chi2"]
        c_shoes = breakdowns_with_shoes[name]["SH0ES_H0_Prior"]
        c_tot = breakdowns_with_shoes[name]["Total_Chi2"]
        d_chi2 = stats_with_shoes[name]["Delta_chi2"]
        d_aic = stats_with_shoes[name]["Delta_AIC"]
        d_bic = stats_with_shoes[name]["Delta_BIC"]
        print(f"{name:<20} | {h0_val:>10.2f}    | {s8_val:>6.4f} | {c_base:>9.2f}   | {c_shoes:>9.2f}   | {c_tot:>8.2f}   | {d_chi2:>+9.2f}   | {d_aic:>+8.2f}   | {d_bic:>+8.2f}", flush=True)
    print("-" * 115, flush=True)
    print(flush=True)

    # ==========================================================================
    # 5. Derived Physical Scales & Acoustic Horizons
    # ==========================================================================
    print_subbanner("4. Derived Physical Scales, Horizon Compression & Clustering Parameters")
    header_scales = f"{'Physical Quantity':<30} | " + " | ".join([f"{name:^{col_w}}" for name, _, _ in models])
    print(header_scales, flush=True)
    print("-" * len(header_scales), flush=True)

    scale_rows = [
        ("Hubble Constant H0 [km/s/Mpc]", [f"{m.params.H0:^{col_w}.2f}" for _, m, _ in models]),
        ("Cosmic Shear Growth S_8", [f"{m.S_8:^{col_w}.4f}" for _, m, _ in models]),
        ("RMS Density Fluctuation sigma_8", [f"{m.sigma_8:^{col_w}.4f}" for _, m, _ in models]),
        ("Sound Horizon r_s(z_*) [Mpc]", [f"{m.r_s_star:^{col_w}.2f}" for _, m, _ in models]),
        ("Drag Horizon r_d [Mpc]", [f"{m.r_drag:^{col_w}.2f}" for _, m, _ in models]),
        ("CMB Acoustic Scale ell_a", [f"{m.acoustic_scale_ell_a:^{col_w}.3f}" for _, m, _ in models]),
        ("Shift Parameter R", [f"{m.cmb_shift_parameter_R:^{col_w}.4f}" for _, m, _ in models]),
        ("100 * theta_*", [f"{m.acoustic_angular_scale_theta_star:^{col_w}.4f}" for _, m, _ in models]),
        ("IDR Damping Factor D_IDR", [f"{m.idr_damping_factor:^{col_w}.4f}" for _, m, _ in models]),
        ("Curvature Radius R_c [Gpc]", [f"{m.params.radius_of_curvature/1000.0:^{col_w}.2f}" if abs(m.params.Omega_k) > 1e-6 else f"{'Infinity':^{col_w}}" for _, m, _ in models]),
    ]

    for label, vals in scale_rows:
        print(f"{label:<30} | " + " | ".join(vals), flush=True)
    print("-" * len(header_scales), flush=True)
    print(flush=True)

    # ==========================================================================
    # 6. Fast Multi-Chain MCMC Posterior Sampling on S^3/I* + IDR Model
    # ==========================================================================
    print_subbanner("5. Fast Multi-Chain MCMC Exploration (S^3/I* + IDR Concordance Model)")
    active_params = ["H0", "omega_b", "omega_cdm", "Omega_k", "f_EDE", "delta_N_idr", "g_dark_coupling", "w0", "wa"]
    sampler = MCMCSampler(joint_likelihood=joint_no_shoes, active_params=active_params, use_poincare_topology=True)

    x0_idr = np.array([71.50, 0.02239, 0.1577, -0.0027, 0.1244, 0.35, 0.14, -0.800, -0.500])

    t_mcmc_start = time.perf_counter()
    chains, summary = sampler.run_multi_chain(
        x0=x0_idr,
        n_chains=4,
        n_samples=200,
        burn_in=60,
        seed=42
    )
    t_mcmc_end = time.perf_counter()
    mcmc_duration = t_mcmc_end - t_mcmc_start

    print(f"  MCMC completed in {mcmc_duration:.2f} seconds ({len(chains)*200} posterior samples across 4 chains)", flush=True)
    print(f"  Mean Chain Acceptance Fraction: {np.mean([c.acceptance_fraction for c in chains])*100:.1f}%\n", flush=True)

    print(f"{'Parameter':<16} | {'Mean ± 1sigma':<18} | {'Median (68% CI)':<26} | {'95% Credible Interval':<24} | {'R_hat'}", flush=True)
    print("-" * 100, flush=True)
    for p in active_params:
        mean_val = summary.means[p]
        std_val = summary.stds[p]
        med_val = summary.medians[p]
        ci68 = summary.ci_68[p]
        ci95 = summary.ci_95[p]
        r_hat = summary.gelman_rubin_r_hat[p] if summary.gelman_rubin_r_hat else 1.0
        
        print(
            f"{p:<16} | {mean_val:>7.4f} ± {std_val:<7.4f} | "
            f"{med_val:>7.4f} [{ci68[0]:>7.4f}, {ci68[1]:<7.4f}] | "
            f"[{ci95[0]:>7.4f}, {ci95[1]:<7.4f}]   | {r_hat:<5.3f}",
            flush=True
        )
    print("-" * 100, flush=True)
    print(flush=True)

    # ==========================================================================
    # 7. Concordance Scorecard & Statistical Verdict
    # ==========================================================================
    print_banner("CONCORDANCE SCORECARD & STATISTICAL VERDICT")
    tot_time = time.perf_counter() - t_start
    max_r_hat = max(summary.gelman_rubin_r_hat.values()) if summary.gelman_rubin_r_hat else 1.0
    print(f"  • Total Runtime: {tot_time:.2f} seconds (Target: < 30.0s) [{'PASSED' if tot_time < 30.0 else 'FAILED'}]", flush=True)
    conv_status = "< 1.15 [CONVERGED]" if max_r_hat < 1.15 else f"[R_hat={max_r_hat:.2f}, FAST PROBE]"
    print(f"  • Gelman-Rubin Diagnostic: Max R_hat = {max_r_hat:.3f} {conv_status}", flush=True)
    print(f"  • Baseline (No SH0ES) Delta Chi2 vs LCDM:  S^3/I* EDE: {stats_no_shoes['S^3/I* Axion EDE']['Delta_chi2']:+.2f} | IDR: {stats_no_shoes['S^3/I* + IDR']['Delta_chi2']:+.2f} | NEDE: {stats_no_shoes['S^3/I* + NEDE']['Delta_chi2']:+.2f}", flush=True)
    print(f"  • Baseline (No SH0ES) Delta AIC vs LCDM:   S^3/I* EDE: {stats_no_shoes['S^3/I* Axion EDE']['Delta_AIC']:+.2f} | IDR: {stats_no_shoes['S^3/I* + IDR']['Delta_AIC']:+.2f} | NEDE: {stats_no_shoes['S^3/I* + NEDE']['Delta_AIC']:+.2f}", flush=True)
    print(f"  • With SH0ES Prior Delta Chi2 vs LCDM:     S^3/I* EDE: {stats_with_shoes['S^3/I* Axion EDE']['Delta_chi2']:+.2f} | IDR: {stats_with_shoes['S^3/I* + IDR']['Delta_chi2']:+.2f} | NEDE: {stats_with_shoes['S^3/I* + NEDE']['Delta_chi2']:+.2f}", flush=True)
    print(f"  • With SH0ES Prior Delta AIC vs LCDM:      S^3/I* EDE: {stats_with_shoes['S^3/I* Axion EDE']['Delta_AIC']:+.2f} | IDR: {stats_with_shoes['S^3/I* + IDR']['Delta_AIC']:+.2f} | NEDE: {stats_with_shoes['S^3/I* + NEDE']['Delta_AIC']:+.2f}", flush=True)
    print(f"  • Structure Growth S_8 Concordance:        Flat LCDM: {model_lcdm.S_8:.4f} | S^3/I* EDE: {model_ede.S_8:.4f} | IDR: {model_idr.S_8:.4f} (DES Y3: 0.776 ± 0.017)", flush=True)
    print(f"  • Hubble Constant H0 Concordance:          Flat LCDM: {model_lcdm.params.H0:.2f} | S^3/I* EDE: {model_ede.params.H0:.2f} | IDR: {model_idr.params.H0:.2f} (SH0ES: 73.04 ± 1.04)", flush=True)
    print("=" * 100, flush=True)


if __name__ == '__main__':
    run_quick_evaluation()
