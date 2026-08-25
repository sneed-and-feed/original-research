/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace.Basic
import Formalization.SymplecticTriangleRepresentations.Basic
import Formalization.SymplecticTriangleRepresentations.Representations
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring

open scoped Matrix
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Symplectic Group $\mathrm{Sp}_4(\mathbb{Z})$ Action and Fractional Linear Transformations

This submodule formalizes the $2 \times 2$ block decomposition of $4 \times 4$ symplectic matrices
$M = \begin{pmatrix} A & B \\ C & D \end{pmatrix} \in \mathrm{Sp}_4(\mathbb{Z})$, verifies the symplectic relations
for triangle group generators $T_1, T_2, T_0$, defines matrix inversion for $2 \times 2$ complex matrices,
and formalizes the generalized fractional linear transformation (FLT) action $M \cdot Z = (A Z + B)(C Z + D)^{-1}$
on the Siegel upper half-space $\mathbb{H}_2$.

## Mathematical Overview

A $4 \times 4$ symplectic matrix $M \in \mathrm{Sp}_4(\mathbb{Z})$ decomposed into $2 \times 2$ blocks
$M = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$ satisfies the symplectic relations:
- $A^T C = C^T A$
- $B^T D = D^T B$
- $A^T D - C^T B = I_2$

The action on period matrices $Z \in \mathbb{H}_2$ is given by the generalized fractional linear transformation:
$$M \cdot Z = (A Z + B)(C Z + D)^{-1}$$

## Main Declarations

- `AbelianSurfaceDegenerations.blockA`, `blockB`, `blockC`, `blockD`: $2 \times 2$ block projections of $4 \times 4$ integer matrices.
- `AbelianSurfaceDegenerations.toRealMat`: Real embedding of an integer $2 \times 2$ matrix.
- `AbelianSurfaceDegenerations.toComplexMat`: Complex embedding of an integer $2 \times 2$ matrix.
- `AbelianSurfaceDegenerations.toComplexMatrix`: Complex embedding of a real $2 \times 2$ matrix.
- `AbelianSurfaceDegenerations.T1_block_*`, `T2_block_*`, `T0_block_*`: Machine-checked symplectic block relations for $(3,4,\infty)$ generators.
- `AbelianSurfaceDegenerations.det2C`, `adjugate2C`, `inv2C`: Inversion formulas for $2 \times 2$ complex matrices.
- `AbelianSurfaceDegenerations.mul_adjugate2C`, `adjugate2C_mul`: Product identities with adjugate.
- `AbelianSurfaceDegenerations.mul_inv2C`, `inv2C_mul`, `inv2C_one`: Inversion properties.
- `AbelianSurfaceDegenerations.fltAction`: Fractional linear transformation $(A Z + B)(C Z + D)^{-1}$.
- `AbelianSurfaceDegenerations.flt_translation`: Translation by real symmetric matrices.
- `AbelianSurfaceDegenerations.imMatrix_add_real`, `symm_add_real`, `translation_in_Siegel`: Invariance of $\mathbb{H}_2$ under real translations.
-/

namespace AbelianSurfaceDegenerations

/-- $2 \times 2$ Block $A$ of a $4 \times 4$ integer matrix. -/
def blockA (M : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![M 0 0, M 0 1], ![M 1 0, M 1 1]]

/-- $2 \times 2$ Block $B$ of a $4 \times 4$ integer matrix. -/
def blockB (M : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![M 0 2, M 0 3], ![M 1 2, M 1 3]]

/-- $2 \times 2$ Block $C$ of a $4 \times 4$ integer matrix. -/
def blockC (M : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![M 2 0, M 2 1], ![M 3 0, M 3 1]]

/-- $2 \times 2$ Block $D$ of a $4 \times 4$ integer matrix. -/
def blockD (M : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![M 2 2, M 2 3], ![M 3 2, M 3 3]]

/-- Real embedding of an integer $2 \times 2$ matrix. -/
def toRealMat (M : Matrix (Fin 2) (Fin 2) ℤ) : Matrix (Fin 2) (Fin 2) ℝ :=
  fun i j => (M i j : ℝ)

/-- Complex embedding of an integer $2 \times 2$ matrix. -/
def toComplexMat (M : Matrix (Fin 2) (Fin 2) ℤ) : Matrix (Fin 2) (Fin 2) ℂ :=
  fun i j => (M i j : ℂ)

/-- Complex embedding of a real $2 \times 2$ matrix. -/
def toComplexMatrix (M : Matrix (Fin 2) (Fin 2) ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  fun i j => (M i j : ℂ)

/-- Verification of symplectic block relation $A^T C = C^T A$ for $T_1$. -/
theorem T1_block_ATC : (blockA T1)ᵀ * (blockC T1) = (blockC T1)ᵀ * (blockA T1) := by decide

/-- Verification of symplectic block relation $B^T D = D^T B$ for $T_1$. -/
theorem T1_block_BTD : (blockB T1)ᵀ * (blockD T1) = (blockD T1)ᵀ * (blockB T1) := by decide

/-- Verification of symplectic block relation $A^T D - C^T B = I_2$ for $T_1$. -/
theorem T1_block_ATD_sub_CTB : (blockA T1)ᵀ * (blockD T1) - (blockC T1)ᵀ * (blockB T1) = 1 := by decide

/-- Verification of symplectic block relations for $T_2$. -/
theorem T2_block_ATC : (blockA T2)ᵀ * (blockC T2) = (blockC T2)ᵀ * (blockA T2) := by decide

theorem T2_block_BTD : (blockB T2)ᵀ * (blockD T2) = (blockD T2)ᵀ * (blockB T2) := by decide

theorem T2_block_ATD_sub_CTB : (blockA T2)ᵀ * (blockD T2) - (blockC T2)ᵀ * (blockB T2) = 1 := by decide

/-- Verification of symplectic block relations for $T_0$. -/
theorem T0_block_ATC : (blockA T0)ᵀ * (blockC T0) = (blockC T0)ᵀ * (blockA T0) := by decide

theorem T0_block_BTD : (blockB T0)ᵀ * (blockD T0) = (blockD T0)ᵀ * (blockB T0) := by decide

theorem T0_block_ATD_sub_CTB : (blockA T0)ᵀ * (blockD T0) - (blockC T0)ᵀ * (blockB T0) = 1 := by decide

/-- Determinant of a $2 \times 2$ complex matrix. -/
def det2C (M : Matrix (Fin 2) (Fin 2) ℂ) : ℂ :=
  M 0 0 * M 1 1 - M 0 1 * M 1 0

/-- Adjugate of a $2 \times 2$ complex matrix. -/
def adjugate2C (M : Matrix (Fin 2) (Fin 2) ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![ M 1 1, -M 0 1],
    ![-M 1 0,  M 0 0]]

/-- Inversion formula for a $2 \times 2$ complex matrix. -/
noncomputable def inv2C (M : Matrix (Fin 2) (Fin 2) ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  (det2C M)⁻¹ • adjugate2C M

/-- Product of a $2 \times 2$ complex matrix with its adjugate is $(\det M) I_2$. -/
theorem mul_adjugate2C (M : Matrix (Fin 2) (Fin 2) ℂ) :
    M * adjugate2C M = (det2C M) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j; fin_cases i <;> fin_cases j <;> {
    rw [mul_apply, Fin.sum_univ_two, smul_apply]
    dsimp [adjugate2C, det2C]
    first | rw [one_apply_eq]; ring | rw [one_apply_ne (by decide)]; ring
  }

/-- Left product with adjugate is $(\det M) I_2$. -/
theorem adjugate2C_mul (M : Matrix (Fin 2) (Fin 2) ℂ) :
    adjugate2C M * M = (det2C M) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j; fin_cases i <;> fin_cases j <;> {
    rw [mul_apply, Fin.sum_univ_two, smul_apply]
    dsimp [adjugate2C, det2C]
    first | rw [one_apply_eq]; ring | rw [one_apply_ne (by decide)]; ring
  }

/-- Right inverse property: $M \cdot M^{-1} = I_2$ when $\det M \ne 0$. -/
theorem mul_inv2C (M : Matrix (Fin 2) (Fin 2) ℂ) (hdet : det2C M ≠ 0) :
    M * inv2C M = 1 := by
  dsimp [inv2C]
  rw [Matrix.mul_smul, mul_adjugate2C, smul_smul, inv_mul_cancel₀ hdet, one_smul]

/-- Left inverse property: $M^{-1} \cdot M = I_2$ when $\det M \ne 0$. -/
theorem inv2C_mul (M : Matrix (Fin 2) (Fin 2) ℂ) (hdet : det2C M ≠ 0) :
    inv2C M * M = 1 := by
  dsimp [inv2C]
  rw [Matrix.smul_mul, adjugate2C_mul, smul_smul, inv_mul_cancel₀ hdet, one_smul]

/-- Inverse of the identity $2 \times 2$ matrix is $I_2$. -/
theorem inv2C_one : inv2C (1 : Matrix (Fin 2) (Fin 2) ℂ) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> first
  | change (1 * 1 - 0 * 0 : ℂ)⁻¹ * 1 = 1; ring
  | change (1 * 1 - 0 * 0 : ℂ)⁻¹ * (-0) = 0; ring

/-- Fractional linear transformation action on $Z$: $M \cdot Z = (A Z + B)(C Z + D)^{-1}$. -/
noncomputable def fltAction (A B C D : Matrix (Fin 2) (Fin 2) ℂ) (Z : Matrix (Fin 2) (Fin 2) ℂ) :
    Matrix (Fin 2) (Fin 2) ℂ :=
  (A * Z + B) * inv2C (C * Z + D)

/-- Translation action by a symmetric real matrix $B$: $\begin{pmatrix} I & B \\ 0 & I \end{pmatrix} \cdot Z = Z + B$. -/
theorem flt_translation (B : Matrix (Fin 2) (Fin 2) ℝ) (Z : Matrix (Fin 2) (Fin 2) ℂ) :
    fltAction 1 (toComplexMatrix B) 0 1 Z = Z + toComplexMatrix B := by
  dsimp [fltAction]
  have hCD : (0 : Matrix (Fin 2) (Fin 2) ℂ) * Z + 1 = 1 := by simp
  rw [hCD, inv2C_one, Matrix.mul_one, Matrix.one_mul]

/-- Translation preserves the imaginary part: $\operatorname{Im}(Z + B) = \operatorname{Im}(Z)$ for real $B$. -/
theorem imMatrix_add_real (Z : Matrix (Fin 2) (Fin 2) ℂ) (B : Matrix (Fin 2) (Fin 2) ℝ) :
    imMatrix (Z + toComplexMatrix B) = imMatrix Z := by
  ext i j; simp [imMatrix, toComplexMatrix]

/-- Translation preserves symmetry when $B$ is symmetric. -/
theorem symm_add_real (Z : Matrix (Fin 2) (Fin 2) ℂ) (B : Matrix (Fin 2) (Fin 2) ℝ)
    (hZ : Zᵀ = Z) (hB : Bᵀ = B) :
    (Z + toComplexMatrix B)ᵀ = Z + toComplexMatrix B := by
  ext i j
  have hzij := congr_fun (congr_fun hZ j) i
  have hbij := congr_fun (congr_fun hB j) i
  dsimp [transpose, toComplexMatrix] at *
  rw [hzij, hbij]

/-- Real translation maps $\mathbb{H}_2$ to $\mathbb{H}_2$. -/
theorem translation_in_Siegel (Z : SiegelHalfSpace2) (B : Matrix (Fin 2) (Fin 2) ℝ) (_hB : Bᵀ = B) :
    IsPosDef2 (imMatrix (Z.Z + toComplexMatrix B)) := by
  rw [imMatrix_add_real]; exact Z.pos_def

end AbelianSurfaceDegenerations
