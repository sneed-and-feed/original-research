/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.GeneralSeifertClassification.Cofactors
import Mathlib.Data.Int.GCD
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Algebra.BigOperators.Associated
import Mathlib.RingTheory.PrincipalIdealDomain
import Mathlib.Data.Nat.Prime.Int
import Mathlib.Data.Nat.Prime.Defs
import Mathlib.RingTheory.Int.Basic

/-!
# Universal Diophantine Solvability and Coprimality Sufficiency

This module establishes the master Diophantine solvability equivalence for $k$-point Seifert
fibrations and proves that pairwise coprimality of multiplicities guarantees the existence
of integer twists yielding a homology 3-sphere.

## Main Theorems
- `GeneralSeifert.exists_sphere_iff_cofactorGCD_eq_one`: Homology sphere existence $\iff \gcd(A_1, \dots, A_k) = 1$.
- `GeneralSeifert.PairwiseCoprime`: Pairwise coprimality predicate $\forall i \ne j, \gcd(a_i, a_j) = 1$.
- `GeneralSeifert.pairwise_coprime_implies_cofactorGCD_eq_one`: Pairwise coprimality implies cofactor GCD is 1.
- `GeneralSeifert.pairwise_coprime_exists_sphere`: Pairwise coprimality implies homology sphere existence.
- `GeneralSeifert.PairwiseCoprimeLt`: Strict ordering formulation $\forall i < j, \gcd(a_i, a_j) = 1$.
- `GeneralSeifert.pairwiseCoprime_iff_pairwiseCoprimeLt`: Equivalence between standard and ordered formulations.
- `GeneralSeifert.pairwise_coprime_lt_exists_sphere`: Existence theorem using ordered pairwise coprimality.
-/

namespace GeneralSeifert

open Finset

/-- **Theorem (Master Diophantine Solvability Theorem)**:
For any $k$-point Seifert fibration ($k \ge 1$), there exist integer twists $(\ell_0, \ell_1, \dots, \ell_k)$
yielding a homology sphere if and only if the cofactor GCD $\gcd(A_1, \dots, A_k) = 1$. -/
theorem exists_sphere_iff_cofactorGCD_eq_one {k : ℕ} [Nonempty (Fin k)] (a : Fin k → ℤ) :
    (∃ (l0 : ℤ) (l : Fin k → ℤ), IsHomotopySphere a l0 l) ↔ cofactorGCD a = 1 := by
  constructor
  · rintro ⟨l0, l, (h_sphere : |seifertOrder a l0 l| = 1)⟩
    have hdvd := cofactorGCD_dvd_seifertOrder a l0 l
    have hdvd1 : cofactorGCD a ∣ 1 := by
      obtain h | h := abs_choice (seifertOrder a l0 l) <;> rw [h] at h_sphere
      · rwa [h_sphere] at hdvd
      · have : seifertOrder a l0 l = -1 := by omega
        rw [this] at hdvd; exact dvd_neg.mp hdvd
    exact Int.eq_one_of_dvd_one (cofactorGCD_nonneg a) hdvd1
  · intro hGCD
    obtain ⟨g, hg⟩ := Finset.gcd_eq_sum_mul Finset.univ (cofactor a)
    refine ⟨0, fun j => -g j, ?_⟩
    dsimp [IsHomotopySphere]
    rw [show seifertOrder a 0 (fun j => -g j) = 1 by
      simp only [seifertOrder, mul_zero, zero_sub, mul_neg, Finset.sum_neg_distrib, neg_neg]
      exact hg.symm.trans hGCD]
    rfl

/-- A multiplicity vector $a : \mathrm{Fin}\; k \to \mathbb{Z}$ is pairwise coprime if
$\gcd(a_i, a_j) = 1$ for all distinct indices $i \ne j$. -/
def PairwiseCoprime {k : ℕ} (a : Fin k → ℤ) : Prop :=
  ∀ ⦃i j : Fin k⦄, i ≠ j → (a i).gcd (a j) = 1

/-- If $a$ is pairwise coprime, then its cofactor GCD is equal to 1. -/
theorem pairwise_coprime_implies_cofactorGCD_eq_one {k : ℕ} [Nonempty (Fin k)] {a : Fin k → ℤ}
    (h_cop : PairwiseCoprime a) : cofactorGCD a = 1 := by
  by_contra h_ne_one
  have h_nat : (cofactorGCD a).natAbs ≠ 1 := by
    intro h; obtain h1 | _ := Int.natAbs_eq_iff.mp h
    · exact h_ne_one h1
    · have := cofactorGCD_nonneg a; omega
  obtain ⟨p, hp_prime, hp_dvd⟩ := Int.exists_prime_and_dvd h_nat
  obtain ⟨i⟩ := ‹Nonempty (Fin k)›
  have get_factor (x : Fin k) : ∃ y ≠ x, p ∣ a y := by
    have hp_c : p ∣ cofactor a x := hp_dvd.trans (cofactorGCD_dvd a x)
    dsimp [cofactor] at hp_c
    rw [Prime.dvd_finsetProd_iff hp_prime] at hp_c
    obtain ⟨y, hy, hpy⟩ := hp_c
    exact ⟨y, (mem_erase.mp hy).1, hpy⟩
  obtain ⟨j, _, hp_aj⟩ := get_factor i
  obtain ⟨m, hmj, hp_am⟩ := get_factor j
  have h_dvd : p.natAbs ∣ (a j).gcd (a m) :=
    Nat.dvd_gcd (Int.natAbs_dvd_natAbs.mpr hp_aj) (Int.natAbs_dvd_natAbs.mpr hp_am)
  rw [h_cop hmj.symm] at h_dvd
  exact hp_prime.not_isUnit (Int.isUnit_iff_natAbs_eq.mpr (Nat.eq_one_of_dvd_one h_dvd))

/-- **Theorem (Pairwise Coprimality Sufficiency Theorem)**:
If the fiber multiplicities $(a_1, \dots, a_k)$ are pairwise coprime, then there exist
integer twists $(\ell_0, \ell_1, \dots, \ell_k)$ yielding a homology sphere. -/
theorem pairwise_coprime_exists_sphere {k : ℕ} [Nonempty (Fin k)] {a : Fin k → ℤ}
    (h_cop : PairwiseCoprime a) :
    ∃ (l0 : ℤ) (l : Fin k → ℤ), IsHomotopySphere a l0 l :=
  (exists_sphere_iff_cofactorGCD_eq_one a).mpr (pairwise_coprime_implies_cofactorGCD_eq_one h_cop)

/-- Strict ordering version of pairwise coprimality: $\gcd(a_i, a_j) = 1$ for all $i < j$. -/
def PairwiseCoprimeLt {k : ℕ} (a : Fin k → ℤ) : Prop :=
  ∀ ⦃i j : Fin k⦄, i < j → (a i).gcd (a j) = 1

/-- Equivalence of pairwise coprimality formulations ($i \ne j$ versus $i < j$). -/
theorem pairwiseCoprime_iff_pairwiseCoprimeLt {k : ℕ} (a : Fin k → ℤ) :
    PairwiseCoprime a ↔ PairwiseCoprimeLt a :=
  ⟨fun h _ _ hij => h (ne_of_lt hij),
   fun h _ _ hij => (lt_or_gt_of_ne hij).elim (h ·) (by rw [Int.gcd_comm]; exact (h ·))⟩

/-- Pairwise coprimality sufficiency using the strict ordering formulation ($i < j$). -/
theorem pairwise_coprime_lt_exists_sphere {k : ℕ} [Nonempty (Fin k)] {a : Fin k → ℤ}
    (h_cop : PairwiseCoprimeLt a) :
    ∃ (l0 : ℤ) (l : Fin k → ℤ), IsHomotopySphere a l0 l :=
  pairwise_coprime_exists_sphere ((pairwiseCoprime_iff_pairwiseCoprimeLt a).mpr h_cop)

end GeneralSeifert
