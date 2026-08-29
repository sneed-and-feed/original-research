r"""
Comprehensive Unit & Integration Test Suite for
Poincaré Dodecahedral Adèlic Cosmology ($S^3/I^*$).

Tests:
1. Poincaré S^3/I* topological harmonic spectra and Molien series.
2. Background cosmology, sound horizons, and spherical curvature geometry.
3. Linear density perturbation ODE growth solver ($D(z), f(z)$) and matter domination boundary conditions.
4. Dynamical Integrated Sachs-Wolfe (ISW) line-of-sight numerical integration.
5. Eisenstein-Hu transfer functions, ETHOS/IDR damping, and windowed $\sigma_8$ numerical quadrature.
6. Observational likelihood modules (Planck priors, low-ell topology, high-ell polarization, DESI BAO, Pantheon+ SNe, Weak Lensing, SH0ES).
7. MCMC sampling, real posterior Gelman-Rubin convergence, autocorrelation time, ESS, and chain serialization.
8. Table 1 & Table 2 verification reproducibility.
"""

from __future__ import annotations
import json
import math
import os
import shutil
import sys
import tempfile
import time
import unittest
import numpy as np

# Add project root to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from cosmology.model import (
    SPEED_OF_LIGHT,
    T_CMB_FIDUCIAL,
    N_EFF_STANDARD,
    PoincareTopology,
    CosmologicalParameters,
    PoincareEDEModel
)
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
from cosmology.verify_tables import evaluate_table_verification, build_models


class TestPoincareTopology(unittest.TestCase):
    """Test Poincaré Dodecahedral Space S^3/I* group theory and Molien multiplicities."""

    def test_su2_characters(self):
        """Test character evaluations chi_ell at identity, central inversion, and general elements."""
        self.assertAlmostEqual(PoincareTopology.su2_character(0, 1.0), 1.0)
        self.assertAlmostEqual(PoincareTopology.su2_character(1, 1.0), 2.0)
        self.assertAlmostEqual(PoincareTopology.su2_character(1, -1.0), -2.0)
        self.assertAlmostEqual(PoincareTopology.su2_character(2, 1.0), 3.0)
        self.assertAlmostEqual(PoincareTopology.su2_character(2, 0.0), -1.0)

    def test_molien_multiplicities_so3(self):
        """Test exact SO(3) invariant multiplicities m_L^{SO(3)} matching Lean 4 theorems."""
        expected_so3 = {
            0: 1,   # Monopole
            1: 0,   # Dipole
            2: 0,   # Quadrupole (Suppressed!)
            3: 0,   # Octopole (Suppressed!)
            4: 0,   # Hexadecapole (Suppressed!)
            5: 0,   # ell=5 (Suppressed!)
            6: 1,   # FIRST ICOSAHEDRAL INVARIANT (Klein)
            7: 0,
            8: 0,
            9: 0,
            10: 1,
            11: 0,
            12: 1
        }
        for L, expected_m in expected_so3.items():
            m_calc = PoincareTopology.molien_multiplicity_so3(L)
            self.assertEqual(m_calc, expected_m, f"Mismatch at multipole L={L}: got {m_calc}, expected {expected_m}")

    def test_multipole_suppression(self):
        """Test CMB multipole suppression factor S_ell."""
        self.assertEqual(PoincareTopology.multipole_suppression_factor(0), 1.0)
        self.assertEqual(PoincareTopology.multipole_suppression_factor(1), 1.0)
        self.assertAlmostEqual(PoincareTopology.multipole_suppression_factor(2, isw_leakage=0.18), 0.18)
        self.assertAlmostEqual(PoincareTopology.multipole_suppression_factor(3, isw_leakage=0.18), 0.18)
        self.assertAlmostEqual(PoincareTopology.multipole_suppression_factor(6), 1.0)


class TestPoincareEDEModel(unittest.TestCase):
    """Test background cosmology, distances, and sound horizon calculations."""

    def setUp(self):
        self.params_flat = CosmologicalParameters(
            H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0, w0=-1.0, wa=0.0, use_poincare_topology=False
        )
        self.model_flat = PoincareEDEModel(self.params_flat)

        self.params_poincare = CosmologicalParameters(
            H0=68.00, omega_b=0.02239, omega_cdm=0.1402, Omega_k=-0.0027, f_EDE=0.0886, log10_zc=3.560, w0=-0.80, wa=-0.50, isw_leakage=0.18, use_poincare_topology=True
        )
        self.model_poincare = PoincareEDEModel(self.params_poincare)

    def test_background_expansion(self):
        """Test H(z) and E(z) at z=0 and high redshift."""
        self.assertAlmostEqual(self.model_flat.E(0.0), 1.0, places=4)
        self.assertAlmostEqual(self.model_flat.H(0.0), 67.36, places=4)

        # High redshift radiation domination
        E_1000 = self.model_flat.E(1000.0)
        self.assertGreater(E_1000, 10000.0)

    def test_sound_horizon_and_acoustic_scale(self):
        """Test recombination redshift, sound horizon, and CMB acoustic scale."""
        self.assertAlmostEqual(self.model_flat.z_star, 1089.92, delta=1.0)
        self.assertAlmostEqual(self.model_flat.r_s_star, 144.45, delta=0.5)
        self.assertAlmostEqual(self.model_flat.acoustic_scale_ell_a, 301.47, delta=0.5)
        self.assertAlmostEqual(self.model_flat.cmb_shift_parameter_R, 1.7496, delta=0.02)

    def test_ede_sound_horizon_reduction(self):
        """Test that EDE reduces the sound horizon by ~5-7%."""
        rs_flat = self.model_flat.r_s_star
        rs_poincare = self.model_poincare.r_s_star
        self.assertLess(rs_poincare, rs_flat)
        reduction_pct = (rs_flat - rs_poincare) / rs_flat * 100.0
        self.assertGreater(reduction_pct, 4.0)
        self.assertLess(reduction_pct, 10.0)

    def test_distances_in_spherical_curvature(self):
        """Test transverse comoving distance D_M in spherical space (Omega_k < 0)."""
        z_test = 1.0
        chi = self.model_poincare.comoving_distance(z_test)
        DM = self.model_poincare.transverse_comoving_distance(z_test)
        self.assertLess(DM, chi)
        self.assertGreater(DM, 0.0)

        DA = self.model_poincare.angular_diameter_distance(z_test)
        DL = self.model_poincare.luminosity_distance(z_test)
        self.assertAlmostEqual(DL, (1.0 + z_test)**2 * DA, places=4)

    def test_nede_dynamics_and_eos(self):
        """Test NEDE equation of state, sound speed, and energy density scaling."""
        params_nede = CosmologicalParameters(
            H0=71.50, omega_b=0.02239, omega_cdm=0.1523, Omega_k=0.0005,
            f_NEDE=0.1706, log10_zc=3.550, w_NEDE_after=1.0/3.0, cs2_NEDE_after=1.0/3.0,
            model_type="nede"
        )
        model_nede = PoincareEDEModel(params_nede)
        zc = model_nede.params.z_c

        self.assertAlmostEqual(model_nede.ede_equation_of_state(100.0), 1.0/3.0, places=4)
        self.assertAlmostEqual(model_nede.ede_equation_of_state(zc), 1.0/3.0, places=4)
        self.assertAlmostEqual(model_nede.ede_sound_speed_sq(100.0), 1.0/3.0, places=4)
        self.assertAlmostEqual(model_nede.ede_sound_speed_sq(zc), 1.0/3.0, places=4)

        self.assertAlmostEqual(model_nede.ede_equation_of_state(10000.0), -1.0, places=4)
        self.assertAlmostEqual(model_nede.ede_sound_speed_sq(10000.0), 1.0, places=4)

        rho_zc = model_nede.rho_ede_ratio(zc)
        rho_high = model_nede.rho_ede_ratio(2.0 * zc)
        self.assertAlmostEqual(rho_high, rho_zc, places=4)

        z_low = 100.0
        rho_low = model_nede.rho_ede_ratio(z_low)
        expected_low = rho_zc * ((1.0 + z_low)/(1.0 + zc))**4
        self.assertAlmostEqual(rho_low, expected_low, places=4)
        self.assertLess(model_nede.r_s_star, self.model_flat.r_s_star)


class TestODEGrowthSolver(unittest.TestCase):
    """Test linear perturbation ODE growth factor D(z), growth rate f(z), and potential decay."""

    def setUp(self):
        self.params_flat = CosmologicalParameters(
            H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0, w0=-1.0, wa=0.0, use_poincare_topology=False
        )
        self.model = PoincareEDEModel(self.params_flat)

    def test_growth_factor_matter_domination_limit(self):
        """Confirm D(a) -> a in matter-dominated era and D(z=0) = 1.0."""
        # 1. Normalization at z=0
        self.assertAlmostEqual(self.model.growth_factor(0.0), 1.0, places=5)

        # 2. Boundary condition: unnormalized delta(a) -> a at early matter domination
        z_high = 500.0
        a_high = 1.0 / (1.0 + z_high)
        delta_unnorm_high = self.model.growth_factor_unnormalized(z_high)
        ratio = delta_unnorm_high / a_high
        # In early matter domination, delta(a)/a should be close to 1.0
        self.assertAlmostEqual(ratio, 1.0, delta=0.05)

        # 3. Monotonic growth: D(z1) < D(z0) for z1 > z0
        z_grid = [0.0, 0.5, 1.0, 2.0, 5.0, 10.0]
        d_vals = [self.model.growth_factor(z) for z in z_grid]
        for i in range(len(d_vals) - 1):
            self.assertGreater(d_vals[i], d_vals[i + 1])

    def test_growth_rate_dark_energy_suppression(self):
        """Confirm f(z=0) < 1.0 in dark energy domination and f(z) -> 1.0 in matter domination."""
        # At z=0 in flat LCDM with Omega_m ~ 0.31: f(z=0) ~ Omega_m^0.55 ~ 0.52-0.55
        f0 = self.model.growth_rate_f(0.0)
        self.assertLess(f0, 1.0)
        self.assertGreater(f0, 0.45)
        self.assertAlmostEqual(f0, (self.model.params.Omega_m)**0.55, delta=0.05)

        # In matter domination (z >= 20): f(z) -> 1.0
        f_md = self.model.growth_rate_f(30.0)
        self.assertAlmostEqual(f_md, 1.0, delta=0.03)

    def test_potential_decay_rate(self):
        """Confirm late-time gravitational potential decay (f < 1) and vanishing in matter domination."""
        # At z=0: potential decays due to dark energy acceleration (decay < 0 and f < 1)
        decay_0 = self.model.potential_decay_rate(0.0)
        f_0 = self.model.growth_rate_f(0.0)
        self.assertLess(decay_0, 0.0)
        self.assertLess(f_0, 1.0)

        # Fractional decay per e-fold |f(z) - 1| vanishes in matter domination (z >= 30)
        f_high = self.model.growth_rate_f(50.0)
        self.assertAlmostEqual(f_high, 1.0, delta=0.03)
        self.assertLess(abs(f_high - 1.0), 0.1 * abs(f_0 - 1.0))


class TestDynamicalISW(unittest.TestCase):
    """Test line-of-sight dynamical Integrated Sachs-Wolfe numerical quadrature."""

    def setUp(self):
        self.params_flat = CosmologicalParameters(
            H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0, w0=-1.0, wa=0.0, use_poincare_topology=False
        )
        self.model_flat = PoincareEDEModel(self.params_flat)

        self.params_poincare = CosmologicalParameters(
            H0=68.00, omega_b=0.02239, omega_cdm=0.1402, Omega_k=-0.0027, f_EDE=0.0886, log10_zc=3.560, w0=-0.80, wa=-0.50, isw_leakage=0.18, use_poincare_topology=True
        )
        self.model_poincare = PoincareEDEModel(self.params_poincare)

    def test_isw_power_positivity(self):
        """Confirm C_ell^ISW and D_ell^ISW > 0 for all multipoles ell in [2, 10]."""
        d_isw = self.model_flat.cmb_low_ell_isw_power(ell_max=10)
        for ell in range(2, 11):
            self.assertIn(ell, d_isw)
            self.assertGreater(d_isw[ell], 0.0, f"ISW power must be positive at ell={ell}")

    def test_poincare_multipole_suppression_low_ell(self):
        """Confirm Poincaré topology suppresses quadrupole D_2 from ~1200 muK^2 down to ~200-400 muK^2."""
        d_flat = self.model_flat.cmb_low_ell_power(ell_max=6)
        d_poincare = self.model_poincare.cmb_low_ell_power(ell_max=6)

        # Standard flat LCDM quadrupole is high (~1100-1300 muK^2)
        self.assertGreater(d_flat[2], 1000.0)

        # Poincaré topology quadrupole is suppressed to residual ISW + projected mode (~200-450 muK^2)
        self.assertLess(d_poincare[2], 450.0)
        self.assertGreater(d_poincare[2], 100.0)

        # First unsuppressed icosahedral mode (ell=6) retains full power
        self.assertGreater(d_poincare[6], 700.0)


class TestTransferFunctionAndSigma8(unittest.TestCase):
    """Test Eisenstein-Hu T(k), ETHOS/IDR damping, and windowed sigma_8 quadrature."""

    def setUp(self):
        self.params_lcdm = CosmologicalParameters(
            H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0,
            n_s=0.9649, A_s=math.exp(3.044)*1e-10, use_poincare_topology=False
        )
        self.model_lcdm = PoincareEDEModel(self.params_lcdm)

        self.params_idr = CosmologicalParameters(
            H0=73.45, omega_b=0.02258, omega_cdm=0.1315, Omega_k=-0.0008,
            f_EDE=0.118, log10_zc=3.58, theta_i=2.82, delta_N_idr=0.24,
            g_dark_coupling=0.085, n_s=0.991, A_s=math.exp(3.068)*1e-10,
            model_type="idr", use_poincare_topology=True
        )
        self.model_idr = PoincareEDEModel(self.params_idr)

    def test_eisenstein_hu_transfer_function(self):
        """Confirm T_EH98(k -> 0) -> 1.0 and monotonic damping at high k."""
        k_small = 1e-4
        T_0 = self.model_lcdm.transfer_function_eh98(k_small)
        self.assertAlmostEqual(T_0, 1.0, delta=0.01)

        k_high = 10.0
        T_high = self.model_lcdm.transfer_function_eh98(k_high)
        self.assertLess(T_high, 0.01)
        self.assertGreater(T_high, 0.0)

    def test_sigma8_quadrature_lcdm(self):
        """Confirm sigma_8 ~ 0.81-0.83 and S_8 ~ 0.82-0.84 for Planck 2018 flat LCDM."""
        sig8 = self.model_lcdm.sigma_8
        s8 = self.model_lcdm.S_8
        self.assertGreater(sig8, 0.80)
        self.assertLess(sig8, 0.83)
        self.assertGreater(s8, 0.81)
        self.assertLess(s8, 0.85)

    def test_idr_damping_and_s8_alleviation(self):
        """Confirm IDR dark radiation damping suppresses S_8 to ~0.73-0.78 matching DES Y3 + KiDS-1000."""
        d_idr = self.model_idr.idr_damping_factor
        self.assertLess(d_idr, 1.0)
        self.assertGreater(d_idr, 0.60)

        s8_idr = self.model_idr.S_8
        self.assertLess(s8_idr, 0.80)
        self.assertGreater(s8_idr, 0.70)


class TestObservationalLikelihoods(unittest.TestCase):
    """Test Planck, DESI, and Pantheon+ likelihood evaluations."""

    def setUp(self):
        self.joint = JointLikelihood(include_low_ell=True)
        self.params_lcdm = CosmologicalParameters(
            H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0, w0=-1.0, wa=0.0, use_poincare_topology=False
        )
        self.model_lcdm = PoincareEDEModel(self.params_lcdm)

        self.params_poincare = CosmologicalParameters(
            H0=68.00, omega_b=0.02239, omega_cdm=0.1402, Omega_k=-0.0027, f_EDE=0.0886, log10_zc=3.560, w0=-0.80, wa=-0.50, isw_leakage=0.18, use_poincare_topology=True
        )
        self.model_poincare = PoincareEDEModel(self.params_poincare)

    def test_planck_priors_likelihood(self):
        """Test Planck 2018 compressed distance priors."""
        c2_lcdm = self.joint.planck.chi2(self.model_lcdm)
        self.assertLess(c2_lcdm, 10.0)

        c2_poincare = self.joint.planck.chi2(self.model_poincare)
        self.assertLess(c2_poincare, 1.0)

    def test_low_ell_topology_advantage(self):
        """Test that S^3/I* topological multipole suppression yields Delta chi^2 < -50 over Lambda-CDM."""
        c2_low_lcdm = self.joint.low_ell.chi2(self.model_lcdm)
        c2_low_poincare = self.joint.low_ell.chi2(self.model_poincare)
        delta_low = c2_low_poincare - c2_low_lcdm
        self.assertLess(delta_low, -50.0)

    def test_desi_2024_bao_likelihood(self):
        """Test DESI 2024 BAO likelihood evaluation across all 13 observables."""
        c2_desi_lcdm = self.joint.desi.chi2(self.model_lcdm)
        c2_desi_poincare = self.joint.desi.chi2(self.model_poincare)
        self.assertGreater(c2_desi_lcdm, 0.0)
        self.assertGreater(c2_desi_poincare, 0.0)
        self.assertLess(c2_desi_poincare, 30.0)

    def test_pantheon_plus_likelihood(self):
        """Test Pantheon+ SNe Ia marginalized chi^2."""
        c2_sne_lcdm = self.joint.pantheon.chi2(self.model_lcdm)
        c2_sne_poincare = self.joint.pantheon.chi2(self.model_poincare)
        self.assertGreater(c2_sne_lcdm, 0.0)
        self.assertGreater(c2_sne_poincare, 0.0)

    def test_likelihood_data_counts_and_dof(self):
        """Test exact data point counts, degrees of freedom, and breakdowns."""
        self.assertEqual(self.joint.planck.n_data, 3)
        self.assertEqual(self.joint.low_ell.n_data, 5)
        self.assertEqual(self.joint.desi.n_data, 13)
        self.assertEqual(self.joint.pantheon.n_data, 74)
        self.assertEqual(self.joint.n_data, 95)
        
        self.assertEqual(self.joint.degrees_of_freedom(6), 89)
        self.assertEqual(self.joint.degrees_of_freedom(9), 86)


class TestMCMCSamplerAndDiagnostics(unittest.TestCase):
    """Test MCMC harness, Gelman-Rubin on actual likelihood posterior, ACT, ESS, and serialization."""

    def test_information_criteria(self):
        """Test AIC and BIC computation with exact standard mathematical formulas."""
        stats = compute_information_criteria(chi2_min=73.996, k_params=9, n_data=95, chi2_ref=169.261, k_ref=6)
        self.assertAlmostEqual(stats["AIC"], 73.996 + 18.0)
        self.assertAlmostEqual(stats["BIC"], 73.996 + 9.0 * math.log(95))
        self.assertAlmostEqual(stats["AIC_ref"], 169.261 + 12.0)
        self.assertAlmostEqual(stats["BIC_ref"], 169.261 + 6.0 * math.log(95))
        self.assertAlmostEqual(stats["Delta_chi2"], 73.996 - 169.261)
        self.assertAlmostEqual(stats["Delta_AIC"], (73.996 + 18.0) - (169.261 + 12.0))
        self.assertAlmostEqual(stats["Delta_BIC"], (73.996 + 9.0 * math.log(95)) - (169.261 + 6.0 * math.log(95)))

    def test_gelman_rubin_array_interfaces(self):
        """Test Gelman-Rubin diagnostic on raw 2D and 3D numpy arrays."""
        rng = np.random.default_rng(42)
        # 3 chains x 200 samples x 2 params
        c_data = rng.normal(10.0, 1.0, size=(3, 200, 2))
        r_hat_arr = gelman_rubin_diagnostic(c_data)
        self.assertIsInstance(r_hat_arr, np.ndarray)
        self.assertEqual(len(r_hat_arr), 2)
        for r in r_hat_arr:
            self.assertLess(r, 1.05)

        # 2D array (M, N)
        r_hat_1d = gelman_rubin_diagnostic(c_data[:, :, 0])
        self.assertIsInstance(r_hat_1d, float)
        self.assertLess(r_hat_1d, 1.05)

        # With param_names
        r_hat_dict = gelman_rubin_diagnostic(c_data, param_names=["param_A", "param_B"])
        self.assertIsInstance(r_hat_dict, dict)
        self.assertIn("param_A", r_hat_dict)
        self.assertLess(r_hat_dict["param_A"], 1.05)

    def test_autocorr_and_ess(self):
        """Test integrated autocorrelation time and ESS estimation."""
        rng = np.random.default_rng(42)
        # Independent white noise has tau ~ 1.0
        wn = rng.normal(size=500)
        tau_wn = integrated_autocorr_time(wn)
        self.assertAlmostEqual(tau_wn, 1.0, delta=0.5)

        ess_wn = effective_sample_size(wn)
        self.assertGreater(ess_wn, 300.0)

    def test_real_mcmc_posterior_sampling_and_gelman_rubin(self):
        """
        Crucial: Execute real multi-chain MCMC sampler directly on JointLikelihood.log_posterior
        and assert Gelman-Rubin diagnostic and parameter convergence on actual likelihood chains.
        """
        joint = JointLikelihood(include_low_ell=True, include_high_ell_pol=False, include_weak_lensing=False, include_shoes=False)
        active_params = ["H0", "omega_b", "omega_cdm"]
        sampler = MCMCSampler(joint_likelihood=joint, active_params=active_params, use_poincare_topology=False)

        x0 = np.array([67.36, 0.02237, 0.1200])
        chains, summary = sampler.run_ensemble_multi_chain(
            x0=x0,
            n_walkers=12,
            n_steps=70,
            burn_in=30,
            seed=42
        )

        self.assertEqual(len(chains), 12)
        for c in chains:
            self.assertEqual(c.n_samples, 70)
            self.assertEqual(c.n_dim, 3)
            self.assertGreater(c.acceptance_fraction, 0.20)

        # Assert Gelman-Rubin R_hat on real posterior chains
        r_hat = gelman_rubin_diagnostic(chains)
        self.assertEqual(len(r_hat), 3)
        for p in active_params:
            self.assertIn(p, r_hat)
            self.assertGreater(r_hat[p], 0.99)
            # Fast unit-test probe (70 steps) achieves R_hat < 1.50
            self.assertLess(r_hat[p], 1.50)

        # Check summary properties
        self.assertIn("H0", summary.means)
        self.assertGreater(summary.means["H0"], 58.0)
        self.assertLess(summary.means["H0"], 78.0)
        self.assertIn("omega_b", summary.means)
        self.assertIn("omega_cdm", summary.means)
        self.assertIsNotNone(summary.autocorr_time)
        self.assertIsNotNone(summary.effective_sample_size)

    def test_chain_and_summary_serialization_roundtrip(self):
        """Test saving and loading MCMC chains and PosteriorSummary to/from disk."""
        tmp_dir = tempfile.mkdtemp()
        try:
            samples1 = np.random.normal(size=(50, 2))
            samples2 = np.random.normal(size=(50, 2))
            c1 = MCMCChain(param_names=["H0", "w0"], samples=samples1, log_probs=np.zeros(50), acceptance_fraction=0.25, chain_id=0)
            c2 = MCMCChain(param_names=["H0", "w0"], samples=samples2, log_probs=np.zeros(50), acceptance_fraction=0.28, chain_id=1)
            chains = [c1, c2]

            # Save and load chains (.npz)
            npz_path = os.path.join(tmp_dir, "test_chains.npz")
            save_chains(chains, npz_path)
            self.assertTrue(os.path.exists(npz_path))

            loaded_chains = load_chains(npz_path)
            self.assertEqual(len(loaded_chains), 2)
            self.assertEqual(loaded_chains[0].param_names, ["H0", "w0"])
            np.testing.assert_allclose(loaded_chains[0].samples, samples1)
            self.assertAlmostEqual(loaded_chains[1].acceptance_fraction, 0.28)

            # Save and load summary (.json)
            summary = PosteriorSummary(
                param_names=["H0", "w0"],
                means={"H0": 70.0, "w0": -0.9},
                stds={"H0": 0.5, "w0": 0.05},
                medians={"H0": 70.0, "w0": -0.9},
                ci_68={"H0": (69.5, 70.5), "w0": (-0.95, -0.85)},
                ci_95={"H0": (69.0, 71.0), "w0": (-1.0, -0.8)},
                map_estimate={"H0": 70.1, "w0": -0.91},
                cov_matrix=np.eye(2),
                corr_matrix=np.eye(2),
                gelman_rubin_r_hat={"H0": 1.01, "w0": 1.02}
            )
            json_path = os.path.join(tmp_dir, "test_summary.json")
            save_posterior_summary(summary, json_path)
            self.assertTrue(os.path.exists(json_path))

            loaded_summary = load_posterior_summary(json_path)
            self.assertEqual(loaded_summary.param_names, ["H0", "w0"])
            self.assertAlmostEqual(loaded_summary.means["H0"], 70.0)
            self.assertAlmostEqual(loaded_summary.gelman_rubin_r_hat["H0"], 1.01)
            np.testing.assert_allclose(loaded_summary.cov_matrix, np.eye(2))
        finally:
            shutil.rmtree(tmp_dir, ignore_errors=True)


class TestTableVerificationReproducibility(unittest.TestCase):
    """Test full table verification reproducibility matching paper2_cosmology.md Table 1 & Table 2."""

    def test_table_verification_evaluates_cleanly(self):
        """Confirm evaluate_table_verification returns complete, finite results across all models."""
        results = evaluate_table_verification()
        self.assertIn("models", results)
        models = results["models"]
        self.assertIn("model1_lcdm", models)
        self.assertIn("model2_ede", models)
        self.assertIn("model3_idr", models)

        m1 = models["model1_lcdm"]
        m2 = models["model2_ede"]
        m3 = models["model3_idr"]

        # 1. Check Table 1 parameter values
        self.assertAlmostEqual(m1["parameters"]["H0"], 67.36)
        self.assertAlmostEqual(m2["parameters"]["H0"], 70.93)
        self.assertAlmostEqual(m3["parameters"]["H0"], 70.93)

        # 2. Check derived observables
        self.assertAlmostEqual(m1["derived_observables"]["sigma_8"], 0.811, delta=0.02)
        self.assertAlmostEqual(m1["derived_observables"]["S_8"], 0.830, delta=0.02)
        
        # IDR damping reduces S_8
        self.assertLess(m3["derived_observables"]["S_8"], m2["derived_observables"]["S_8"])

        # 3. Check low-ell quadrupole suppression
        d2_m1 = m1["derived_observables"]["D_ell_TT"][2]
        d2_m2 = m2["derived_observables"]["D_ell_TT"][2]
        d2_m3 = m3["derived_observables"]["D_ell_TT"][2]
        self.assertGreater(d2_m1, 1000.0)
        self.assertLess(d2_m2, 450.0)
        self.assertLess(d2_m3, 450.0)

        # 4. Check SH0ES resolution
        chi2_shoes_m1 = m1["likelihood_with_shoes"]["breakdown"]["SH0ES_H0_Prior"]
        chi2_shoes_m2 = m2["likelihood_with_shoes"]["breakdown"]["SH0ES_H0_Prior"]
        chi2_shoes_m3 = m3["likelihood_with_shoes"]["breakdown"]["SH0ES_H0_Prior"]
        self.assertGreater(chi2_shoes_m1, 25.0)
        self.assertLess(chi2_shoes_m2, 5.0)
        self.assertLess(chi2_shoes_m3, 5.0)


if __name__ == '__main__':
    unittest.main()
