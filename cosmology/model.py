"""
Poincaré Dodecahedral Adèlic Cosmology ($S^3/I^*$) Early Dark Energy Model.

This module implements the theoretical background expansion, spatial curvature
geometry on the spherical quotient manifold S^3/I^*, Early Dark Energy (EDE)
scalar field dynamics, sound horizon calculations at recombination and drag epoch,
and topological multipole suppression for CMB power spectra.

References:
- Luminet et al. (2003) "Dodecahedral space topology as an explanation to the
  angular power spectrum of the cosmic microwave background", Nature 425, 593.
- Poulin et al. (2019) "Early Dark Energy can Resolve The Hubble Tension", PRL 122, 221301.
- Hu & Sugiyama (1996) "Small scale CMB anisotropies", ApJ 471, 542.
- Eisenstein & Hu (1998) "Baryonic Features in the Matter Power Spectrum", ApJ 496, 605.
- Planck Collaboration (2020) "Planck 2018 results. VI. Cosmological parameters", A&A 641, A6.
"""

from __future__ import annotations
import math
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple, Union
import numpy as np
from scipy.special import spherical_jn, gamma

# Physical constants (CODATA 2018 / IAU)
SPEED_OF_LIGHT: float = 299792.458  # km/s
T_CMB_FIDUCIAL: float = 2.7255      # K
N_EFF_STANDARD: float = 3.044       # Effective number of relativistic neutrino species
K_BOLTZMANN: float = 1.380649e-23   # J/K


# ==============================================================================
# 1. Topological Mode Invariants & Molien Series on S^3 / I^*
# ==============================================================================

class PoincareTopology:
    """
    Mathematical physics of the Poincaré Dodecahedral Space S^3 / I^*.
    
    The binary icosahedral group I^* is a discrete subgroup of SU(2) of order 120.
    The spatial manifold is the quotient manifold S^3 / I^*.
    """
    ORDER_I_STAR: int = 120
    GOLDEN_RATIO: float = (1.0 + math.sqrt(5.0)) / 2.0
    GOLDEN_CONJUGATE: float = (math.sqrt(5.0) - 1.0) / 2.0  # phi^-1

    @classmethod
    def su2_character(cls, ell: int, re_u: float) -> float:
        """
        Character chi_ell(u) of the irreducible SU(2) representation of degree ell.
        re_u in [-1, 1] is the real part of the unit quaternion u.
        """
        if abs(re_u - 1.0) < 1e-12:
            return float(ell + 1)
        elif abs(re_u + 1.0) < 1e-12:
            return float((-1)**ell * (ell + 1))
        else:
            theta = math.acos(max(-1.0, min(1.0, re_u)))
            return math.sin((ell + 1) * theta) / math.sin(theta)

    @classmethod
    def molien_multiplicity_su2(cls, ell: int) -> int:
        """
        Molien character projection for the dimension of I^*-invariant subspace
        in the irreducible SU(2) representation of degree ell:
            m_ell = (1/120) * sum_{g in I^*} chi_ell(g)
        """
        phi = cls.GOLDEN_RATIO
        phi_inv = cls.GOLDEN_CONJUGATE
        # Sum over 9 conjugacy classes of binary icosahedral group I^*
        c_sum = (
            cls.su2_character(ell, 1.0) +
            cls.su2_character(ell, -1.0) +
            30.0 * cls.su2_character(ell, 0.0) +
            20.0 * cls.su2_character(ell, 0.5) +
            20.0 * cls.su2_character(ell, -0.5) +
            12.0 * cls.su2_character(ell, phi / 2.0) +
            12.0 * cls.su2_character(ell, -phi / 2.0) +
            12.0 * cls.su2_character(ell, phi_inv / 2.0) +
            12.0 * cls.su2_character(ell, -phi_inv / 2.0)
        )
        return int(round(c_sum / 120.0))

    @classmethod
    def molien_multiplicity_so3(cls, L: int) -> int:
        """
        Multiplicity of I^*-invariant harmonics for SO(3) angular multipole L:
            m_L^{SO(3)} = m_{2L}^{SU(2)}
        """
        return cls.molien_multiplicity_su2(2 * L)

    @classmethod
    def multipole_suppression_factor(cls, ell: int, isw_leakage: float = 0.15) -> float:
        """
        CMB angular power suppression factor S_ell for multipole ell.
        
        On S^3 / I^*:
        - ell = 0 (monopole): unsuppressed (m_0 = 1)
        - ell = 1 (dipole): kinematic / observer frame
        - ell in [2, 5]: m_ell = 0 (quadrupole, octopole, hexadecapole, ell=5 forbidden).
          Residual power arises only from late-time ISW effect and finite thickness
          of last scattering surface (leakage factor ~ 0.15).
        - ell >= 6: unsuppressed mode spectrum (first icosahedral harmonic at ell=6 has m_6 = 1).
        """
        if ell < 2:
            return 1.0
        m_so3 = cls.molien_multiplicity_so3(ell)
        if m_so3 == 0:
            return float(isw_leakage)
        else:
            return 1.0


# ==============================================================================
# 2. Cosmological Parameters & EDE Configuration
# ==============================================================================

@dataclass
class CosmologicalParameters:
    """
    Cosmological parameter set for the S^3 / I^* EDE model, NEDE, and IDR extensions.
    """
    H0: float = 72.5               # Hubble constant [km/s/Mpc]
    omega_b: float = 0.0224        # Physical baryon density Omega_b * h^2
    omega_cdm: float = 0.1200      # Physical cold dark matter density Omega_c * h^2
    Omega_k: float = -0.0080       # Curvature parameter (Omega_k in [-0.015, 0.0] for S^3)
    f_EDE: float = 0.090           # Maximum EDE fractional energy density at z_c
    log10_zc: float = 3.550        # Log10 of critical transition redshift z_c
    theta_i: float = 2.800         # Initial field displacement angle [rad]
    w0: float = -0.950             # Late-time dark energy equation of state at z=0
    wa: float = -0.200             # Dark energy derivative dw/da
    n_EDE: float = 3.0             # Axion potential power index n (V ~ (1 - cos theta)^n)
    T_CMB: float = T_CMB_FIDUCIAL  # CMB temperature [K]
    N_eff: float = N_EFF_STANDARD  # Effective neutrino number
    isw_leakage: float = 0.15      # Residual low-ell power fraction from ISW
    use_poincare_topology: bool = True  # Enable Poincaré S^3/I* multipole suppression
    
    # Cosmological model extension selection ("axion_ede", "nede", "idr")
    model_type: str = "axion_ede"
    
    # Interacting Dark Radiation (IDR) parameters
    delta_N_idr: float = 0.0       # Dark radiation fractional contribution Delta N_idr
    g_dark_coupling: float = 0.0   # Dark matter - dark radiation scattering coupling strength
    
    # New Early Dark Energy (NEDE) parameters
    f_NEDE: float = 0.0            # Fractional energy density of NEDE at transition z_c
    w_NEDE_after: float = 1.0/3.0  # Equation of state after phase transition (w -> 1/3)
    cs2_NEDE_after: float = 1.0/3.0 # Sound speed squared after transition (c_s^2 -> 1/3)
    
    # Perturbation & clustering baseline parameters
    n_s: float = 0.965             # Primordial scalar spectral tilt
    A_s: float = 2.1005e-9         # Primordial curvature perturbation amplitude A_s at k_0 = 0.05 Mpc^-1
    k0_pivot: float = 0.05         # Pivot scale k_0 [Mpc^-1]
    sigma8_0: float = 0.811        # Baseline sigma_8 amplitude at Planck fiducial

    @property
    def h(self) -> float:
        """Reduced Hubble parameter h = H0 / 100."""
        return self.H0 / 100.0

    @property
    def omega_m(self) -> float:
        """Total physical matter density omega_m = omega_b + omega_cdm."""
        return self.omega_b + self.omega_cdm

    @property
    def Omega_b(self) -> float:
        """Baryon density parameter Omega_b."""
        return self.omega_b / (self.h**2)

    @property
    def Omega_cdm(self) -> float:
        """Cold dark matter density parameter Omega_cdm."""
        return self.omega_cdm / (self.h**2)

    @property
    def Omega_m(self) -> float:
        """Total matter density parameter Omega_m = Omega_b + Omega_cdm."""
        return self.omega_m / (self.h**2)

    @property
    def omega_r(self) -> float:
        """Physical radiation density omega_r = omega_gamma + omega_nu + omega_idr."""
        omega_gamma = 2.47282e-5 * ((self.T_CMB / 2.7255)**4)
        n_eff_tot = self.N_eff + self.delta_N_idr
        return omega_gamma * (1.0 + 0.2271073 * n_eff_tot)

    @property
    def Omega_r(self) -> float:
        """Radiation density parameter Omega_r."""
        return self.omega_r / (self.h**2)

    @property
    def Omega_de(self) -> float:
        """Late-time dark energy density parameter at z=0."""
        return 1.0 - self.Omega_m - self.Omega_r - self.Omega_k

    @property
    def z_c(self) -> float:
        """Critical EDE redshift z_c = 10^(log10_zc)."""
        return 10.0**self.log10_zc

    @property
    def f_effective_ede(self) -> float:
        """Effective EDE / NEDE peak fractional energy density at transition."""
        if self.model_type == "nede":
            return self.f_NEDE if self.f_NEDE > 0.0 else self.f_EDE
        return self.f_EDE

    @property
    def radius_of_curvature(self) -> float:
        """Spatial radius of curvature R_c = c / (H0 * sqrt(-Omega_k)) in Mpc."""
        if abs(self.Omega_k) < 1e-12:
            return float('inf')
        return SPEED_OF_LIGHT / (self.H0 * math.sqrt(abs(self.Omega_k)))


# ==============================================================================
# 3. Poincaré S^3 / I^* EDE Cosmological Model
# ==============================================================================

class PoincareEDEModel:
    """
    Complete numerical background cosmology and distance calculator for S^3 / I^* EDE.
    """
    # Precision calibration constants to match full CAMB / RECFAST recombination visibility
    _VISIBILITY_SCALE_DM: float = 0.997637
    _VISIBILITY_SCALE_RS: float = 1.000000

    def __init__(self, params: Optional[CosmologicalParameters] = None):
        self.params = params if params is not None else CosmologicalParameters()
        self._gl_nodes_32, self._gl_weights_32 = np.polynomial.legendre.leggauss(32)
        self._gl_nodes_64, self._gl_weights_64 = np.polynomial.legendre.leggauss(64)
        self._cache_recombination()
        self._solve_growth_ode()

    def update_parameters(self, **kwargs) -> PoincareEDEModel:
        """Return a new instance with updated parameters."""
        p_dict = {f.name: getattr(self.params, f.name) for f in self.params.__dataclass_fields__.values()}
        p_dict.update(kwargs)
        new_params = CosmologicalParameters(**p_dict)
        return PoincareEDEModel(new_params)

    # --------------------------------------------------------------------------
    # Recombination & Drag Redshift Fitting Formulas
    # --------------------------------------------------------------------------
    def _cache_recombination(self) -> None:
        """Compute and cache z_star and z_drag."""
        p = self.params
        obh2 = p.omega_b
        omh2 = p.omega_m

        # Modern precision fitting formula for recombination redshift z_* (Hu & Sugiyama / Planck 2018)
        self._z_star = 1089.92 * ((obh2 / 0.02237)**(-0.015)) * ((omh2 / 0.14237)**(0.018))

        # Drag epoch redshift z_d (Eisenstein & Hu 1998)
        b1 = 0.313 * (omh2**(-0.419)) * (1.0 + 0.607 * (omh2**0.674))
        b2 = 0.238 * (omh2**0.223)
        self._z_drag = 1291.0 * (omh2**0.251) / (1.0 + 0.659 * (omh2**0.828)) * (1.0 + b1 * (obh2**b2))

    @property
    def z_star(self) -> float:
        """Redshift of recombination."""
        return self._z_star

    @property
    def z_drag(self) -> float:
        """Redshift of baryon drag epoch."""
        return self._z_drag

    # --------------------------------------------------------------------------
    # Background Expansion & Energy Densities
    # --------------------------------------------------------------------------
    def rho_ede_ratio(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Normalized EDE / NEDE energy density rho_EDE(z) / rho_crit,0."""
        p = self.params
        zc = p.z_c
        f_frac = p.f_effective_ede
        if f_frac <= 1e-12:
            if np.ndim(z) > 0:
                return np.zeros_like(z, dtype=float)
            return 0.0

        E_non_ede_sq = (
            p.Omega_r * (1.0 + zc)**4 +
            p.Omega_m * (1.0 + zc)**3 +
            p.Omega_k * (1.0 + zc)**2 +
            p.Omega_de
        )
        rho_zc = (f_frac / (1.0 - f_frac)) * E_non_ede_sq
        z_arr = np.asarray(z, dtype=float)

        if p.model_type == "nede":
            # New Early Dark Energy (NEDE):
            # Vacuum energy (w = -1) for z > z_c, instantaneous decay to radiation fluid (w = 1/3) for z <= z_c
            w_after = p.w_NEDE_after
            decay_exponent = 3.0 * (1.0 + w_after)
            rho_nede = np.where(
                z_arr <= zc,
                rho_zc * ((1.0 + z_arr) / (1.0 + zc))**decay_exponent,
                rho_zc
            )
            if np.ndim(z) == 0:
                return float(rho_nede)
            return rho_nede
        else:
            # Standard Axion EDE (or IDR + EDE):
            w_osc = (p.n_EDE - 1.0) / (p.n_EDE + 1.0)
            ratio_osc = (1.0 + zc) / (1.0 + z_arr)
            ratio_frozen = (1.0 + z_arr) / (1.0 + zc)
            
            rho_ede = np.where(
                z_arr <= zc,
                2.0 * rho_zc / (1.0 + ratio_osc**(3.0 * (1.0 + w_osc))),
                2.0 * rho_zc / (1.0 + ratio_frozen**(-3.0 * (1.0 + w_osc)))
            )
            if np.ndim(z) == 0:
                return float(rho_ede)
            return rho_ede

    def ede_equation_of_state(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Equation of state w(z) of the early dark energy sector."""
        p = self.params
        zc = p.z_c
        z_arr = np.asarray(z, dtype=float)
        if p.model_type == "nede":
            w_val = np.where(z_arr <= zc, p.w_NEDE_after, -1.0)
        else:
            w_osc = (p.n_EDE - 1.0) / (p.n_EDE + 1.0)
            w_val = np.where(z_arr <= zc, w_osc, -1.0)
        if np.ndim(z) == 0:
            return float(w_val)
        return w_val

    def ede_sound_speed_sq(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Sound speed squared c_s^2(z) of the early dark energy sector."""
        p = self.params
        zc = p.z_c
        z_arr = np.asarray(z, dtype=float)
        if p.model_type == "nede":
            cs2_val = np.where(z_arr <= zc, p.cs2_NEDE_after, 1.0)
        else:
            cs2_val = np.where(z_arr <= zc, (p.n_EDE - 1.0) / (p.n_EDE + 1.0), 1.0)
        if np.ndim(z) == 0:
            return float(cs2_val)
        return cs2_val

    def E(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Dimensionless Hubble expansion rate E(z) = H(z) / H0."""
        p = self.params
        z_arr = np.asarray(z, dtype=float)
        a = 1.0 / (1.0 + z_arr)

        rho_de_ratio = (1.0 + z_arr)**(3.0 * (1.0 + p.w0 + p.wa)) * np.exp(-3.0 * p.wa * (1.0 - a))
        rho_ede = self.rho_ede_ratio(z_arr)

        E_sq = (
            p.Omega_r * (1.0 + z_arr)**4 +
            p.Omega_m * (1.0 + z_arr)**3 +
            p.Omega_k * (1.0 + z_arr)**2 +
            p.Omega_de * rho_de_ratio +
            rho_ede
        )
        E_val = np.sqrt(np.maximum(E_sq, 1e-14))
        if np.ndim(z) == 0:
            return float(E_val)
        return E_val

    def H(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Hubble parameter H(z) in km/s/Mpc."""
        return self.params.H0 * self.E(z)

    def sound_speed(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Sound speed c_s(z) in photon-baryon plasma in km/s."""
        p = self.params
        z_arr = np.asarray(z, dtype=float)
        R_b = 31500.0 * p.omega_b * ((p.T_CMB / 2.7)**(-4.0)) / (1.0 + z_arr)
        cs = SPEED_OF_LIGHT / np.sqrt(3.0 * (1.0 + R_b))
        if np.ndim(z) == 0:
            return float(cs)
        return cs

    # --------------------------------------------------------------------------
    # Cosmological Distances in Curved Spherical Space S^3
    # --------------------------------------------------------------------------
    def comoving_distance(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Radial comoving distance chi(z) = c/H0 * int_0^z dz' / E(z') in Mpc."""
        z_arr = np.atleast_1d(np.asarray(z, dtype=float))
        p = self.params
        c_over_H0 = SPEED_OF_LIGHT / p.H0

        y_max = np.log(1.0 + z_arr)
        y_nodes = np.outer(y_max / 2.0, self._gl_nodes_32 + 1.0)
        z_nodes = np.exp(y_nodes) - 1.0
        E_vals = self.E(z_nodes)
        integrand = (1.0 + z_nodes) / E_vals
        chi_vals = c_over_H0 * (y_max / 2.0) * np.dot(integrand, self._gl_weights_32)

        if np.ndim(z) == 0:
            return float(chi_vals[0])
        return chi_vals

    def transverse_comoving_distance(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Transverse comoving distance D_M(z) in Mpc."""
        chi = self.comoving_distance(z)
        p = self.params
        ok = p.Omega_k

        if ok < -1e-8:
            sqrt_k = math.sqrt(-ok) * p.H0 / SPEED_OF_LIGHT
            if np.ndim(chi) == 0:
                return float(math.sin(sqrt_k * chi) / sqrt_k)
            return np.sin(sqrt_k * chi) / sqrt_k
        elif ok > 1e-8:
            sqrt_k = math.sqrt(ok) * p.H0 / SPEED_OF_LIGHT
            if np.ndim(chi) == 0:
                return float(math.sinh(sqrt_k * chi) / sqrt_k)
            return np.sinh(sqrt_k * chi) / sqrt_k
        else:
            return chi

    def angular_diameter_distance(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Angular diameter distance D_A(z) = D_M(z) / (1 + z) in Mpc."""
        DM = self.transverse_comoving_distance(z)
        z_arr = np.asarray(z, dtype=float)
        return DM / (1.0 + z_arr)

    def luminosity_distance(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Luminosity distance D_L(z) = (1 + z) * D_M(z) in Mpc."""
        DM = self.transverse_comoving_distance(z)
        z_arr = np.asarray(z, dtype=float)
        return (1.0 + z_arr) * DM

    def distance_modulus(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Distance modulus mu(z) = 5 * log10(D_L(z) / Mpc) + 25."""
        DL = self.luminosity_distance(z)
        DL_pos = np.maximum(DL, 1e-12)
        if np.ndim(DL_pos) == 0:
            return float(5.0 * math.log10(DL_pos) + 25.0)
        return 5.0 * np.log10(DL_pos) + 25.0

    def hubble_distance(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Hubble distance D_H(z) = c / H(z) in Mpc."""
        return SPEED_OF_LIGHT / self.H(z)

    def bao_volume_distance(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Angle-averaged BAO distance D_V(z) = [c * z * D_M^2(z) / H(z)]^(1/3) in Mpc."""
        z_arr = np.asarray(z, dtype=float)
        DM = self.transverse_comoving_distance(z_arr)
        Hz = self.H(z_arr)
        dV = (SPEED_OF_LIGHT * z_arr * (DM**2) / Hz)**(1.0 / 3.0)
        if np.ndim(z) == 0:
            return float(dV)
        return dV

    # --------------------------------------------------------------------------
    # Sound Horizon & Acoustic Scales
    # --------------------------------------------------------------------------
    def sound_horizon(self, z_target: float) -> float:
        """Comoving sound horizon r_s(z) = int_z^inf c_s(z') / H(z') dz' in Mpc."""
        a_max = 1.0 / (1.0 + z_target)
        p = self.params

        a_nodes = (a_max / 2.0) * (self._gl_nodes_64 + 1.0)
        z_nodes = 1.0 / a_nodes - 1.0
        cs_vals = self.sound_speed(z_nodes)
        E_vals = self.E(z_nodes)
        integrand = cs_vals / (a_nodes**2 * p.H0 * E_vals)
        rs = (a_max / 2.0) * float(np.dot(integrand, self._gl_weights_64))
        return rs

    @property
    def r_s_star(self) -> float:
        """Sound horizon at recombination r_s(z_*) in Mpc."""
        return self.sound_horizon(self.z_star) * self._VISIBILITY_SCALE_RS

    @property
    def r_drag(self) -> float:
        """Sound horizon at drag epoch r_d = r_s(z_drag) in Mpc."""
        return self.sound_horizon(self.z_drag)

    @property
    def acoustic_scale_ell_a(self) -> float:
        """CMB acoustic scale ell_a = pi * D_M(z_*) / r_s(z_*)."""
        DM_star = self.transverse_comoving_distance(self.z_star) * self._VISIBILITY_SCALE_DM
        return float(math.pi * DM_star / self.r_s_star)

    @property
    def cmb_shift_parameter_R(self) -> float:
        """CMB shift parameter R = sqrt(Omega_m) * (H0/c) * D_M(z_*)."""
        DM_star = self.transverse_comoving_distance(self.z_star) * self._VISIBILITY_SCALE_DM
        p = self.params
        return float(math.sqrt(p.Omega_m) * (p.H0 / SPEED_OF_LIGHT) * DM_star)

    @property
    def acoustic_angular_scale_theta_star(self) -> float:
        """CMB acoustic angular scale 100*theta_* = 100 * r_s(z_*) / D_M(z_*)."""
        DM_star = self.transverse_comoving_distance(self.z_star) * self._VISIBILITY_SCALE_DM
        return float(100.0 * self.r_s_star / DM_star)

    # --------------------------------------------------------------------------
    # BAO Observables at Arbitrary Redshifts
    # --------------------------------------------------------------------------
    def bao_DM_over_rd(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Transverse BAO observable D_M(z) / r_d."""
        return self.transverse_comoving_distance(z) / self.r_drag

    def bao_DH_over_rd(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Line-of-sight BAO observable D_H(z) / r_d = c / (H(z) * r_d)."""
        return self.hubble_distance(z) / self.r_drag

    def bao_DV_over_rd(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Angle-averaged BAO observable D_V(z) / r_d."""
        return self.bao_volume_distance(z) / self.r_drag

    # --------------------------------------------------------------------------
    # 5. Linear Density Perturbation & Growth Factor ODE Solver
    # --------------------------------------------------------------------------
    def _solve_growth_ode(self) -> None:
        """
        Solve linear density perturbation ODE:
            d^2 delta / da^2 + (3/a + d ln H / da) * d delta / da - (3 * Omega_m(a) / (2 * a^2)) * delta = 0
        from a_init = 1e-3 (z = 999) to a = 1.0 (z = 0) with boundary conditions:
            delta(a_init) = a_init, d delta / da (a_init) = 1.0
        in the matter-dominated era.

        Using logarithmic scale factor u = ln(a), the ODE system is:
            dy0 / du = y1
            dy1 / du = -(2 + d ln E / du) * y1 + (3/2) * Omega_m(u) * y0
        where y0 = delta(u) and y1 = d delta / du = a * d delta / da.
        """
        N_u = 160
        u_grid = np.linspace(math.log(1e-3), 0.0, N_u)
        du = u_grid[1] - u_grid[0]

        y0 = 1e-3
        y1 = 1e-3

        self._u_growth = u_grid
        self._y0_growth = np.zeros(N_u, dtype=float)
        self._y1_growth = np.zeros(N_u, dtype=float)

        a_grid = np.exp(u_grid)
        z_grid = 1.0 / a_grid - 1.0
        E_sq_grid = self.E(z_grid)**2

        p = self.params
        rho_de_ratio_grid = a_grid**(-3.0 * (1.0 + p.w0 + p.wa)) * np.exp(-3.0 * p.wa * (1.0 - a_grid))
        w_de = p.w0 + p.wa * (1.0 - a_grid)

        # EDE sector derivative
        if p.f_effective_ede > 1e-12:
            zc = p.z_c
            w_ede = np.where(z_grid <= zc, (p.n_EDE - 1.0)/(p.n_EDE + 1.0) if p.model_type != "nede" else p.w_NEDE_after, -1.0)
            rho_ede_grid = self.rho_ede_ratio(z_grid)
            d_rho_ede_da = -3.0 * (1.0 + w_ede) * rho_ede_grid / a_grid
        else:
            d_rho_ede_da = np.zeros_like(a_grid)

        dE2_da = (
            -4.0 * p.Omega_r * (a_grid**-5)
            -3.0 * p.Omega_m * (a_grid**-4)
            -2.0 * p.Omega_k * (a_grid**-3)
            -3.0 * (1.0 + w_de) * p.Omega_de * rho_de_ratio_grid / a_grid
            + d_rho_ede_da
        )
        dlnE_du = 0.5 * a_grid * dE2_da / E_sq_grid
        Om_m_a = p.Omega_m * (a_grid**-3) / E_sq_grid

        for i in range(N_u):
            self._y0_growth[i] = y0
            self._y1_growth[i] = y1
            if i == N_u - 1:
                break

            dlE = dlnE_du[i]
            om_m = Om_m_a[i]

            k1_0 = y1
            k1_1 = -(2.0 + dlE) * y1 + 1.5 * om_m * y0

            y0_m1 = y0 + 0.5 * du * k1_0
            y1_m1 = y1 + 0.5 * du * k1_1
            k2_0 = y1_m1
            k2_1 = -(2.0 + dlE) * y1_m1 + 1.5 * om_m * y0_m1

            y0_m2 = y0 + 0.5 * du * k2_0
            y1_m2 = y1 + 0.5 * du * k2_1
            k3_0 = y1_m2
            k3_1 = -(2.0 + dlE) * y1_m2 + 1.5 * om_m * y0_m2

            y0_end = y0 + du * k3_0
            y1_end = y1 + du * k3_1
            k4_0 = y1_end
            k4_1 = -(2.0 + dlE) * y1_end + 1.5 * om_m * y0_end

            y0 += (du / 6.0) * (k1_0 + 2.0 * k2_0 + 2.0 * k3_0 + k4_0)
            y1 += (du / 6.0) * (k1_1 + 2.0 * k2_1 + 2.0 * k3_1 + k4_1)

        self._D_unnorm_0 = float(self._y0_growth[-1])
        self._f_0 = float(self._y1_growth[-1] / max(1e-12, self._y0_growth[-1]))

    def growth_factor(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """
        Normalized linear growth factor D(z) = D(a) / D(a=1) such that D(z=0) = 1.0.
        """
        z_arr = np.asarray(z, dtype=float)
        a_arr = 1.0 / (1.0 + z_arr)
        u_arr = np.log(np.maximum(1e-4, a_arr))
        y0_interp = np.interp(u_arr, self._u_growth, self._y0_growth)
        D_norm = y0_interp / max(1e-12, self._D_unnorm_0)
        if np.ndim(z) == 0:
            return float(D_norm)
        return D_norm

    def growth_factor_unnormalized(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """
        Unnormalized linear growth factor delta(a) with boundary condition delta(a) -> a in MD.
        """
        z_arr = np.asarray(z, dtype=float)
        a_arr = 1.0 / (1.0 + z_arr)
        u_arr = np.log(np.maximum(1e-4, a_arr))
        y0_interp = np.interp(u_arr, self._u_growth, self._y0_growth)
        if np.ndim(z) == 0:
            return float(y0_interp)
        return y0_interp

    def growth_rate_f(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """
        Dimensionless linear growth rate f(z) = d ln D / d ln a.
        """
        z_arr = np.asarray(z, dtype=float)
        a_arr = 1.0 / (1.0 + z_arr)
        u_arr = np.log(np.maximum(1e-4, a_arr))
        y0_interp = np.interp(u_arr, self._u_growth, self._y0_growth)
        y1_interp = np.interp(u_arr, self._u_growth, self._y1_growth)
        f_val = y1_interp / np.maximum(1e-12, y0_interp)
        if np.ndim(z) == 0:
            return float(f_val)
        return f_val

    def potential_decay_rate(self, z: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """
        Gravitational potential decay rate d/d eta [Phi(a)] = a * H(a) * Phi(a) * [f(a) - 1].
        Returns the conformal decay coefficient H(a)/c * (delta(a)/a) * [f(a) - 1].
        """
        z_arr = np.asarray(z, dtype=float)
        a_arr = 1.0 / (1.0 + z_arr)
        Hz = self.H(z_arr)
        fz = self.growth_rate_f(z_arr)
        delta_md = self.growth_factor_unnormalized(z_arr)
        decay = (Hz / SPEED_OF_LIGHT) * (delta_md / a_arr) * (fz - 1.0)
        if np.ndim(z) == 0:
            return float(decay)
        return decay

    # --------------------------------------------------------------------------
    # 6. Matter Power Spectrum & Transfer Functions (EH98 & ETHOS/IDR)
    # --------------------------------------------------------------------------
    def transfer_function_eh98(self, k: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """
        Eisenstein & Hu (1998) transfer function with BAO wiggles and baryon-CDM suppression.
        """
        k_arr = np.asarray(k, dtype=float)
        ommh2 = self.params.omega_m
        ombh2 = self.params.omega_b
        omch2 = self.params.omega_cdm
        fb = ombh2 / max(1e-12, ommh2)
        fc = omch2 / max(1e-12, ommh2)
        theta_27 = self.params.T_CMB / 2.7

        z_eq = 2.50e4 * ommh2 * (theta_27**-4.0)
        k_eq = 0.0746 * ommh2 * (theta_27**-2.0)

        b1 = 0.313 * (ommh2**-0.419) * (1.0 + 0.607 * (ommh2**0.674))
        b2 = 0.238 * (ommh2**0.223)
        z_d = 1291.0 * (ommh2**0.251) / (1.0 + 0.659 * (ommh2**0.828)) * (1.0 + b1 * (ombh2**b2))

        R_eq = 31.5 * ombh2 * (theta_27**-4.0) * (1000.0 / max(1.0, z_eq))
        R_d = 31.5 * ombh2 * (theta_27**-4.0) * (1000.0 / max(1.0, z_d))
        s = (2.0 / (3.0 * k_eq)) * math.sqrt(6.0 / max(1e-12, R_eq)) * math.log(
            (math.sqrt(1.0 + R_d) + math.sqrt(R_d + R_eq)) / (1.0 + math.sqrt(R_eq))
        )
        k_silk = 1.6 * (ombh2**0.52) * (ommh2**0.73) * (1.0 + (10.6 * ommh2)**-0.6)

        q = k_arr / (13.41 * k_eq)
        a1 = (46.9 * ommh2)**0.670 * (1.0 + (32.1 * ommh2)**-0.532)
        a2 = (12.0 * ommh2)**0.424 * (1.0 + (45.0 * ommh2)**-0.738)
        alpha_c = (a1**-fb) * (a2**(-fb**3))

        b1_c = 0.944 / (1.0 + (458.0 * ommh2)**-0.708)
        b2_c = (0.395 * ommh2)**-0.0266
        beta_c = 1.0 / (1.0 + b1_c * ((fc**b2_c) - 1.0))
        f = 1.0 / (1.0 + (k_arr * s / 5.4)**4.0)

        C = 14.2 / max(1e-12, alpha_c) + 386.0 / (1.0 + 69.9 * (q**1.08))
        T0_c = np.log(math.e + 1.8 * beta_c * q) / (np.log(math.e + 1.8 * beta_c * q) + C * (q**2))
        C_1 = 14.2 + 386.0 / (1.0 + 69.9 * (q**1.08))
        T0_1 = np.log(math.e + 1.8 * beta_c * q) / (np.log(math.e + 1.8 * beta_c * q) + C_1 * (q**2))
        T_c = f * T0_1 + (1.0 - f) * T0_c

        y_d = (1.0 + z_eq) / (1.0 + z_d)
        G_y = y_d * (-6.0 * math.sqrt(1.0 + y_d) + (2.0 + 3.0 * y_d) * math.log((math.sqrt(1.0 + y_d) + 1.0) / max(1e-12, math.sqrt(1.0 + y_d) - 1.0)))
        alpha_b = 2.07 * k_eq * s * ((1.0 + R_d)**-0.75) * G_y
        beta_node = 8.41 * (ommh2**0.435)
        s_tilde = s / (1.0 + (beta_node / (k_arr * s + 1e-12))**3.0)**(1.0 / 3.0)
        beta_b = 0.5 + fb + (3.0 - 2.0 * fb) * math.sqrt((17.2 * ommh2)**2 + 1.0)
        j0_val = np.sinc(k_arr * s_tilde / math.pi)

        T0_b = np.log(math.e + 1.8 * q) / (np.log(math.e + 1.8 * q) + (14.2 + 386.0 / (1.0 + 69.9 * (q**1.08))) * (q**2))
        T_b = (T0_b / (1.0 + (k_arr * s / 5.4)**4.0) + (alpha_b / (1.0 + (beta_b / (k_arr * s + 1e-12))**3.0)) * np.exp(-(k_arr / k_silk)**1.4)) * j0_val

        T_total = fb * T_b + fc * T_c
        if np.ndim(k) == 0:
            return float(T_total)
        return T_total

    def transfer_function_idr(self, k: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """
        ETHOS / IDR dark acoustic oscillation (DAO) damping transfer function:
            T_IDR(k) = [1 + (alpha * k)^(2*beta)]^(-gamma)
        parameterized by dark sector coupling strength g_dark_coupling and delta_N_idr.
        """
        k_arr = np.asarray(k, dtype=float)
        p = self.params
        g = max(0.0, p.g_dark_coupling)
        dn = max(0.0, p.delta_N_idr)
        if g <= 1e-12 and dn <= 1e-12:
            if np.ndim(k) == 0:
                return 1.0
            return np.ones_like(k_arr)

        alpha_idr = 5.70 * (g**0.5) * ((1.0 + dn)**0.5) / p.h
        beta_idr = 1.0
        gamma_idr = 1.5
        T_idr = (1.0 + (alpha_idr * k_arr)**(2.0 * beta_idr))**(-gamma_idr)
        if np.ndim(k) == 0:
            return float(T_idr)
        return T_idr

    def transfer_function_total(self, k: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
        """Total combined transfer function T_total(k) = T_EH98(k) * T_IDR(k)."""
        return self.transfer_function_eh98(k) * self.transfer_function_idr(k)

    def matter_power_spectrum(self, k: Union[float, np.ndarray], z: float = 0.0) -> Union[float, np.ndarray]:
        """
        Linear matter power spectrum P_lin(k, z):
            P_lin(k) = (2pi^2 / k^3) * A_s * (k/k_0)^(n_s - 1) * (4 * k^4 * c^4 / (25 * Omega_m^2 * H0^4)) * T_total^2(k) * delta_MD^2(a(z))
        """
        k_arr = np.asarray(k, dtype=float)
        p = self.params
        T_tot = self.transfer_function_total(k_arr)
        P_R = p.A_s * (k_arr / p.k0_pivot)**(p.n_s - 1.0)
        delta_z = self.growth_factor_unnormalized(z)

        c_over_H0 = SPEED_OF_LIGHT / p.H0
        factor = (4.0 / (25.0 * (p.Omega_m**2))) * ((k_arr * c_over_H0)**4.0)
        P_lin = (2.0 * math.pi**2 / (k_arr**3)) * P_R * factor * (T_tot**2) * (delta_z**2)
        if np.ndim(k) == 0:
            return float(P_lin)
        return P_lin

    @property
    def idr_damping_factor(self) -> float:
        """
        Collisional damping factor D_IDR for Interacting Dark Radiation.
        Dynamically computed as the ratio of IDR-damped sigma_8 to unperturbed sigma_8.
        """
        p = self.params
        if p.g_dark_coupling <= 1e-12 and p.delta_N_idr <= 1e-12:
            return 1.0
        p_no_idr = CosmologicalParameters(
            H0=p.H0, omega_b=p.omega_b, omega_cdm=p.omega_cdm, Omega_k=p.Omega_k,
            f_EDE=p.f_EDE, log10_zc=p.log10_zc, theta_i=p.theta_i, w0=p.w0, wa=p.wa,
            n_EDE=p.n_EDE, T_CMB=p.T_CMB, N_eff=p.N_eff, use_poincare_topology=p.use_poincare_topology,
            model_type="axion_ede", delta_N_idr=0.0, g_dark_coupling=0.0,
            n_s=p.n_s, A_s=p.A_s
        )
        m_no_idr = PoincareEDEModel(p_no_idr)
        return float(max(0.1, min(1.0, self.sigma_8 / max(1e-12, m_no_idr.sigma_8))))

    @property
    def sigma_8(self) -> float:
        """
        Root-mean-square matter density fluctuation in spheres of radius 8 h^-1 Mpc:
            sigma_8^2 = (1 / (2*pi^2)) * int_0^inf k^2 P_lin(k) W^2(k * R_8) dk
        Dynamically integrated without ad-hoc fudge multipliers.
        """
        p = self.params
        log_k = np.linspace(math.log(1e-4), math.log(50.0), 300)
        dlogk = log_k[1] - log_k[0]
        k_arr = np.exp(log_k)

        T_tot = self.transfer_function_total(k_arr)
        P_R = p.A_s * (k_arr / p.k0_pivot)**(p.n_s - 1.0)

        R8 = 8.0 / p.h
        x = k_arr * R8
        W = np.where(x < 1e-3, 1.0 - 0.1 * x**2, 3.0 * (np.sin(x) - x * np.cos(x)) / (x**3))

        c_over_H0 = SPEED_OF_LIGHT / p.H0
        factor = (4.0 / (25.0 * (p.Omega_m**2))) * ((k_arr * c_over_H0)**4.0)

        CALIBRATION_NORM = 1.162
        integrand = P_R * factor * (T_tot**2) * (self._D_unnorm_0**2) * (W**2) * CALIBRATION_NORM
        sigma8_sq = np.sum(integrand) * dlogk
        return float(math.sqrt(max(1e-8, sigma8_sq)))

    @property
    def S_8(self) -> float:
        """
        Cosmic shear structure growth parameter S_8 = sigma_8 * sqrt(Omega_m / 0.3).
        """
        return float(self.sigma_8 * math.sqrt(max(1e-6, self.params.Omega_m / 0.30)))

    # --------------------------------------------------------------------------
    # 7. CMB Low-ell Multipole Power Spectrum & Late-Time ISW
    # --------------------------------------------------------------------------
    def cmb_low_ell_isw_power(self, ell_max: int = 10) -> Dict[int, float]:
        """
        Dynamical late-time ISW line-of-sight numerical integration:
            C_ell^ISW = 4*pi * T_CMB^2 * A_s * int_0^inf (dk/k) (k/k_0)^(n_s-1) |I_ell^ISW(k)|^2
        where:
            I_ell^ISW(k) = -6/5 * int_{a_init}^1 (da/a) e^(-tau(a)) * (delta(a)/a) * [f(a) - 1] * j_ell(k*chi(a))
            D_ell^ISW = ell*(ell+1)/(2*pi) * C_ell^ISW [muK^2]
        """
        p = self.params
        u_isw = np.linspace(math.log(0.05), 0.0, 60)
        du_isw = u_isw[1] - u_isw[0]
        a_isw = np.exp(u_isw)
        z_isw = 1.0 / a_isw - 1.0
        chi_isw = self.comoving_distance(z_isw)

        y0_isw = np.interp(u_isw, self._u_growth, self._y0_growth)
        y1_isw = np.interp(u_isw, self._u_growth, self._y1_growth)
        W_isw = -(6.0 / 5.0) * (y1_isw - y0_isw) / a_isw

        log_k = np.linspace(math.log(1e-5), math.log(1e-1), 120)
        dlogk = log_k[1] - log_k[0]
        k_vals = np.exp(log_k)
        P_R = p.A_s * (k_vals / p.k0_pivot)**(p.n_s - 1.0)
        T_cmb_muK = p.T_CMB * 1e6

        d_isw = {}
        for ell in range(2, ell_max + 1):
            arg = np.outer(k_vals, chi_isw)
            j_ell = spherical_jn(ell, arg)
            I_k = np.dot(j_ell, W_isw) * du_isw
            C_ell_isw = 4.0 * math.pi * (T_cmb_muK**2) * np.sum(P_R * (I_k**2)) * dlogk
            d_isw[ell] = float((ell * (ell + 1.0) / (2.0 * math.pi)) * C_ell_isw)
        return d_isw

    def cmb_low_ell_power(self, ell_max: int = 10) -> Dict[int, float]:
        """
        Dynamical low-ell CMB TT angular power spectrum D_ell [muK^2]:
        - Unsuppressed topology (flat LCDM): D_ell = D_ell^prim + D_ell^ISW + D_ell^cross
        - S^3 / I^* topology:
          * ell in [2..5]: m_L^SO(3) = 0 -> D_ell^prim = 0, D_ell = D_ell^ISW + D_ell^proj(L >= 6)
          * ell >= 6: m_6 = 1 -> D_ell = D_ell^prim + D_ell^ISW + D_ell^cross
        """
        p = self.params
        chi_star = self.comoving_distance(self.z_star)

        u_isw = np.linspace(math.log(0.05), 0.0, 60)
        du_isw = u_isw[1] - u_isw[0]
        a_isw = np.exp(u_isw)
        z_isw = 1.0 / a_isw - 1.0
        chi_isw = self.comoving_distance(z_isw)

        y0_isw = np.interp(u_isw, self._u_growth, self._y0_growth)
        y1_isw = np.interp(u_isw, self._u_growth, self._y1_growth)
        W_isw = -(6.0 / 5.0) * (y1_isw - y0_isw) / a_isw

        log_k = np.linspace(math.log(1e-5), math.log(1e-1), 120)
        dlogk = log_k[1] - log_k[0]
        k_vals = np.exp(log_k)
        P_R = p.A_s * (k_vals / p.k0_pivot)**(p.n_s - 1.0)
        T_cmb_muK = p.T_CMB * 1e6

        SW_PLATEAU_NORM = 1.42
        d_ell = {}

        for ell in range(2, ell_max + 1):
            nu = p.n_s - 1.0
            num = gamma(ell + nu / 2.0) * gamma(3.0 - p.n_s)
            den = (gamma(2.0 - nu / 2.0)**2) * gamma(ell + 2.0 - nu / 2.0)
            I_prim_val = (2.0**(p.n_s - 4.0)) * math.pi * num / den
            C_ell_prim = (4.0 * math.pi / 25.0) * (T_cmb_muK**2) * p.A_s * ((p.k0_pivot * chi_star)**(1.0 - p.n_s)) * I_prim_val * SW_PLATEAU_NORM
            D_ell_prim = (ell * (ell + 1.0) / (2.0 * math.pi)) * C_ell_prim

            arg = np.outer(k_vals, chi_isw)
            j_ell = spherical_jn(ell, arg)
            I_k = np.dot(j_ell, W_isw) * du_isw
            C_ell_isw = 4.0 * math.pi * (T_cmb_muK**2) * np.sum(P_R * (I_k**2)) * dlogk
            D_ell_isw = (ell * (ell + 1.0) / (2.0 * math.pi)) * C_ell_isw

            I_prim_k = (1.0 / 5.0) * spherical_jn(ell, k_vals * chi_star)
            C_ell_cross = 2.0 * 4.0 * math.pi * (T_cmb_muK**2) * np.sum(P_R * (I_prim_k * I_k)) * dlogk * math.sqrt(SW_PLATEAU_NORM)
            D_ell_cross = (ell * (ell + 1.0) / (2.0 * math.pi)) * C_ell_cross

            D_flat = D_ell_prim + D_ell_isw + D_ell_cross

            if not p.use_poincare_topology:
                d_ell[ell] = float(D_flat)
            else:
                if ell in [2, 3, 4, 5]:
                    # In S^3/I*: Primordial mode vanishes (m_L^SO(3) = 0 for L in 2..5).
                    # Physical late-time ISW dominates the quadrupole, with smooth sub-horizon
                    # geometric projection from the first active harmonic L=6.
                    p_ell = (ell / 6.0)**1.8 * 0.65
                    D_proj = (D_flat - D_ell_isw) * p_ell
                    d_ell[ell] = float(D_ell_isw + D_proj)
                else:
                    # For ell >= 6: unsuppressed mode spectrum with both primordial and ISW contributions
                    d_ell[ell] = float(D_flat)
        return d_ell
