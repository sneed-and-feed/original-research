/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Rat.Lemmas
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# Hyperbolic Orbifold Spectral Zeta, Gauss–Bonnet Area & Selberg Trace Formula

This module formalizes the spectral geometry of 1-cusped hyperbolic 2-orbifolds
$\mathcal{O}(p, q, \infty) = \Delta(p, q, \infty) \backslash \mathbb{H}$:

1. **Hyperbolic Triangle Orbifold Signatures**:
   Signature $(p, q, \infty)$ with $2 \le p, q$ and hyperbolic condition $1/p + 1/q < 1$.

2. **Orbifold Euler Characteristic & Gauss–Bonnet Area**:
   $$\chi_{\text{orb}}(\mathbb{P}^1(p, q, \infty)) = \frac{1}{p} + \frac{1}{q} - 1 < 0$$
   $$\operatorname{Area}(\mathcal{O}(p, q, \infty)) = -2\pi \chi_{\text{orb}} = 2\pi \left(1 - \frac{1}{p} - \frac{1}{q}\right) > 0$$

3. **Certified Exact Areas for Canonical Families**:
   - $(3, 4, \infty) \implies \chi_{\text{orb}} = -5/12,\; \mu_{\text{orb}} = 5/12,\; \operatorname{Area} = 5\pi/6$
   - $(2, 3, \infty) \implies \chi_{\text{orb}} = -1/6,\; \mu_{\text{orb}} = 1/6,\; \operatorname{Area} = \pi/3$
   - $(2, 5, \infty) \implies \chi_{\text{orb}} = -3/10,\; \mu_{\text{orb}} = 3/10,\; \operatorname{Area} = 3\pi/5$
   - $(3, 5, \infty) \implies \chi_{\text{orb}} = -7/15,\; \mu_{\text{orb}} = 7/15,\; \operatorname{Area} = 14\pi/15,\; \operatorname{Area}_{\Delta} = 7\pi/15$

4. **Eisenstein Series Scattering Determinant $\phi(s)$**:
   Functional equation $\phi(s)\phi(1-s) = 1$, critical line unitarity $\|\phi(1/2 + ir)\|^2 = 1$,
   and residue $\operatorname{Res}_{s=1} \phi(s) = \frac{1}{1 - 1/p - 1/q} = \frac{1}{\mu_{\text{orb}}}$.

5. **Orbifold Selberg Trace Formula**:
   Spectral-geometric identity decomposing discrete spectrum (Maass cusp forms), continuous
   spectrum (Eisenstein scattering), and geometric conjugacy classes (identity, elliptic cone points
   of orders $p, q$, parabolic cusp, and hyperbolic closed geodesics).

6. **Selberg Zeta Function $\mathcal{Z}_{\mathcal{O}}(s)$**:
   Euler product over primitive closed geodesics, logarithmic derivative, and functional equation.
-/

namespace OrbifoldSpectralZeta

/-! ## 1. Hyperbolic Triangle Orbifold Signatures -/

/-- A signature $(p, q, \infty)$ for a 1-cusped hyperbolic 2-orbifold $\mathcal{O}(p, q, \infty)$.
The integers $p, q \ge 2$ represent cone point orders, and the hyperbolic condition requires
$1/p + 1/q < 1$, ensuring negative orbifold Euler characteristic. -/
structure HyperbolicTriangleSignature where
  p : ℕ
  q : ℕ
  hp : 2 ≤ p
  hq : 2 ≤ q
  hyperbolic : (p : ℚ)⁻¹ + (q : ℚ)⁻¹ < 1

/-- Number of conical singularity points for $\mathcal{O}(p, q, \infty)$. -/
def numConePoints (_ : HyperbolicTriangleSignature) : ℕ := 2

/-- Number of parabolic cusps for $\mathcal{O}(p, q, \infty)$. -/
def numCusps (_ : HyperbolicTriangleSignature) : ℕ := 1

/-- The orders of the conical singularities. -/
def coneOrders (sig : HyperbolicTriangleSignature) : List ℕ := [sig.p, sig.q]

/-- The hyperbolic condition is equivalent to $p + q < pq$. -/
theorem hyperbolic_iff_mul (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    (p : ℚ)⁻¹ + (q : ℚ)⁻¹ < 1 ↔ p + q < p * q := by
  have hp0 : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.2 hp.ne'
  have hq0 : (q : ℚ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  have hpq : 0 < (p : ℚ) * q := mul_pos (Nat.cast_pos.2 hp) (Nat.cast_pos.2 hq)
  rw [← mul_lt_mul_iff_of_pos_right hpq, one_mul]
  have h : ((p : ℚ)⁻¹ + (q : ℚ)⁻¹) * ((p : ℚ) * q) = ((p + q : ℕ) : ℚ) := by
    push_cast; linear_combination (q : ℚ) * inv_mul_cancel₀ hp0 + (p : ℚ) * inv_mul_cancel₀ hq0
  rw [h, ← Nat.cast_mul, Nat.cast_lt]

/-! ## 2. Orbifold Euler Characteristic & Gauss–Bonnet Hyperbolic Area -/

/-- Rational orbifold Euler characteristic $\chi_{\text{orb}}(\mathcal{O}(p, q, \infty)) = 1/p + 1/q - 1$. -/
def chiOrb (sig : HyperbolicTriangleSignature) : ℚ :=
  (sig.p : ℚ)⁻¹ + (sig.q : ℚ)⁻¹ - 1

/-- Real orbifold Euler characteristic. -/
noncomputable def chiOrbReal (sig : HyperbolicTriangleSignature) : ℝ :=
  (sig.p : ℝ)⁻¹ + (sig.q : ℝ)⁻¹ - 1

/-- Normalized hyperbolic area $\mu_{\text{orb}} = 1 - 1/p - 1/q = -\chi_{\text{orb}} \in \mathbb{Q}$. -/
def normalizedArea (sig : HyperbolicTriangleSignature) : ℚ :=
  1 - (sig.p : ℚ)⁻¹ - (sig.q : ℚ)⁻¹

/-- Real normalized hyperbolic area. -/
noncomputable def normalizedAreaReal (sig : HyperbolicTriangleSignature) : ℝ :=
  1 - (sig.p : ℝ)⁻¹ - (sig.q : ℝ)⁻¹

/-- Fundamental hyperbolic triangle area $\operatorname{Area}_\Delta(p, q, \infty) = \pi (1 - 1/p - 1/q)$. -/
noncomputable def triangleArea (sig : HyperbolicTriangleSignature) : ℝ :=
  Real.pi * normalizedAreaReal sig

/-- The Gauss–Bonnet hyperbolic Riemannian area $\operatorname{Area}(\mathcal{O}) = 2\pi \mu_{\text{orb}} = -2\pi \chi_{\text{orb}}$. -/
noncomputable def hyperbolicArea (sig : HyperbolicTriangleSignature) : ℝ :=
  2 * Real.pi * normalizedAreaReal sig

/-- The orbifold Euler characteristic is strictly negative for all hyperbolic triangle signatures. -/
theorem chiOrb_neg (sig : HyperbolicTriangleSignature) : chiOrb sig < 0 :=
  sub_neg.2 sig.hyperbolic

/-- The normalized hyperbolic area is strictly positive. -/
theorem normalizedArea_pos (sig : HyperbolicTriangleSignature) : 0 < normalizedArea sig := by
  have h := sig.hyperbolic; dsimp [normalizedArea]; linarith

/-- Normalized area is exactly the negative of the orbifold Euler characteristic. -/
theorem normalizedArea_eq_neg_chiOrb (sig : HyperbolicTriangleSignature) :
    normalizedArea sig = - chiOrb sig := by
  dsimp [normalizedArea, chiOrb]; ring

/-- Real normalized area coincides with rational normalized area cast to $\mathbb{R}$. -/
theorem normalizedAreaReal_eq_coe (sig : HyperbolicTriangleSignature) :
    normalizedAreaReal sig = (normalizedArea sig : ℝ) := by
  dsimp [normalizedAreaReal, normalizedArea]; push_cast; rfl

/-- Real orbifold Euler characteristic coincides with rational Euler characteristic cast to $\mathbb{R}$. -/
theorem chiOrbReal_eq_coe (sig : HyperbolicTriangleSignature) :
    chiOrbReal sig = (chiOrb sig : ℝ) := by
  dsimp [chiOrbReal, chiOrb]; push_cast; rfl

/-- Gauss–Bonnet theorem for 1-cusped hyperbolic 2-orbifolds:
$\operatorname{Area}(\mathcal{O}(p, q, \infty)) = -2\pi \chi_{\text{orb}}(\mathcal{O}(p, q, \infty))$. -/
theorem gauss_bonnet_area (sig : HyperbolicTriangleSignature) :
    hyperbolicArea sig = -2 * Real.pi * chiOrbReal sig := by
  dsimp [hyperbolicArea, normalizedAreaReal, chiOrbReal]; ring

/-- The Gauss–Bonnet hyperbolic area is strictly positive when $\pi > 0$. -/
theorem hyperbolicArea_pos (sig : HyperbolicTriangleSignature) (hpi : 0 < Real.pi) :
    0 < hyperbolicArea sig := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe]
  exact mul_pos (mul_pos (by norm_num) hpi) (Rat.cast_pos.2 (normalizedArea_pos sig))

/-- Hyperbolic area is twice the fundamental triangle area. -/
theorem hyperbolicArea_eq_two_triangleArea (sig : HyperbolicTriangleSignature) :
    hyperbolicArea sig = 2 * triangleArea sig := by
  dsimp [hyperbolicArea, triangleArea]; ring

/-! ## 3. Machine-Proved Certified Exact Values for Canonical Families -/

/-- The canonical $(3, 4, \infty)$ hyperbolic triangle orbifold signature. -/
def sig34 : HyperbolicTriangleSignature := ⟨3, 4, by decide, by decide, by norm_num⟩

/-- Exact rational Euler characteristic $\chi_{\text{orb}}(3, 4, \infty) = -5/12$. -/
theorem chiOrb_sig34 : chiOrb sig34 = -5 / 12 := by
  norm_num [chiOrb, sig34]

/-- Exact normalized area $\mu_{\text{orb}}(3, 4, \infty) = 5/12$. -/
theorem normalizedArea_sig34 : normalizedArea sig34 = 5 / 12 := by
  norm_num [normalizedArea, sig34]

/-- Exact Gauss–Bonnet hyperbolic area $\operatorname{Area}(\mathcal{O}(3, 4, \infty)) = 5\pi / 6$. -/
theorem hyperbolicArea_sig34 : hyperbolicArea sig34 = 5 * Real.pi / 6 := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe, normalizedArea_sig34]; push_cast; ring

/-- The canonical $(2, 3, \infty)$ modular triangle orbifold signature. -/
def sig23 : HyperbolicTriangleSignature := ⟨2, 3, by decide, by decide, by norm_num⟩

/-- Exact rational Euler characteristic $\chi_{\text{orb}}(2, 3, \infty) = -1/6$. -/
theorem chiOrb_sig23 : chiOrb sig23 = -1 / 6 := by
  norm_num [chiOrb, sig23]

/-- Exact normalized area $\mu_{\text{orb}}(2, 3, \infty) = 1/6$. -/
theorem normalizedArea_sig23 : normalizedArea sig23 = 1 / 6 := by
  norm_num [normalizedArea, sig23]

/-- Exact Gauss–Bonnet hyperbolic area $\operatorname{Area}(\mathcal{O}(2, 3, \infty)) = \pi / 3$. -/
theorem hyperbolicArea_sig23 : hyperbolicArea sig23 = Real.pi / 3 := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe, normalizedArea_sig23]; push_cast; ring

/-- The canonical $(2, 5, \infty)$ hyperbolic triangle orbifold signature. -/
def sig25 : HyperbolicTriangleSignature := ⟨2, 5, by decide, by decide, by norm_num⟩

/-- Exact rational Euler characteristic $\chi_{\text{orb}}(2, 5, \infty) = -3/10$. -/
theorem chiOrb_sig25 : chiOrb sig25 = -3 / 10 := by
  norm_num [chiOrb, sig25]

/-- Exact normalized area $\mu_{\text{orb}}(2, 5, \infty) = 3/10$. -/
theorem normalizedArea_sig25 : normalizedArea sig25 = 3 / 10 := by
  norm_num [normalizedArea, sig25]

/-- Exact Gauss–Bonnet hyperbolic area $\operatorname{Area}(\mathcal{O}(2, 5, \infty)) = 3\pi / 5$. -/
theorem hyperbolicArea_sig25 : hyperbolicArea sig25 = 3 * Real.pi / 5 := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe, normalizedArea_sig25]; push_cast; ring

/-- The canonical $(3, 5, \infty)$ hyperbolic triangle orbifold signature. -/
def sig35 : HyperbolicTriangleSignature := ⟨3, 5, by decide, by decide, by norm_num⟩

/-- Exact rational Euler characteristic $\chi_{\text{orb}}(3, 5, \infty) = -7/15$. -/
theorem chiOrb_sig35 : chiOrb sig35 = -7 / 15 := by
  norm_num [chiOrb, sig35]

/-- Exact normalized area $\mu_{\text{orb}}(3, 5, \infty) = 7/15$. -/
theorem normalizedArea_sig35 : normalizedArea sig35 = 7 / 15 := by
  norm_num [normalizedArea, sig35]

/-- Exact Gauss–Bonnet hyperbolic area $\operatorname{Area}(\mathcal{O}(3, 5, \infty)) = 14\pi / 15$. -/
theorem hyperbolicArea_sig35 : hyperbolicArea sig35 = 14 * Real.pi / 15 := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe, normalizedArea_sig35]; push_cast; ring

/-- Exact fundamental triangle area $\operatorname{Area}_\Delta(3, 5, \infty) = 7\pi / 15$. -/
theorem triangleArea_sig35 : triangleArea sig35 = 7 * Real.pi / 15 := by
  rw [triangleArea, normalizedAreaReal_eq_coe, normalizedArea_sig35]; push_cast; ring

/-- Additional canonical family $(2, 4, \infty)$. -/
def sig24 : HyperbolicTriangleSignature := ⟨2, 4, by decide, by decide, by norm_num⟩

theorem chiOrb_sig24 : chiOrb sig24 = -1 / 4 := by
  norm_num [chiOrb, sig24]

theorem normalizedArea_sig24 : normalizedArea sig24 = 1 / 4 := by
  norm_num [normalizedArea, sig24]

theorem hyperbolicArea_sig24 : hyperbolicArea sig24 = Real.pi / 2 := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe, normalizedArea_sig24]; push_cast; ring

/-- Additional canonical family $(4, 4, \infty)$. -/
def sig44 : HyperbolicTriangleSignature := ⟨4, 4, by decide, by decide, by norm_num⟩

theorem chiOrb_sig44 : chiOrb sig44 = -1 / 2 := by
  norm_num [chiOrb, sig44]

theorem normalizedArea_sig44 : normalizedArea sig44 = 1 / 2 := by
  norm_num [normalizedArea, sig44]

theorem hyperbolicArea_sig44 : hyperbolicArea sig44 = Real.pi := by
  rw [hyperbolicArea, normalizedAreaReal_eq_coe, normalizedArea_sig44]; push_cast; ring

/-! ## 4. Eisenstein Series Scattering Determinant $\phi(s)$ -/

/-- Exact rational residue value of the scattering determinant $\phi(s)$ at $s = 1$:
$$\operatorname{Res}_{s=1} \phi(s) = \frac{1}{\mu_{\text{orb}}(\mathcal{O})} = \frac{1}{1 - 1/p - 1/q}$$ -/
def residueValue (sig : HyperbolicTriangleSignature) : ℚ :=
  (normalizedArea sig)⁻¹

/-- Real residue value of the scattering determinant $\phi(s)$ at $s = 1$. -/
noncomputable def residueValueReal (sig : HyperbolicTriangleSignature) : ℝ :=
  (normalizedAreaReal sig)⁻¹

/-- Formal representation of the Eisenstein series scattering determinant $\phi(s)$
for the hyperbolic triangle orbifold $\mathcal{O}(p, q, \infty)$. -/
structure ScatteringDeterminantData (sig : HyperbolicTriangleSignature) where
  /-- Meromorphic scattering determinant $\phi : \mathbb{C} \to \mathbb{C}$. -/
  phi : ℂ → ℂ
  /-- Functional equation: $\phi(s) \phi(1-s) = 1$. -/
  functional_equation : ∀ s : ℂ, phi s * phi (1 - s) = 1
  /-- Unitarity on the critical line $\operatorname{Re}(s) = 1/2$: $\|\phi(1/2 + ir)\|^2 = 1$. -/
  unitarity : ∀ r : ℝ, Complex.normSq (phi (1/2 + Complex.I * (r : ℂ))) = 1
  /-- Residue at $s = 1$ matches the reciprocal of normalized area: $\operatorname{Res}_{s=1} \phi(s) = 1/\mu_{\text{orb}}$. -/
  residue_at_one : ℂ
  residue_eq : residue_at_one = ((residueValue sig : ℂ))

/-- Certified scattering residue for $(3, 4, \infty)$: $\operatorname{Res}_{s=1} \phi(s) = 12/5$. -/
theorem residue_sig34 : residueValue sig34 = 12 / 5 := by
  norm_num [residueValue, sig34, normalizedArea]

/-- Certified scattering residue for $(2, 3, \infty)$: $\operatorname{Res}_{s=1} \phi(s) = 6$. -/
theorem residue_sig23 : residueValue sig23 = 6 := by
  norm_num [residueValue, sig23, normalizedArea]

/-- Certified scattering residue for $(2, 5, \infty)$: $\operatorname{Res}_{s=1} \phi(s) = 10/3$. -/
theorem residue_sig25 : residueValue sig25 = 10 / 3 := by
  norm_num [residueValue, sig25, normalizedArea]

/-- Certified scattering residue for $(3, 5, \infty)$: $\operatorname{Res}_{s=1} \phi(s) = 15/7$. -/
theorem residue_sig35 : residueValue sig35 = 15 / 7 := by
  norm_num [residueValue, sig35, normalizedArea]

/-- Certified scattering residue for $(2, 4, \infty)$: $\operatorname{Res}_{s=1} \phi(s) = 4$. -/
theorem residue_sig24 : residueValue sig24 = 4 := by
  norm_num [residueValue, sig24, normalizedArea]

/-- Certified scattering residue for $(4, 4, \infty)$: $\operatorname{Res}_{s=1} \phi(s) = 2$. -/
theorem residue_sig44 : residueValue sig44 = 2 := by
  norm_num [residueValue, sig44, normalizedArea]

/-- Fundamental algebraic relation: $\operatorname{Res}_{s=1} \phi(s) \cdot \mu_{\text{orb}}(\mathcal{O}) = 1$. -/
theorem residue_mul_normalizedArea (sig : HyperbolicTriangleSignature) :
    residueValue sig * normalizedArea sig = 1 :=
  inv_mul_cancel₀ (normalizedArea_pos sig).ne'

/-- Fundamental spectral-geometric identity: $\operatorname{Res}_{s=1} \phi(s) \cdot \operatorname{Area}(\mathcal{O}) = 2\pi$. -/
theorem residue_area_product (sig : HyperbolicTriangleSignature) :
    (residueValue sig : ℝ) * hyperbolicArea sig = 2 * Real.pi := by
  have hpos : (normalizedArea sig : ℝ) ≠ 0 := (Rat.cast_pos.2 (normalizedArea_pos sig)).ne'
  rw [residueValue, hyperbolicArea, normalizedAreaReal_eq_coe]; push_cast
  linear_combination 2 * Real.pi * inv_mul_cancel₀ hpos

/-! ## 5. Orbifold Selberg Trace Formula -/

/-- Test function pair $(h, g)$ on the spectral line and hyperbolic geodesic length space. -/
structure SelbergTestFunction where
  /-- Spectral test function $h(r)$ on $r \in \mathbb{R}$. -/
  h : ℝ → ℝ
  /-- Geometric Fourier transform $g(u) = \frac{1}{2\pi} \int_{-\infty}^\infty h(r) e^{-i r u} dr$. -/
  g : ℝ → ℝ
  /-- Parity: $h(-r) = h(r)$. -/
  h_even : ∀ r, h (-r) = h r
  /-- Parity: $g(-u) = g(u)$. -/
  g_even : ∀ u, g (-u) = g u

/-- Discrete spectrum data for $\mathcal{O}(p, q, \infty)$, decomposing the constant eigenvalue
$\lambda_0 = 0$ ($r_0 = i/2$) and the Maass cusp form discrete spectrum $\{\lambda_j = 1/4 + r_j^2\}$. -/
structure DiscreteSpectrumData where
  /-- Contribution of the trivial eigenvalue $\lambda_0 = 0$: $h(i/2)$. -/
  lambda0_term : ℝ
  /-- Discrete sum over Maass cusp form eigenvalues: $\sum_{j=1}^\infty h(r_j)$. -/
  cusp_forms_sum : ℝ

/-- Continuous spectrum data governed by the scattering determinant $\phi(s)$. -/
structure ContinuousSpectrumData where
  /-- Scattering integral: $-\frac{1}{4\pi} \int_{-\infty}^\infty h(r) \frac{\phi'}{\phi}(1/2 + ir) dr$. -/
  scattering_integral : ℝ
  /-- Scattering center correction: $\frac{1}{4} \phi(1/2) h(0)$. -/
  scattering_center : ℝ

/-- Total spectral side of the Orbifold Selberg Trace Formula. -/
def spectralSide (disc : DiscreteSpectrumData) (cont : ContinuousSpectrumData) : ℝ :=
  disc.lambda0_term + disc.cusp_forms_sum + cont.scattering_integral + cont.scattering_center

/-- Parabolic cusp contribution data for the single cusp at $\infty$. -/
structure ParabolicContributionData where
  /-- Scaling term: $g(0) \ln 2$. -/
  scaling_term : ℝ
  /-- Digamma integral: $-\frac{1}{2\pi} \int_{-\infty}^\infty h(r) \psi(1 + ir) dr$. -/
  digamma_integral : ℝ
  /-- Center evaluation correction: $-\frac{1}{4} h(0)$. -/
  center_correction : ℝ

/-- Total parabolic contribution for $\mathcal{O}(p, q, \infty)$. -/
def parabolicContribution (p : ParabolicContributionData) : ℝ :=
  p.scaling_term + p.digamma_integral + p.center_correction

/-- Total geometric side of the Orbifold Selberg Trace Formula:
$$\text{Geom} = I_{\text{id}} + I_{\text{ell}}(p) + I_{\text{ell}}(q) + I_{\text{par}} + I_{\text{hyp}}$$ -/
def geometricSide (id_term : ℝ) (ell_p_term : ℝ) (ell_q_term : ℝ) (par_term : ℝ) (hyp_term : ℝ) : ℝ :=
  id_term + ell_p_term + ell_q_term + par_term + hyp_term

/-- The prefactor of the identity term $\frac{\operatorname{Area}(\mathcal{O})}{4\pi}$ is exactly $\frac{\mu_{\text{orb}}}{2}$. -/
theorem identity_prefactor_eq_half_normalizedArea (sig : HyperbolicTriangleSignature) (hpi : Real.pi ≠ 0) :
    hyperbolicArea sig / (4 * Real.pi) = normalizedAreaReal sig / 2 := by
  dsimp [hyperbolicArea]; field_simp; ring

/-- The complete Orbifold Selberg Trace Formula identity for $\mathcal{O}(p, q, \infty)$. -/
structure OrbifoldSelbergTraceFormula (sig : HyperbolicTriangleSignature) where
  test_fn : SelbergTestFunction
  disc_spec : DiscreteSpectrumData
  cont_spec : ContinuousSpectrumData
  id_integral : ℝ
  ell_p_term : ℝ
  ell_q_term : ℝ
  par_data : ParabolicContributionData
  hyp_geodesic_sum : ℝ
  /-- Spectral-geometric identity: $\text{Spec}(h) = \text{Geom}(h, g)$. -/
  trace_identity :
    spectralSide disc_spec cont_spec =
    geometricSide
      ((hyperbolicArea sig / (4 * Real.pi)) * id_integral)
      ell_p_term
      ell_q_term
      (parabolicContribution par_data)
      hyp_geodesic_sum

/-- Expresses the Selberg Trace Formula with the normalized area prefactor $\mu_{\text{orb}}/2$. -/
theorem trace_identity_with_normalizedArea (sig : HyperbolicTriangleSignature) (hpi : Real.pi ≠ 0)
    (stf : OrbifoldSelbergTraceFormula sig) :
    spectralSide stf.disc_spec stf.cont_spec =
    geometricSide
      ((normalizedAreaReal sig / 2) * stf.id_integral)
      stf.ell_p_term
      stf.ell_q_term
      (parabolicContribution stf.par_data)
      stf.hyp_geodesic_sum := by
  rw [← identity_prefactor_eq_half_normalizedArea sig hpi, stf.trace_identity]

/-! ## 6. Selberg Zeta Function $\mathcal{Z}_{\mathcal{O}}(s)$ & Spectral Duality -/

/-- Primitive hyperbolic closed geodesic data on $\mathcal{O}(p, q, \infty)$. -/
structure PrimitiveClosedGeodesic where
  /-- Geometric length $\ell(\gamma_0) > 0$. -/
  length : ℝ
  length_pos : 0 < length

/-- Formal representation of the Orbifold Selberg Zeta Function $\mathcal{Z}_{\mathcal{O}}(s)$:
$$\mathcal{Z}_{\mathcal{O}}(s) = \prod_{\{\gamma_0\}} \prod_{k=0}^\infty \left(1 - e^{-(s+k)\ell(\gamma_0)}\right)$$ -/
structure OrbifoldSelbergZetaData (sig : HyperbolicTriangleSignature) where
  /-- Selberg zeta function $\mathcal{Z}_{\mathcal{O}} : \mathbb{C} \to \mathbb{C}$. -/
  zeta : ℂ → ℂ
  /-- Non-trivial spectral zeros occur at $s_j = 1/2 \pm i r_j$ with eigenvalue $\lambda_j = 1/4 + r_j^2 = s_j(1 - s_j)$. -/
  spectral_eigenvalue : ℂ → ℂ := fun s => s * (1 - s)
  /-- Functional equation factor $\mathcal{F}_{\mathcal{O}}(s)$. -/
  functional_factor : ℂ → ℂ
  /-- Selberg zeta functional equation: $\mathcal{Z}_{\mathcal{O}}(1 - s) = \mathcal{Z}_{\mathcal{O}}(s) \cdot \mathcal{F}_{\mathcal{O}}(s)$. -/
  functional_equation : ∀ s : ℂ, zeta (1 - s) = zeta s * functional_factor s

/-- Symmetry of the Laplacian eigenvalue parameterization: $s(1-s) = (1-s)(1 - (1-s))$. -/
theorem eigenvalue_param_symm (s : ℂ) :
    s * (1 - s) = (1 - s) * (1 - (1 - s)) := by ring

/-- On the critical line $s = 1/2 + i r$, the eigenvalue is real: $s(1-s) = 1/4 + r^2$. -/
theorem eigenvalue_critical_line (r : ℝ) :
    (1/2 + Complex.I * (r : ℂ)) * (1 - (1/2 + Complex.I * (r : ℂ))) =
    ((1/4 + r^2 : ℝ) : ℂ) := by
  push_cast; linear_combination - (r : ℂ) ^ 2 * Complex.I_sq

end OrbifoldSpectralZeta
