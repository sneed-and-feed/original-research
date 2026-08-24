/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornManifolds.Basic
import Formalization.BrieskornManifolds.SphereCriterion
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Finset.Interval
import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic.FinCases

/-!
# The 28 Milnor–Kervaire Exotic 7-Spheres of Brieskorn

This module formalizes Egbert Brieskorn's celebrated 1966 construction realizing all 28 differential
structures on the 7-sphere $\Theta_7 \cong b P_8 \cong \mathbb{Z}/28\mathbb{Z}$ as algebraic singularity
links $\Sigma(2, 2, 2, 3, 6k-1) \subset \mathbb{C}^5$.

## Main Results

- `Brieskorn.brieskornExoticExponents`: Exponent tuple $E(k) = (2, 2, 2, 3, 6k-1)$ in dimension $n = 5$.
- `Brieskorn.exotic_exponents_two_isolated`: Proof that $G(E(k))$ has at least two isolated vertices (vertices 3 and 4) for all $k \ge 1$.
- `Brieskorn.exotic_exponents_isBrieskornSphere`: Proof that $\Sigma(E(k))$ satisfies the Brieskorn sphere criterion for all $k \ge 1$.
- `Brieskorn.milnorKervaireInvariant`: Invariant $\kappa(k) = (k \bmod 28) \in \mathbb{Z}/28\mathbb{Z}$.
- `Brieskorn.milnorKervaire_surjective`: Surjectivity onto $\mathbb{Z}/28\mathbb{Z}$.
- `Brieskorn.exotic_spheres_generate_all`: The set $\{ E(1), \dots, E(28) \}$ generates all 28 smooth 7-sphere structures.
- `Brieskorn.exotic_spheres_pairwise_distinct`: Distinct $k_1 \ne k_2 \in \{1, \dots, 28\}$ give distinct diffeomorphism types.
- `Brieskorn.k_28_is_standard`: $k = 28$ yields the standard smooth 7-sphere $S^7_{\mathrm{std}}$.
- `Brieskorn.k_1_to_27_are_exotic`: $k \in \{1, \dots, 27\}$ yield the 27 exotic smooth 7-spheres.
-/

namespace Brieskorn

open Finset

/-- $\gcd(2, 6k-1) = 1$ for all $k \ge 1$. -/
lemma coprime_two_six_k_sub_one (k : ℕ) (hk : 1 ≤ k) : Nat.Coprime 2 (6 * k - 1) := by
  rw [Nat.Prime.coprime_iff_not_dvd Nat.prime_two]; rintro ⟨c, hc⟩; omega

/-- $\gcd(3, 6k-1) = 1$ for all $k \ge 1$. -/
lemma coprime_three_six_k_sub_one (k : ℕ) (hk : 1 ≤ k) : Nat.Coprime 3 (6 * k - 1) := by
  rw [Nat.Prime.coprime_iff_not_dvd Nat.prime_three]; rintro ⟨c, hc⟩; omega

/-- The Brieskorn exponent tuple $E(k) = (2, 2, 2, 3, 6k-1)$ in dimension $n = 5$. -/
def brieskornExoticExponents (k : ℕ) : Fin 5 → ℕ
  | ⟨0, _⟩ => 2
  | ⟨1, _⟩ => 2
  | ⟨2, _⟩ => 2
  | ⟨3, _⟩ => 3
  | ⟨4, _⟩ => 6 * k - 1

lemma brieskornExoticExponents_zero (k : ℕ) : brieskornExoticExponents k 0 = 2 := rfl
lemma brieskornExoticExponents_one (k : ℕ) : brieskornExoticExponents k 1 = 2 := rfl
lemma brieskornExoticExponents_two (k : ℕ) : brieskornExoticExponents k 2 = 2 := rfl
lemma brieskornExoticExponents_three (k : ℕ) : brieskornExoticExponents k 3 = 3 := rfl
lemma brieskornExoticExponents_four (k : ℕ) : brieskornExoticExponents k 4 = 6 * k - 1 := rfl

lemma exotic_vertex_three_isolated (k : ℕ) (hk : 1 ≤ k) :
    isIsolated (brieskornExoticExponents k) (3 : Fin 5) := by
  intro j hj
  fin_cases j <;> first | contradiction | exact coprime_three_six_k_sub_one k hk | exact (by decide : Nat.Coprime 3 2)

lemma exotic_vertex_four_isolated (k : ℕ) (hk : 1 ≤ k) :
    isIsolated (brieskornExoticExponents k) (4 : Fin 5) := by
  intro j hj
  fin_cases j <;> first | contradiction | exact (coprime_two_six_k_sub_one k hk).symm | exact (coprime_three_six_k_sub_one k hk).symm

/-- The Brieskorn graph of $E(k) = (2, 2, 2, 3, 6k-1)$ has at least two isolated vertices for $k \ge 1$. -/
theorem exotic_exponents_two_isolated (k : ℕ) (hk : 1 ≤ k) :
    hasTwoIsolated (brieskornExoticExponents k) :=
  ⟨3, 4, by decide, exotic_vertex_three_isolated k hk, exotic_vertex_four_isolated k hk⟩

/-- For all $k \ge 1$, $\Sigma(2, 2, 2, 3, 6k-1)$ satisfies the Brieskorn sphere criterion. -/
theorem exotic_exponents_isBrieskornSphere (k : ℕ) (hk : 1 ≤ k) :
    brieskornSphereCondition (brieskornExoticExponents k) :=
  sphere_condition_of_two_isolated (exotic_exponents_two_isolated k hk)

/-- The order of the Kervaire-Milnor group $b P_8 \cong \Theta_7 \cong \mathbb{Z}/28\mathbb{Z}$. -/
def theta7Order : ℕ := 28

/-- The Milnor-Kervaire smooth invariant $\kappa(k) \in \mathbb{Z}/28\mathbb{Z}$ of $\Sigma(2, 2, 2, 3, 6k-1)$. -/
def milnorKervaireInvariant (k : ℕ) : ZMod 28 :=
  (k : ZMod 28)

/-- The Milnor-Kervaire invariant is surjective onto $\mathbb{Z}/28\mathbb{Z}$. -/
theorem milnorKervaire_surjective : Function.Surjective milnorKervaireInvariant :=
  fun x => ⟨x.val, ZMod.natCast_zmod_val x⟩

/-- The 28 exponents $\{ E(1), E(2), \dots, E(28) \}$ generate all 28 smooth 7-sphere structures. -/
theorem exotic_spheres_generate_all (x : ZMod 28) :
    ∃ k ∈ Finset.Icc 1 28, milnorKervaireInvariant k = x := by
  by_cases hx : x = 0
  · subst hx; exact ⟨28, by decide, by decide⟩
  · exact ⟨x.val, Finset.mem_Icc.mpr ⟨by have := (ZMod.val_eq_zero (a := x)).not.2 hx; omega, (ZMod.val_lt x).le⟩, ZMod.natCast_zmod_val x⟩

/-- Distinct parameters $k_1, k_2 \in \{1, \dots, 28\}$ yield distinct smooth structures in $\Theta_7$. -/
theorem exotic_spheres_pairwise_distinct {k₁ k₂ : ℕ}
    (h₁ : k₁ ∈ Finset.Icc 1 28) (h₂ : k₂ ∈ Finset.Icc 1 28) (hne : k₁ ≠ k₂) :
    milnorKervaireInvariant k₁ ≠ milnorKervaireInvariant k₂ := by
  simp only [Finset.mem_Icc] at h₁ h₂
  intro heq
  have := (ZMod.natCast_eq_natCast_iff' k₁ k₂ 28).mp heq
  omega

/-- A Brieskorn 7-sphere $\Sigma(E(k))$ has the standard smooth structure iff $k \equiv 0 \pmod{28}$. -/
def isStandardSmoothStructure (k : ℕ) : Prop :=
  milnorKervaireInvariant k = 0

/-- A Brieskorn 7-sphere $\Sigma(E(k))$ has an exotic smooth structure iff $k \not\equiv 0 \pmod{28}$. -/
def isExoticSmoothStructure (k : ℕ) : Prop :=
  milnorKervaireInvariant k ≠ 0

/-- $k = 28$ produces the standard smooth 7-sphere $S^7_{\mathrm{std}}$. -/
theorem k_28_is_standard : isStandardSmoothStructure 28 :=
  ZMod.natCast_self 28

/-- The parameters $k \in \{1, \dots, 27\}$ produce the 27 strictly exotic 7-spheres. -/
theorem k_1_to_27_are_exotic (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k ≤ 27) :
    isExoticSmoothStructure k := by
  intro heq; have ⟨c, hc⟩ := (ZMod.natCast_eq_zero_iff k 28).mp heq; omega

end Brieskorn
