/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Int.GCD
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Associated
import Mathlib.Algebra.GCDMonoid.Finset
import Mathlib.RingTheory.PrincipalIdealDomain
import Mathlib.Data.Nat.Prime.Int
import Mathlib.Data.Nat.Prime.Defs
import Mathlib.RingTheory.Int.Basic

/-!
# Universal Diophantine Classification for $k$-Point Seifert Fibrations & Homology Spheres

This module formalizes the universal Diophantine classification of sphere-yielding Seifert fibrations
over base 2-orbifolds with an arbitrary number of conical singularities $k \ge 1$.

## Mathematical Background

For a Seifert fibered 3-manifold with base orbifold having $k$ conical points of multiplicities
$a = (a_1, a_2, \dots, a_k) \in \mathbb{Z}^k$ and central/fiber twist parameters
$\ell_0 \in \mathbb{Z}, \ell = (\ell_1, \dots, \ell_k) \in \mathbb{Z}^k$, the fundamental group
presentation gives the central Seifert order invariant:
$$O_k(a; \ell_0, \ell) = \left(\prod_{i=1}^k a_i\right) \ell_0 - \sum_{j=1}^k \left(\prod_{i \ne j} a_i\right) \ell_j$$
Defining the cofactor products $A_j = \prod_{i \ne j} a_i$, the order invariant simplifies to:
$$O_k(a; \ell_0, \ell) = \left(\prod_{i=1}^k a_i\right) \ell_0 - \sum_{j=1}^k A_j \ell_j$$

The 3-manifold is a homology sphere if and only if $|O_k(a; \ell_0, \ell)| = 1$.

## Key Results Formalized

1. **Generalized Seifert Invariants & Cofactors**:
   - `cofactor a j`: $A_j = \prod_{i \ne j} a_i$.
   - `mul_cofactor`: $a_j \cdot A_j = \prod_{i=1}^k a_i$.
   - `seifertOrder a l0 l`: $O_k(a; \ell_0, \ell)$.
   - `IsHomotopySphere a l0 l`: $|O_k(a; \ell_0, \ell)| = 1$.
   - `cofactorGCD a`: $\gcd(A_1, \dots, A_k)$.

2. **Master Diophantine Solvability Theorem (`exists_sphere_iff_cofactorGCD_eq_one`)**:
   $$\exists (\ell_0, \dots, \ell_k) \in \mathbb{Z}^{k+1}, \quad |O_k(a; \ell_0, \ell)| = 1 \iff \gcd(A_1, \dots, A_k) = 1$$

3. **Pairwise Coprimality Sufficiency Theorem (`pairwise_coprime_exists_sphere`)**:
   $$(\forall i \ne j, \gcd(a_i, a_j) = 1) \implies \gcd(A_1, \dots, A_k) = 1 \implies \exists \vec{\ell}, |O_k| = 1$$

4. **Common Divisor Obstruction (`common_divisor_obstruction`, `noncoprime_pair_obstruction`)**:
   If $\gcd(a_i, a_j) = d > 1$ for some pair $i \ne j$, then $d \mid A_m$ for all $m$, so $d \mid O_k$
   for all twists, precluding any homology sphere.

5. **Concrete Family Classifications & Certificates**:
   - 3-point families: Poincaré $\Sigma(2,3,5)$, Brieskorn $\Sigma(2,3,7)$, $\Sigma(2,3,11)$, and non-coprime obstruction $\Sigma(2,4,6)$.
   - 4-point families: $\Sigma(2,3,5,7)$, $\Sigma(2,3,5,11)$, and non-coprime obstruction $\Sigma(2,3,4,5)$.
-/

namespace GeneralSeifert

open Finset

/-! ### 1. Generalized $k$-Point Seifert Invariants & Cofactors -/

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

/-! ### 2. Master Diophantine Solvability Theorem -/

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

/-! ### 3. Pairwise Coprimality Sufficiency Theorem -/

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

/-! ### 4. Common Divisor Obstruction -/

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

/-! ### 5. Concrete Constructors & Family Classifications -/

/-- Explicit vector constructor for 3-point systems $(a_1, a_2, a_3)$. -/
def vec3 (a1 a2 a3 : ℤ) : Fin 3 → ℤ :=
  fun | ⟨0, _⟩ => a1
      | ⟨1, _⟩ => a2
      | ⟨2, _⟩ => a3

/-- Explicit twist constructor for 3-point systems $(\ell_1, \ell_2, \ell_3)$. -/
def twist3 (l1 l2 l3 : ℤ) : Fin 3 → ℤ :=
  fun | ⟨0, _⟩ => l1
      | ⟨1, _⟩ => l2
      | ⟨2, _⟩ => l3

/-- Explicit vector constructor for 4-point systems $(a_1, a_2, a_3, a_4)$. -/
def vec4 (a1 a2 a3 a4 : ℤ) : Fin 4 → ℤ :=
  fun | ⟨0, _⟩ => a1
      | ⟨1, _⟩ => a2
      | ⟨2, _⟩ => a3
      | ⟨3, _⟩ => a4

/-- Explicit twist constructor for 4-point systems $(\ell_1, \ell_2, \ell_3, \ell_4)$. -/
def twist4 (l1 l2 l3 l4 : ℤ) : Fin 4 → ℤ :=
  fun | ⟨0, _⟩ => l1
      | ⟨1, _⟩ => l2
      | ⟨2, _⟩ => l3
      | ⟨3, _⟩ => l4

/-! #### 3-Point Classification Theorems -/

/-- Poincaré Homology Sphere $\Sigma(2, 3, 5)$ under generalized $k$-point invariant:
$|30(1) - 15(1) - 10(1) - 6(1)| = |-1| = 1$. -/
theorem sphere_3point_2_3_5 : IsHomotopySphere (vec3 2 3 5) 1 (twist3 1 1 1) := by
  dsimp [IsHomotopySphere, seifertOrder, vec3, twist3, cofactor]; decide

/-- Brieskorn Homology Sphere $\Sigma(2, 3, 7)$ under generalized $k$-point invariant:
$|42(1) - 21(1) - 14(1) - 6(1)| = |1| = 1$. -/
theorem sphere_3point_2_3_7 : IsHomotopySphere (vec3 2 3 7) 1 (twist3 1 1 1) := by
  dsimp [IsHomotopySphere, seifertOrder, vec3, twist3, cofactor]; decide

/-- Brieskorn Homology Sphere $\Sigma(2, 3, 11)$ under generalized $k$-point invariant:
$|66(0) - 33(1) - 22(-1) - 6(-2)| = |1| = 1$. -/
theorem sphere_3point_2_3_11 : IsHomotopySphere (vec3 2 3 11) 0 (twist3 1 (-1) (-2)) := by
  dsimp [IsHomotopySphere, seifertOrder, vec3, twist3, cofactor]; decide

/-- Non-coprime obstruction certificate for $(2, 4, 6)$: $d = 2 > 1$ divides $a_0 = 2$ and $a_1 = 4$,
precluding any homology sphere. -/
theorem obstruction_3point_2_4_6 (l0 l1 l2 l3 : ℤ) :
    2 ∣ seifertOrder (vec3 2 4 6) l0 (twist3 l1 l2 l3) ∧
    ¬ IsHomotopySphere (vec3 2 4 6) l0 (twist3 l1 l2 l3) :=
  common_divisor_obstruction (show (0 : Fin 3) ≠ 1 by decide) (by omega) ⟨1, rfl⟩ ⟨2, rfl⟩ l0 (twist3 l1 l2 l3)

/-! #### 4-Point Classification Theorems -/

/-- 4-Point Seifert Homology Sphere $\Sigma(2, 3, 5, 7)$:
Twists $(0, 1, -1, -3, 3)$ yield:
$|210(0) - 105(1) - 70(-1) - 42(-3) - 30(3)| = |-105 + 70 + 126 - 90| = |1| = 1$. -/
theorem sphere_4point_2_3_5_7 : IsHomotopySphere (vec4 2 3 5 7) 0 (twist4 1 (-1) (-3) 3) := by
  dsimp [IsHomotopySphere, seifertOrder, vec4, twist4, cofactor]; decide

/-- 4-Point Seifert Homology Sphere $\Sigma(2, 3, 5, 11)$:
Twists $(0, -1, 1, 9, -18)$ yield:
$|330(0) - 165(-1) - 110(1) - 66(9) - 30(-18)| = |165 - 110 - 594 + 540| = |1| = 1$. -/
theorem sphere_4point_2_3_5_11 : IsHomotopySphere (vec4 2 3 5 11) 0 (twist4 (-1) 1 9 (-18)) := by
  dsimp [IsHomotopySphere, seifertOrder, vec4, twist4, cofactor]; decide

/-- Non-coprime obstruction certificate for $(2, 3, 4, 5)$:
$d = 2 > 1$ divides $a_0 = 2$ and $a_2 = 4$ (indices $0 \ne 2$), precluding any homology sphere. -/
theorem obstruction_4point_2_3_4_5 (l0 l1 l2 l3 l4 : ℤ) :
    2 ∣ seifertOrder (vec4 2 3 4 5) l0 (twist4 l1 l2 l3 l4) ∧
    ¬ IsHomotopySphere (vec4 2 3 4 5) l0 (twist4 l1 l2 l3 l4) :=
  common_divisor_obstruction (show (0 : Fin 4) ≠ 2 by decide) (by omega) ⟨1, rfl⟩ ⟨2, rfl⟩ l0 (twist4 l1 l2 l3 l4)

/-! ### 6. List-Based Formulation & Equivalences -/

/-- List-based cofactor product: product of elements in `a` omitting index `idx`. -/
def cofactorList (a : List ℤ) (idx : ℕ) : ℤ :=
  (a.eraseIdx idx).prod

/-- List-based generalized $k$-point Seifert invariant order formula:
$$O_k(a; \ell_0, \ell) = a.\mathrm{prod} \cdot \ell_0 - \sum_{j=0}^{k-1} (\mathrm{cofactorList}\; a\; j) \cdot \ell_j$$ -/
def seifertOrderList (a : List ℤ) (l0 : ℤ) (l : List ℤ) : ℤ :=
  a.prod * l0 - (List.zipWith (fun c lj => c * lj) (List.range a.length |>.map (cofactorList a)) l).sum

/-- Homotopy sphere condition for list-based Seifert invariant. -/
def IsHomotopySphereList (a : List ℤ) (l0 : ℤ) (l : List ℤ) : Prop :=
  |seifertOrderList a l0 l| = 1

/-- List-based Poincaré Homology Sphere $\Sigma(2, 3, 5)$:
$|30(1) - 15(1) - 10(1) - 6(1)| = |-1| = 1$. -/
theorem sphere_list_2_3_5 : IsHomotopySphereList [2, 3, 5] 1 [1, 1, 1] := by
  dsimp [IsHomotopySphereList, seifertOrderList, cofactorList]; decide

/-- List-based Brieskorn Homology Sphere $\Sigma(2, 3, 7)$:
$|42(1) - 21(1) - 14(1) - 6(1)| = |1| = 1$. -/
theorem sphere_list_2_3_7 : IsHomotopySphereList [2, 3, 7] 1 [1, 1, 1] := by
  dsimp [IsHomotopySphereList, seifertOrderList, cofactorList]; decide

/-- List-based 4-point Homology Sphere $\Sigma(2, 3, 5, 7)$:
$|210(0) - 105(1) - 70(-1) - 42(-3) - 30(3)| = |1| = 1$. -/
theorem sphere_list_2_3_5_7 : IsHomotopySphereList [2, 3, 5, 7] 0 [1, -1, -3, 3] := by
  dsimp [IsHomotopySphereList, seifertOrderList, cofactorList]; decide

/-- List-based 4-point Homology Sphere $\Sigma(2, 3, 5, 11)$:
$|330(0) - 165(-1) - 110(1) - 66(9) - 30(-18)| = |1| = 1$. -/
theorem sphere_list_2_3_5_11 : IsHomotopySphereList [2, 3, 5, 11] 0 [-1, 1, 9, -18] := by
  dsimp [IsHomotopySphereList, seifertOrderList, cofactorList]; decide

end GeneralSeifert
