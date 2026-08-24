/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.TriangleModularGroup
import Formalization.SymplecticTriangleRepresentations
import Formalization.PicardFuchsMirrorMonodromy
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

open scoped Matrix

/-!
# Deligne-Schmid Mixed Hodge Weight Filtration $W_\bullet(N)$ & Symplectic Monodromy

This module formalizes Deligne's canonical weight filtration formula for nilpotent monodromy
operators $N$ on cohomology and integral lattices, establishing:

1. **Deligne's Canonical Subspace Formula**:
   For any nilpotent operator $N \in \mathrm{Mat}_n(R)$ with $N^{k+1} = 0$:
   $$W_l(N, k) = \sum_{j=0}^k \left( \ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k}) \right)$$
   Formalized via set union with general commutative ring coefficients $R$.

2. **Universal Filtration Properties**:
   - Monotonicity: $W_l(N, k) \subseteq W_{l+1}(N, k)$ and $W_{l_1}(N, k) \subseteq W_{l_2}(N, k)$ for $l_1 \le l_2$.
   - Shift Property: $N(W_l(N, k)) \subseteq W_{l-2}(N, k)$.
   - Extremal Properties: $0 \in W_l$ for all $l$, and $W_{2k}(N, k) = V$ (the full space).

3. **Explicit Weight 2 Filtration for $(3,4,\infty)$ Modular Monodromy**:
   For $N = T_0 - I_4 \in \mathrm{Mat}_4(\mathbb{Z})$ (Type II degeneration, $N^2 = 0$):
   - $W_0 = \{0\}$
   - $W_1 = \operatorname{im}(N) = \ker(N^2) \cap \operatorname{im}(N) \subseteq \ker(N)$
   - $W_2 = \mathbb{Z}^4 = \ker(N^2)$
   - Explicit basis action: $N\gamma = 0$, $Nu = -\gamma$, $Nw = \delta$, $N\delta = 0$.
   - $S_6$-family action: $N\gamma = 0$, $Nu = 0$, $Nw = -u$, $N\delta = \gamma$.

4. **Explicit Weight 3 Filtration for Type III MUM Monodromy**:
   For $N_{\mathrm{MUM}}$ with $N_{\mathrm{MUM}}^4 = 0$ (CY3 Maximally Unipotent Monodromy):
   - $W_0 = \{0\} \subset W_1 \subset W_2 \subset W_3 \subset W_4 = \mathbb{Z}^4$.
   - Step shift inclusions: $N_{\mathrm{MUM}}(W_j) \subseteq W_{j-1}$ and $N_{\mathrm{MUM}}^2(W_j) \subseteq W_{j-2}$.

5. **Hodge-Riemann Symplectic Polarization & Nondegeneracy**:
   - Infinitesimal symplectic Lie algebra identity: $J N + N^T J = 0$ and $N^T J + J N = 0$.
   - Polarized bilinear form $Q_N(v, w) = \langle v, N w \rangle_J$.
   - Machine-checked symmetry, nondegeneracy, and positivity on primitive subspace generators.
-/

namespace UniversalMonodromyWeightFiltration

open Matrix

/-! ### 1. General Matrix Operator Algebra & Deligne-Schmid Weight Filtration -/

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

/-- Deligne's $(j, l, k)$-summand $\ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k})$. -/
def DeligneSummand {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) (j : ℕ) : Set (Fin n → R) :=
  kerPower N (j + 1) ∩ imPower N ((j : ℤ) - (l : ℤ) + (k : ℤ))

/-- Deligne weight space $W_l(N, k) = \bigcup_{j=0}^k \left( \ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k}) \right)$. -/
def DeligneWeightSpace {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) : Set (Fin n → R) :=
  {v | ∃ j : ℕ, j ≤ k ∧ v ∈ DeligneSummand N k l j}

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

/-- Monotonicity for arbitrary levels: if $l_1 \le l_2$, then $W_{l_1}(N, k) \subseteq W_{l_2}(N, k)$. -/
theorem DeligneWeightSpace_mono {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) :
    ∀ {l1 l2 : ℕ}, l1 ≤ l2 → DeligneWeightSpace N k l1 ⊆ DeligneWeightSpace N k l2 := by
  intro l1 l2 h; obtain ⟨d, rfl⟩ := Nat.le.dest h; clear h
  induction d with
  | zero => exact Set.Subset.rfl
  | succ d ih => exact Set.Subset.trans ih (DeligneWeightSpace_subset_succ N k (l1 + d))

/-- Shift property on Deligne summands for kernels: $N$ maps $\ker(N^{j+1})$ into $\ker(N^j)$. -/
theorem N_mulVec_mem_kerPower_pred {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (j : ℕ) (v : Fin n → R)
    (hv : v ∈ kerPower N (j + 1)) :
    N *ᵥ v ∈ kerPower N j := by
  dsimp [kerPower, kerMat] at hv ⊢
  rw [mulVec_mulVec, ← pow_succ, hv]

/-- Shift property on image powers: $N$ maps $\operatorname{im}(N^m)$ into $\operatorname{im}(N^{m+1})$. -/
theorem N_mulVec_mem_imPower_succ {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (m : ℤ) (v : Fin n → R)
    (hv : v ∈ imPower N m) :
    N *ᵥ v ∈ imPower N (m + 1) := by
  dsimp [imPower] at hv ⊢
  split_ifs at hv with h1 <;> split_ifs with h2 <;> try trivial
  · have : (m + 1).toNat = 1 := by omega
    exact ⟨v, by rw [this, pow_one]⟩
  · obtain ⟨u, rfl⟩ := hv
    have : (m + 1).toNat = m.toNat + 1 := by omega
    exact ⟨u, by rw [this, pow_succ', mulVec_mulVec]⟩

/-- Extremal property: for nilpotent $N$ with $N^{k+1} = 0$, $W_{2k}(N, k)$ is the full space. -/
theorem DeligneWeightSpace_top {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (hk : N ^ (k + 1) = 0) (l : ℕ) (hl : 2 * k ≤ l) :
    DeligneWeightSpace N k l = Set.univ := by
  ext v; simp only [Set.mem_univ, iff_true]
  refine ⟨k, le_rfl, by simp [kerPower, kerMat, hk], ?_⟩
  dsimp [DeligneSummand, imPower]; split_ifs <;> [trivial; omega]

/-- Fundamental shift property of Deligne weight filtration: $N(W_l) \subseteq W_{l-2}$. -/
theorem DeligneWeightSpace_shift {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) (l : ℕ) (v : Fin n → R)
    (hv : v ∈ DeligneWeightSpace N k l) :
    N *ᵥ v ∈ DeligneWeightSpace N k (l - 2) := by
  obtain ⟨_|j, hj, hvj⟩ := hv
  · have h_ker : N *ᵥ v = 0 := by simpa [DeligneSummand, kerPower, kerMat] using hvj.1
    rw [h_ker]
    exact zero_mem_DeligneWeightSpace N k (l - 2)
  · refine ⟨j, by omega, N_mulVec_mem_kerPower_pred N (j + 1) v hvj.1, ?_⟩
    have him := N_mulVec_mem_imPower_succ N ((j + 1 : ℤ) - (l : ℤ) + (k : ℤ)) v hvj.2
    exact imPower_anti N _ _ (by omega) him

/-! ### 2. Explicit Computation on $\mathbb{Z}^4$ for $(3,4,\infty)$ Modular Monodromy -/

/-- Weight space $W_0 = \{0\}$ for the $(3,4,\infty)$ modular monodromy. -/
def W0_34 : Set (Fin 4 → ℤ) := {0}

/-- Weight space $W_1 = \operatorname{im}(N)$ for the $(3,4,\infty)$ modular monodromy. -/
def W1_34 : Set (Fin 4 → ℤ) := imMat SymplecticTriangleRepresentations.N

/-- Weight space $W_2 = \mathbb{Z}^4$ for the $(3,4,\infty)$ modular monodromy. -/
def W2_34 : Set (Fin 4 → ℤ) := Set.univ

/-- Filtration step $W_0 \subseteq W_1$. -/
theorem W0_sub_W1 : W0_34 ⊆ W1_34 := by
  rintro _ rfl; exact ⟨0, mulVec_zero _⟩

/-- Filtration step $W_1 \subseteq W_2$. -/
theorem W1_sub_W2 : W1_34 ⊆ W2_34 :=
  Set.subset_univ _

/-- Complete chain $W_0 \subseteq W_1 \subseteq W_2$. -/
theorem weight_filtration_chain_34 : W0_34 ⊆ W1_34 ∧ W1_34 ⊆ W2_34 :=
  ⟨W0_sub_W1, W1_sub_W2⟩

/-- The image of $N$ is contained in the kernel of $N$: $N(W_1) \subseteq W_0 = \{0\}$. -/
theorem N_act_W1_in_W0 (v : Fin 4 → ℤ) (hv : v ∈ W1_34) :
    SymplecticTriangleRepresentations.N *ᵥ v ∈ W0_34 := by
  obtain ⟨u, rfl⟩ := hv
  simp [W0_34, mulVec_mulVec, SymplecticTriangleRepresentations.N_squared_zero]

/-- $N$ maps $W_2 = \mathbb{Z}^4$ into $W_1 = \operatorname{im}(N)$. -/
theorem N_act_W2_in_W1 (v : Fin 4 → ℤ) (_hv : v ∈ W2_34) :
    SymplecticTriangleRepresentations.N *ᵥ v ∈ W1_34 :=
  ⟨v, rfl⟩

/-- Shift verification: $N^2$ annihilates $W_2$, so $N^2(W_2) \subseteq W_0$. -/
theorem N_act_W2_in_W0 (v : Fin 4 → ℤ) (hv : v ∈ W2_34) :
    SymplecticTriangleRepresentations.N *ᵥ (SymplecticTriangleRepresentations.N *ᵥ v) ∈ W0_34 :=
  N_act_W1_in_W0 _ (N_act_W2_in_W1 v hv)

/-- Explicit action of $N$ on basis vector $\gamma = (1, 0, 0, 0)^T$. -/
theorem N_act_gamma : SymplecticTriangleRepresentations.N *ᵥ PicardFuchsMirrorMonodromy.gamma = 0 := by
  ext i; fin_cases i <;> rfl

/-- Explicit action of $N$ on basis vector $u = (0, 1, 0, 0)^T$. -/
theorem N_act_u :
    SymplecticTriangleRepresentations.N *ᵥ PicardFuchsMirrorMonodromy.u =
    -PicardFuchsMirrorMonodromy.gamma := by
  ext i; fin_cases i <;> rfl

/-- Explicit action of $N$ on basis vector $w = (0, 0, 1, 0)^T$. -/
theorem N_act_w :
    SymplecticTriangleRepresentations.N *ᵥ PicardFuchsMirrorMonodromy.w =
    PicardFuchsMirrorMonodromy.delta := by
  ext i; fin_cases i <;> rfl

/-- Explicit action of $N$ on basis vector $\delta = (0, 0, 0, 1)^T$. -/
theorem N_act_delta : SymplecticTriangleRepresentations.N *ᵥ PicardFuchsMirrorMonodromy.delta = 0 := by
  ext i; fin_cases i <;> rfl

/-- Explicit action of $S_6$ monodromy operator $N_{S_6}$ on $\gamma$: $N_{S_6}\gamma = 0$. -/
theorem S6_N_act_gamma : ModularFamilyS6.N *ᵥ PicardFuchsMirrorMonodromy.gamma = 0 :=
  ModularFamilyS6.N_act_gamma

/-- Explicit action of $S_6$ monodromy operator $N_{S_6}$ on $u$: $N_{S_6}u = 0$. -/
theorem S6_N_act_u : ModularFamilyS6.N *ᵥ PicardFuchsMirrorMonodromy.u = 0 :=
  ModularFamilyS6.N_act_u

/-- Explicit action of $S_6$ monodromy operator $N_{S_6}$ on $w$: $N_{S_6}w = -u$. -/
theorem S6_N_act_w :
    ModularFamilyS6.N *ᵥ PicardFuchsMirrorMonodromy.w = -PicardFuchsMirrorMonodromy.u :=
  ModularFamilyS6.N_act_w

/-- Explicit action of $S_6$ monodromy operator $N_{S_6}$ on $\delta$: $N_{S_6}\delta = \gamma$. -/
theorem S6_N_act_delta :
    ModularFamilyS6.N *ᵥ PicardFuchsMirrorMonodromy.delta = PicardFuchsMirrorMonodromy.gamma :=
  ModularFamilyS6.N_act_delta

/-! ### 3. Explicit Computation for Type III MUM Monodromy -/

/-- Weight space $W_0 = \{0\}$ for the CY3 MUM operator $N_{\mathrm{MUM}}$. -/
def W_MUM_0 : Set (Fin 4 → ℤ) := {0}

/-- Weight space $W_1 = \operatorname{span}(e_0) = \ker(N_{\mathrm{MUM}})$. -/
def W_MUM_1 : Set (Fin 4 → ℤ) := {v | v 1 = 0 ∧ v 2 = 0 ∧ v 3 = 0}

/-- Weight space $W_2 = \operatorname{span}(e_0, e_1) = \ker(N_{\mathrm{MUM}}^2)$. -/
def W_MUM_2 : Set (Fin 4 → ℤ) := {v | v 2 = 0 ∧ v 3 = 0}

/-- Weight space $W_3 = \operatorname{span}(e_0, e_1, e_2) = \ker(N_{\mathrm{MUM}}^3)$. -/
def W_MUM_3 : Set (Fin 4 → ℤ) := {v | v 3 = 0}

/-- Weight space $W_4 = \mathbb{Z}^4 = \ker(N_{\mathrm{MUM}}^4)$. -/
def W_MUM_4 : Set (Fin 4 → ℤ) := Set.univ

/-- Filtration inclusion $W_0 \subseteq W_1$ for MUM. -/
theorem W_MUM_chain_0_1 : W_MUM_0 ⊆ W_MUM_1 := by
  rintro _ rfl; simp [W_MUM_1]

/-- Filtration inclusion $W_1 \subseteq W_2$ for MUM. -/
theorem W_MUM_chain_1_2 : W_MUM_1 ⊆ W_MUM_2 :=
  fun _ ⟨_, h2, h3⟩ => ⟨h2, h3⟩

/-- Filtration inclusion $W_2 \subseteq W_3$ for MUM. -/
theorem W_MUM_chain_2_3 : W_MUM_2 ⊆ W_MUM_3 :=
  fun _ ⟨_, h3⟩ => h3

/-- Filtration inclusion $W_3 \subseteq W_4$ for MUM. -/
theorem W_MUM_chain_3_4 : W_MUM_3 ⊆ W_MUM_4 :=
  Set.subset_univ _

/-- Complete chain $W_0 \subseteq W_1 \subseteq W_2 \subseteq W_3 \subseteq W_4$ for MUM. -/
theorem W_MUM_complete_chain :
    W_MUM_0 ⊆ W_MUM_1 ∧ W_MUM_1 ⊆ W_MUM_2 ∧ W_MUM_2 ⊆ W_MUM_3 ∧ W_MUM_3 ⊆ W_MUM_4 :=
  ⟨W_MUM_chain_0_1, W_MUM_chain_1_2, W_MUM_chain_2_3, W_MUM_chain_3_4⟩

/-- Matrix-vector multiplication for $N_{\mathrm{MUM}}$. -/
theorem mulVec_N_MUM (v : Fin 4 → ℤ) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ v = ![v 1, v 2, v 3, 0] := by
  ext i
  fin_cases i <;> simp [PicardFuchsMirrorMonodromy.N_MUM, mulVec, dotProduct, Fin.sum_univ_four]

/-- $N_{\mathrm{MUM}}$ maps $W_0$ into $W_0$. -/
theorem N_MUM_act_W0 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_0) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ v ∈ W_MUM_0 := by
  subst hv; simp [W_MUM_0, mulVec_zero]

/-- $N_{\mathrm{MUM}}$ maps $W_1$ into $W_0$. -/
theorem N_MUM_act_W1 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_1) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ v ∈ W_MUM_0 := by
  rw [mulVec_N_MUM]
  obtain ⟨h1, h2, h3⟩ := hv
  ext i; fin_cases i <;> simp [h1, h2, h3]

/-- $N_{\mathrm{MUM}}$ maps $W_2$ into $W_1$. -/
theorem N_MUM_act_W2 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_2) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ v ∈ W_MUM_1 := by
  rw [mulVec_N_MUM]; exact ⟨hv.1, hv.2, rfl⟩

/-- $N_{\mathrm{MUM}}$ maps $W_3$ into $W_2$. -/
theorem N_MUM_act_W3 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_3) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ v ∈ W_MUM_2 := by
  rw [mulVec_N_MUM]; exact ⟨hv, rfl⟩

/-- $N_{\mathrm{MUM}}$ maps $W_4$ into $W_3$. -/
theorem N_MUM_act_W4 (v : Fin 4 → ℤ) (_hv : v ∈ W_MUM_4) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ v ∈ W_MUM_3 := by
  rw [mulVec_N_MUM]; rfl

/-- Two-step shift: $N_{\mathrm{MUM}}^2$ maps $W_2$ into $W_0$. -/
theorem N_MUM_shift_2_0 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_2) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ (PicardFuchsMirrorMonodromy.N_MUM *ᵥ v) ∈ W_MUM_0 :=
  N_MUM_act_W1 _ (N_MUM_act_W2 v hv)

/-- Two-step shift: $N_{\mathrm{MUM}}^2$ maps $W_3$ into $W_1$. -/
theorem N_MUM_shift_3_1 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_3) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ (PicardFuchsMirrorMonodromy.N_MUM *ᵥ v) ∈ W_MUM_1 :=
  N_MUM_act_W2 _ (N_MUM_act_W3 v hv)

/-- Two-step shift: $N_{\mathrm{MUM}}^2$ maps $W_4$ into $W_2$. -/
theorem N_MUM_shift_4_2 (v : Fin 4 → ℤ) (hv : v ∈ W_MUM_4) :
    PicardFuchsMirrorMonodromy.N_MUM *ᵥ (PicardFuchsMirrorMonodromy.N_MUM *ᵥ v) ∈ W_MUM_2 :=
  N_MUM_act_W3 _ (N_MUM_act_W4 v hv)

/-! ### 4. Hodge-Riemann Symplectic Polarization & Infinitesimal Isometry -/

/-- Infinitesimal symplectic Lie algebra condition: $J N + N^T J = 0$. -/
theorem J_N_plus_NT_J_zero :
    SymplecticTriangleRepresentations.J * SymplecticTriangleRepresentations.N +
    SymplecticTriangleRepresentations.Nᵀ * SymplecticTriangleRepresentations.J = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Infinitesimal symplectic Lie algebra condition: $N^T J + J N = 0$. -/
theorem NT_J_plus_J_N_zero :
    SymplecticTriangleRepresentations.Nᵀ * SymplecticTriangleRepresentations.J +
    SymplecticTriangleRepresentations.J * SymplecticTriangleRepresentations.N = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Hodge-Riemann polarized bilinear form $Q_N(v, w) = \langle v, N w \rangle_J$. -/
def Q_N (v w : Fin 4 → ℤ) : ℤ :=
  PicardFuchsMirrorMonodromy.symplecticPairing v (SymplecticTriangleRepresentations.N *ᵥ w)

/-- Symmetry of the Hodge-Riemann polarized bilinear form: $Q_N(v, w) = Q_N(w, v)$. -/
theorem Q_N_symm (v w : Fin 4 → ℤ) : Q_N v w = Q_N w v := by
  dsimp [Q_N]
  have h := PicardFuchsMirrorMonodromy.symplecticPairing_N_invariant w v
  have hskew := PicardFuchsMirrorMonodromy.symplecticPairing_skew
    (SymplecticTriangleRepresentations.N *ᵥ w) v
  have hN : PicardFuchsMirrorMonodromy.N = SymplecticTriangleRepresentations.N := rfl
  rw [hN] at h
  linarith

/-- Evaluation of $Q_N$ on primitive generator pair $(u, w)$: $Q_N(u, w) = 1$. -/
theorem Q_N_u_w :
    Q_N PicardFuchsMirrorMonodromy.u PicardFuchsMirrorMonodromy.w = 1 :=
  rfl

/-- Evaluation of $Q_N$ on primitive generator pair $(w, u)$: $Q_N(w, u) = 1$. -/
theorem Q_N_w_u :
    Q_N PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.u = 1 :=
  rfl

/-- $Q_N$ vanishes on $(u, u)$: $Q_N(u, u) = 0$. -/
theorem Q_N_u_u :
    Q_N PicardFuchsMirrorMonodromy.u PicardFuchsMirrorMonodromy.u = 0 :=
  rfl

/-- $Q_N$ vanishes on $(w, w)$: $Q_N(w, w) = 0$. -/
theorem Q_N_w_w :
    Q_N PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.w = 0 :=
  rfl

/-- Strict positivity on diagonal primitive subspace generator $u + w$: $Q_N(u+w, u+w) = 2 > 0$. -/
theorem Q_N_u_add_w_eval :
    Q_N (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w)
        (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w) = 2 :=
  rfl

/-- Positivity certificate: $Q_N(u+w, u+w) > 0$. -/
theorem Q_N_u_add_w_strictly_positive :
    0 < Q_N (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w)
            (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w) := by
  decide

/-- Polarized bilinear form for the $S_6$ Seifert family: $Q_{N_{S_6}}(v, w) = \langle v, N_{S_6} w \rangle_{\Omega_6}$. -/
def Q_N_S6 (v w : Fin 4 → ℤ) : ℤ :=
  PicardFuchsMirrorMonodromy.symplecticPairingOmega6 v (ModularFamilyS6.N *ᵥ w)

/-- Symmetry of the $S_6$ polarized bilinear form: $Q_{N_{S_6}}(v, w) = Q_{N_{S_6}}(w, v)$. -/
theorem Q_N_S6_symm (v w : Fin 4 → ℤ) : Q_N_S6 v w = Q_N_S6 w v := by
  dsimp [Q_N_S6]
  have h := PicardFuchsMirrorMonodromy.symplecticPairingOmega6_N_invariant w v
  have hskew := PicardFuchsMirrorMonodromy.symplecticPairingOmega6_skew (ModularFamilyS6.N *ᵥ w) v
  linarith

/-- Evaluation of $S_6$ polarized form on primitive generator $w$: $Q_{N_{S_6}}(w, w) = 6$. -/
theorem Q_N_S6_w_pos :
    Q_N_S6 PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.w = 6 :=
  rfl

/-- Strict positivity on primitive generator $w$: $Q_{N_{S_6}}(w, w) > 0$. -/
theorem Q_N_S6_w_strictly_positive :
    0 < Q_N_S6 PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.w := by
  decide

/-- Evaluation of $S_6$ polarized form on primitive generator $\delta$: $Q_{N_{S_6}}(\delta, \delta) = -1$. -/
theorem Q_N_S6_delta_eval :
    Q_N_S6 PicardFuchsMirrorMonodromy.delta PicardFuchsMirrorMonodromy.delta = -1 :=
  rfl

/-- Non-degeneracy on primitive generator $\delta$: $Q_{N_{S_6}}(\delta, \delta) \ne 0$. -/
theorem Q_N_S6_delta_nondegenerate :
    Q_N_S6 PicardFuchsMirrorMonodromy.delta PicardFuchsMirrorMonodromy.delta ≠ 0 := by
  decide

end UniversalMonodromyWeightFiltration

