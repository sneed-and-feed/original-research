/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Matrix.Basic

open scoped Matrix

/-!
# Deligne's Canonical Monodromy Weight Filtration Formula

This submodule formalizes Deligne's canonical algebraic formula for the weight filtration
$W_\bullet(N)$ associated to a nilpotent monodromy operator $N$ on a module or vector space.

## Mathematical Overview

For a nilpotent operator $N \in \mathrm{End}(V)$ satisfying $N^{k+1} = 0$, Deligne's canonical
monodromy weight filtration $W_\bullet(N, k)$ is defined by the subspace sum:
$$W_l(N, k) = \sum_{j=0}^k \left( \ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k}) \right)$$
where:
- $\operatorname{im}(N^m) = V$ for $m \le 0$, and
- $\ker(N^m) = \{0\}$ for $m \le 0$.

In general commutative ring coefficients $R$, the filtration levels are represented as subsets of `Fin n → R`.

## Main Declarations

- `UniversalMonodromyWeightFiltration.kerMat`: Kernel of a matrix operator as a subset of `Fin n → R`.
- `UniversalMonodromyWeightFiltration.imMat`: Image of a matrix operator as a subset of `Fin n → R`.
- `UniversalMonodromyWeightFiltration.imPower`: Generalized image power $\operatorname{im}(N^m)$ ($V$ for $m \le 0$).
- `UniversalMonodromyWeightFiltration.kerPower`: Generalized kernel power $\ker(N^m)$.
- `UniversalMonodromyWeightFiltration.DeligneSummand`: The $(j, l, k)$-summand $\ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k})$.
- `UniversalMonodromyWeightFiltration.DeligneWeightSpace`: The weight space $W_l(N, k) = \bigcup_{j=0}^k \operatorname{DeligneSummand}(N, k, l, j)$.
- `UniversalMonodromyWeightFiltration.zero_mem_kerPower`, `zero_mem_imPower`: Zero vector inclusion.
- `UniversalMonodromyWeightFiltration.zero_mem_DeligneSummand`, `zero_mem_DeligneWeightSpace`: Zero vector inclusion for summands and weight spaces.
- `UniversalMonodromyWeightFiltration.imPower_anti`: Antitone inclusion of image powers $\operatorname{im}(N^{m_2}) \subseteq \operatorname{im}(N^{m_1})$ for $m_1 \le m_2$.
- `UniversalMonodromyWeightFiltration.DeligneSummand_subset_succ`: Step inclusion for summands.
- `UniversalMonodromyWeightFiltration.DeligneWeightSpace_subset_succ`: Step inclusion for weight spaces.
-/

namespace UniversalMonodromyWeightFiltration

open Matrix

/-! ### Kernel and Image Powers of Matrix Operators -/

/-- Kernel of matrix-vector multiplication as a subset of `Fin n → R`. -/
def kerMat {n : ℕ} {R : Type*} [CommRing R] (M : Matrix (Fin n) (Fin n) R) : Set (Fin n → R) :=
  {v | M *ᵥ v = 0}

/-- Image of matrix-vector multiplication as a subset of `Fin n → R`. -/
def imMat {n : ℕ} {R : Type*} [CommRing R] (M : Matrix (Fin n) (Fin n) R) : Set (Fin n → R) :=
  {v | ∃ u, M *ᵥ u = v}

/-- Generalized image power: $\operatorname{im}(N^m)$ for $m > 0$ and full space for $m \le 0$. -/
def imPower {n : ℕ} {R : Type*} [CommRing R] (N : Matrix (Fin n) (Fin n) R) (m : ℤ) : Set (Fin n → R) :=
  if m ≤ 0 then Set.univ else imMat (N ^ m.toNat)

/-- Generalized kernel power: $\ker(N^m)$. -/
def kerPower {n : ℕ} {R : Type*} [CommRing R] (N : Matrix (Fin n) (Fin n) R) (m : ℕ) : Set (Fin n → R) :=
  kerMat (N ^ m)

/-! ### Deligne's Weight Filtration Formula -/

/-- Deligne's $(j, l, k)$-summand $\ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k})$. -/
def DeligneSummand {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) (j : ℕ) : Set (Fin n → R) :=
  kerPower N (j + 1) ∩ imPower N ((j : ℤ) - (l : ℤ) + (k : ℤ))

/-- Deligne weight space $W_l(N, k) = \bigcup_{j=0}^k \left( \ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k}) \right)$. -/
def DeligneWeightSpace {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) : Set (Fin n → R) :=
  {v | ∃ j : ℕ, j ≤ k ∧ v ∈ DeligneSummand N k l j}

/-! ### Foundational Properties and Zero Inclusions -/

/-- The zero vector belongs to every kernel power. -/
theorem zero_mem_kerPower {n : ℕ} {R : Type*} [CommRing R] (N : Matrix (Fin n) (Fin n) R) (m : ℕ) :
    (0 : Fin n → R) ∈ kerPower N m :=
  mulVec_zero (N ^ m)

/-- The zero vector belongs to every image power. -/
theorem zero_mem_imPower {n : ℕ} {R : Type*} [CommRing R] (N : Matrix (Fin n) (Fin n) R) (m : ℤ) :
    (0 : Fin n → R) ∈ imPower N m := by
  dsimp [imPower]; split_ifs <;> [trivial; exact ⟨0, mulVec_zero _⟩]

/-- The zero vector belongs to every Deligne summand. -/
theorem zero_mem_DeligneSummand {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) (j : ℕ) :
    (0 : Fin n → R) ∈ DeligneSummand N k l j :=
  ⟨zero_mem_kerPower N (j + 1), zero_mem_imPower N (j - l + k)⟩

/-- The zero vector belongs to every Deligne weight space. -/
theorem zero_mem_DeligneWeightSpace {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) :
    (0 : Fin n → R) ∈ DeligneWeightSpace N k l :=
  ⟨0, Nat.zero_le k, zero_mem_DeligneSummand N k l 0⟩

/-- Image powers are antitone: if $m_1 \le m_2$, then $\operatorname{im}(N^{m_2}) \subseteq \operatorname{im}(N^{m_1})$. -/
theorem imPower_anti {n : ℕ} {R : Type*} [CommRing R] (N : Matrix (Fin n) (Fin n) R)
    (m1 m2 : ℤ) (h : m1 ≤ m2) :
    imPower N m2 ⊆ imPower N m1 := by
  dsimp [imPower]; split_ifs with h2 h1 <;> try (first | rfl | exact Set.subset_univ _ | exact (h1 (h.trans h2)).elim)
  rintro v ⟨u, rfl⟩; obtain ⟨d, hd⟩ := Nat.le.dest (Int.toNat_le_toNat h)
  exact ⟨(N ^ d) *ᵥ u, by rw [mulVec_mulVec, ← pow_add, hd]⟩

/-- Each Deligne summand is monotonic in the filtration level $l$:
    $\operatorname{DeligneSummand}(N, k, l, j) \subseteq \operatorname{DeligneSummand}(N, k, l+1, j)$. -/
theorem DeligneSummand_subset_succ {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) (j : ℕ) :
    DeligneSummand N k l j ⊆ DeligneSummand N k (l + 1) j :=
  fun _ ⟨hker, him⟩ => ⟨hker, imPower_anti N _ _ (by omega) him⟩

/-- The Deligne weight spaces are increasing: $W_l(N, k) \subseteq W_{l+1}(N, k)$. -/
theorem DeligneWeightSpace_subset_succ {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) :
    DeligneWeightSpace N k l ⊆ DeligneWeightSpace N k (l + 1) :=
  fun _ ⟨j, hj, hv⟩ => ⟨j, hj, DeligneSummand_subset_succ N k l j hv⟩

end UniversalMonodromyWeightFiltration
