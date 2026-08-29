"""
Unit Test Suite for Poincaré Dodecahedral Adèlic Cosmology ($S^3/I^*$).
"""

import math
import os
import sys
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
    gelman_rubin_diagnostic,
    compute_information_criteria
)


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
        # In spherical space, DM = R_c * sin(chi / R_c) < chi
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

        # Equation of state & sound speed:
        # z <= z_c: w = 1/3, c_s^2 = 1/3 (radiation fluid)
        self.assertAlmostEqual(model_nede.ede_equation_of_state(100.0), 1.0/3.0, places=4)
        self.assertAlmostEqual(model_nede.ede_equation_of_state(zc), 1.0/3.0, places=4)
        self.assertAlmostEqual(model_nede.ede_sound_speed_sq(100.0), 1.0/3.0, places=4)
        self.assertAlmostEqual(model_nede.ede_sound_speed_sq(zc), 1.0/3.0, places=4)

        # z > z_c: w = -1, c_s^2 = 1.0 (vacuum energy)
        self.assertAlmostEqual(model_nede.ede_equation_of_state(10000.0), -1.0, places=4)
        self.assertAlmostEqual(model_nede.ede_sound_speed_sq(10000.0), 1.0, places=4)

        # Energy density ratio: constant for z > z_c, radiation decay (1+z)^4 for z <= z_c
        rho_zc = model_nede.rho_ede_ratio(zc)
        rho_high = model_nede.rho_ede_ratio(2.0 * zc)
        self.assertAlmostEqual(rho_high, rho_zc, places=4)

        z_low = 100.0
        rho_low = model_nede.rho_ede_ratio(z_low)
        expected_low = rho_zc * ((1.0 + z_low)/(1.0 + zc))**4
        self.assertAlmostEqual(rho_low, expected_low, places=4)

        # Sound horizon is compressed compared to flat LCDM
        self.assertLess(model_nede.r_s_star, self.model_flat.r_s_star)

    def test_idr_collisional_damping_and_s8(self):
        """Test IDR dark radiation energy density, collisional damping factor, and dynamic S_8."""
        params_idr = CosmologicalParameters(
            H0=71.50, omega_b=0.02239, omega_cdm=0.1577, Omega_k=-0.0027,
            f_EDE=0.1244, log10_zc=3.560, theta_i=2.80, delta_N_idr=0.35,
            g_dark_coupling=0.14, n_s=0.967, sigma8_0=0.811,
            model_type="idr", use_poincare_topology=True
        )
        model_idr = PoincareEDEModel(params_idr)

        # Dark radiation boosts physical radiation energy density
        self.assertGreater(params_idr.omega_r, self.params_poincare.omega_r)

        # Collisional damping factor D_IDR is strictly < 1.0
        self.assertEqual(self.model_poincare.idr_damping_factor, 1.0)
        self.assertLess(model_idr.idr_damping_factor, 0.95)
        self.assertGreater(model_idr.idr_damping_factor, 0.70)

        # Dynamic S_8 computation matches target benchmarks
        s8_idr = model_idr.S_8
        s8_poincare = self.model_poincare.S_8
        self.assertGreater(s8_poincare, 0.82)
        self.assertLess(s8_idr, 0.81)
        self.assertGreater(s8_idr, 0.76)


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

    def test_joint_concordance_improvement(self):
        """Test total joint chi^2 demonstrates decisive empirical preference for Poincare EDE."""
        c2_tot_lcdm = self.joint.chi2(self.model_lcdm)
        c2_tot_poincare = self.joint.chi2(self.model_poincare)
        delta_chi2 = c2_tot_poincare - c2_tot_lcdm
        self.assertLess(delta_chi2, -80.0)

    def test_likelihood_data_counts_and_dof(self):
        """Test exact data point counts, degrees of freedom, and breakdowns."""
        self.assertEqual(self.joint.planck.n_data, 3)
        self.assertEqual(self.joint.low_ell.n_data, 5)
        self.assertEqual(self.joint.desi.n_data, 13)
        self.assertEqual(self.joint.pantheon.n_data, 74)
        self.assertEqual(self.joint.n_data, 95)
        
        # Degrees of freedom for LambdaCDM (k=6) and Poincare EDE (k=9)
        self.assertEqual(self.joint.degrees_of_freedom(6), 89)
        self.assertEqual(self.joint.degrees_of_freedom(9), 86)
        
        # Test residual breakdowns
        low_ell_bk = self.joint.low_ell.residual_breakdown(self.model_poincare)
        self.assertEqual(len(low_ell_bk), 5)
        self.assertIn(2, low_ell_bk)
        self.assertIn("pull", low_ell_bk[2])

        desi_bk = self.joint.desi.residual_breakdown(self.model_poincare)
        self.assertEqual(len(desi_bk), 7)

        summary = self.joint.detailed_summary(self.model_poincare, k_params=9)
        self.assertEqual(summary["n_data"], 95)
        self.assertEqual(summary["dof"], 86)
        self.assertAlmostEqual(summary["reduced_chi2"], summary["breakdown"]["Total_Chi2"] / 86.0)

    def test_high_ell_polarization_likelihood(self):
        """Test Planck high-ell polarization damping tail penalty and IDR/NEDE mitigation."""
        lik_pol = PlanckHighEllPolarizationLikelihood()
        self.assertEqual(lik_pol.n_data, 2)

        # Flat LCDM has standard n_s and omega_cdm -> chi2 ~ 0
        c2_lcdm = lik_pol.chi2(self.model_lcdm)
        self.assertLess(c2_lcdm, 1.0)

        # Unmitigated Axion EDE with large omega_cdm has severe polarization penalty
        c2_ede = lik_pol.chi2(self.model_poincare)
        self.assertGreater(c2_ede, 10.0)

        # IDR model mitigates high-ell polarization damping tail
        params_idr = CosmologicalParameters(
            H0=71.50, omega_b=0.02239, omega_cdm=0.1577, Omega_k=-0.0027,
            f_EDE=0.1244, delta_N_idr=0.35, g_dark_coupling=0.14,
            n_s=0.967, model_type="idr", use_poincare_topology=True
        )
        model_idr = PoincareEDEModel(params_idr)
        c2_idr = lik_pol.chi2(model_idr)
        self.assertLess(c2_idr, 10.0)

        # NEDE model also mitigates polarization tension
        params_nede = CosmologicalParameters(
            H0=71.50, omega_b=0.02239, omega_cdm=0.1523, Omega_k=0.0005,
            f_NEDE=0.1706, n_s=0.966, model_type="nede", use_poincare_topology=True
        )
        model_nede = PoincareEDEModel(params_nede)
        c2_nede = lik_pol.chi2(model_nede)
        self.assertLess(c2_nede, 10.0)

        # Check breakdown
        bk = lik_pol.residual_breakdown(model_idr)
        self.assertIn("n_s_eff", bk)
        self.assertIn("omega_cdm_eff", bk)

    def test_weak_lensing_likelihood(self):
        """Test DES Y3 + KiDS-1000 weak lensing cosmic shear constraints."""
        lik_wl = WeakLensingLikelihood()
        self.assertEqual(lik_wl.n_data, 2)

        # Standard high-S8 models have large chi2
        params_high_s8 = CosmologicalParameters(
            H0=68.0, omega_b=0.0224, omega_cdm=0.1402, Omega_k=-0.0027,
            f_EDE=0.0886, model_type="axion_ede", use_poincare_topology=True
        )
        model_high_s8 = PoincareEDEModel(params_high_s8)
        c2_high_s8 = lik_wl.chi2(model_high_s8)
        self.assertGreater(c2_high_s8, 10.0)

        # IDR model with S_8 ~ 0.78-0.80 achieves excellent fit to DES Y3 (0.776 ± 0.017)
        params_idr = CosmologicalParameters(
            H0=71.50, omega_b=0.02239, omega_cdm=0.1577, Omega_k=-0.0027,
            f_EDE=0.1244, delta_N_idr=0.35, g_dark_coupling=0.18,
            model_type="idr", use_poincare_topology=True
        )
        model_idr = PoincareEDEModel(params_idr)
        c2_idr = lik_wl.chi2(model_idr)
        self.assertLess(c2_idr, 5.0)

        # Check breakdown
        bk = lik_wl.residual_breakdown(model_idr)
        self.assertIn("DES_Y3", bk)
        self.assertIn("KiDS_1000", bk)

    def test_shoes_prior_and_joint_toggles(self):
        """Test SH0ES prior and toggling of all likelihood components in JointLikelihood."""
        lik_shoes = SH0ESLikelihood(H0_obs=73.04, sigma_H0=1.04)
        self.assertEqual(lik_shoes.n_data, 1)

        # Model with H0 = 67.36 has ~5.5-sigma tension
        c2_lcdm = lik_shoes.chi2(self.model_lcdm)
        self.assertGreater(c2_lcdm, 25.0)

        # Model with H0 = 72.8 has low chi2
        params_h73 = CosmologicalParameters(H0=72.80)
        model_h73 = PoincareEDEModel(params_h73)
        c2_h73 = lik_shoes.chi2(model_h73)
        self.assertLess(c2_h73, 1.0)

        # Test JointLikelihood toggles
        joint_base = JointLikelihood(include_low_ell=True, include_high_ell_pol=False, include_weak_lensing=False, include_shoes=False)
        self.assertEqual(joint_base.n_data, 95)

        joint_ext = JointLikelihood(include_low_ell=True, include_high_ell_pol=True, include_weak_lensing=True, include_shoes=False)
        self.assertEqual(joint_ext.n_data, 99)

        joint_all = JointLikelihood(include_low_ell=True, include_high_ell_pol=True, include_weak_lensing=True, include_shoes=True)
        self.assertEqual(joint_all.n_data, 100)
        
        info = joint_all.dataset_info()
        self.assertIn("Planck_HighEll_Pol", info)
        self.assertIn("Weak_Lensing_DES_KiDS", info)
        self.assertIn("SH0ES_H0_Prior", info)
        self.assertEqual(info["Total_Data_Points"], 100)

        bk = joint_all.chi2_breakdown(model_h73)
        self.assertIn("Planck_HighEll_Pol", bk)
        self.assertIn("Weak_Lensing_DES_KiDS", bk)
        self.assertIn("SH0ES_H0_Prior", bk)


class TestMCMCAndInformationCriteria(unittest.TestCase):
    """Test MCMC harness, Gelman-Rubin diagnostics, and model selection criteria."""

    def test_information_criteria(self):
        """Test AIC and BIC computation with exact standard mathematical formulas."""
        # Baseline k=6, k=9 comparison
        stats = compute_information_criteria(chi2_min=73.996, k_params=9, n_data=95, chi2_ref=169.261, k_ref=6)
        self.assertAlmostEqual(stats["AIC"], 73.996 + 18.0)
        self.assertAlmostEqual(stats["BIC"], 73.996 + 9.0 * math.log(95))
        self.assertAlmostEqual(stats["AIC_ref"], 169.261 + 12.0)
        self.assertAlmostEqual(stats["BIC_ref"], 169.261 + 6.0 * math.log(95))
        self.assertAlmostEqual(stats["Delta_chi2"], 73.996 - 169.261)
        self.assertAlmostEqual(stats["Delta_AIC"], (73.996 + 18.0) - (169.261 + 12.0))
        self.assertAlmostEqual(stats["Delta_BIC"], (73.996 + 9.0 * math.log(95)) - (169.261 + 6.0 * math.log(95)))

        # Also test direct aic_ref / bic_ref inputs
        stats_direct = compute_information_criteria(
            chi2_min=74.0, k_params=9, n_data=95,
            aic_ref=181.3, bic_ref=196.6
        )
        self.assertAlmostEqual(stats_direct["Delta_AIC"], (74.0 + 18.0) - 181.3)
        self.assertAlmostEqual(stats_direct["Delta_BIC"], (74.0 + 9.0 * math.log(95)) - 196.6)

    def test_gelman_rubin_diagnostic(self):
        """Test Gelman-Rubin R_hat on mock chains."""
        rng = np.random.default_rng(123)
        # 3 identical stationary chains
        samples1 = rng.normal(70.0, 1.0, size=(200, 2))
        samples2 = rng.normal(70.0, 1.0, size=(200, 2))
        samples3 = rng.normal(70.0, 1.0, size=(200, 2))
        param_names = ["H0", "f_EDE"]

        c1 = MCMCChain(param_names=param_names, samples=samples1, log_probs=np.zeros(200), acceptance_fraction=0.3, chain_id=0)
        c2 = MCMCChain(param_names=param_names, samples=samples2, log_probs=np.zeros(200), acceptance_fraction=0.3, chain_id=1)
        c3 = MCMCChain(param_names=param_names, samples=samples3, log_probs=np.zeros(200), acceptance_fraction=0.3, chain_id=2)

        r_hat = gelman_rubin_diagnostic([c1, c2, c3])
        for p, r in r_hat.items():
            self.assertLess(r, 1.05)


if __name__ == '__main__':
    unittest.main()
