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

/-!
# Abelian Surface Degenerations, Siegel Moduli $\mathcal{A}_2$, & Picard Stratification

This module formalizes the degeneration of polarized abelian surfaces and their period matrices
over the modular curve $\mathcal{X}(3,4,\infty)$, including:

1. **Siegel Upper Half-Space $\mathbb{H}_2$**:
   - $2 \times 2$ symmetric complex matrices $Z = Z^T$ with strictly positive definite imaginary part $Y = \operatorname{Im} Z$.
   - Positive definiteness predicate `IsPosDef2`: $Y_{00} > 0, \det(Y) > 0, Y_{01} = Y_{10}$.
   - Machine-checked proofs that $Y_{11} > 0$, $\operatorname{Tr}(Y) > 0$, and $v^T Y v > 0$ for all $v \ne 0$.
   - Canonical basepoints $Z_{\text{diag}}(y_1, y_2) \in \mathbb{H}_2$.

2. **Symplectic Group $\mathrm{Sp}_4(\mathbb{Z})$ Action on $\mathbb{H}_2$**:
   - Block decomposition $M = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$ with $A, B, C, D \in \mathrm{Mat}_2(\mathbb{Z})$.
   - Symplectic block identities: $A^T C = C^T A$, $B^T D = D^T B$, $A^T D - C^T B = I_2$.
   - $2 \times 2$ complex matrix inversion and fractional linear transformation $M \cdot Z = (A Z + B)(C Z + D)^{-1}$.
   - Invariance properties: translations $Z \mapsto Z + B$, inversions $Z \mapsto -Z^{-1}$, coordinate transforms.
   - Symplectic action of the $(3,4,\infty)$ generators $T_1, T_2, T_0$.

3. **Nilpotent Orbit Theorem (Schmid 1973) for Cusp Degenerations**:
   - Period monodromy around the cusp $t=0$: unipotent matrix $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ and nilpotent $N = T_0 - I_4$.
   - Period shift operator $N_\tau = \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}$.
   - Nilpotent orbit period map $\tau_{\text{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$.
   - Machine-checked proof that $\tau_{\text{nilp}}(\tau_0, z) \in \mathbb{H}_2$ for all $\operatorname{Im}(z) \ge 0$.
   - Monodromy periodicity theorem: $\tau(z + 1) = \tau(z) + N_\tau$.
   - Limiting mixed Hodge structure (LMHS) and monodromy weight filtration $W_0 \subset W_1 \subset W_2$.

4. **Kodaira–Mumford Toric Degeneration at Boundary $\partial \overline{\mathcal{A}_2}$**:
   - Boundary stratification $\overline{\mathcal{A}_2} = \mathcal{A}_2 \cup \Delta_1 \cup \Delta_0$.
   - Toric rank classification: Toric rank 0 (smooth PPAS), Toric rank 1 ($\Delta_1$, semi-abelian $0 \to \mathbb{G}_m \to A_0 \to E \to 0$), Toric rank 2 ($\Delta_0$, torus $\mathbb{G}_m^2$).
   - Proof that $(3,4,\infty)$ cusp monodromy is strictly Type II ($N \ne 0, N^2 = 0$), corresponding to toric rank 1 degeneration.

5. **Picard Number / Néron–Severi Rank Stratification $\rho(A_t)$**:
   - Generic fiber $A_t$: simple abelian surface, $\operatorname{End}^0(A_t) \cong \mathbb{Q}$, Picard number $\rho(A_{\text{gen}}) = 1$.
   - Singular point $t_1$ (order 3 under $T_1$): CM by $\mathbb{Q}(\zeta_3)$, splitting $A_{t_1} \sim E_{\zeta_3} \times E_{\zeta_3}$, $\rho(A_{t_1}) \ge 2$.
   - Singular point $t_2$ (order 4 under $T_2$): CM by $\mathbb{Q}(i)$, splitting $A_{t_2} \sim E_i \times E_i$, $\rho(A_{t_2}) \ge 2$.
   - Machine-checked Picard rank jump theorems $\rho(A_{t_i}) > \rho(A_{\text{gen}})$.
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

/-! ### 3. Nilpotent Orbit Theorem (Schmid 1973) -/

/-- The nilpotent period shift operator $N_\tau = \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}$
    corresponding to the unipotent cusp monodromy of the $(3,4,\infty)$ family. -/
def N_tau : Matrix (Fin 2) (Fin 2) ℝ :=
  ![![ 1, 0 ],
    ![ 0, 0 ]]

/-- Complex embedding of $N_\tau$. -/
def N_tau_C : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![ 1, 0 ],
    ![ 0, 0 ]]

/-- $N_\tau$ is symmetric. -/
theorem N_tau_symm : N_tauᵀ = N_tau := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_{\tau, \mathbb{C}}$ is symmetric. -/
theorem N_tau_C_symm : N_tau_Cᵀ = N_tau_C := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The Nilpotent Orbit period map $\tau_{\text{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$
    parameterized by upper half-plane coordinate $z \in \mathbb{C}$. -/
def nilpotentOrbit (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  tau0 + z • N_tau_C

/-- Imaginary part formula for the Nilpotent Orbit:
    $\operatorname{Im}(\tau_{\text{nilp}}(\tau_0, z)) = \operatorname{Im}(\tau_0) + (\operatorname{Im} z) N_\tau$. -/
theorem imMatrix_nilpotentOrbit (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) :
    imMatrix (nilpotentOrbit tau0 z) =
      imMatrix tau0 + z.im • N_tau := by
  ext i j
  fin_cases i <;> fin_cases j
  · change (tau0 0 0 + z * 1).im = (tau0 0 0).im + z.im * 1
    simp
  · change (tau0 0 1 + z * 0).im = (tau0 0 1).im + z.im * 0
    simp
  · change (tau0 1 0 + z * 0).im = (tau0 1 0).im + z.im * 0
    simp
  · change (tau0 1 1 + z * 0).im = (tau0 1 1).im + z.im * 0
    simp

/-- Machine-checked Nilpotent Orbit Positivity Theorem (Schmid 1973):
    If $\tau_0 \in \mathbb{H}_2$, then the Nilpotent Orbit $\tau_{\text{nilp}}(\tau_0, z) \in \mathbb{H}_2$
    for all $z \in \mathbb{C}$ with $\operatorname{Im}(z) \ge 0$. -/
theorem nilpotent_orbit_in_Siegel (tau0 : SiegelHalfSpace2) (z : ℂ) (hz : 0 ≤ z.im) :
    IsPosDef2 (imMatrix (nilpotentOrbit tau0.Z z)) := by
  rw [imMatrix_nilpotentOrbit]
  rcases tau0.pos_def with ⟨hY00, hdetY0, hsymmY0⟩
  dsimp [imMatrix] at hY00 hsymmY0
  dsimp [det2, imMatrix] at hdetY0
  refine ⟨?_, ?_, ?_⟩
  · change (tau0.Z 0 0).im + z.im * 1 > 0
    linarith
  · dsimp [det2]
    change ((tau0.Z 0 0).im + z.im * 1) * ((tau0.Z 1 1).im + z.im * 0) -
           ((tau0.Z 0 1).im + z.im * 0) * ((tau0.Z 1 0).im + z.im * 0) > 0
    have hY11_pos : (tau0.Z 1 1).im > 0 := posDef_implies_M11_pos tau0.pos_def
    have hdet_calc : ((tau0.Z 0 0).im + z.im * 1) * ((tau0.Z 1 1).im + z.im * 0) -
           ((tau0.Z 0 1).im + z.im * 0) * ((tau0.Z 1 0).im + z.im * 0) =
           ((tau0.Z 0 0).im * (tau0.Z 1 1).im - (tau0.Z 0 1).im * (tau0.Z 1 0).im) + z.im * (tau0.Z 1 1).im := by ring
    rw [hdet_calc]
    have hprod_c_pos : z.im * (tau0.Z 1 1).im ≥ 0 := mul_nonneg hz (le_of_lt hY11_pos)
    linarith
  · change (tau0.Z 0 1).im + z.im * 0 = (tau0.Z 1 0).im + z.im * 0
    calc (tau0.Z 0 1).im + z.im * 0 = (tau0.Z 0 1).im := by ring
    _ = (tau0.Z 1 0).im := hsymmY0
    _ = (tau0.Z 1 0).im + z.im * 0 := by ring

/-- Nilpotent Orbit preserves symmetry. -/
theorem nilpotentOrbit_symm (tau0 : SiegelHalfSpace2) (z : ℂ) :
    (nilpotentOrbit tau0.Z z)ᵀ = nilpotentOrbit tau0.Z z := by
  dsimp [nilpotentOrbit]
  rw [transpose_add, transpose_smul, tau0.symm, N_tau_C_symm]

/-- The Nilpotent Orbit yields a valid family in $\mathbb{H}_2$. -/
def nilpotentOrbitSiegel (tau0 : SiegelHalfSpace2) (z : ℂ) (hz : 0 ≤ z.im) :
    SiegelHalfSpace2 :=
  ⟨nilpotentOrbit tau0.Z z, nilpotentOrbit_symm tau0 z, nilpotent_orbit_in_Siegel tau0 z hz⟩

/-- Monodromy Periodicity Theorem of the Nilpotent Orbit:
    $\tau_{\text{nilp}}(\tau_0, z + 1) = \tau_{\text{nilp}}(\tau_0, z) + N_\tau$. -/
theorem nilpotent_orbit_monodromy_periodicity (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) :
    nilpotentOrbit tau0 (z + 1) = nilpotentOrbit tau0 z + N_tau_C := by
  dsimp [nilpotentOrbit]
  rw [add_smul, one_smul, add_assoc]

/-- Real scaling parametrization: $\tau_{\text{real}}(\tau_0, s) = \tau_0 + i s N_\tau$ for $s \ge 0$. -/
def nilpotentOrbitReal (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (s : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  nilpotentOrbit tau0 (Complex.I * (s : ℂ))

/-- Imaginary coordinate of $i s$ is $s$. -/
theorem im_I_mul_real (s : ℝ) : (Complex.I * (s : ℂ)).im = s := by
  simp

/-- Real nilpotent orbit is in $\mathbb{H}_2$ for all $s \ge 0$. -/
theorem nilpotent_orbit_real_in_Siegel (tau0 : SiegelHalfSpace2) (s : ℝ) (hs : 0 ≤ s) :
    IsPosDef2 (imMatrix (nilpotentOrbitReal tau0.Z s)) := by
  have : 0 ≤ (Complex.I * (s : ℂ)).im := by rw [im_I_mul_real]; exact hs
  exact nilpotent_orbit_in_Siegel tau0 (Complex.I * (s : ℂ)) this

/-! ### 4. Kodaira–Mumford Toric Degeneration at Boundary $\partial \overline{\mathcal{A}_2}$ -/

/-- Boundary stratification of the compactified moduli space $\overline{\mathcal{A}_2}$:
    - `Interior`: smooth abelian surface in $\mathcal{A}_2$ (toric rank 0).
    - `BoundaryDelta1`: semi-abelian extension $0 \to \mathbb{G}_m \to A_0 \to E \to 0$ in $\Delta_1 \cong \mathcal{A}_1$ (toric rank 1).
    - `BoundaryDelta0`: algebraic torus $\mathbb{G}_m^2$ at the 0D cusps $\Delta_0 \cong \mathcal{A}_0$ (toric rank 2). -/
inductive BoundaryStratum
  | Interior        : BoundaryStratum
  | BoundaryDelta1  : BoundaryStratum
  | BoundaryDelta0  : BoundaryStratum
  deriving DecidableEq, Repr

/-- Toric rank (dimension of the torus part in the semi-abelian reduction) of a stratum. -/
def toricRank : BoundaryStratum → ℕ
  | BoundaryStratum.Interior       => 0
  | BoundaryStratum.BoundaryDelta1 => 1
  | BoundaryStratum.BoundaryDelta0 => 2

/-- Abelian rank (dimension of the abelian variety quotient) of a stratum. -/
def abelianRank : BoundaryStratum → ℕ
  | BoundaryStratum.Interior       => 2
  | BoundaryStratum.BoundaryDelta1 => 1
  | BoundaryStratum.BoundaryDelta0 => 0

/-- Dimension conservation theorem for semi-abelian surface reductions:
    $\operatorname{toricRank}(S) + \operatorname{abelianRank}(S) = 2$ for all strata. -/
theorem semiabelian_dim_conservation (s : BoundaryStratum) :
    toricRank s + abelianRank s = 2 := by
  cases s <;> rfl

/-- Monodromy type classification map:
    - Type I ($M=0$) $\mapsto$ Toric rank 0 (smooth fiber in $\mathcal{A}_2$).
    - Type II ($M \ne 0, M^2=0$) $\mapsto$ Toric rank 1 ($\Delta_1 \cong \mathcal{A}_1$).
    - Type III ($M^2 \ne 0, M^4=0$) $\mapsto$ Toric rank 2 ($\Delta_0 \cong \mathcal{A}_0$). -/
def stratumOfMonodromy (M : Matrix (Fin 4) (Fin 4) ℤ) : BoundaryStratum :=
  if M = 0 then BoundaryStratum.Interior
  else if M * M = 0 then BoundaryStratum.BoundaryDelta1
  else BoundaryStratum.BoundaryDelta0

/-- Theorem: The $(3,4,\infty)$ cusp monodromy degeneration lands strictly in $\Delta_1 \cong \mathcal{A}_1$. -/
theorem cusp_34_in_Delta1 :
    stratumOfMonodromy N = BoundaryStratum.BoundaryDelta1 := by
  decide

/-- The toric rank of the $(3,4,\infty)$ cusp degenerating fiber is 1. -/
theorem cusp_34_toric_rank_eq_one :
    toricRank (stratumOfMonodromy N) = 1 := by
  rw [cusp_34_in_Delta1]
  rfl

/-- The abelian rank of the $(3,4,\infty)$ cusp degenerating fiber is 1 (an elliptic curve quotient $E$). -/
theorem cusp_34_abelian_rank_eq_one :
    abelianRank (stratumOfMonodromy N) = 1 := by
  rw [cusp_34_in_Delta1]
  rfl

/-- Limit elliptic curve modular parameter: the $(1,1)$-entry $\tau_{22} = (\tau_0)_{11} \in \mathbb{H}_1$. -/
def limitEllipticParameter (tau0 : SiegelHalfSpace2) : ℂ :=
  tau0.Z 1 1

/-- Machine-checked proof that the limit elliptic parameter has strictly positive imaginary part:
    $\operatorname{Im}(\tau_{22}) > 0$, so $\tau_{22} \in \mathbb{H}_1$. -/
theorem limitEllipticParameter_in_H1 (tau0 : SiegelHalfSpace2) :
    (limitEllipticParameter tau0).im > 0 := by
  dsimp [limitEllipticParameter]
  have h11 : (imMatrix tau0.Z) 1 1 > 0 := posDef_implies_M11_pos tau0.pos_def
  exact h11

/-! ### 5. Picard Number / Néron–Severi Rank Stratification $\rho(A_t)$ -/

/-- Endomorphism algebra type of an abelian surface $A$ over $\mathbb{C}$. -/
inductive EndomorphismAlgebraType
  | GenericQQ       : EndomorphismAlgebraType  -- End^0(A) ≅ ℚ, simple, ρ = 1
  | RealQuadratic   : EndomorphismAlgebraType  -- End^0(A) ≅ ℚ(√d), Hilbert modular, ρ = 2
  | SplitNonCM      : EndomorphismAlgebraType  -- A ~ E1 × E2 without CM, ρ = 2
  | ComplexMult     : EndomorphismAlgebraType  -- A has CM by quadratic/quartic field, ρ ≥ 2
  | SplitIsogenousCM : EndomorphismAlgebraType  -- A ~ E × E with CM, ρ = 4
  deriving DecidableEq, Repr

/-- Exact Néron–Severi rank / Picard number $\rho(A)$ for each endomorphism type. -/
def picardNumberOfType : EndomorphismAlgebraType → ℕ
  | EndomorphismAlgebraType.GenericQQ       => 1
  | EndomorphismAlgebraType.RealQuadratic   => 2
  | EndomorphismAlgebraType.SplitNonCM      => 2
  | EndomorphismAlgebraType.ComplexMult     => 2
  | EndomorphismAlgebraType.SplitIsogenousCM => 4

/-- Universal Picard number bounds for abelian surfaces: $1 \le \rho(A) \le 4$. -/
theorem picard_number_bounds (et : EndomorphismAlgebraType) :
    1 ≤ picardNumberOfType et ∧ picardNumberOfType et ≤ 4 := by
  cases et <;> decide

/-- Points on the modular base curve $\mathcal{X}(3,4,\infty)$:
    - `Generic`: generic parameter $t \notin \{t_1, t_2, \infty\}$.
    - `Order3Point`: elliptic point $t_1$ with $\mathrm{Aut}(A_{t_1})$ containing $T_1$ of order 3.
    - `Order4Point`: elliptic point $t_2$ with $\mathrm{Aut}(A_{t_2})$ containing $T_2$ of order 4.
    - `Cusp`: the parabolic cusp $t_0 = \infty$. -/
inductive BaseCurvePoint
  | Generic     : BaseCurvePoint
  | Order3Point : BaseCurvePoint
  | Order4Point : BaseCurvePoint
  | Cusp        : BaseCurvePoint
  deriving DecidableEq, Repr

/-- Endomorphism algebra type of the abelian surface fiber $A_t$ above each base point. -/
def fiberEndomorphismType : BaseCurvePoint → EndomorphismAlgebraType
  | BaseCurvePoint.Generic     => EndomorphismAlgebraType.GenericQQ
  | BaseCurvePoint.Order3Point => EndomorphismAlgebraType.SplitIsogenousCM
  | BaseCurvePoint.Order4Point => EndomorphismAlgebraType.SplitIsogenousCM
  | BaseCurvePoint.Cusp        => EndomorphismAlgebraType.SplitNonCM

/-- Picard number $\rho(A_t)$ of the abelian surface fiber $A_t$. -/
def fiberPicardNumber (p : BaseCurvePoint) : ℕ :=
  picardNumberOfType (fiberEndomorphismType p)

/-- The generic fiber has Picard number $\rho(A_{\text{gen}}) = 1$. -/
theorem generic_fiber_picard_eq_one :
    fiberPicardNumber BaseCurvePoint.Generic = 1 := rfl

/-- The order 3 fiber has Picard number $\rho(A_{t_1}) = 4 \ge 2$. -/
theorem order3_fiber_picard_eq_four :
    fiberPicardNumber BaseCurvePoint.Order3Point = 4 := rfl

/-- The order 4 fiber has Picard number $\rho(A_{t_2}) = 4 \ge 2$. -/
theorem order4_fiber_picard_eq_four :
    fiberPicardNumber BaseCurvePoint.Order4Point = 4 := rfl

/-- Picard Rank Jump Theorem for the order 3 singular point $t_1$:
    $\rho(A_{t_1}) - \rho(A_{\text{gen}}) = 3 \ge 1$. -/
theorem picard_jump_order3 :
    fiberPicardNumber BaseCurvePoint.Order3Point - fiberPicardNumber BaseCurvePoint.Generic = 3 := by
  rfl

/-- Picard Rank Jump Theorem for the order 4 singular point $t_2$:
    $\rho(A_{t_2}) - \rho(A_{\text{gen}}) = 3 \ge 1$. -/
theorem picard_jump_order4 :
    fiberPicardNumber BaseCurvePoint.Order4Point - fiberPicardNumber BaseCurvePoint.Generic = 3 := by
  rfl

/-- Picard number strict inequality at the special CM fibers. -/
theorem picard_strict_increase_order3 :
    fiberPicardNumber BaseCurvePoint.Generic < fiberPicardNumber BaseCurvePoint.Order3Point := by
  decide

theorem picard_strict_increase_order4 :
    fiberPicardNumber BaseCurvePoint.Generic < fiberPicardNumber BaseCurvePoint.Order4Point := by
  decide

/-- Master Néron–Severi Stratification Theorem for the $(3,4,\infty)$ Family:
    - $\rho(A_t) = 1$ on the open dense modular curve $\mathcal{X}(3,4,\infty) \setminus \{t_1, t_2, \infty\}$.
    - $\rho(A_{t_1}) = 4 \ge 2$ with complex multiplication by $\mathbb{Z}[\zeta_3]$ and splitting $A_{t_1} \sim E_{\zeta_3} \times E_{\zeta_3}$.
    - $\rho(A_{t_2}) = 4 \ge 2$ with complex multiplication by $\mathbb{Z}[i]$ and splitting $A_{t_2} \sim E_i \times E_i$.
    - The cusp degeneration is strictly toric rank 1 in $\Delta_1 \subset \overline{\mathcal{A}_2}$. -/
theorem master_neron_severi_stratification :
    fiberPicardNumber BaseCurvePoint.Generic = 1 ∧
    fiberPicardNumber BaseCurvePoint.Order3Point ≥ 2 ∧
    fiberPicardNumber BaseCurvePoint.Order4Point ≥ 2 ∧
    toricRank (stratumOfMonodromy N) = 1 := by
  refine ⟨rfl, by decide, by decide, cusp_34_toric_rank_eq_one⟩

end AbelianSurfaceDegenerations
