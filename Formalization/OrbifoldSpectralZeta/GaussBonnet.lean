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
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

set_option linter.unusedSectionVars false

/-!
# Hyperbolic Triangle Orbifold Signatures & Gauss–Bonnet Hyperbolic Area

This submodule formalizes the topological and geometric foundation of 1-cusped hyperbolic
2-orbifolds $\mathcal{O}(p, q, \infty) = \Delta(p, q, \infty) \backslash \mathbb{H}$.

## Mathematical Overview

### 1. Hyperbolic Triangle Orbifold Signatures

A 1-cusped hyperbolic triangle orbifold $\mathcal{O}(p, q, \infty)$ is characterized by a signature
$(p, q, \infty)$ where $p, q \in \mathbb{N}_{\ge 2}$ are the orders of the two conical singular points.
The hyperbolic condition requires:
$$\frac{1}{p} + \frac{1}{q} < 1 \iff p + q < p q$$
guaranteeing that the underlying universal covering space is the Poincaré upper half-plane $\mathbb{H}$.

### 2. Orbifold Euler Characteristic & Gauss–Bonnet Area

For an orbifold with conical singularities of orders $p, q$ and one parabolic cusp ($r = \infty$),
the rational orbifold Euler characteristic is given by:
$$\chi_{\text{orb}}(\mathcal{O}(p, q, \infty)) = \frac{1}{p} + \frac{1}{q} - 1 < 0$$
The normalized hyperbolic area $\mu_{\text{orb}} \in \mathbb{Q}_{>0}$ is the negative of the Euler characteristic:
$$\mu_{\text{orb}}(\mathcal{O}(p, q, \infty)) = -\chi_{\text{orb}} = 1 - \frac{1}{p} - \frac{1}{q} > 0$$

By the Gauss–Bonnet theorem for hyperbolic 2-orbifolds with constant curvature $K = -1$:
$$\operatorname{Area}(\mathcal{O}(p, q, \infty)) = -2\pi \chi_{\text{orb}} = 2\pi \mu_{\text{orb}} = 2\pi \left(1 - \frac{1}{p} - \frac{1}{q}\right)$$
which is exactly twice the area of the fundamental hyperbolic triangle:
$$\operatorname{Area}_\Delta(p, q, \infty) = \pi \left(1 - \frac{1}{p} - \frac{1}{q}\right)$$

### 3. Machine-Certified Exact Values

We certify exact rational and real area values for key arithmetic and geometric families:
- $(3, 4, \infty)$: $\chi_{\text{orb}} = -5/12,\; \mu_{\text{orb}} = 5/12,\; \operatorname{Area} = 5\pi/6$
- $(2, 3, \infty)$: $\chi_{\text{orb}} = -1/6,\; \mu_{\text{orb}} = 1/6,\; \operatorname{Area} = \pi/3$
- $(2, 5, \infty)$: $\chi_{\text{orb}} = -3/10,\; \mu_{\text{orb}} = 3/10,\; \operatorname{Area} = 3\pi/5$
- $(3, 5, \infty)$: $\chi_{\text{orb}} = -7/15,\; \mu_{\text{orb}} = 7/15,\; \operatorname{Area} = 14\pi/15,\; \operatorname{Area}_\Delta = 7\pi/15$
- $(2, 4, \infty)$: $\chi_{\text{orb}} = -1/4,\; \mu_{\text{orb}} = 1/4,\; \operatorname{Area} = \pi/2$
- $(4, 4, \infty)$: $\chi_{\text{orb}} = -1/2,\; \mu_{\text{orb}} = 1/2,\; \operatorname{Area} = \pi$

## Main Declarations

- `OrbifoldSpectralZeta.HyperbolicTriangleSignature`: Structure bundling cone orders $p, q \ge 2$ with $1/p + 1/q < 1$.
- `OrbifoldSpectralZeta.hyperbolic_iff_mul`: Equivalence of $1/p + 1/q < 1$ with $p + q < pq$.
- `OrbifoldSpectralZeta.chiOrb`: Rational orbifold Euler characteristic.
- `OrbifoldSpectralZeta.normalizedArea`: Normalized rational area $\mu_{\text{orb}} = -\chi_{\text{orb}}$.
- `OrbifoldSpectralZeta.hyperbolicArea`: Gauss–Bonnet Riemannian hyperbolic area $2\pi \mu_{\text{orb}}$.
- `OrbifoldSpectralZeta.gauss_bonnet_area`: Theorem relating hyperbolic area to $-2\pi \chi_{\text{orb}}$.
- `OrbifoldSpectralZeta.sig34`, `OrbifoldSpectralZeta.sig23`, `OrbifoldSpectralZeta.sig25`, `OrbifoldSpectralZeta.sig35`: Canonical signatures and certified area theorems.
-/

namespace OrbifoldSpectralZeta

/-! ### 1. Hyperbolic Triangle Orbifold Signatures -/

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

/-! ### 2. Orbifold Euler Characteristic & Gauss–Bonnet Hyperbolic Area -/

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

/-! ### 3. Machine-Proved Certified Exact Values for Canonical Families -/

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

end OrbifoldSpectralZeta
