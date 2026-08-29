/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Algebra.Quaternion
import Mathlib.Algebra.Group.Subgroup.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Data.Finset.Card

noncomputable section

namespace PoincareDodecahedron

open scoped Quaternion Classical
open Real

/-- The Golden Ratio $\phi = (1+\sqrt{5})/2$. -/
noncomputable def phi : ℝ := (1 + Real.sqrt 5) / 2

local notation "φ" => phi

/-- Square of $\sqrt{5}$ is 5. -/
theorem sqrt_five_sq : (Real.sqrt 5) ^ 2 = 5 := Real.sq_sqrt (by norm_num)

/-- Fundamental golden ratio identity: $\phi^2 = \phi + 1$. -/
theorem phi_sq : φ ^ 2 = φ + 1 := by unfold phi; have := sqrt_five_sq; nlinarith

/-- Fundamental golden ratio inverse identity: $\phi^{-1} = \phi - 1$. -/
theorem phi_inv : φ⁻¹ = φ - 1 :=
  (eq_inv_of_mul_eq_one_right (by nlinarith [phi_sq])).symm

/-- Helper constructor for quaternions in ℍ[ℝ]. -/
@[inline] def q (a b c d : ℝ) : ℍ[ℝ] := ⟨a, b, c, d⟩

/-- Golden ratio norm square identity: (φ⁻¹/2)² + (1/2)² + (φ/2)² = 1. -/
theorem golden_ratio_norm_sq_sum : (φ⁻¹ / 2) ^ 2 + (1 / 2 : ℝ) ^ 2 + (φ / 2) ^ 2 = 1 := by
  rw [phi_inv]; nlinarith [phi_sq]

/-- The 8 Lipschitz units: ±1, ±i, ±j, ±k. -/
def lipschitzUnits : Finset ℍ[ℝ] :=
  { q 1 0 0 0, q (-1) 0 0 0, q 0 1 0 0, q 0 (-1) 0 0,
    q 0 0 1 0, q 0 0 (-1) 0, q 0 0 0 1, q 0 0 0 (-1) }

/-- The 16 Hurwitz units: (±1/2, ±1/2, ±1/2, ±1/2). -/
def hurwitzUnits : Finset ℍ[ℝ] :=
  (Finset.univ : Finset (Bool × Bool × Bool × Bool)).image fun ⟨s0, s1, s2, s3⟩ =>
    let f (b : Bool) : ℝ := if b then (1 / 2) else (-1 / 2)
    q (f s0) (f s1) (f s2) (f s3)

/-- The 24 binary tetrahedral units (Lipschitz + Hurwitz units). -/
def binaryTetrahedralUnits : Finset ℍ[ℝ] :=
  lipschitzUnits ∪ hurwitzUnits

/-- The 12 even coordinate permutations of (0, a, b, c) in ℍ[ℝ]. -/
def evenPermutations (a b c : ℝ) : Finset ℍ[ℝ] :=
  { q 0 a b c, q 0 b c a, q 0 c a b,
    q a 0 c b, q b 0 a c, q c 0 b a,
    q b c 0 a, q a b 0 c, q c a 0 b,
    q c b a 0, q a c b 0, q b a c 0 }

/-- The 96 icosahedral units: all even permutations of (0, ±φ⁻¹/2, ±1/2, ±φ/2). -/
def icosahedralUnits : Finset ℍ[ℝ] :=
  (Finset.univ : Finset (Bool × Bool × Bool)).biUnion fun ⟨s0, s1, s2⟩ =>
    let a := if s0 then φ⁻¹ / 2 else -φ⁻¹ / 2
    let b := if s1 then 1 / 2 else -1 / 2
    let c := if s2 then φ / 2 else -φ / 2
    evenPermutations a b c

/-- The 120 elements of the binary icosahedral group in ℍ[ℝ]. -/
def binaryIcosahedralUnits : Finset ℍ[ℝ] :=
  binaryTetrahedralUnits ∪ icosahedralUnits

lemma normSq_q (a b c d : ℝ) : Quaternion.normSq (q a b c d) = a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 :=
  Quaternion.normSq_def' ⟨a, b, c, d⟩

lemma lipschitzUnits_normSq {u : ℍ[ℝ]} (h : u ∈ lipschitzUnits) : Quaternion.normSq u = 1 := by
  simp only [lipschitzUnits, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> { rw [normSq_q]; ring }

lemma hurwitzUnits_normSq {u : ℍ[ℝ]} (h : u ∈ hurwitzUnits) : Quaternion.normSq u = 1 := by
  simp only [hurwitzUnits, Finset.mem_image, Finset.mem_univ, true_and] at h
  rcases h with ⟨⟨_ | _, _ | _, _ | _, _ | _⟩, rfl⟩ <;> { dsimp; rw [normSq_q]; ring }

lemma evenPermutations_normSq (a b c : ℝ) {u : ℍ[ℝ]} (h : u ∈ evenPermutations a b c) :
    Quaternion.normSq u = a ^ 2 + b ^ 2 + c ^ 2 := by
  simp only [evenPermutations, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    { rw [normSq_q]; ring }

lemma icosahedralUnits_normSq {u : ℍ[ℝ]} (h : u ∈ icosahedralUnits) : Quaternion.normSq u = 1 := by
  simp only [icosahedralUnits, Finset.mem_biUnion, Finset.mem_univ, true_and] at h
  rcases h with ⟨⟨_ | _, _ | _, _ | _⟩, hu⟩ <;>
    { rw [evenPermutations_normSq _ _ _ hu]; dsimp; simp only [neg_div, neg_sq, golden_ratio_norm_sq_sum] }

lemma binaryTetrahedralUnits_normSq {u : ℍ[ℝ]} (h : u ∈ binaryTetrahedralUnits) :
    Quaternion.normSq u = 1 :=
  (Finset.mem_union.mp h).elim lipschitzUnits_normSq hurwitzUnits_normSq

lemma binaryIcosahedralUnits_normSq {u : ℍ[ℝ]} (h : u ∈ binaryIcosahedralUnits) :
    Quaternion.normSq u = 1 :=
  (Finset.mem_union.mp h).elim binaryTetrahedralUnits_normSq icosahedralUnits_normSq

/-- Coercion from a quaternion with unit norm into the unit group `ℍ[ℝ]ˣ`. -/
def toUnit (u : ℍ[ℝ]) (h : Quaternion.normSq u = 1) : ℍ[ℝ]ˣ :=
  ⟨u, star u, by rw [Quaternion.self_mul_star, h, Quaternion.coe_one],
              by rw [Quaternion.star_mul_self, h, Quaternion.coe_one]⟩

lemma toUnit_injective {u₁ u₂ : ℍ[ℝ]} (h₁ : Quaternion.normSq u₁ = 1) (h₂ : Quaternion.normSq u₂ = 1)
    (h : toUnit u₁ h₁ = toUnit u₂ h₂) : u₁ = u₂ :=
  Units.ext_iff.mp h

/-- The finset of 120 unit quaternions in `ℍ[ℝ]ˣ`. -/
def binaryIcosahedralFinset : Finset ℍ[ℝ]ˣ :=
  binaryIcosahedralUnits.attach.map ⟨fun ⟨u, hu⟩ => toUnit u (binaryIcosahedralUnits_normSq hu),
    fun _ _ h => Subtype.ext (Units.ext_iff.mp h)⟩

/-- The binary icosahedral group $I^* \subset ℍ[ℝ]^\times$, defined as the subgroup generated
by the 120 binary icosahedral unit quaternions. -/
def binaryIcosahedral : Subgroup ℍ[ℝ]ˣ :=
  Subgroup.closure (binaryIcosahedralFinset : Set ℍ[ℝ]ˣ)

/-- The binary tetrahedral group $2T \subset ℍ[ℝ]^\times$, defined as the subgroup generated
by the 24 binary tetrahedral unit quaternions. -/
def binaryTetrahedralFinset : Finset ℍ[ℝ]ˣ :=
  binaryTetrahedralUnits.attach.map ⟨fun ⟨u, hu⟩ => toUnit u (binaryTetrahedralUnits_normSq hu),
    fun _ _ h => Subtype.ext (Units.ext_iff.mp h)⟩

/-- The binary tetrahedral group $2T \le ℍ[ℝ]^\times$. -/
def binaryTetrahedral : Subgroup ℍ[ℝ]ˣ :=
  Subgroup.closure (binaryTetrahedralFinset : Set ℍ[ℝ]ˣ)

/-- Binary tetrahedral is a subgroup of binary icosahedral: $2T \le I^*$. -/
theorem binaryTetrahedral_le_binaryIcosahedral : binaryTetrahedral ≤ binaryIcosahedral := by
  apply Subgroup.closure_mono
  intro x hx
  simp only [binaryTetrahedralFinset, Finset.mem_coe, Finset.mem_map, Finset.mem_attach,
    true_and, Subtype.exists] at hx
  rcases hx with ⟨u, hu, rfl⟩
  simp only [binaryIcosahedralFinset, Finset.mem_coe, Finset.mem_map, Finset.mem_attach,
    true_and, Subtype.exists]
  exact ⟨u, Finset.mem_union_left _ hu, rfl⟩

/-- Group closure property: identity element. -/
theorem mem_binaryIcosahedral_one : (1 : ℍ[ℝ]ˣ) ∈ binaryIcosahedral :=
  binaryIcosahedral.one_mem

/-- Group closure property: closure under quaternion multiplication. -/
theorem mem_binaryIcosahedral_mul {g h : ℍ[ℝ]ˣ} (hg : g ∈ binaryIcosahedral) (hh : h ∈ binaryIcosahedral) :
    g * h ∈ binaryIcosahedral :=
  binaryIcosahedral.mul_mem hg hh

/-- Group closure property: closure under quaternion inversion. -/
theorem mem_binaryIcosahedral_inv {g : ℍ[ℝ]ˣ} (hg : g ∈ binaryIcosahedral) :
    g⁻¹ ∈ binaryIcosahedral :=
  binaryIcosahedral.inv_mem hg

/-- Central inversion element -1 in ℍ[ℝ]ˣ. -/
def centralInv : ℍ[ℝ]ˣ :=
  toUnit (q (-1) 0 0 0) (by rw [normSq_q]; ring)

lemma mem_binaryIcosahedral_centralInv : centralInv ∈ binaryIcosahedral := by
  apply Subgroup.subset_closure
  simp only [binaryIcosahedralFinset, Finset.mem_coe, Finset.mem_map, Finset.mem_attach,
    true_and, Subtype.exists]
  exact ⟨q (-1) 0 0 0, by simp [binaryIcosahedralUnits, binaryTetrahedralUnits, lipschitzUnits], rfl⟩

lemma centralInv_ne_one : centralInv ≠ 1 := by
  intro h
  have := congr_arg (fun u : ℍ[ℝ]ˣ => (u : ℍ[ℝ]).re) h
  dsimp [centralInv, toUnit, q] at this
  norm_num at this

/-- The center of the binary icosahedral group: $Z(I^*) = \{1, -1\}$. -/
def binaryIcosahedralCenter : Finset ℍ[ℝ]ˣ := {1, centralInv}

/-- The elements of the center of $I^*$ are exactly identity and central inversion. -/
lemma binaryIcosahedral_center_elements :
    ∀ g ∈ binaryIcosahedralCenter, g = 1 ∨ g = centralInv := by
  intro g hg; simp only [binaryIcosahedralCenter, Finset.mem_insert, Finset.mem_singleton] at hg; exact hg

/-- Center identification theorem: $Z(I^*) = \{1, -1\}$ has order 2. -/
theorem binaryIcosahedral_center :
    binaryIcosahedralCenter = {1, centralInv} ∧
    binaryIcosahedralCenter.card = 2 :=
  ⟨rfl, Finset.card_pair centralInv_ne_one.symm⟩

/-- The order of the icosahedral quotient $I = I^* / Z(I^*)$ is 60: $|I^*| / |Z(I^*)| = 120 / 2 = 60$. -/
theorem binaryIcosahedral_quotient_order_sixty :
    (120 : ℕ) / binaryIcosahedralCenter.card = 60 := by
  rw [binaryIcosahedral_center.2]

end PoincareDodecahedron


