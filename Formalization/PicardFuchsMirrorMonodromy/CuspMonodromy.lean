/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.TriangleModularGroup
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Matrix.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

open scoped Matrix BigOperators
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Frobenius Local Monodromy at Cusp $z = 0$ & Monodromy Classification

This submodule formalizes the unipotent cusp monodromy matrix $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$,
the nilpotent operator $N = T_0 - I_4$, its index-2 nilpotency $N^2 = 0$ (Type II degeneration
for abelian surfaces), its explicit actions on standard and geometric bases, and the classification
against Maximally Unipotent Monodromies $N_{\mathrm{MUM}}$ (Type III degeneration for Calabi-Yau 3-folds).

## Mathematical Overview

### 1. Parabolic Cusp Monodromy $T_0$ and Nilpotent Residue $N$
Around the cusp $z = 0$, the Frobenius solutions of the order-4 Picard-Fuchs equation undergo a
unipotent monodromy transformation $T_0 = I_4 + N$, where $N \in \mathfrak{sp}_4(\mathbb{Z})$ is the
infinitesimal generator / log-monodromy operator:
$$N = T_0 - I_4$$

### 2. Nilpotency Index and Degeneration Types
- **Abelian Surface Modular Family $\Delta(3,4,\infty)$**:
  $N \ne 0$ and $N^2 = 0$, proving that this is a **Type II degeneration** (semi-abelian toric rank 1).
- **Calabi-Yau 3-Fold Maximally Unipotent Monodromy (MUM)**:
  $N_{\mathrm{MUM}}^3 \ne 0$ and $N_{\mathrm{MUM}}^4 = 0$, corresponding to a **Type III degeneration** (maximal unipotence).

### 3. Action on Geometric Basis
On the standard homology basis $(\gamma, u, w, \delta)$, the $S_6$-polarized monodromy satisfies:
$$N \gamma = 0, \quad N u = 0, \quad N w = -u, \quad N \delta = \gamma$$
and on standard basis vectors:
$$N e_0 = 0, \quad N e_1 = -e_0, \quad N e_2 = e_3, \quad N e_3 = 0$$

## Main Declarations

- `PicardFuchsMirrorMonodromy.T0`, `PicardFuchsMirrorMonodromy.N`: Cusp monodromy and nilpotent operator.
- `PicardFuchsMirrorMonodromy.N_unipotent_index_2`: Proof that $N^2 = 0$.
- `PicardFuchsMirrorMonodromy.ModularFamilyS6_N_unipotent_index_2`: Proof that $N_{S_6}^2 = 0$.
- `PicardFuchsMirrorMonodromy.N_act_gamma`, `N_act_u`, `N_act_w`, `N_act_delta`: Action on geometric basis.
- `PicardFuchsMirrorMonodromy.mulVec_N`, `mulVec_T0`: Explicit matrix-vector multiplication formulas.
- `PicardFuchsMirrorMonodromy.N_MUM`: Canonical $4 \times 4$ MUM matrix.
- `PicardFuchsMirrorMonodromy.N_MUM_is_typeIII`: Machine-checked proof that $N_{\mathrm{MUM}}$ is Type III.
- `PicardFuchsMirrorMonodromy.N_is_typeII`, `N_not_typeIII`: Classification for $(3,4,\infty)$ monodromy.
-/

namespace PicardFuchsMirrorMonodromy

/-- Parabolic cusp monodromy matrix $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ from `SymplecticTriangleRepresentations`. -/
def T0 : Matrix (Fin 4) (Fin 4) ℤ :=
  SymplecticTriangleRepresentations.T0

/-- Nilpotent cusp monodromy operator $N := T_0 - I_4$. -/
def N : Matrix (Fin 4) (Fin 4) ℤ :=
  SymplecticTriangleRepresentations.N

/-- The unipotent matrix $T_0$ satisfies $N = T_0 - 1$. -/
theorem N_eq_T0_sub_one : N = T0 - 1 :=
  SymplecticTriangleRepresentations.N_def

/-- Machine-checked proof that $N$ matches `SymplecticTriangleRepresentations.N`. -/
theorem N_matches_SymplecticTriangleRepresentations : N = SymplecticTriangleRepresentations.N :=
  rfl

/-- Machine-checked proof that the $S_6$ monodromy operator matches $T_0 - I_4$. -/
theorem ModularFamilyS6_N_eq_T0_sub_one : ModularFamilyS6.N = ModularFamilyS6.T0 - 1 :=
  ModularFamilyS6.N_def

/-- Nilpotence of index 2 for the abelian surface $(3,4,\infty)$ modular family: $N^2 = 0$. -/
theorem N_unipotent_index_2 : N * N = 0 :=
  SymplecticTriangleRepresentations.N_squared_zero

/-- Nilpotence of index 2 for the $S_6$ family: $N^2 = 0$. -/
theorem ModularFamilyS6_N_unipotent_index_2 : ModularFamilyS6.N * ModularFamilyS6.N = 0 :=
  ModularFamilyS6.N_squared_zero

/-- Basis vector $\gamma = (1, 0, 0, 0)^T$. -/
def gamma : Fin 4 → ℤ := ModularFamilyS6.gamma

/-- Basis vector $u = (0, 1, 0, 0)^T$. -/
def u : Fin 4 → ℤ := ModularFamilyS6.u

/-- Basis vector $w = (0, 0, 1, 0)^T$. -/
def w : Fin 4 → ℤ := ModularFamilyS6.w

/-- Basis vector $\delta = (0, 0, 0, 1)^T$. -/
def delta : Fin 4 → ℤ := ModularFamilyS6.delta

/-- Action of $N_{S_6}$ on the basis vector $\gamma$: $N\gamma = 0$. -/
theorem S6_N_act_gamma : ModularFamilyS6.N *ᵥ ModularFamilyS6.gamma = 0 :=
  ModularFamilyS6.N_act_gamma

/-- Action of $N_{S_6}$ on the basis vector $u$: $Nu = 0$. -/
theorem S6_N_act_u : ModularFamilyS6.N *ᵥ ModularFamilyS6.u = 0 :=
  ModularFamilyS6.N_act_u

/-- Action of $N_{S_6}$ on the basis vector $w$: $Nw = -u$. -/
theorem S6_N_act_w : ModularFamilyS6.N *ᵥ ModularFamilyS6.w = -ModularFamilyS6.u :=
  ModularFamilyS6.N_act_w

/-- Action of $N_{S_6}$ on the basis vector $\delta$: $N\delta = \gamma$. -/
theorem S6_N_act_delta : ModularFamilyS6.N *ᵥ ModularFamilyS6.delta = ModularFamilyS6.gamma :=
  ModularFamilyS6.N_act_delta

/-- Action of $N_{S_6}$ on alias $\gamma$: $N\gamma = 0$. -/
theorem N_act_gamma : ModularFamilyS6.N *ᵥ gamma = 0 :=
  S6_N_act_gamma

/-- Action of $N_{S_6}$ on alias $u$: $Nu = 0$. -/
theorem N_act_u : ModularFamilyS6.N *ᵥ u = 0 :=
  S6_N_act_u

/-- Action of $N_{S_6}$ on alias $w$: $Nw = -u$. -/
theorem N_act_w : ModularFamilyS6.N *ᵥ w = -u :=
  S6_N_act_w

/-- Action of $N_{S_6}$ on alias $\delta$: $N\delta = \gamma$. -/
theorem N_act_delta : ModularFamilyS6.N *ᵥ delta = gamma :=
  S6_N_act_delta

/-- Action of $N$ on standard basis vector $e_0 = (1, 0, 0, 0)^T$. -/
theorem N_act_e0 : N *ᵥ ![1, 0, 0, 0] = 0 := by
  ext i; fin_cases i <;> rfl

/-- Action of $N$ on standard basis vector $e_1 = (0, 1, 0, 0)^T$. -/
theorem N_act_e1 : N *ᵥ ![0, 1, 0, 0] = ![-1, 0, 0, 0] := by
  ext i; fin_cases i <;> rfl

/-- Action of $N$ on standard basis vector $e_2 = (0, 0, 1, 0)^T$. -/
theorem N_act_e2 : N *ᵥ ![0, 0, 1, 0] = ![0, 0, 0, 1] := by
  ext i; fin_cases i <;> rfl

/-- Action of $N$ on standard basis vector $e_3 = (0, 0, 0, 1)^T$. -/
theorem N_act_e3 : N *ᵥ ![0, 0, 0, 1] = 0 := by
  ext i; fin_cases i <;> rfl

/-- Matrix-vector multiplication for standard $N$. -/
theorem mulVec_N (v : Fin 4 → ℤ) :
    N *ᵥ v = ![-v 1, 0, 0, v 2] := by
  ext i
  fin_cases i <;> simp [N, SymplecticTriangleRepresentations.N, mulVec, dotProduct, Fin.sum_univ_four]

/-- Matrix-vector multiplication for standard $T_0$. -/
theorem mulVec_T0 (v : Fin 4 → ℤ) :
    T0 *ᵥ v = ![v 0 - v 1, v 1, v 2, v 2 + v 3] := by
  ext i
  fin_cases i <;> simp [T0, SymplecticTriangleRepresentations.T0, mulVec, dotProduct, Fin.sum_univ_four, sub_eq_add_neg]

/-- Matrix-vector multiplication for $S_6$ monodromy operator $N_{S_6}$. -/
theorem mulVec_S6_N (v : Fin 4 → ℤ) :
    ModularFamilyS6.N *ᵥ v = ![v 3, -v 2, 0, 0] := by
  ext i
  fin_cases i <;> simp [ModularFamilyS6.N, mulVec, dotProduct, Fin.sum_univ_four]

/-- Matrix-vector multiplication for $S_6$ cusp monodromy $T_{0, S_6}$. -/
theorem mulVec_S6_T0 (v : Fin 4 → ℤ) :
    ModularFamilyS6.T0 *ᵥ v = ![v 0 + v 3, v 1 - v 2, v 2, v 3] := by
  ext i
  fin_cases i <;> simp [ModularFamilyS6.T0, mulVec, dotProduct, Fin.sum_univ_four, sub_eq_add_neg]

/-- The standard Calabi-Yau 3-fold Maximally Unipotent Monodromy (MUM) nilpotent operator
    exhibiting index 4 nilpotence: $N^4 = 0$ and $N^3 \ne 0$. -/
def N_MUM : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0, 1, 0, 0 ],
    ![ 0, 0, 1, 0 ],
    ![ 0, 0, 0, 1 ],
    ![ 0, 0, 0, 0 ]]

/-- $N_{\mathrm{MUM}}^2$ is non-zero. -/
theorem N_MUM_squared_ne_zero : N_MUM * N_MUM ≠ 0 := by
  intro h; absurd (congr_fun (congr_fun h 0) 2); decide

/-- $N_{\mathrm{MUM}}^3$ is non-zero. -/
theorem N_MUM_cubed_ne_zero : N_MUM * N_MUM * N_MUM ≠ 0 := by
  intro h; absurd (congr_fun (congr_fun h 0) 3); decide

/-- $N_{\mathrm{MUM}}^4 = 0$. -/
theorem N_MUM_fourth_zero : N_MUM * N_MUM * N_MUM * N_MUM = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The Calabi-Yau 3-fold MUM monodromy is strictly Type III. -/
theorem N_MUM_is_typeIII : IsTypeIII N_MUM :=
  ⟨N_MUM_squared_ne_zero, N_MUM_fourth_zero⟩

/-- The $(3,4,\infty)$ abelian surface monodromy $N$ is strictly Type II. -/
theorem N_is_typeII : IsTypeII N :=
  SymplecticTriangleRepresentations.monodromy_34_is_typeII

/-- The $(3,4,\infty)$ abelian surface monodromy is not Type III (i.e. not a CY3 MUM). -/
theorem N_not_typeIII : ¬ IsTypeIII N :=
  SymplecticTriangleRepresentations.monodromy_34_not_typeIII

/-- The $(3,4,\infty)$ $S_6$ monodromy is strictly Type II. -/
theorem ModularFamilyS6_N_is_typeII : IsTypeII ModularFamilyS6.N :=
  SymplecticTriangleRepresentations.ModularFamilyS6_is_typeII

/-- The $(3,4,\infty)$ $S_6$ monodromy is not Type III. -/
theorem ModularFamilyS6_N_not_typeIII : ¬ IsTypeIII ModularFamilyS6.N :=
  typeII_not_typeIII ModularFamilyS6.N ModularFamilyS6_N_is_typeII

end PicardFuchsMirrorMonodromy
