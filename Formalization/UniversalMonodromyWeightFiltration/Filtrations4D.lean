/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.UniversalMonodromyWeightFiltration.FiltrationProperties
import Formalization.TriangleModularGroup
import Formalization.SymplecticTriangleRepresentations
import Formalization.PicardFuchsMirrorMonodromy
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases

open scoped Matrix

/-!
# 4D Nilpotent Monodromy Weight Filtrations: Type II vs Type III MUM

This submodule computes and verifies the explicit weight filtrations on the lattice $\mathbb{Z}^4$
for two canonical geometric degenerations:
1. **Type II Degeneration (Abelian Surfaces)**: The unipotent cusp monodromy for $\Delta(3,4,\infty)$
   with $N^2 = 0$, yielding a 2-step filtration $W_0 \subset W_1 \subset W_2$.
2. **Type III Degeneration (CY3 Maximally Unipotent Monodromy)**: The standard MUM nilpotent
   operator $N_{\mathrm{MUM}}$ with $N_{\mathrm{MUM}}^4 = 0$ and $N_{\mathrm{MUM}}^3 \ne 0$,
   yielding a complete 4-step filtration $W_0 \subset W_1 \subset W_2 \subset W_3 \subset W_4$.

## Mathematical Overview

### 1. Type II Filtration for $(3,4,\infty)$
For $N = T_0 - I_4 \in \mathrm{Mat}_4(\mathbb{Z})$:
- $W_0 = \{0\}$
- $W_1 = \operatorname{im}(N) \subseteq \ker(N)$ (rank 2 isotropic subspace)
- $W_2 = \mathbb{Z}^4 = \ker(N^2)$ (full space)
- Nilpotent action on the geometric basis $(\gamma, u, w, \delta)$:
  $$N\gamma = 0, \quad Nu = -\gamma, \quad Nw = \delta, \quad N\delta = 0$$
- Action of the $S_6$-family nilpotent operator $N_{S_6}$:
  $$N_{S_6}\gamma = 0, \quad N_{S_6}u = 0, \quad N_{S_6}w = -u, \quad N_{S_6}\delta = \gamma$$

### 2. Type III MUM Filtration for Calabi-Yau 3-folds
For the standard Jordan block nilpotent operator $N_{\mathrm{MUM}}$:
- $W_0 = \{0\}$
- $W_1 = \operatorname{span}(e_0) = \ker(N_{\mathrm{MUM}})$
- $W_2 = \operatorname{span}(e_0, e_1) = \ker(N_{\mathrm{MUM}}^2)$
- $W_3 = \operatorname{span}(e_0, e_1, e_2) = \ker(N_{\mathrm{MUM}}^3)$
- $W_4 = \mathbb{Z}^4 = \ker(N_{\mathrm{MUM}}^4)$
- Step shift inclusions: $N_{\mathrm{MUM}}(W_j) \subseteq W_{j-1}$ and $N_{\mathrm{MUM}}^2(W_j) \subseteq W_{j-2}$.

## Main Declarations

- `UniversalMonodromyWeightFiltration.W0_34`, `W1_34`, `W2_34`: Weight spaces for $(3,4,\infty)$.
- `UniversalMonodromyWeightFiltration.W0_sub_W1`, `W1_sub_W2`, `weight_filtration_chain_34`: Verified chain inclusions.
- `UniversalMonodromyWeightFiltration.N_act_W1_in_W0`, `N_act_W2_in_W1`, `N_act_W2_in_W0`: Step shifts.
- `UniversalMonodromyWeightFiltration.N_act_gamma`, `N_act_u`, `N_act_w`, `N_act_delta`: Action on geometric basis.
- `UniversalMonodromyWeightFiltration.S6_N_act_gamma`, `S6_N_act_u`, `S6_N_act_w`, `S6_N_act_delta`: $S_6$ action.
- `UniversalMonodromyWeightFiltration.W_MUM_0` through `W_MUM_4`: Weight spaces for MUM.
- `UniversalMonodromyWeightFiltration.W_MUM_complete_chain`: Complete 4-step inclusion chain for MUM.
- `UniversalMonodromyWeightFiltration.mulVec_N_MUM`: Matrix-vector formula for $N_{\mathrm{MUM}}$.
- `UniversalMonodromyWeightFiltration.N_MUM_act_W0` through `N_MUM_act_W4`: Step shifts $N(W_j) \subseteq W_{j-1}$.
- `UniversalMonodromyWeightFiltration.N_MUM_shift_2_0`, `N_MUM_shift_3_1`, `N_MUM_shift_4_2`: 2-step shifts $N^2(W_j) \subseteq W_{j-2}$.
-/

namespace UniversalMonodromyWeightFiltration

open Matrix

/-! ### 1. Explicit Computation on $\mathbb{Z}^4$ for $(3,4,\infty)$ Modular Monodromy -/

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

/-! ### 2. Explicit Computation for Type III MUM Monodromy -/

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

end UniversalMonodromyWeightFiltration
