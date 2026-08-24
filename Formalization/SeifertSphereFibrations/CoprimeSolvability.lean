/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SeifertSphereFibrations.Basic
import Mathlib.Tactic.Ring

/-!
# Coprime Solvability & Non-Coprime Obstructions for 2-Orbifold Seifert Fibrations

This submodule establishes the complete Diophantine classification for 2-orbifold Seifert fibrations
over $S^2(a_1, a_2, \infty)$:
1. **Solvability / Bézout Existence**: When $\gcd(a_1, a_2) = 1$, explicit translation twists
   derived from the Euclidean algorithm guarantee that the total space is a homology sphere.
2. **Non-Coprime Obstruction**: When $\gcd(a_1, a_2) = d > 1$, any common divisor divides the
   order invariant $O(a_1, a_2; \ell_0, \ell_1, \ell_2)$, strictly precluding homotopy sphere solutions.

## Main Declarations

- `SeifertFibration.coprime_exists_sphere`: Existence of homotopy sphere twists when $\gcd(a_1, a_2) = 1$.
- `SeifertFibration.coprime_witnesses_isHomotopySphere`: Constructive certification using Bézout witnesses.
- `SeifertFibration.coprime_natAbs_exists_sphere`: Reformulation using `Nat.Coprime`.
- `SeifertFibration.dvd_seifertOrder`: Common divisors $d \mid a_1, d \mid a_2$ divide $O(a_1, a_2; \dots)$.
- `SeifertFibration.not_dvd_one_of_gt_one`: Non-divisibility lemma $d > 1 \implies \neg (d \mid 1)$.
- `SeifertFibration.not_dvd_neg_one_of_gt_one`: Non-divisibility lemma $d > 1 \implies \neg (d \mid -1)$.
- `SeifertFibration.noncoprime_obstruction`: The obstruction theorem proving no homotopy sphere can exist when $d > 1$.
-/

namespace SeifertFibration

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

end SeifertFibration
