/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Int.GCD
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Associated
import Mathlib.Algebra.GCDMonoid.Finset
import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.Ring.Divisibility.Basic

/-!
# Generalized $k$-Point Seifert Invariants and Cofactors

This module defines the algebraic framework for universal $k$-point Seifert invariants,
cofactor products, and the cofactor GCD on arbitrary conical base orbifolds.

## Main Definitions
- `GeneralSeifert.cofactor`: Cofactor product $A_j = \prod_{i \ne j} a_i$.
- `GeneralSeifert.seifertOrder`: Generalized order invariant $O_k(a; \ell_0, \ell) = (\prod a_i)\ell_0 - \sum A_j \ell_j$.
- `GeneralSeifert.IsHomotopySphere`: Homotopy sphere condition $|O_k(a; \ell_0, \ell)| = 1$.
- `GeneralSeifert.cofactorGCD`: Greatest common divisor $\gcd(A_1, \dots, A_k)$.

## Main Theorems
- `GeneralSeifert.mul_cofactor`: $a_j \cdot A_j = \prod_{i=1}^k a_i$.
- `GeneralSeifert.cofactor_mul`: $A_j \cdot a_j = \prod_{i=1}^k a_i$.
- `GeneralSeifert.cofactorGCD_nonneg`: $\gcd(A_1, \dots, A_k) \ge 0$.
- `GeneralSeifert.cofactorGCD_dvd`: $\gcd(A_1, \dots, A_k) \mid A_j$.
- `GeneralSeifert.cofactorGCD_dvd_prod`: $\gcd(A_1, \dots, A_k) \mid \prod a_i$.
- `GeneralSeifert.dvd_prod_of_dvd_all_cofactors`: $(\forall j, d \mid A_j) \implies d \mid \prod a_i$.
- `GeneralSeifert.dvd_seifertOrder_of_dvd_all_cofactors`: $(\forall j, d \mid A_j) \implies d \mid O_k(a; \ell_0, \ell)$.
- `GeneralSeifert.cofactorGCD_dvd_seifertOrder`: $\gcd(A_1, \dots, A_k) \mid O_k(a; \ell_0, \ell)$.
-/

namespace GeneralSeifert

open Finset

/-- Cofactor product $A_j = \prod_{i \ne j} a_i$ for index $j \in \mathrm{Fin}\; k$. -/
def cofactor {k : ℕ} (a : Fin k → ℤ) (j : Fin k) : ℤ :=
  ∏ i ∈ Finset.univ.erase j, a i

/-- Multiplying $a_j$ with cofactor $A_j$ reconstructs the full product $\prod_{i=1}^k a_i$. -/
theorem mul_cofactor {k : ℕ} (a : Fin k → ℤ) (j : Fin k) :
    a j * cofactor a j = ∏ i, a i :=
  mul_prod_erase univ a (mem_univ j)

/-- Commuted product of cofactor and $a_j$. -/
theorem cofactor_mul {k : ℕ} (a : Fin k → ℤ) (j : Fin k) :
    cofactor a j * a j = ∏ i, a i := by
  rw [mul_comm, mul_cofactor]

/-- The generalized $k$-point Seifert invariant order formula:
$$O_k(a; \ell_0, \ell) = \left(\prod_{i=1}^k a_i\right) \ell_0 - \sum_{j=1}^k A_j \ell_j$$ -/
def seifertOrder {k : ℕ} (a : Fin k → ℤ) (l0 : ℤ) (l : Fin k → ℤ) : ℤ :=
  (∏ i, a i) * l0 - ∑ j, cofactor a j * l j

/-- Homotopy sphere condition for $k$-point Seifert fibered 3-manifolds:
the generalized order invariant has absolute value equal to 1. -/
def IsHomotopySphere {k : ℕ} (a : Fin k → ℤ) (l0 : ℤ) (l : Fin k → ℤ) : Prop :=
  |seifertOrder a l0 l| = 1

/-- The greatest common divisor of all cofactor products: $\gcd(A_1, \dots, A_k)$. -/
def cofactorGCD {k : ℕ} (a : Fin k → ℤ) : ℤ :=
  Finset.univ.gcd (cofactor a)

/-- The cofactor GCD is always non-negative. -/
theorem cofactorGCD_nonneg {k : ℕ} (a : Fin k → ℤ) : 0 ≤ cofactorGCD a :=
  Finset.Int.finsetGcd_nonneg

/-- The cofactor GCD divides every individual cofactor $A_j$. -/
theorem cofactorGCD_dvd {k : ℕ} (a : Fin k → ℤ) (j : Fin k) :
    cofactorGCD a ∣ cofactor a j :=
  Finset.gcd_dvd (Finset.mem_univ j)

/-- The cofactor GCD divides the full product $\prod_{i=1}^k a_i$. -/
theorem cofactorGCD_dvd_prod {k : ℕ} [Nonempty (Fin k)] (a : Fin k → ℤ) :
    cofactorGCD a ∣ ∏ i, a i := by
  obtain ⟨j⟩ := ‹Nonempty (Fin k)›
  rw [← mul_cofactor a j]
  exact dvd_mul_of_dvd_right (cofactorGCD_dvd a j) _

/-- Any common divisor $d$ of all cofactors divides the full product $\prod_{i=1}^k a_i$. -/
theorem dvd_prod_of_dvd_all_cofactors {k : ℕ} [Nonempty (Fin k)] (a : Fin k → ℤ) (d : ℤ)
    (hd : ∀ j : Fin k, d ∣ cofactor a j) :
    d ∣ ∏ i, a i := by
  obtain ⟨j⟩ := ‹Nonempty (Fin k)›
  rw [← mul_cofactor a j]
  exact dvd_mul_of_dvd_right (hd j) _

/-- Any common divisor $d$ of all cofactors divides the Seifert order $O_k(a; \ell_0, \ell)$
for any integer twists $(\ell_0, \ell)$. -/
theorem dvd_seifertOrder_of_dvd_all_cofactors {k : ℕ} [Nonempty (Fin k)] (a : Fin k → ℤ) (d : ℤ)
    (hd : ∀ j : Fin k, d ∣ cofactor a j) (l0 : ℤ) (l : Fin k → ℤ) :
    d ∣ seifertOrder a l0 l :=
  dvd_sub (dvd_mul_of_dvd_left (dvd_prod_of_dvd_all_cofactors a d hd) l0)
    (Finset.dvd_sum fun j _ => dvd_mul_of_dvd_left (hd j) (l j))

/-- The cofactor GCD divides the Seifert order for any choice of twists. -/
theorem cofactorGCD_dvd_seifertOrder {k : ℕ} [Nonempty (Fin k)] (a : Fin k → ℤ) (l0 : ℤ) (l : Fin k → ℤ) :
    cofactorGCD a ∣ seifertOrder a l0 l :=
  dvd_seifertOrder_of_dvd_all_cofactors a (cofactorGCD a) (cofactorGCD_dvd a) l0 l

end GeneralSeifert
