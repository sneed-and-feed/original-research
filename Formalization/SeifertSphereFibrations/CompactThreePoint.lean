/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SeifertSphereFibrations.CoprimeSolvability

/-!
# Compact 3-Point Seifert Fibrations & Brieskorn Homology Spheres

This submodule formalizes the Seifert invariants and sphere-yielding classifications for
compact 3-manifold total spaces fibered over closed 2-orbifolds $S^2(a_1, a_2, a_3)$ with
three conical singularities of pairwise coprime orders.

## Mathematical Overview

For a compact Seifert fibration over $S^2(a_1, a_2, a_3)$ with translation parameters
$(\ell_0, \ell_1, \ell_2, \ell_3) \in \mathbb{Z}^4$, the Seifert invariant order formula is:
$$O_3(a_1, a_2, a_3; \ell_0, \ell_1, \ell_2, \ell_3) = a_1 a_2 a_3 \ell_0 - a_2 a_3 \ell_1 - a_1 a_3 \ell_2 - a_1 a_2 \ell_3$$

The manifold is a homology sphere if and only if:
$$|O_3(a_1, a_2, a_3; \ell_0, \ell_1, \ell_2, \ell_3)| = 1$$

When $a_1, a_2, a_3$ are pairwise coprime, an iterated Bézout construction produces an explicit
integer solution yielding $|O_3| = 1$. Conversely, any common divisor between a pair of cone orders
divides $O_3$, creating a non-coprime obstruction.

This framework directly covers classical Brieskorn homology spheres:
- Poincaré Homology Sphere $\Sigma(2, 3, 5) = M(2, 3, 5)$
- Brieskorn Sphere $\Sigma(2, 3, 7) = M(2, 3, 7)$

## Main Declarations

- `SeifertFibration.seifertOrder3`: Order formula $a_1 a_2 a_3 \ell_0 - a_2 a_3 \ell_1 - a_1 a_3 \ell_2 - a_1 a_2 \ell_3$.
- `SeifertFibration.IsHomotopySphere3`: Predicate $|O_3(a_1, a_2, a_3; \dots)| = 1$.
- `SeifertFibration.coprime_mul_of_coprime_pair`: Coprimality lemma $\gcd(a_1, a_3)=1 \wedge \gcd(a_2, a_3)=1 \implies \gcd(a_3, a_1 a_2)=1$.
- `SeifertFibration.seifertOrder3_bezout`: Iterated Bézout evaluation formula.
- `SeifertFibration.pairwise_coprime_exists_sphere3`: Pairwise coprime existence theorem for 3-point fibrations.
- `SeifertFibration.dvd_seifertOrder3_of_dvd_12`: Divisibility of $O_3$ by common divisor $d \mid a_1, d \mid a_2$.
- `SeifertFibration.noncoprime_obstruction3_12`: Non-coprime obstruction for 3-point fibrations.
- `SeifertFibration.brieskorn_sphere_2_3_5`: Poincaré sphere $\Sigma(2, 3, 5)$ certificate with twists $(1, 1, 1, 1)$.
- `SeifertFibration.brieskorn_sphere_2_3_7`: Brieskorn sphere $\Sigma(2, 3, 7)$ certificate with twists $(1, 1, 1, 1)$.
-/

namespace SeifertFibration

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
