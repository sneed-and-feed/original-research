/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

open scoped Matrix
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Genus-2 Siegel Upper Half-Space $\mathbb{H}_2$ & $\mathrm{Sp}_4(\mathbb{Z})$ Action

This submodule formalizes the genus $g=2$ Siegel upper half-space $\mathbb{H}_2$, positive definiteness
criteria for $2 \times 2$ real symmetric matrices, canonical basepoints, block decomposition of
integral symplectic transformations in $\mathrm{Sp}_4(\mathbb{Z})$, and fractional linear transformations.

## Mathematical Overview

### 1. The Siegel Upper Half-Space $\mathbb{H}_2$
The Siegel upper half-space $\mathbb{H}_2$ parameterizes principally polarized abelian surfaces (PPAS).
It consists of symmetric $2 \times 2$ complex matrices with strictly positive definite imaginary part:
$$\mathbb{H}_2 = \{ Z \in \mathrm{Mat}_2(\mathbb{C}) \mid Z^T = Z, \, \operatorname{Im}(Z) > 0 \}$$

For a $2 \times 2$ real symmetric matrix $Y = \begin{pmatrix} y_{00} & y_{01} \\ y_{10} & y_{11} \end{pmatrix}$ with $y_{01} = y_{10}$,
Sylvester's criterion states that $Y > 0$ (positive definite) if and only if:
1. $y_{00} > 0$ (leading principal minor)
2. $\det(Y) = y_{00} y_{11} - y_{01}^2 > 0$

We formalize this via the predicate `IsPosDef2` and prove machine-checked consequences:
- $y_{11} > 0$ (`posDef_implies_M11_pos`)
- $\operatorname{Tr}(Y) = y_{00} + y_{11} > 0$ (`posDef_implies_trace_pos`)
- $v^T Y v > 0$ for all non-zero vectors $v \in \mathbb{R}^2 \setminus \{0\}$ (`posDef_quadForm_pos`)

### 2. Fractional Linear Action of $\mathrm{Sp}_4(\mathbb{Z})$
A $4 \times 4$ symplectic matrix $M \in \mathrm{Sp}_4(\mathbb{Z})$ decomposed into $2 \times 2$ blocks
$M = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$ satisfies the symplectic relations:
- $A^T C = C^T A$
- $B^T D = D^T B$
- $A^T D - C^T B = I_2$

The action on period matrices $Z \in \mathbb{H}_2$ is given by the generalized fractional linear transformation:
$$M \cdot Z = (A Z + B)(C Z + D)^{-1}$$

## Main Declarations

- `AbelianSurfaceDegenerations.imMatrix`: Imaginary part matrix $\operatorname{Im}(Z) \in \mathrm{Mat}_2(\mathbb{R})$.
- `AbelianSurfaceDegenerations.reMatrix`: Real part matrix $\operatorname{Re}(Z) \in \mathrm{Mat}_2(\mathbb{R})$.
- `AbelianSurfaceDegenerations.det2`: Real $2 \times 2$ determinant.
- `AbelianSurfaceDegenerations.trace2`: Real $2 \times 2$ trace.
- `AbelianSurfaceDegenerations.quadForm`: Quadratic form $v^T M v$.
- `AbelianSurfaceDegenerations.IsPosDef2`: Positive definiteness predicate for $2 \times 2$ matrices.
- `AbelianSurfaceDegenerations.posDef_implies_M11_pos`: Proof that $M_{11} > 0$.
- `AbelianSurfaceDegenerations.posDef_implies_trace_pos`: Proof that $\operatorname{Tr}(M) > 0$.
- `AbelianSurfaceDegenerations.quadForm_scaled_identity`: Algebraic completion of squares identity.
- `AbelianSurfaceDegenerations.posDef_quadForm_pos`: Strict positivity $v^T M v > 0$ for $v \ne 0$.
- `AbelianSurfaceDegenerations.SiegelHalfSpace2`: Structure representing elements of $\mathbb{H}_2$.
- `AbelianSurfaceDegenerations.diagPeriod`: Diagonal period matrix $Z_{\mathrm{diag}}(y_1, y_2)$.
- `AbelianSurfaceDegenerations.diagPeriod_in_Siegel`: Proof that $Z_{\mathrm{diag}}(y_1, y_2) \in \mathbb{H}_2$ for $y_1, y_2 > 0$.
- `AbelianSurfaceDegenerations.blockA`, `blockB`, `blockC`, `blockD`: $2 \times 2$ block projections of $4 \times 4$ matrices.
- `AbelianSurfaceDegenerations.T1_block_*`, `T2_block_*`, `T0_block_*`: Machine-checked symplectic block relations for $(3,4,\infty)$ generators.
- `AbelianSurfaceDegenerations.det2C`, `adjugate2C`, `inv2C`: Inversion formulas for $2 \times 2$ complex matrices.
- `AbelianSurfaceDegenerations.fltAction`: Fractional linear transformation $(A Z + B)(C Z + D)^{-1}$.
- `AbelianSurfaceDegenerations.translation_in_Siegel`: Translation invariance of $\mathbb{H}_2$.
-/

namespace AbelianSurfaceDegenerations

/-! ### 1. Siegel Upper Half-Space $\mathbb{H}_2$ -/

/-- Imaginary part of a $2 \times 2$ complex matrix as a real matrix. -/
def imMatrix (Z : Matrix (Fin 2) (Fin 2) ℂ) : Matrix (Fin 2) (Fin 2) ℝ :=
  fun i j => (Z i j).im

/-- Real part of a $2 \times 2$ complex matrix as a real matrix. -/
def reMatrix (Z : Matrix (Fin 2) (Fin 2) ℂ) : Matrix (Fin 2) (Fin 2) ℝ :=
  fun i j => (Z i j).re

/-- Determinant of a $2 \times 2$ real matrix. -/
def det2 (M : Matrix (Fin 2) (Fin 2) ℝ) : ℝ :=
  M 0 0 * M 1 1 - M 0 1 * M 1 0

/-- Trace of a $2 \times 2$ real matrix. -/
def trace2 (M : Matrix (Fin 2) (Fin 2) ℝ) : ℝ :=
  M 0 0 + M 1 1

/-- Quadratic form $v^T M v$ for a $2 \times 2$ real matrix. -/
def quadForm (M : Matrix (Fin 2) (Fin 2) ℝ) (v : Fin 2 → ℝ) : ℝ :=
  v 0 * (M 0 0 * v 0 + M 0 1 * v 1) + v 1 * (M 1 0 * v 0 + M 1 1 * v 1)

/-- Positive definiteness predicate for a symmetric $2 \times 2$ real matrix:
    $M_{00} > 0$, $\det(M) > 0$, and symmetry $M_{01} = M_{10}$. -/
def IsPosDef2 (M : Matrix (Fin 2) (Fin 2) ℝ) : Prop :=
  M 0 0 > 0 ∧ det2 M > 0 ∧ M 0 1 = M 1 0

/-- Positive definiteness implies the bottom-right entry is strictly positive: $M_{11} > 0$. -/
theorem posDef_implies_M11_pos {M : Matrix (Fin 2) (Fin 2) ℝ} (h : IsPosDef2 M) : M 1 1 > 0 := by
  rcases h with ⟨h00, hdet, hsymm⟩
  dsimp [det2] at hdet
  have hprod : M 0 0 * M 1 1 > 0 := by
    calc M 0 0 * M 1 1 = (M 0 0 * M 1 1 - M 0 1 * M 1 0) + M 0 1 * M 1 0 := by ring
    _ = (M 0 0 * M 1 1 - M 0 1 * M 1 0) + M 0 1 * M 0 1 := by rw [hsymm]
    _ > 0 := by
      have hsq_nonneg : M 0 1 * M 0 1 ≥ 0 := mul_self_nonneg (M 0 1)
      linarith
  exact pos_of_mul_pos_right hprod (le_of_lt h00)

/-- Positive definiteness implies the trace is strictly positive: $\operatorname{Tr}(M) > 0$. -/
theorem posDef_implies_trace_pos {M : Matrix (Fin 2) (Fin 2) ℝ} (h : IsPosDef2 M) : trace2 M > 0 := by
  dsimp [trace2]
  have h11 := posDef_implies_M11_pos h
  linarith [h.1, h11]

/-- Quadratic form algebraic completion identity. -/
theorem quadForm_scaled_identity (M : Matrix (Fin 2) (Fin 2) ℝ) (v : Fin 2 → ℝ) (hsymm : M 0 1 = M 1 0) :
    M 0 0 * quadForm M v = (M 0 0 * v 0 + M 0 1 * v 1)^2 + det2 M * (v 1)^2 := by
  dsimp [quadForm, det2]
  rw [hsymm]
  ring

/-- Positive definiteness implies $v^T M v > 0$ for all non-zero vectors $v \in \mathbb{R}^2 \setminus \{0\}$. -/
theorem posDef_quadForm_pos {M : Matrix (Fin 2) (Fin 2) ℝ} (h : IsPosDef2 M) (v : Fin 2 → ℝ) (hv : v ≠ 0) :
    quadForm M v > 0 := by
  rcases h with ⟨h00, hdet, hsymm⟩
  have h_scaled : M 0 0 * quadForm M v = (M 0 0 * v 0 + M 0 1 * v 1)^2 + det2 M * (v 1)^2 :=
    quadForm_scaled_identity M v hsymm
  have h_scaled_pos : M 0 0 * quadForm M v > 0 := by
    rw [h_scaled]
    by_cases hv1 : v 1 = 0
    · have hv0 : v 0 ≠ 0 := by
        intro hv0
        apply hv
        ext i
        fin_cases i <;> assumption
      rw [hv1]
      have : M 0 0 * v 0 + M 0 1 * 0 = M 0 0 * v 0 := by ring
      rw [this]
      have hne : M 0 0 * v 0 ≠ 0 := mul_ne_zero (ne_of_gt h00) hv0
      have hsq : (M 0 0 * v 0)^2 > 0 := sq_pos_of_ne_zero hne
      have : det2 M * (0 : ℝ)^2 = 0 := by ring
      rw [this]
      linarith
    · have hv1_sq_pos : (v 1)^2 > 0 := sq_pos_of_ne_zero hv1
      have hterm2 : det2 M * (v 1)^2 > 0 := mul_pos hdet hv1_sq_pos
      have hsq1 : (M 0 0 * v 0 + M 0 1 * v 1)^2 ≥ 0 := sq_nonneg _
      linarith
  exact pos_of_mul_pos_right h_scaled_pos (le_of_lt h00)

/-- The Siegel Upper Half-Space $\mathbb{H}_2$ for genus $g=2$:
    symmetric $2 \times 2$ complex matrices $Z = Z^T$ with strictly positive definite imaginary part. -/
structure SiegelHalfSpace2 where
  Z : Matrix (Fin 2) (Fin 2) ℂ
  symm : Zᵀ = Z
  pos_def : IsPosDef2 (imMatrix Z)

/-- Diagonal period matrix $Z_{\text{diag}}(y_1, y_2) = \begin{pmatrix} i y_1 & 0 \\ 0 & i y_2 \end{pmatrix}$. -/
def diagPeriod (y1 y2 : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![ Complex.I * (y1 : ℂ), 0 ],
    ![ 0, Complex.I * (y2 : ℂ) ]]

/-- The imaginary part of a diagonal period matrix. -/
theorem imMatrix_diagPeriod (y1 y2 : ℝ) :
    imMatrix (diagPeriod y1 y2) = ![![y1, 0], ![0, y2]] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [diagPeriod, imMatrix]

/-- $Z_{\text{diag}}(y_1, y_2)$ is symmetric. -/
theorem diagPeriod_symm (y1 y2 : ℝ) : (diagPeriod y1 y2)ᵀ = diagPeriod y1 y2 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- For any $y_1, y_2 > 0$, the diagonal period matrix $Z_{\text{diag}}(y_1, y_2)$ is in $\mathbb{H}_2$. -/
theorem diagPeriod_in_Siegel (y1 y2 : ℝ) (hy1 : y1 > 0) (hy2 : y2 > 0) :
    IsPosDef2 (imMatrix (diagPeriod y1 y2)) := by
  rw [imMatrix_diagPeriod]
  refine ⟨hy1, ?_, rfl⟩
  dsimp [det2]
  have : y1 * y2 - 0 * 0 = y1 * y2 := by ring
  rw [this]
  exact mul_pos hy1 hy2

/-- Canonical point constructor for $\mathbb{H}_2$. -/
def canonicalSiegelPoint (y1 y2 : ℝ) (hy1 : y1 > 0) (hy2 : y2 > 0) : SiegelHalfSpace2 :=
  ⟨diagPeriod y1 y2, diagPeriod_symm y1 y2, diagPeriod_in_Siegel y1 y2 hy1 hy2⟩

/-! ### 2. Symplectic Group $\mathrm{Sp}_4(\mathbb{Z})$ Action on $\mathbb{H}_2$ -/

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
theorem T1_block_ATC : (blockA T1)ᵀ * (blockC T1) = (blockC T1)ᵀ * (blockA T1) := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Verification of symplectic block relation $B^T D = D^T B$ for $T_1$. -/
theorem T1_block_BTD : (blockB T1)ᵀ * (blockD T1) = (blockD T1)ᵀ * (blockB T1) := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Verification of symplectic block relation $A^T D - C^T B = I_2$ for $T_1$. -/
theorem T1_block_ATD_sub_CTB : (blockA T1)ᵀ * (blockD T1) - (blockC T1)ᵀ * (blockB T1) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Verification of symplectic block relations for $T_2$. -/
theorem T2_block_ATC : (blockA T2)ᵀ * (blockC T2) = (blockC T2)ᵀ * (blockA T2) := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

theorem T2_block_BTD : (blockB T2)ᵀ * (blockD T2) = (blockD T2)ᵀ * (blockB T2) := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

theorem T2_block_ATD_sub_CTB : (blockA T2)ᵀ * (blockD T2) - (blockC T2)ᵀ * (blockB T2) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Verification of symplectic block relations for $T_0$. -/
theorem T0_block_ATC : (blockA T0)ᵀ * (blockC T0) = (blockC T0)ᵀ * (blockA T0) := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

theorem T0_block_BTD : (blockB T0)ᵀ * (blockD T0) = (blockD T0)ᵀ * (blockB T0) := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

theorem T0_block_ATD_sub_CTB : (blockA T0)ᵀ * (blockD T0) - (blockC T0)ᵀ * (blockB T0) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

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
  ext i j
  fin_cases i <;> fin_cases j
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_eq]
    dsimp [adjugate2C, det2C]
    ring
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_ne (by decide)]
    dsimp [adjugate2C, det2C]
    ring
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_ne (by decide)]
    dsimp [adjugate2C, det2C]
    ring
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_eq]
    dsimp [adjugate2C, det2C]
    ring

/-- Left product with adjugate is $(\det M) I_2$. -/
theorem adjugate2C_mul (M : Matrix (Fin 2) (Fin 2) ℂ) :
    adjugate2C M * M = (det2C M) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_eq]
    dsimp [adjugate2C, det2C]
    ring
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_ne (by decide)]
    dsimp [adjugate2C, det2C]
    ring
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_ne (by decide)]
    dsimp [adjugate2C, det2C]
    ring
  · rw [mul_apply, Fin.sum_univ_two, smul_apply, one_apply_eq]
    dsimp [adjugate2C, det2C]
    ring

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
  dsimp [inv2C, adjugate2C, det2C]
  ext i j
  fin_cases i <;> fin_cases j
  · change (1 * 1 - 0 * 0 : ℂ)⁻¹ * 1 = (1 : Matrix (Fin 2) (Fin 2) ℂ) 0 0
    simp
  · change (1 * 1 - 0 * 0 : ℂ)⁻¹ * (-0) = (1 : Matrix (Fin 2) (Fin 2) ℂ) 0 1
    simp
  · change (1 * 1 - 0 * 0 : ℂ)⁻¹ * (-0) = (1 : Matrix (Fin 2) (Fin 2) ℂ) 1 0
    simp
  · change (1 * 1 - 0 * 0 : ℂ)⁻¹ * 1 = (1 : Matrix (Fin 2) (Fin 2) ℂ) 1 1
    simp

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
  ext i j
  dsimp [imMatrix, toComplexMatrix]
  simp

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
  rw [imMatrix_add_real]
  exact Z.pos_def

end AbelianSurfaceDegenerations
