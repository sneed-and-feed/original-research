#!/usr/bin/env python3
"""
Verification Suite for Table 1 & Table 2 in paper2_cosmology.md.

Evaluates the exact cosmological models:
1. Model 1: Flat Lambda-CDM (Planck 2018 baseline, k=6)
2. Model 2: S^3 / I^* EDE Canonical (k=9)
3. Model 3: S^3 / I^* + IDR / NEDE Concordance (k=11)

Computes and verifies:
- Individual likelihood subtotals: Planck distance priors, Low-ell TT, High-ell polarization,
  DESI BAO, Pantheon+ SNe Ia, Weak Lensing (DES Y3 + KiDS-1000), SH0ES.
- Total Chi2 without SH0ES and with SH0ES.
- AIC, BIC, Delta Chi2, Delta AIC, Delta BIC for both compressed (N=96/95) and uncompressed (N=4201/4200) setups.
- S_8 and sigma_8 from the dynamical ODE growth and transfer function quadrature.
- Formatted console output and JSON export to `cosmology/table_verification_results.json`.
"""

from __future__ import annotations
import json
import math
import os
import sys
import time
from typing import Any, Dict, List, Tuple

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from cosmology.model import CosmologicalParameters, PoincareEDEModel, PoincareTopology
from cosmology.likelihoods import (
    PlanckLikelihood,
    PlanckLowEllLikelihood,
    PlanckHighEllPolarizationLikelihood,
    WeakLensingLikelihood,
    SH0ESLikelihood,
    DESI2024Likelihood,
    PantheonPlusLikelihood,
    JointLikelihood
)
from cosmology.mcmc import compute_information_criteria


def build_models() -> Dict[str, Tuple[PoincareEDEModel, int, Dict[str, Any]]]:
    """
    Construct the three canonical models matching Table 1 & Table 2 in paper2_cosmology.md.
    """
    # --------------------------------------------------------------------------
    # Model 1: Flat Lambda-CDM (Planck 2018 baseline, k=6)
    # --------------------------------------------------------------------------
    params_lcdm = CosmologicalParameters(
        H0=67.36,
        omega_b=0.02237,
        omega_cdm=0.1200,
        Omega_k=0.0,
        f_EDE=0.0,
        log10_zc=3.55,
        n_s=0.9649,
        A_s=math.exp(3.044) * 1e-10,  # ln(10^10 A_s) = 3.044 -> ~2.0989e-9
        w0=-1.0,
        wa=0.0,
        use_poincare_topology=False,
        model_type="axion_ede"
    )
    model_lcdm = PoincareEDEModel(params_lcdm)
    meta_lcdm = {
        "name": "Flat Lambda-CDM (Planck 2018)",
        "short_name": "Flat LCDM",
        "k_params": 6,
        "description": "Standard 6-parameter flat LCDM baseline from Planck 2018"
    }

    # --------------------------------------------------------------------------
    # Model 2: S^3 / I^* EDE Canonical (k=9)
    # --------------------------------------------------------------------------
    params_ede = CosmologicalParameters(
        H0=70.93,
        omega_b=0.02247,
        omega_cdm=0.1565,
        Omega_k=-0.0044,
        f_EDE=0.110,
        log10_zc=3.560,
        theta_i=2.80,
        n_s=0.9880,
        A_s=math.exp(3.062) * 1e-10,  # ln(10^10 A_s) = 3.062 -> ~2.1370e-9
        w0=-0.586,
        wa=-1.327,
        isw_leakage=0.18,
        use_poincare_topology=True,
        model_type="axion_ede"
    )
    model_ede = PoincareEDEModel(params_ede)
    meta_ede = {
        "name": "S^3 / I^* EDE (Canonical)",
        "short_name": "S^3/I* EDE",
        "k_params": 9,
        "description": "Poincaré dodecahedral space S^3/I* with Axion Early Dark Energy"
    }

    # --------------------------------------------------------------------------
    # Model 3: S^3 / I^* + IDR / NEDE Concordance (k=11)
    # --------------------------------------------------------------------------
    params_idr = CosmologicalParameters(
        H0=70.93,
        omega_b=0.02247,
        omega_cdm=0.1565,
        Omega_k=-0.0044,
        f_EDE=0.110,
        log10_zc=3.560,
        theta_i=2.80,
        delta_N_idr=0.51,
        g_dark_coupling=0.151,       # Converged dark sector coupling
        n_s=0.9880,
        A_s=math.exp(3.062) * 1e-10,  # ln(10^10 A_s) = 3.062 -> ~2.1370e-9
        w0=-0.586,
        wa=-1.327,
        isw_leakage=0.18,
        use_poincare_topology=True,
        model_type="idr"
    )
    model_idr = PoincareEDEModel(params_idr)
    meta_idr = {
        "name": "S^3 / I^* + IDR / NEDE (Concordance)",
        "short_name": "S^3/I* + IDR",
        "k_params": 11,
        "description": "Poincaré space with Interacting Dark Radiation and EDE resolving H0 and S8 tensions"
    }

    return {
        "model1_lcdm": (model_lcdm, 6, meta_lcdm),
        "model2_ede": (model_ede, 9, meta_ede),
        "model3_idr": (model_idr, 11, meta_idr),
    }


def evaluate_table_verification() -> Dict[str, Any]:
    """
    Execute full numerical verification of Table 1 & Table 2 metrics across all models.
    Returns structured results dictionary.
    """
    models_dict = build_models()
    
    # Initialize JointLikelihood setups
    joint_no_shoes = JointLikelihood(
        include_low_ell=True,
        include_high_ell_pol=True,
        include_weak_lensing=True,
        include_shoes=False
    )
    joint_with_shoes = JointLikelihood(
        include_low_ell=True,
        include_high_ell_pol=True,
        include_weak_lensing=True,
        include_shoes=True
    )

    # Effective uncompressed dataset size from paper Table 2
    N_UNCOMPRESSED_NO_SHOES = 4200
    N_UNCOMPRESSED_WITH_SHOES = 4201

    N_COMPRESSED_NO_SHOES = joint_no_shoes.n_data   # 95
    N_COMPRESSED_WITH_SHOES = joint_with_shoes.n_data # 96

    results: Dict[str, Any] = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "dataset_counts": {
            "compressed_no_shoes": N_COMPRESSED_NO_SHOES,
            "compressed_with_shoes": N_COMPRESSED_WITH_SHOES,
            "uncompressed_no_shoes": N_UNCOMPRESSED_NO_SHOES,
            "uncompressed_with_shoes": N_UNCOMPRESSED_WITH_SHOES,
        },
        "models": {},
        "comparison_table": {}
    }

    # Reference values (Model 1 Flat LCDM)
    m1_model, m1_k, _ = models_dict["model1_lcdm"]
    chi2_ref_no_shoes = joint_no_shoes.chi2(m1_model)
    chi2_ref_with_shoes = joint_with_shoes.chi2(m1_model)

    for m_key, (m_obj, k_val, meta) in models_dict.items():
        bk_no_shoes = joint_no_shoes.chi2_breakdown(m_obj)
        bk_with_shoes = joint_with_shoes.chi2_breakdown(m_obj)
        
        # Compressed criteria
        ic_comp_no_shoes = compute_information_criteria(
            chi2_min=bk_no_shoes["Total_Chi2"],
            k_params=k_val,
            n_data=N_COMPRESSED_NO_SHOES,
            chi2_ref=chi2_ref_no_shoes,
            k_ref=m1_k
        )
        ic_comp_with_shoes = compute_information_criteria(
            chi2_min=bk_with_shoes["Total_Chi2"],
            k_params=k_val,
            n_data=N_COMPRESSED_WITH_SHOES,
            chi2_ref=chi2_ref_with_shoes,
            k_ref=m1_k
        )

        # Uncompressed criteria (using N=4200 / 4201)
        ic_uncomp_no_shoes = compute_information_criteria(
            chi2_min=bk_no_shoes["Total_Chi2"],
            k_params=k_val,
            n_data=N_UNCOMPRESSED_NO_SHOES,
            chi2_ref=chi2_ref_no_shoes,
            k_ref=m1_k
        )
        ic_uncomp_with_shoes = compute_information_criteria(
            chi2_min=bk_with_shoes["Total_Chi2"],
            k_params=k_val,
            n_data=N_UNCOMPRESSED_WITH_SHOES,
            chi2_ref=chi2_ref_with_shoes,
            k_ref=m1_k
        )

        # Derived observables
        p = m_obj.params
        d_ell = m_obj.cmb_low_ell_power(ell_max=6)

        results["models"][m_key] = {
            "metadata": meta,
            "parameters": {
                "H0": p.H0,
                "omega_b": p.omega_b,
                "omega_cdm": p.omega_cdm,
                "Omega_m": p.Omega_m,
                "Omega_k": p.Omega_k,
                "f_EDE": p.f_EDE,
                "log10_zc": p.log10_zc,
                "theta_i": p.theta_i,
                "delta_N_idr": p.delta_N_idr,
                "g_dark_coupling": p.g_dark_coupling,
                "n_s": p.n_s,
                "A_s": p.A_s,
                "w0": p.w0,
                "wa": p.wa,
                "use_poincare_topology": p.use_poincare_topology,
            },
            "derived_observables": {
                "S_8": m_obj.S_8,
                "sigma_8": m_obj.sigma_8,
                "r_s_star_Mpc": m_obj.r_s_star,
                "r_drag_Mpc": m_obj.r_drag,
                "ell_a": m_obj.acoustic_scale_ell_a,
                "R_shift": m_obj.cmb_shift_parameter_R,
                "100_theta_star": m_obj.acoustic_angular_scale_theta_star,
                "radius_of_curvature_Gpc": p.radius_of_curvature / 1000.0 if abs(p.Omega_k) > 1e-6 else float('inf'),
                "idr_damping_factor": m_obj.idr_damping_factor,
                "D_ell_TT": {int(k): float(v) for k, v in d_ell.items()}
            },
            "likelihood_no_shoes": {
                "breakdown": bk_no_shoes,
                "information_criteria_compressed": ic_comp_no_shoes,
                "information_criteria_uncompressed": ic_uncomp_no_shoes,
            },
            "likelihood_with_shoes": {
                "breakdown": bk_with_shoes,
                "information_criteria_compressed": ic_comp_with_shoes,
                "information_criteria_uncompressed": ic_uncomp_with_shoes,
            }
        }

    return results


def print_table_verification(results: Dict[str, Any]) -> None:
    """Print formatted ASCII tables corresponding to Table 1 and Table 2 in paper2_cosmology.md."""
    models_dict = results["models"]
    m_keys = ["model1_lcdm", "model2_ede", "model3_idr"]

    print("=" * 116)
    print("        POINCARÉ DODECAHEDRAL COSMOLOGY: TABLE 1 & TABLE 2 VERIFICATION REPORT        ".center(116))
    print("=" * 116)

    # --------------------------------------------------------------------------
    # Table 1: Parameters & Derived Observables
    # --------------------------------------------------------------------------
    print("\n" + "-" * 116)
    print("  TABLE 1: Best-Fit & Derived Cosmological Parameters")
    print("-" * 116)
    col_w = 26
    header = f"{'Quantity / Parameter':<32} | " + " | ".join([f"{models_dict[k]['metadata']['short_name']:^{col_w}}" for k in m_keys])
    print(header)
    print("-" * len(header))

    table1_rows = [
        ("Hubble Constant H0 [km/s/Mpc]", lambda m: f"{m['parameters']['H0']:.2f}"),
        ("Baryon Density omega_b", lambda m: f"{m['parameters']['omega_b']:.5f}"),
        ("CDM Density omega_cdm", lambda m: f"{m['parameters']['omega_cdm']:.4f}"),
        ("Matter Density Omega_m", lambda m: f"{m['parameters']['Omega_m']:.4f}"),
        ("Spatial Curvature Omega_k", lambda m: f"{m['parameters']['Omega_k']:+.4f}" if m['parameters']['Omega_k'] != 0 else "0.0000 (flat)"),
        ("EDE Fraction f_EDE(z_c)", lambda m: f"{m['parameters']['f_EDE']:.3f}" if m['parameters']['f_EDE'] > 0 else "—"),
        ("Critical Redshift log10(z_c)", lambda m: f"{m['parameters']['log10_zc']:.2f}" if m['parameters']['f_EDE'] > 0 else "—"),
        ("Initial Angle theta_i [rad]", lambda m: f"{m['parameters']['theta_i']:.2f}" if m['parameters']['f_EDE'] > 0 else "—"),
        ("IDR DoF Delta N_idr", lambda m: f"{m['parameters']['delta_N_idr']:.2f}" if m['parameters']['delta_N_idr'] > 0 else "—"),
        ("Dark Coupling g_dark", lambda m: f"{m['parameters']['g_dark_coupling']:.3f}" if m['parameters']['g_dark_coupling'] > 0 else "—"),
        ("Scalar Tilt n_s", lambda m: f"{m['parameters']['n_s']:.4f}"),
        ("Curvature Radius R_c [Gpc]", lambda m: f"{m['derived_observables']['radius_of_curvature_Gpc']:.1f} Gpc" if math.isfinite(m['derived_observables']['radius_of_curvature_Gpc']) else "Infinity"),
        ("Sound Horizon r_s(z_*) [Mpc]", lambda m: f"{m['derived_observables']['r_s_star_Mpc']:.2f} Mpc"),
        ("Drag Sound Horizon r_d [Mpc]", lambda m: f"{m['derived_observables']['r_drag_Mpc']:.2f} Mpc"),
        ("Structure Growth Index S_8", lambda m: f"{m['derived_observables']['S_8']:.4f}"),
        ("Fluctuation Amplitude sigma_8", lambda m: f"{m['derived_observables']['sigma_8']:.4f}"),
        ("CMB Quadrupole D_2 [muK^2]", lambda m: f"{m['derived_observables']['D_ell_TT'].get(2, m['derived_observables']['D_ell_TT'].get('2', 0.0)):.1f} muK^2"),
        ("CMB Octopole D_3 [muK^2]", lambda m: f"{m['derived_observables']['D_ell_TT'].get(3, m['derived_observables']['D_ell_TT'].get('3', 0.0)):.1f} muK^2"),
        ("CMB Hexadecapole D_4 [muK^2]", lambda m: f"{m['derived_observables']['D_ell_TT'].get(4, m['derived_observables']['D_ell_TT'].get('4', 0.0)):.1f} muK^2"),
        ("CMB Mode D_6 [muK^2]", lambda m: f"{m['derived_observables']['D_ell_TT'].get(6, m['derived_observables']['D_ell_TT'].get('6', 0.0)):.1f} muK^2"),
    ]

    for label, fn in table1_rows:
        vals = [f"{fn(models_dict[k]):^{col_w}}" for k in m_keys]
        print(f"{label:<32} | " + " | ".join(vals))
    print("-" * len(header))

    # --------------------------------------------------------------------------
    # Table 2: Likelihood Breakdown & Information Criteria
    # --------------------------------------------------------------------------
    print("\n" + "-" * 116)
    print("  TABLE 2: Observational Likelihood Breakdown & Statistical Information Criteria")
    print("-" * 116)
    print(header)
    print("-" * len(header))

    lik_rows = [
        ("Planck 2018 Distance Priors", lambda m: f"{m['likelihood_no_shoes']['breakdown']['Planck_2018_Priors']:.2f}"),
        ("Planck Low-ell TT (Topology)", lambda m: f"{m['likelihood_no_shoes']['breakdown']['Planck_LowEll_Topology']:.2f}"),
        ("Planck High-ell Pol (TE/EE)", lambda m: f"{m['likelihood_no_shoes']['breakdown']['Planck_HighEll_Pol']:.2f}"),
        ("DESI 2024 BAO (DR1)", lambda m: f"{m['likelihood_no_shoes']['breakdown']['DESI_2024_BAO']:.2f}"),
        ("Pantheon+ SNe Ia", lambda m: f"{m['likelihood_no_shoes']['breakdown']['PantheonPlus_SNe']:.2f}"),
        ("Weak Lensing (DES Y3 + KiDS)", lambda m: f"{m['likelihood_no_shoes']['breakdown']['Weak_Lensing_DES_KiDS']:.2f}"),
        ("Total Chi2 (Without SH0ES)", lambda m: f"{m['likelihood_no_shoes']['breakdown']['Total_Chi2']:.2f}"),
        ("SH0ES 2022 H0 Prior", lambda m: f"{m['likelihood_with_shoes']['breakdown']['SH0ES_H0_Prior']:.2f}"),
        ("Total Chi2 (With SH0ES)", lambda m: f"{m['likelihood_with_shoes']['breakdown']['Total_Chi2']:.2f}"),
        ("Parameters k", lambda m: f"{m['metadata']['k_params']:d}"),
        ("--- COMPRESSED (N=96/95) ---", lambda m: "--------------------------"),
        ("Delta Chi2 (No SH0ES)", lambda m: f"{m['likelihood_no_shoes']['information_criteria_compressed']['Delta_chi2']:+.2f}"),
        ("Delta AIC (No SH0ES)", lambda m: f"{m['likelihood_no_shoes']['information_criteria_compressed']['Delta_AIC']:+.2f}"),
        ("Delta BIC (No SH0ES)", lambda m: f"{m['likelihood_no_shoes']['information_criteria_compressed']['Delta_BIC']:+.2f}"),
        ("Delta Chi2 (With SH0ES)", lambda m: f"{m['likelihood_with_shoes']['information_criteria_compressed']['Delta_chi2']:+.2f}"),
        ("Delta AIC (With SH0ES)", lambda m: f"{m['likelihood_with_shoes']['information_criteria_compressed']['Delta_AIC']:+.2f}"),
        ("Delta BIC (With SH0ES)", lambda m: f"{m['likelihood_with_shoes']['information_criteria_compressed']['Delta_BIC']:+.2f}"),
        ("--- UNCOMPRESSED (N=4201) ---", lambda m: "--------------------------"),
        ("Delta BIC (Uncompressed, No SH0ES)", lambda m: f"{m['likelihood_no_shoes']['information_criteria_uncompressed']['Delta_BIC']:+.2f}"),
        ("Delta BIC (Uncompressed, With SH0ES)", lambda m: f"{m['likelihood_with_shoes']['information_criteria_uncompressed']['Delta_BIC']:+.2f}"),
    ]

    for label, fn in lik_rows:
        vals = [f"{fn(models_dict[k]):^{col_w}}" for k in m_keys]
        print(f"{label:<32} | " + " | ".join(vals))
    print("-" * len(header))
    print("=" * 116 + "\n")


def save_verification_results(results: Dict[str, Any], output_path: str = "cosmology/table_verification_results.json") -> None:
    """Save verification results dictionary to JSON file on disk."""
    dir_name = os.path.dirname(output_path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    print(f"[OK] Verification results saved to {output_path}")


def verify_tables_main() -> Dict[str, Any]:
    """Main verification routine."""
    t0 = time.perf_counter()
    results = evaluate_table_verification()
    print_table_verification(results)
    save_verification_results(results)
    elapsed = time.perf_counter() - t0
    print(f"Table verification completed in {elapsed:.3f} seconds.\n")
    return results


if __name__ == '__main__':
    verify_tables_main()
