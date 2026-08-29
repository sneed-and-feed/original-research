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
