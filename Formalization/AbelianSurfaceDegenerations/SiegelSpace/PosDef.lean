/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Real $2 \times 2$ Positive Definite Symmetric Matrices

This submodule formalizes positive definiteness criteria for $2 \times 2$ real symmetric matrices
and proves the fundamental algebraic consequences including positivity of diagonal entries, trace positivity,
and positive definiteness of the associated quadratic form on non-zero vectors.

## Mathematical Overview

For a $2 \times 2$ real symmetric matrix $Y = \begin{pmatrix} y_{00} & y_{01} \\ y_{10} & y_{11} \end{pmatrix}$ with $y_{01} = y_{10}$,
Sylvester's criterion states that $Y > 0$ (positive definite) if and only if:
1. $y_{00} > 0$ (leading principal minor)
2. $\det(Y) = y_{00} y_{11} - y_{01}^2 > 0$

We formalize this via the predicate `IsPosDef2` and prove machine-checked consequences:
- $y_{11} > 0$ (`posDef_implies_M11_pos`)
- $\operatorname{Tr}(Y) = y_{00} + y_{11} > 0$ (`posDef_implies_trace_pos`)
- $v^T Y v > 0$ for all non-zero vectors $v \in \mathbb{R}^2 \setminus \{0\}$ (`posDef_quadForm_pos`)

## Main Declarations

- `AbelianSurfaceDegenerations.det2`: Determinant of a $2 \times 2$ real matrix.
- `AbelianSurfaceDegenerations.trace2`: Trace of a $2 \times 2$ real matrix.
- `AbelianSurfaceDegenerations.quadForm`: Quadratic form $v^T M v$ on $\mathbb{R}^2$.
- `AbelianSurfaceDegenerations.IsPosDef2`: Positive definiteness predicate ($M_{00} > 0$, $\det M > 0$, $M_{01} = M_{10}$).
- `AbelianSurfaceDegenerations.posDef_implies_M11_pos`: Proof that $M_{11} > 0$.
- `AbelianSurfaceDegenerations.posDef_implies_trace_pos`: Proof that $\operatorname{Tr}(M) > 0$.
- `AbelianSurfaceDegenerations.quadForm_scaled_identity`: Algebraic completion of squares identity.
- `AbelianSurfaceDegenerations.posDef_quadForm_pos`: Strict positivity $v^T M v > 0$ for $v \ne 0$.
-/

namespace AbelianSurfaceDegenerations

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
  have hdet := h.2.1; dsimp [det2] at hdet; rw [h.2.2] at hdet
  nlinarith [h.1, mul_self_nonneg (M 0 1)]

/-- Positive definiteness implies the trace is strictly positive: $\operatorname{Tr}(M) > 0$. -/
theorem posDef_implies_trace_pos {M : Matrix (Fin 2) (Fin 2) ℝ} (h : IsPosDef2 M) : trace2 M > 0 := by
  dsimp [trace2]; linarith [h.1, posDef_implies_M11_pos h]

/-- Quadratic form algebraic completion identity. -/
theorem quadForm_scaled_identity (M : Matrix (Fin 2) (Fin 2) ℝ) (v : Fin 2 → ℝ) (hsymm : M 0 1 = M 1 0) :
    M 0 0 * quadForm M v = (M 0 0 * v 0 + M 0 1 * v 1)^2 + det2 M * (v 1)^2 := by
  dsimp [quadForm, det2]; rw [hsymm]; ring

/-- Positive definiteness implies $v^T M v > 0$ for all non-zero vectors $v \in \mathbb{R}^2 \setminus \{0\}$. -/
theorem posDef_quadForm_pos {M : Matrix (Fin 2) (Fin 2) ℝ} (h : IsPosDef2 M) (v : Fin 2 → ℝ) (hv : v ≠ 0) :
    quadForm M v > 0 := by
  have h_scaled := quadForm_scaled_identity M v h.2.2
  by_cases hv1 : v 1 = 0
  · have hv0 : v 0 ≠ 0 := fun h0 => hv (by ext i; fin_cases i <;> assumption)
    rw [hv1] at h_scaled; nlinarith [h.1, sq_pos_of_ne_zero (mul_ne_zero (ne_of_gt h.1) hv0)]
  · nlinarith [h.1, h.2.1, sq_pos_of_ne_zero hv1, sq_nonneg (M 0 0 * v 0 + M 0 1 * v 1)]

end AbelianSurfaceDegenerations
