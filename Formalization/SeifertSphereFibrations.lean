/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Int.GCD
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Tactic.Ring

/-!
# Diophantine Classification of Sphere-Yielding Seifert Fibrations (Direction 1)

This module formalizes the Diophantine classification of sphere-yielding Seifert fibrations
over 2-orbifold bases with a cusp and compact 3-point Seifert fibered homology spheres.

## Mathematical Context

A Seifert fibered 3-manifold with base orbifold $S^2(a_1, a_2, \infty)$ (two conical singularities
with cone angles $2\pi/a_1, 2\pi/a_2$ and one parabolic cusp) has fundamental group presentation
governed by the central Seifert invariant:
$$O(a_1, a_2; \ell_0, \ell_1, \ell_2) = a_1 a_2 \ell_0 - a_2 \ell_1 - a_1 \ell_2$$
The manifold is a homotopy sphere (or trivial fundamental group contractible cycle) if and only if:
$$|O(a_1, a_2; \ell_0, \ell_1, \ell_2)| = 1$$

## Main Theorems

1. **Coprime Solvability / Bézout Existence (`coprime_exists_sphere`)**:
   For any integers $a_1, a_2$ with $\gcd(a_1, a_2) = 1$, there exist integer translation twists
   $(\ell_0, \ell_1, \ell_2)$ such that $|O(a_1, a_2; \ell_0, \ell_1, \ell_2)| = 1$, explicitly constructed
   via Bézout coefficients $(\ell_0, \ell_1, \ell_2) = (0, -\operatorname{gcdB}(a_1, a_2), -\operatorname{gcdA}(a_1, a_2))$.

2. **Non-Coprime Obstruction (`noncoprime_obstruction`)**:
   If $d > 1$ divides both $a_1$ and $a_2$, then $d \mid O(a_1, a_2; \ell_0, \ell_1, \ell_2)$ for all
   translation twists $(\ell_0, \ell_1, \ell_2)$, precluding any homotopy sphere solutions.

3. **Canonical Hyperbolic Triangle Families**:
   Explicit sphere-yielding solutions for the canonical modular/hyperbolic families:
   - $(2, 3, \infty)$ with $(0, 1, -1) \implies |6(0) - 3(1) - 2(-1)| = |-1| = 1$.
   - $(3, 4, \infty)$ with $(0, 1, -1) \implies |12(0) - 4(1) - 3(-1)| = 1$.
   - $(2, 5, \infty)$ with $(0, 1, -2) \implies |10(0) - 5(1) - 2(-2)| = 1$.
   - $(3, 5, \infty)$ with $(0, 1, -2) \implies |15(0) - 5(1) - 3(-2)| = 1$.

4. **Extension to 3-Point Compact Seifert Fibrations (`pairwise_coprime_exists_sphere3`)**:
   For compact Seifert fibrations over $S^2(a_1, a_2, a_3)$, the order formula:
   $$O_3(a_1, a_2, a_3; \ell_0, \ell_1, \ell_2, \ell_3) = a_1 a_2 a_3 \ell_0 - a_2 a_3 \ell_1 - a_1 a_3 \ell_2 - a_1 a_2 \ell_3$$
   admits a sphere solution if $(a_1, a_2, a_3)$ are pairwise coprime.
-/

namespace SeifertFibration

/-! ### 1. Two-Orbifold Point + 1 Cusp Seifert Invariants -/

/-- The Seifert invariant order formula for 2 orbifold cone points $(a_1, a_2)$ and 1 cusp. -/
def seifertOrder (a1 a2 l0 l1 l2 : ℤ) : ℤ :=
  a1 * a2 * l0 - a2 * l1 - a1 * l2

/-- Homotopy sphere condition: the Seifert order has absolute value equal to 1. -/
def IsHomotopySphere (a1 a2 l0 l1 l2 : ℤ) : Prop :=
  |seifertOrder a1 a2 l0 l1 l2| = 1

/-- Explicit Bézout witness constructor for translation twists from $(a_1, a_2)$. -/
def coprimeWitnesses (a1 a2 : ℤ) : ℤ × ℤ × ℤ :=
  (0, -Int.gcdB a1 a2, -Int.gcdA a1 a2)

/-- The Seifert order evaluated at the explicit Bézout witnesses reproduces $\gcd(a_1, a_2)$. -/
theorem seifertOrder_bezout (a1 a2 : ℤ) :
    seifertOrder a1 a2 0 (-Int.gcdB a1 a2) (-Int.gcdA a1 a2) = (a1.gcd a2 : ℤ) := by
  dsimp [seifertOrder]
  rw [Int.gcd_eq_gcd_ab]
  ring

/-- The explicit witness function evaluates to $\gcd(a_1, a_2)$. -/
theorem seifertOrder_coprimeWitnesses (a1 a2 : ℤ) :
    let (l0, l1, l2) := coprimeWitnesses a1 a2
    seifertOrder a1 a2 l0 l1 l2 = (a1.gcd a2 : ℤ) := by
  exact seifertOrder_bezout a1 a2

/-! ### 2. Theorem 1: Coprime Solvability / Bézout Existence -/

/-- **Theorem 1 (Coprime Solvability / Bézout Existence)**:
    If $\gcd(a_1, a_2) = 1$, then there exist integer translation twists $(\ell_0, \ell_1, \ell_2)$
    such that the resulting Seifert fibration is a homotopy sphere. -/
theorem coprime_exists_sphere {a1 a2 : ℤ} (h : a1.gcd a2 = 1) :
    ∃ l0 l1 l2 : ℤ, IsHomotopySphere a1 a2 l0 l1 l2 := by
  use 0, -Int.gcdB a1 a2, -Int.gcdA a1 a2
  dsimp [IsHomotopySphere]
  rw [seifertOrder_bezout, h]
  rfl

/-- Explicit constructive witness version of Theorem 1: the Bézout witnesses yield a homotopy sphere. -/
theorem coprime_witnesses_isHomotopySphere {a1 a2 : ℤ} (h : a1.gcd a2 = 1) :
    let (l0, l1, l2) := coprimeWitnesses a1 a2
    IsHomotopySphere a1 a2 l0 l1 l2 := by
  dsimp [IsHomotopySphere, coprimeWitnesses]
  rw [seifertOrder_bezout, h]
  rfl

/-- Formulation using `Nat.Coprime` on integer absolute values. -/
theorem coprime_natAbs_exists_sphere {a1 a2 : ℤ} (h : Nat.Coprime a1.natAbs a2.natAbs) :
    ∃ l0 l1 l2 : ℤ, IsHomotopySphere a1 a2 l0 l1 l2 :=
  coprime_exists_sphere h

/-! ### 3. Theorem 2: Non-Coprime Obstruction -/

/-- Divisibility lemma: any common divisor $d$ of $a_1$ and $a_2$ divides the Seifert order. -/
theorem dvd_seifertOrder {d a1 a2 l0 l1 l2 : ℤ} (h1 : d ∣ a1) (h2 : d ∣ a2) :
    d ∣ seifertOrder a1 a2 l0 l1 l2 := by
  dsimp [seifertOrder]
  rcases h1 with ⟨k1, rfl⟩
  rcases h2 with ⟨k2, rfl⟩
  use k1 * (d * k2) * l0 - k2 * l1 - k1 * l2
  ring

/-- An integer $d > 1$ cannot divide $1$. -/
theorem not_dvd_one_of_gt_one {d : ℤ} (hd : 1 < d) : ¬ (d ∣ 1) := by
  intro h
  have : d ≤ 1 := Int.le_of_dvd (by omega) h
  omega

/-- An integer $d > 1$ cannot divide $-1$. -/
theorem not_dvd_neg_one_of_gt_one {d : ℤ} (hd : 1 < d) : ¬ (d ∣ -1) := by
  intro ⟨k, hk⟩
  have hk' : 1 = d * (-k) := by
    calc 1 = -(-1) := by ring
    _ = -(d * k) := by rw [hk]
    _ = d * -k := by ring
  have h1 : d ∣ 1 := ⟨-k, hk'⟩
  exact not_dvd_one_of_gt_one hd h1

/-- **Theorem 2 (Non-Coprime Obstruction)**:
    If $d > 1$ divides both $a_1$ and $a_2$, then for ANY integer twists $(\ell_0, \ell_1, \ell_2)$,
    $d \mid O(a_1, a_2; \ell_0, \ell_1, \ell_2)$ and therefore the manifold CANNOT be a homotopy sphere. -/
theorem noncoprime_obstruction {d a1 a2 : ℤ} (hd : 1 < d) (h1 : d ∣ a1) (h2 : d ∣ a2)
    (l0 l1 l2 : ℤ) :
    d ∣ seifertOrder a1 a2 l0 l1 l2 ∧ ¬ IsHomotopySphere a1 a2 l0 l1 l2 := by
  have hdvd := dvd_seifertOrder h1 h2 (l0 := l0) (l1 := l1) (l2 := l2)
  refine ⟨hdvd, ?_⟩
  intro h_sphere
  dsimp [IsHomotopySphere] at h_sphere
  have h_cases : seifertOrder a1 a2 l0 l1 l2 = 1 ∨ seifertOrder a1 a2 l0 l1 l2 = -1 := by
    obtain h | h := abs_choice (seifertOrder a1 a2 l0 l1 l2)
    · rw [h] at h_sphere
      exact Or.inl h_sphere
    · rw [h] at h_sphere
      exact Or.inr (by omega)
  rcases h_cases with h | h
  · rw [h] at hdvd
    exact not_dvd_one_of_gt_one hd hdvd
  · rw [h] at hdvd
    exact not_dvd_neg_one_of_gt_one hd hdvd

/-! ### 4. Theorem 3: Canonical Hyperbolic Triangle Families -/

/-- Canonical hyperbolic triangle family $(2, 3, \infty)$ yields a homotopy sphere with twists $(0, 1, -1)$:
    $|2 \cdot 3 \cdot 0 - 3 \cdot 1 - 2 \cdot (-1)| = |-1| = 1$. -/
theorem sphere_2_3_infty : IsHomotopySphere 2 3 0 1 (-1) := by
  dsimp [IsHomotopySphere, seifertOrder]
  rfl

/-- Canonical hyperbolic triangle family $(3, 4, \infty)$ yields a homotopy sphere with twists $(0, 1, -1)$:
    $|3 \cdot 4 \cdot 0 - 4 \cdot 1 - 3 \cdot (-1)| = |-1| = 1$. -/
theorem sphere_3_4_infty : IsHomotopySphere 3 4 0 1 (-1) := by
  dsimp [IsHomotopySphere, seifertOrder]
  rfl

/-- Canonical hyperbolic triangle family $(2, 5, \infty)$ yields a homotopy sphere with twists $(0, 1, -2)$:
    $|2 \cdot 5 \cdot 0 - 5 \cdot 1 - 2 \cdot (-2)| = |-1| = 1$. -/
theorem sphere_2_5_infty : IsHomotopySphere 2 5 0 1 (-2) := by
  dsimp [IsHomotopySphere, seifertOrder]
  rfl

/-- Canonical hyperbolic triangle family $(3, 5, \infty)$ yields a homotopy sphere with twists $(0, 1, -2)$:
    $|3 \cdot 5 \cdot 0 - 5 \cdot 1 - 3 \cdot (-2)| = |1| = 1$. -/
theorem sphere_3_5_infty : IsHomotopySphere 3 5 0 1 (-2) := by
  dsimp [IsHomotopySphere, seifertOrder]
  rfl

/-! ### 5. Extension: General 3-Point Compact Seifert Fibrations -/

/-- Seifert invariant order formula for 3-point compact Seifert fibered manifolds over $S^2(a_1, a_2, a_3)$. -/
def seifertOrder3 (a1 a2 a3 l0 l1 l2 l3 : ℤ) : ℤ :=
  a1 * a2 * a3 * l0 - a2 * a3 * l1 - a1 * a3 * l2 - a1 * a2 * l3

/-- Homotopy sphere condition for 3-point compact Seifert fibered manifolds. -/
def IsHomotopySphere3 (a1 a2 a3 l0 l1 l2 l3 : ℤ) : Prop :=
  |seifertOrder3 a1 a2 a3 l0 l1 l2 l3| = 1

/-- If $a_3$ is coprime to both $a_1$ and $a_2$, it is coprime to their product $a_1 a_2$. -/
theorem coprime_mul_of_coprime_pair {a1 a2 a3 : ℤ}
    (h13 : a1.gcd a3 = 1) (h23 : a2.gcd a3 = 1) :
    a3.gcd (a1 * a2) = 1 := by
  have h13' : a3.natAbs.Coprime a1.natAbs := Nat.Coprime.symm h13
  have h23' : a3.natAbs.Coprime a2.natAbs := Nat.Coprime.symm h23
  have h_mul : a3.natAbs.Coprime (a1.natAbs * a2.natAbs) := Nat.Coprime.mul_right h13' h23'
  rw [← Int.natAbs_mul] at h_mul
  exact h_mul

/-- Explicit Bézout evaluation for 3-point Seifert fibration order formula. -/
theorem seifertOrder3_bezout (a1 a2 a3 : ℤ) (h12 : a1.gcd a2 = 1) :
    seifertOrder3 a1 a2 a3 0
      (-(Int.gcdA a3 (a1 * a2) * Int.gcdB a1 a2))
      (-(Int.gcdA a3 (a1 * a2) * Int.gcdA a1 a2))
      (-(Int.gcdB a3 (a1 * a2)))
    = (a3.gcd (a1 * a2) : ℤ) := by
  dsimp [seifertOrder3]
  have h_ab12 : (a1.gcd a2 : ℤ) = a1 * Int.gcdA a1 a2 + a2 * Int.gcdB a1 a2 :=
    Int.gcd_eq_gcd_ab a1 a2
  have h_ab3 : (a3.gcd (a1 * a2) : ℤ) = a3 * Int.gcdA a3 (a1 * a2) + (a1 * a2) * Int.gcdB a3 (a1 * a2) :=
    Int.gcd_eq_gcd_ab a3 (a1 * a2)
  rw [h12] at h_ab12
  norm_cast at h_ab12
  calc
    a1 * a2 * a3 * 0 - a2 * a3 * -(Int.gcdA a3 (a1 * a2) * Int.gcdB a1 a2) -
        a1 * a3 * -(Int.gcdA a3 (a1 * a2) * Int.gcdA a1 a2) -
        a1 * a2 * -Int.gcdB a3 (a1 * a2)
    _ = a3 * Int.gcdA a3 (a1 * a2) * (a1 * Int.gcdA a1 a2 + a2 * Int.gcdB a1 a2) + (a1 * a2) * Int.gcdB a3 (a1 * a2) := by ring
    _ = a3 * Int.gcdA a3 (a1 * a2) * 1 + (a1 * a2) * Int.gcdB a3 (a1 * a2) := by rw [h_ab12]
    _ = a3 * Int.gcdA a3 (a1 * a2) + (a1 * a2) * Int.gcdB a3 (a1 * a2) := by ring
    _ = (a3.gcd (a1 * a2) : ℤ) := h_ab3.symm

/-- **Extension Theorem (Pairwise Coprime Solvability for 3-Point Seifert Fibrations)**:
    If $(a_1, a_2, a_3)$ are pairwise coprime integers, then there exist integer translation twists
    $(\ell_0, \ell_1, \ell_2, \ell_3)$ such that the 3-point Seifert fibration is a homotopy sphere. -/
theorem pairwise_coprime_exists_sphere3 {a1 a2 a3 : ℤ}
    (h12 : a1.gcd a2 = 1) (h23 : a2.gcd a3 = 1) (h13 : a1.gcd a3 = 1) :
    ∃ l0 l1 l2 l3 : ℤ, IsHomotopySphere3 a1 a2 a3 l0 l1 l2 l3 := by
  use 0,
    -(Int.gcdA a3 (a1 * a2) * Int.gcdB a1 a2),
    -(Int.gcdA a3 (a1 * a2) * Int.gcdA a1 a2),
    -(Int.gcdB a3 (a1 * a2))
  dsimp [IsHomotopySphere3]
  have h_cop : a3.gcd (a1 * a2) = 1 := coprime_mul_of_coprime_pair h13 h23
  rw [seifertOrder3_bezout a1 a2 a3 h12, h_cop]
  rfl

/-- Common divisor obstruction for 3-point Seifert fibrations: if $d \mid a_1$ and $d \mid a_2$, then $d \mid O_3$. -/
theorem dvd_seifertOrder3_of_dvd_12 {d a1 a2 a3 l0 l1 l2 l3 : ℤ}
    (h1 : d ∣ a1) (h2 : d ∣ a2) :
    d ∣ seifertOrder3 a1 a2 a3 l0 l1 l2 l3 := by
  dsimp [seifertOrder3]
  rcases h1 with ⟨k1, rfl⟩
  rcases h2 with ⟨k2, rfl⟩
  use k1 * (d * k2) * a3 * l0 - k2 * a3 * l1 - k1 * a3 * l2 - k1 * (d * k2) * l3
  ring

/-- **Theorem (Non-Coprime Obstruction for 3-Point Seifert Fibrations)**:
    If $d > 1$ divides any pair (e.g. $a_1$ and $a_2$), then $d \mid O_3$ for all twists,
    preventing the manifold from being a homotopy sphere. -/
theorem noncoprime_obstruction3_12 {d a1 a2 a3 : ℤ} (hd : 1 < d)
    (h1 : d ∣ a1) (h2 : d ∣ a2) (l0 l1 l2 l3 : ℤ) :
    d ∣ seifertOrder3 a1 a2 a3 l0 l1 l2 l3 ∧ ¬ IsHomotopySphere3 a1 a2 a3 l0 l1 l2 l3 := by
  have hdvd := dvd_seifertOrder3_of_dvd_12 (a3 := a3) (l0 := l0) (l1 := l1) (l2 := l2) (l3 := l3) h1 h2
  refine ⟨hdvd, ?_⟩
  intro h_sphere
  dsimp [IsHomotopySphere3] at h_sphere
  have h_cases : seifertOrder3 a1 a2 a3 l0 l1 l2 l3 = 1 ∨ seifertOrder3 a1 a2 a3 l0 l1 l2 l3 = -1 := by
    obtain h | h := abs_choice (seifertOrder3 a1 a2 a3 l0 l1 l2 l3)
    · rw [h] at h_sphere
      exact Or.inl h_sphere
    · rw [h] at h_sphere
      exact Or.inr (by omega)
  rcases h_cases with h | h
  · rw [h] at hdvd
    exact not_dvd_one_of_gt_one hd hdvd
  · rw [h] at hdvd
    exact not_dvd_neg_one_of_gt_one hd hdvd

/-! ### 6. Canonical Brieskorn Homology Spheres -/

/-- Poincaré Homology Sphere $\Sigma(2, 3, 5)$ with twists $(1, 1, 1, 1)$:
    $|30(1) - 15(1) - 10(1) - 6(1)| = |30 - 31| = |-1| = 1$. -/
theorem brieskorn_sphere_2_3_5 : IsHomotopySphere3 2 3 5 1 1 1 1 := by
  dsimp [IsHomotopySphere3, seifertOrder3]
  rfl

/-- Brieskorn Homology Sphere $\Sigma(2, 3, 7)$ with twists $(1, 1, 1, 1)$:
    $|42(1) - 21(1) - 14(1) - 6(1)| = |42 - 41| = |1| = 1$. -/
theorem brieskorn_sphere_2_3_7 : IsHomotopySphere3 2 3 7 1 1 1 1 := by
  dsimp [IsHomotopySphere3, seifertOrder3]
  rfl

end SeifertFibration
