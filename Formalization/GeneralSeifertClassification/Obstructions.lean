/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.GeneralSeifertClassification.Cofactors
import Mathlib.Data.Int.GCD
import Mathlib.Algebra.Order.Group.Abs

/-!
# Common Divisor Obstructions for General Seifert Fibrations

This module formalizes the universal common divisor obstruction: if any two multiplicity
indices share a common factor $d > 1$, then $d$ divides every cofactor product and thus
divides the Seifert order invariant $O_k(a; \ell_0, \ell)$ for all integer twists $(\ell_0, \ell)$,
ruling out homology sphere solutions.

## Main Theorems
- `GeneralSeifert.common_divisor_dvd_cofactor`: Common factor $d \mid a_i, a_j$ ($i \ne j$) divides every cofactor $A_m$.
- `GeneralSeifert.common_divisor_dvd_cofactorGCD`: Common factor divides $\gcd(A_1, \dots, A_k)$.
- `GeneralSeifert.common_divisor_dvd_seifertOrder`: Common factor divides $O_k(a; \ell_0, \ell)$ for all twists.
- `GeneralSeifert.common_divisor_obstruction`: $d > 1$ common divisor obstruction to homology spheres.
- `GeneralSeifert.noncoprime_pair_obstruction`: Non-coprime pair $\gcd(a_i, a_j) > 1$ obstruction.
-/

namespace GeneralSeifert

open Finset

/-- If $d$ divides $a_i$ and $a_j$ for distinct indices $i \ne j$, then $d$ divides
EVERY cofactor $A_m$ for all $m \in \mathrm{Fin}\; k$. -/
theorem common_divisor_dvd_cofactor {k : ℕ} {a : Fin k → ℤ} {i j : Fin k} (hij : i ≠ j)
    {d : ℤ} (hdi : d ∣ a i) (hdj : d ∣ a j) (m : Fin k) :
    d ∣ cofactor a m := by
  dsimp [cofactor]
  by_cases h : m = i
  · exact hdj.trans (dvd_prod_of_mem a (mem_erase.mpr ⟨h ▸ hij.symm, mem_univ j⟩))
  · exact hdi.trans (dvd_prod_of_mem a (mem_erase.mpr ⟨Ne.symm h, mem_univ i⟩))

/-- If $d \ge 0$ divides $a_i$ and $a_j$ with $i \ne j$, then $d$ divides the cofactor GCD. -/
theorem common_divisor_dvd_cofactorGCD {k : ℕ} {a : Fin k → ℤ} {i j : Fin k} (hij : i ≠ j)
    {d : ℤ} (hdi : d ∣ a i) (hdj : d ∣ a j) :
    d ∣ cofactorGCD a :=
  Finset.dvd_gcd fun m _ => common_divisor_dvd_cofactor hij hdi hdj m

/-- If $d$ divides $a_i$ and $a_j$ with $i \ne j$, then $d$ divides the Seifert order
$O_k(a; \ell_0, \ell)$ for ALL integer twists. -/
theorem common_divisor_dvd_seifertOrder {k : ℕ} [Nonempty (Fin k)] {a : Fin k → ℤ}
    {i j : Fin k} (hij : i ≠ j) {d : ℤ} (hdi : d ∣ a i) (hdj : d ∣ a j)
    (l0 : ℤ) (l : Fin k → ℤ) :
    d ∣ seifertOrder a l0 l :=
  dvd_seifertOrder_of_dvd_all_cofactors a d (common_divisor_dvd_cofactor hij hdi hdj) l0 l

/-- **Theorem (Common Divisor Obstruction Theorem)**:
If a common factor $d > 1$ divides any pair $(a_i, a_j)$ with $i \ne j$, then $d \mid O_k(a; \ell_0, \ell)$
for all twists $(\ell_0, \ell)$, and NO integer twists can yield a homology sphere. -/
theorem common_divisor_obstruction {k : ℕ} [Nonempty (Fin k)] {a : Fin k → ℤ}
    {i j : Fin k} (hij : i ≠ j) {d : ℤ} (hd : 1 < d) (hdi : d ∣ a i) (hdj : d ∣ a j)
    (l0 : ℤ) (l : Fin k → ℤ) :
    d ∣ seifertOrder a l0 l ∧ ¬ IsHomotopySphere a l0 l := by
  have hdvd := common_divisor_dvd_seifertOrder hij hdi hdj l0 l
  refine ⟨hdvd, fun (h_sphere : |seifertOrder a l0 l| = 1) => ?_⟩
  have hdvd1 : d ∣ 1 := by
    obtain h | h := abs_choice (seifertOrder a l0 l) <;> rw [h] at h_sphere
    · rwa [h_sphere] at hdvd
    · have : seifertOrder a l0 l = -1 := by omega
      rw [this] at hdvd; exact dvd_neg.mp hdvd
  have := Int.le_of_dvd (by omega) hdvd1
  omega

/-- Non-coprime pair obstruction: if $\gcd(a_i, a_j) > 1$ for some $i \ne j$, no twists can yield
a homology sphere. -/
theorem noncoprime_pair_obstruction {k : ℕ} [Nonempty (Fin k)] {a : Fin k → ℤ}
    {i j : Fin k} (hij : i ≠ j) (h_gcd : 1 < (a i).gcd (a j))
    (l0 : ℤ) (l : Fin k → ℤ) :
    ¬ IsHomotopySphere a l0 l :=
  (common_divisor_obstruction hij (by exact_mod_cast h_gcd)
    (Int.gcd_dvd_left _ _) (Int.gcd_dvd_right _ _) l0 l).2

end GeneralSeifert
