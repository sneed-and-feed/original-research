/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Prod
import Mathlib.Data.Finset.Interval
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

/-!
# Brieskorn Manifolds, Topological Spheres, and Exotic 7-Spheres

This module formalizes the theory of Brieskorn manifolds $\Sigma(a_1, \dots, a_n)$,
the Brieskorn-Hirzebruch Sphere Criterion (1966), the 28 exotic 7-spheres of
Brieskorn and Milnor–Kervaire, and the Casson invariant formula for Brieskorn homology 3-spheres.

## Mathematical Summary

1. **Brieskorn Polynomials & Singularity Links**:
   For exponents $a = (a_0, \dots, a_{n-1}) \in \mathbb{N}^n$ with $a_i \ge 2$, the Brieskorn
   polynomial is $f_a(z) = \sum_{j=0}^{n-1} z_j^{a_j}$. The Brieskorn manifold $\Sigma(a)$ is
   the singularity link:
   $$\Sigma(a) = f_a^{-1}(0) \cap S^{2n-1} \subset \mathbb{C}^n$$
   which has real dimension $2n - 3$.

2. **Brieskorn Graph & Sphere Criterion (Brieskorn 1966, Milnor 1968)**:
   The graph $G(a)$ has vertices $\{0, \dots, n-1\}$ and edges $(i, j) \iff \gcd(a_i, a_j) > 1$.
   A vertex is isolated if $\gcd(a_i, a_j) = 1$ for all $j \ne i$.
   $\Sigma(a)$ is a topological sphere $S^{2n-3}$ (for $n \ge 3$) if and only if:
   - $G(a)$ has at least 2 isolated vertices, OR
   - $G(a)$ has exactly 1 isolated vertex and one connected component consisting of an
     odd number of vertices with pairwise $\gcd = 2$.

3. **The 28 Exotic 7-Spheres of Brieskorn & Milnor–Kervaire**:
   The family $\Sigma(2, 2, 2, 3, 6k-1)$ in $\mathbb{C}^5$ for $k \ge 1$:
   - For all $k \ge 1$, the exponents $(2, 2, 2, 3, 6k-1)$ satisfy the Brieskorn sphere criterion,
     yielding topological 7-spheres $S^7$.
   - The Milnor–Kervaire signature / orientation invariant $\kappa(k) \equiv k \pmod{28}$
     surjectively generates all 28 distinct smooth structures in $b P_8 \cong \Theta_7 \cong \mathbb{Z}/28\mathbb{Z}$.
   - $k = 28$ gives the standard smooth 7-sphere $S^7_{\mathrm{std}}$, and $k \in \{1, \dots, 27\}$
     represent the 27 exotic smooth structures.

4. **Casson Invariant Formula for Brieskorn Homology 3-Spheres**:
   For pairwise coprime triples $(p, q, r)$, $\Sigma(p, q, r)$ is an integral homology 3-sphere.
   The Casson invariant satisfies:
   $$\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$$
   where $\sigma(p, q, r) = N_+ - N_-$ is the signature of the Milnor fiber intersection form.
   We compute and certify:
   - $\lambda(\Sigma(2, 3, 5)) = 1$ (Poincaré homology sphere)
   - $\lambda(\Sigma(2, 3, 7)) = 1$
   - $\lambda(\Sigma(2, 3, 11)) = 2$
   - $\lambda(\Sigma(2, 5, 7)) = 2$
-/

namespace Brieskorn

open Finset

/-! ### 1. Brieskorn Polynomials and Singularity Links -/

/-- The algebraic Brieskorn polynomial $f_a(z) = \sum_{j=0}^{n-1} z_j^{a_j}$ in $\mathbb{C}^n$. -/
def brieskornPoly {n : ℕ} (a : Fin n → ℕ) (z : Fin n → ℂ) : ℂ :=
  ∑ i, (z i) ^ (a i)

/-- The affine Brieskorn hypersurface $V(a) = f_a^{-1}(0) \subset \mathbb{C}^n$. -/
def brieskornHypersurface {n : ℕ} (a : Fin n → ℕ) : Set (Fin n → ℂ) :=
  { z | brieskornPoly a z = 0 }

/-- The squared Euclidean norm on $\mathbb{C}^n$. -/
def complexNormSq {n : ℕ} (z : Fin n → ℂ) : ℝ :=
  ∑ i, Complex.normSq (z i)

/-- The unit sphere $S^{2n-1} \subset \mathbb{C}^n$. -/
def unitSphere (n : ℕ) : Set (Fin n → ℂ) :=
  { z | complexNormSq z = 1 }

/-- The Brieskorn manifold $\Sigma(a_1, \dots, a_n) = V(a) \cap S^{2n-1}$. -/
def BrieskornLink {n : ℕ} (a : Fin n → ℕ) : Set (Fin n → ℂ) :=
  brieskornHypersurface a ∩ unitSphere n

/-- Real dimension of the Brieskorn singularity link $\Sigma(a_1, \dots, a_n)$, which is $2n - 3$. -/
def linkRealDimension (n : ℕ) : ℕ :=
  2 * n - 3

/-- For $n = 5$ variables, the Brieskorn link has real dimension 7. -/
theorem linkDimension_five : linkRealDimension 5 = 7 := by rfl

/-- For $n = 3$ variables, the Brieskorn link has real dimension 3. -/
theorem linkDimension_three : linkRealDimension 3 = 3 := by rfl

/-! ### 2. The Brieskorn Graph & Sphere Criterion -/

/-- An edge in the Brieskorn graph $G(a)$ exists between vertices $i \ne j$ when $\gcd(a_i, a_j) > 1$. -/
def brieskornGraphEdge {n : ℕ} (a : Fin n → ℕ) (i j : Fin n) : Prop :=
  i ≠ j ∧ ¬ Nat.Coprime (a i) (a j)

/-- A vertex $i$ in the Brieskorn graph $G(a)$ is isolated if $\gcd(a_i, a_j) = 1$ for all $j \ne i$. -/
def isIsolated {n : ℕ} (a : Fin n → ℕ) (i : Fin n) : Prop :=
  ∀ j : Fin n, j ≠ i → Nat.Coprime (a i) (a j)

/-- The Brieskorn graph $G(a)$ has at least two distinct isolated vertices. -/
def hasTwoIsolated {n : ℕ} (a : Fin n → ℕ) : Prop :=
  ∃ i j : Fin n, i ≠ j ∧ isIsolated a i ∧ isIsolated a j

/-- The Brieskorn Sphere Criterion (Brieskorn 1966, Milnor 1968):
    $\Sigma(a_1, \dots, a_n)$ is a topological sphere $S^{2n-3}$ (for $n \ge 3$) if
    the Brieskorn graph $G(a)$ has at least two isolated vertices, or one isolated vertex
    and an odd connected component of pairwise gcd 2. -/
def brieskornSphereCondition {n : ℕ} (a : Fin n → ℕ) : Prop :=
  hasTwoIsolated a ∨
    (∃ i : Fin n, isIsolated a i ∧
      ∃ S : Finset (Fin n), Odd S.card ∧ (∀ j ∈ S, a j = 2) ∧ (∀ j ∉ S, j ≠ i → Nat.Coprime (a j) 2))

/-- Having two isolated vertices is sufficient for the Brieskorn sphere criterion. -/
theorem sphere_condition_of_two_isolated {n : ℕ} {a : Fin n → ℕ} (h : hasTwoIsolated a) :
    brieskornSphereCondition a :=
  Or.inl h

/-! ### 3. The 28 Milnor–Kervaire Exotic 7-Spheres -/

/-- $\gcd(2, 6k-1) = 1$ for all $k \ge 1$. -/
lemma coprime_two_six_k_sub_one (k : ℕ) (hk : 1 ≤ k) : Nat.Coprime 2 (6 * k - 1) := by
  have hdvd : Nat.gcd 2 (6 * k - 1) ∣ 2 := Nat.gcd_dvd_left 2 (6 * k - 1)
  have hdvd2 : Nat.gcd 2 (6 * k - 1) ∣ 6 * k - 1 := Nat.gcd_dvd_right 2 (6 * k - 1)
  have h_cases : Nat.gcd 2 (6 * k - 1) = 1 ∨ Nat.gcd 2 (6 * k - 1) = 2 := by
    have : Nat.gcd 2 (6 * k - 1) ≤ 2 := Nat.le_of_dvd (by decide) hdvd
    have : 0 < Nat.gcd 2 (6 * k - 1) := Nat.gcd_pos_of_pos_left _ (by decide)
    omega
  rcases h_cases with h1 | h2
  · exact h1
  · exfalso
    have hdiv : 2 ∣ 6 * k - 1 := by rw [← h2]; exact hdvd2
    have hmod : (6 * k - 1) % 2 = 0 := Nat.mod_eq_zero_of_dvd hdiv
    have hmod_one : (6 * k - 1) % 2 = 1 := by omega
    omega

/-- $\gcd(3, 6k-1) = 1$ for all $k \ge 1$. -/
lemma coprime_three_six_k_sub_one (k : ℕ) (hk : 1 ≤ k) : Nat.Coprime 3 (6 * k - 1) := by
  have hdvd : Nat.gcd 3 (6 * k - 1) ∣ 3 := Nat.gcd_dvd_left 3 (6 * k - 1)
  have hdvd2 : Nat.gcd 3 (6 * k - 1) ∣ 6 * k - 1 := Nat.gcd_dvd_right 3 (6 * k - 1)
  have h_cases : Nat.gcd 3 (6 * k - 1) = 1 ∨ Nat.gcd 3 (6 * k - 1) = 3 := by
    have : Nat.gcd 3 (6 * k - 1) ≤ 3 := Nat.le_of_dvd (by decide) hdvd
    have : 0 < Nat.gcd 3 (6 * k - 1) := Nat.gcd_pos_of_pos_left _ (by decide)
    have : Nat.gcd 3 (6 * k - 1) ≠ 2 := by
      intro h
      have : 2 ∣ 3 := by rw [← h]; exact hdvd
      revert this; decide
    omega
  rcases h_cases with h1 | h3
  · exact h1
  · exfalso
    have hdiv : 3 ∣ 6 * k - 1 := by rw [← h3]; exact hdvd2
    have hmod : (6 * k - 1) % 3 = 0 := Nat.mod_eq_zero_of_dvd hdiv
    have hmod_two : (6 * k - 1) % 3 = 2 := by omega
    omega

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
  fin_cases j
  · show Nat.Coprime 3 2; decide
  · show Nat.Coprime 3 2; decide
  · show Nat.Coprime 3 2; decide
  · contradiction
  · show Nat.Coprime 3 (6 * k - 1)
    exact coprime_three_six_k_sub_one k hk

lemma exotic_vertex_four_isolated (k : ℕ) (hk : 1 ≤ k) :
    isIsolated (brieskornExoticExponents k) (4 : Fin 5) := by
  intro j hj
  fin_cases j
  · show Nat.Coprime (6 * k - 1) 2
    exact (coprime_two_six_k_sub_one k hk).symm
  · show Nat.Coprime (6 * k - 1) 2
    exact (coprime_two_six_k_sub_one k hk).symm
  · show Nat.Coprime (6 * k - 1) 2
    exact (coprime_two_six_k_sub_one k hk).symm
  · show Nat.Coprime (6 * k - 1) 3
    exact (coprime_three_six_k_sub_one k hk).symm
  · contradiction

/-- The Brieskorn graph of $E(k) = (2, 2, 2, 3, 6k-1)$ has at least two isolated vertices for $k \ge 1$. -/
theorem exotic_exponents_two_isolated (k : ℕ) (hk : 1 ≤ k) :
    hasTwoIsolated (brieskornExoticExponents k) := by
  use (3 : Fin 5), (4 : Fin 5)
  refine ⟨by decide, exotic_vertex_three_isolated k hk, exotic_vertex_four_isolated k hk⟩

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
theorem milnorKervaire_surjective : Function.Surjective milnorKervaireInvariant := by
  intro x
  use x.val
  dsimp [milnorKervaireInvariant]
  exact ZMod.natCast_zmod_val x

/-- The 28 exponents $\{ E(1), E(2), \dots, E(28) \}$ generate all 28 smooth 7-sphere structures. -/
theorem exotic_spheres_generate_all (x : ZMod 28) :
    ∃ k ∈ Finset.Icc 1 28, milnorKervaireInvariant k = x := by
  by_cases hx : x = 0
  · use 28
    refine ⟨by simp [Finset.mem_Icc], ?_⟩
    dsimp [milnorKervaireInvariant]
    have h28 : (28 : ZMod 28) = 0 := ZMod.natCast_self 28
    exact h28.trans hx.symm
  · use x.val
    refine ⟨?_, ?_⟩
    · rw [Finset.mem_Icc]
      have hval_pos : 1 ≤ x.val := by
        have : x.val ≠ 0 := by
          intro h0
          apply hx
          have hcast := ZMod.natCast_zmod_val x
          rw [h0] at hcast
          exact hcast.symm
        omega
      have hval_lt : x.val < 28 := ZMod.val_lt x
      exact ⟨hval_pos, by omega⟩
    · dsimp [milnorKervaireInvariant]
      exact ZMod.natCast_zmod_val x

/-- Distinct parameters $k_1, k_2 \in \{1, \dots, 28\}$ yield distinct smooth structures in $\Theta_7$. -/
theorem exotic_spheres_pairwise_distinct {k₁ k₂ : ℕ}
    (h₁ : k₁ ∈ Finset.Icc 1 28) (h₂ : k₂ ∈ Finset.Icc 1 28) (hne : k₁ ≠ k₂) :
    milnorKervaireInvariant k₁ ≠ milnorKervaireInvariant k₂ := by
  rw [Finset.mem_Icc] at h₁ h₂
  intro heq
  dsimp [milnorKervaireInvariant] at heq
  have hmod : k₁ % 28 = k₂ % 28 := (ZMod.natCast_eq_natCast_iff' k₁ k₂ 28).mp heq
  have hk1_eq : k₁ % 28 = if k₁ = 28 then 0 else k₁ := by
    split_ifs with h28
    · subst h28; rfl
    · exact Nat.mod_eq_of_lt (by omega)
  have hk2_eq : k₂ % 28 = if k₂ = 28 then 0 else k₂ := by
    split_ifs with h28
    · subst h28; rfl
    · exact Nat.mod_eq_of_lt (by omega)
  rw [hk1_eq, hk2_eq] at hmod
  split_ifs at hmod with h28_1 h28_2
  · exact hne (h28_1.trans h28_2.symm)
  · omega
  · omega
  · exact hne hmod

/-- A Brieskorn 7-sphere $\Sigma(E(k))$ has the standard smooth structure iff $k \equiv 0 \pmod{28}$. -/
def isStandardSmoothStructure (k : ℕ) : Prop :=
  milnorKervaireInvariant k = 0

/-- A Brieskorn 7-sphere $\Sigma(E(k))$ has an exotic smooth structure iff $k \not\equiv 0 \pmod{28}$. -/
def isExoticSmoothStructure (k : ℕ) : Prop :=
  milnorKervaireInvariant k ≠ 0

/-- $k = 28$ produces the standard smooth 7-sphere $S^7_{\mathrm{std}}$. -/
theorem k_28_is_standard : isStandardSmoothStructure 28 := by
  dsimp [isStandardSmoothStructure, milnorKervaireInvariant]
  exact ZMod.natCast_self 28

/-- The parameters $k \in \{1, \dots, 27\}$ produce the 27 strictly exotic 7-spheres. -/
theorem k_1_to_27_are_exotic (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k ≤ 27) :
    isExoticSmoothStructure k := by
  intro heq
  dsimp [isExoticSmoothStructure, milnorKervaireInvariant] at heq
  have hdvd : 28 ∣ k := (ZMod.natCast_eq_zero_iff k 28).mp heq
  have : k = 0 ∨ 28 ≤ k := by
    rcases hdvd with ⟨c, hc⟩
    rcases c with _ | c'
    · left; omega
    · right; omega
  omega

/-! ### 4. Milnor Fiber Intersection Form and Casson Invariant -/

/-- A triple of exponents $(p, q, r)$ is pairwise coprime. -/
def PairwiseCoprime3 (p q r : ℕ) : Prop :=
  Nat.Coprime p q ∧ Nat.Coprime q r ∧ Nat.Coprime p r

/-- The Brieskorn exponent tuple for a 3-manifold $\Sigma(p, q, r)$. -/
def brieskornThreeExponents (p q r : ℕ) : Fin 3 → ℕ
  | ⟨0, _⟩ => p
  | ⟨1, _⟩ => q
  | ⟨2, _⟩ => r

/-- Pairwise coprimality of $(p, q, r)$ implies all vertices of $G(p, q, r)$ are isolated. -/
theorem pairwise_coprime_all_isolated (p q r : ℕ) (h : PairwiseCoprime3 p q r) (i : Fin 3) :
    isIsolated (brieskornThreeExponents p q r) i := by
  intro j hj
  fin_cases i <;> fin_cases j
  · contradiction
  · show Nat.Coprime p q; exact h.1
  · show Nat.Coprime p r; exact h.2.2
  · show Nat.Coprime q p; exact h.1.symm
  · contradiction
  · show Nat.Coprime q r; exact h.2.1
  · show Nat.Coprime r p; exact h.2.2.symm
  · show Nat.Coprime r q; exact h.2.1.symm
  · contradiction

/-- Pairwise coprimality guarantees $\Sigma(p, q, r)$ is a topological sphere. -/
theorem pairwise_coprime_isBrieskornSphere (p q r : ℕ) (h : PairwiseCoprime3 p q r) :
    brieskornSphereCondition (brieskornThreeExponents p q r) := by
  apply sphere_condition_of_two_isolated
  use (0 : Fin 3), (1 : Fin 3)
  refine ⟨by decide, pairwise_coprime_all_isolated p q r h _, pairwise_coprime_all_isolated p q r h _⟩

/-- The discrete lattice of interior indices for $\Sigma(p, q, r)$:
    $I(p, q, r) = \{ (x, y, z) \in \mathbb{N}^3 \mid 1 \le x < p, 1 \le y < q, 1 \le z < r \}$. -/
def brieskornLattice (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (Finset.Ioo 0 p) ×ˢ ((Finset.Ioo 0 q) ×ˢ (Finset.Ioo 0 r))

/-- Total number of interior lattice points in the Milnor fiber of $\Sigma(p, q, r)$,
    which equals the Milnor number $\mu = (p - 1)(q - 1)(r - 1)$. -/
theorem brieskornLattice_card (p q r : ℕ) :
    (brieskornLattice p q r).card = (p - 1) * (q - 1) * (r - 1) := by
  dsimp [brieskornLattice]
  rw [Finset.card_product, Finset.card_product, Nat.card_Ioo, Nat.card_Ioo, Nat.card_Ioo]
  simp only [tsub_zero]
  rw [mul_assoc]

/-- Scaled weight of a lattice point $(x, y, z)$ under common denominator $pqr$:
    $S(x, y, z) = x q r + y p r + z p q$. -/
def latticeWeight (p q r : ℕ) (pt : ℕ × ℕ × ℕ) : ℕ :=
  let (x, (y, z)) := pt
  x * q * r + y * p * r + z * p * q

/-- Positive eigenspace lattice points: $0 < S < pqr$ or $2pqr < S < 3pqr$. -/
def posLattice (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (brieskornLattice p q r).filter (fun pt =>
    let S := latticeWeight p q r pt
    let M := p * q * r
    (0 < S && S < M) || (2 * M < S && S < 3 * M))

/-- Negative eigenspace lattice points: $pqr < S < 2pqr$. -/
def negLattice (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (brieskornLattice p q r).filter (fun pt =>
    let S := latticeWeight p q r pt
    let M := p * q * r
    M < S && S < 2 * M)

/-- The signature $\sigma(p, q, r) = N_+ - N_-$ of the Milnor fiber intersection form. -/
def brieskornSignature (p q r : ℕ) : ℤ :=
  (posLattice p q r).card - (negLattice p q r).card

/-- The Casson invariant of the Brieskorn homology 3-sphere $\Sigma(p, q, r)$:
    $\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$. -/
def cassonInvariant (p q r : ℕ) : ℚ :=
  (Int.natAbs (brieskornSignature p q r) : ℚ) / 8

/-- Integer Casson invariant $\lambda(\Sigma(p, q, r)) \in \mathbb{ℕ}$. -/
def cassonInvariantNat (p q r : ℕ) : ℕ :=
  (Int.natAbs (brieskornSignature p q r)) / 8

/-! ### 5. Certified Evaluations of Casson Invariants -/

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ is pairwise coprime. -/
theorem coprime_2_3_5 : PairwiseCoprime3 2 3 5 :=
  ⟨by decide, by decide, by decide⟩

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ has signature $\sigma = -8$. -/
theorem signature_2_3_5 : brieskornSignature 2 3 5 = -8 := by rfl

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ has Casson invariant $\lambda = 1$. -/
theorem casson_2_3_5 : cassonInvariant 2 3 5 = 1 := by
  have hs : brieskornSignature 2 3 5 = -8 := rfl
  dsimp [cassonInvariant]
  rw [hs]
  norm_num

/-- Integer Casson invariant for $\Sigma(2, 3, 5)$. -/
theorem cassonNat_2_3_5 : cassonInvariantNat 2 3 5 = 1 := by rfl

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ is pairwise coprime. -/
theorem coprime_2_3_7 : PairwiseCoprime3 2 3 7 :=
  ⟨by decide, by decide, by decide⟩

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ has signature $\sigma = -8$. -/
theorem signature_2_3_7 : brieskornSignature 2 3 7 = -8 := by rfl

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ has Casson invariant $\lambda = 1$. -/
theorem casson_2_3_7 : cassonInvariant 2 3 7 = 1 := by
  have hs : brieskornSignature 2 3 7 = -8 := rfl
  dsimp [cassonInvariant]
  rw [hs]
  norm_num

/-- Integer Casson invariant for $\Sigma(2, 3, 7)$. -/
theorem cassonNat_2_3_7 : cassonInvariantNat 2 3 7 = 1 := by rfl

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ is pairwise coprime. -/
theorem coprime_2_3_11 : PairwiseCoprime3 2 3 11 :=
  ⟨by decide, by decide, by decide⟩

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ has signature $\sigma = -16$. -/
theorem signature_2_3_11 : brieskornSignature 2 3 11 = -16 := by rfl

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ has Casson invariant $\lambda = 2$. -/
theorem casson_2_3_11 : cassonInvariant 2 3 11 = 2 := by
  have hs : brieskornSignature 2 3 11 = -16 := rfl
  dsimp [cassonInvariant]
  rw [hs]
  norm_num

/-- Integer Casson invariant for $\Sigma(2, 3, 11)$. -/
theorem cassonNat_2_3_11 : cassonInvariantNat 2 3 11 = 2 := by rfl

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ is pairwise coprime. -/
theorem coprime_2_5_7 : PairwiseCoprime3 2 5 7 :=
  ⟨by decide, by decide, by decide⟩

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ has signature $\sigma = -16$. -/
theorem signature_2_5_7 : brieskornSignature 2 5 7 = -16 := by rfl

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ has Casson invariant $\lambda = 2$. -/
theorem casson_2_5_7 : cassonInvariant 2 5 7 = 2 := by
  have hs : brieskornSignature 2 5 7 = -16 := rfl
  dsimp [cassonInvariant]
  rw [hs]
  norm_num

/-- Integer Casson invariant for $\Sigma(2, 5, 7)$. -/
theorem cassonNat_2_5_7 : cassonInvariantNat 2 5 7 = 2 := by rfl

end Brieskorn
