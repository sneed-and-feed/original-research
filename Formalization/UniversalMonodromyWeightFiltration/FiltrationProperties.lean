/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.UniversalMonodromyWeightFiltration.DeligneFormula
import Mathlib.Data.Matrix.Basic

open scoped Matrix

/-!
# Universal Properties of the Deligne Weight Filtration

This submodule establishes the foundational universal theorems for the Deligne-Schmid
weight filtration $W_\bullet(N, k)$:
1. **Monotonicity**: $W_{l_1}(N, k) \subseteq W_{l_2}(N, k)$ whenever $l_1 \le l_2$.
2. **Top Space Exhaustion**: $W_{2k}(N, k) = V$ when $N^{k+1} = 0$.
3. **Weight Shift**: $N(W_l(N, k)) \subseteq W_{l-2}(N, k)$.

## Mathematical Overview

For a nilpotent operator $N$ of order $k+1$ ($N^{k+1} = 0$), the weight filtration satisfies:
- $0 = W_{-1} \subseteq W_0 \subseteq W_1 \subseteq \dots \subseteq W_{2k} = V$.
- $N(W_l) \subseteq W_{l-2}$ for all $l$.
- $N^r$ induces an isomorphism $\operatorname{Gr}_{k+r}^W \xrightarrow{\sim} \operatorname{Gr}_{k-r}^W$ (Hard Lefschetz property for monodromy weight filtration).

## Main Declarations

- `UniversalMonodromyWeightFiltration.DeligneWeightSpace_mono`: Monotonicity $l_1 \le l_2 \implies W_{l_1} \subseteq W_{l_2}$.
- `UniversalMonodromyWeightFiltration.DeligneWeightSpace_mono_le`: Monotonicity with explicit inequality hypothesis.
- `UniversalMonodromyWeightFiltration.N_mulVec_mem_kerPower_pred`: Kernel step down $N(\ker N^{j+1}) \subseteq \ker N^j$.
- `UniversalMonodromyWeightFiltration.N_mulVec_mem_imPower_succ`: Image step up $N(\operatorname{im} N^m) \subseteq \operatorname{im} N^{m+1}$.
- `UniversalMonodromyWeightFiltration.DeligneWeightSpace_top`: Top space equality $W_{2k}(N, k) = \mathrm{Set.univ}$ under $N^{k+1} = 0$.
- `UniversalMonodromyWeightFiltration.DeligneWeightSpace_shift`: Universal weight shift $N(W_l) \subseteq W_{l-2}$.
-/

namespace UniversalMonodromyWeightFiltration

open Matrix

/-! ### Monotonicity Theorems -/

/-- Monotonicity for arbitrary levels: if $l_1 \le l_2$, then $W_{l_1}(N, k) \subseteq W_{l_2}(N, k)$. -/
theorem DeligneWeightSpace_mono {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) :
    ∀ {l1 l2 : ℕ}, l1 ≤ l2 → DeligneWeightSpace N k l1 ⊆ DeligneWeightSpace N k l2 := by
  intro l1 l2 h; obtain ⟨d, rfl⟩ := Nat.le.dest h; clear h
  induction d with
  | zero => exact Set.Subset.rfl
  | succ d ih => exact Set.Subset.trans ih (DeligneWeightSpace_subset_succ N k (l1 + d))

/-- Monotonicity with explicit inequality hypothesis: $l_1 \le l_2 \implies W_{l_1}(N, k) \subseteq W_{l_2}(N, k)$. -/
theorem DeligneWeightSpace_mono_le {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (k : ℕ) {l1 l2 : ℕ} (h : l1 ≤ l2) :
    DeligneWeightSpace N k l1 ⊆ DeligneWeightSpace N k l2 :=
  DeligneWeightSpace_mono N k h

/-! ### Operator Shift on Kernels and Images -/

/-- Shift property on Deligne summands for kernels: $N$ maps $\ker(N^{j+1})$ into $\ker(N^j)$. -/
theorem N_mulVec_mem_kerPower_pred {n : ℕ} {R : Type*} [CommRing R]
    (N : Matrix (Fin n) (Fin n) R) (j : ℕ) (v : Fin n → R)
    (hv : v ∈ kerPower N (j + 1)) :
    N *ᵥ v ∈ kerPower N j := by
  dsimp [kerPower, kerMat] at hv ⊢
  rw [mulVec_mulVec, ← pow_succ, hv]

/-- Shift property on image powers: $N$ maps $\operatorname{im}(N^m)$ into $\operatorname{im}(N^{m+1}). -/
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

/-! ### Top Space and Fundamental Shift Theorems -/

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

end UniversalMonodromyWeightFiltration
