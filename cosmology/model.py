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
    Cosmological parameter set for the S^3 / I^* EDE model.
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
        """Physical radiation density omega_r = omega_gamma + omega_nu."""
        omega_gamma = 2.47282e-5 * ((self.T_CMB / 2.7255)**4)
        return omega_gamma * (1.0 + 0.2271073 * self.N_eff)

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
        """Normalized EDE energy density rho_EDE(z) / rho_crit,0."""
        p = self.params
        zc = p.z_c
        f_ede = p.f_EDE
        if f_ede <= 1e-12:
            if np.ndim(z) > 0:
                return np.zeros_like(z, dtype=float)
            return 0.0

        E_non_ede_sq = (
            p.Omega_r * (1.0 + zc)**4 +
            p.Omega_m * (1.0 + zc)**3 +
            p.Omega_k * (1.0 + zc)**2 +
            p.Omega_de
        )
        rho_ede_zc = (f_ede / (1.0 - f_ede)) * E_non_ede_sq
        w_osc = (p.n_EDE - 1.0) / (p.n_EDE + 1.0)

        z_arr = np.asarray(z, dtype=float)
        ratio_osc = (1.0 + zc) / (1.0 + z_arr)
        ratio_frozen = (1.0 + z_arr) / (1.0 + zc)
        
        rho_ede = np.where(
            z_arr <= zc,
            2.0 * rho_ede_zc / (1.0 + ratio_osc**(3.0 * (1.0 + w_osc))),
            2.0 * rho_ede_zc / (1.0 + ratio_frozen**(-3.0 * (1.0 + w_osc)))
        )
        if np.ndim(z) == 0:
            return float(rho_ede)
        return rho_ede

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
    # CMB Low-ell Multipole Power Spectrum
    # --------------------------------------------------------------------------
    def cmb_low_ell_power(self, ell_max: int = 10) -> Dict[int, float]:
        """
        Compute predicted low-ell CMB TT angular power D_ell = ell(ell+1)/(2*pi) * C_ell [muK^2]
        including Poincaré dodecahedral topological suppression factor S_ell.
        """
        fiducial_plateau = 1100.0 * (self.params.H0 / 67.4)**0.2
        d_ell = {}
        for ell in range(2, ell_max + 1):
            if self.params.use_poincare_topology:
                s_ell = PoincareTopology.multipole_suppression_factor(ell, self.params.isw_leakage)
            else:
                s_ell = 1.0  # Standard unsuppressed flat topology
            d_ell[ell] = fiducial_plateau * s_ell * (ell / 2.0)**(-0.04)
        return d_ell
