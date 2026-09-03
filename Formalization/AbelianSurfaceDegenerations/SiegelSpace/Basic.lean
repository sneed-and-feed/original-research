/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace.PosDef
import Mathlib.Data.Complex.Basic
import Mathlib.Tactic.FinCases

open scoped Matrix
open Matrix

/-!
# Genus-2 Siegel Upper Half-Space $\mathbb{H}_2$

This module formalizes the complex Siegel upper half-space $\mathbb{H}_2$ for genus $g=2$,
defined as the space of symmetric $2 \times 2$ complex matrices with strictly positive definite
imaginary part. It provides the definition of diagonal period matrices and verifies the
canonical basepoints.

## Mathematical Overview

The Siegel upper half-space $\mathbb{H}_2$ parameterizes principally polarized abelian surfaces (PPAS).
It consists of symmetric $2 \times 2$ complex matrices with strictly positive definite imaginary part:
$$\mathbb{H}_2 = \{ Z \in \mathrm{Mat}_2(\mathbb{C}) \mid Z^T = Z, \, \operatorname{Im}(Z) > 0 \}$$
where $\operatorname{Im}(Z) > 0$ indicates that the $2 \times 2$ real symmetric matrix $\operatorname{Im}(Z)$
satisfies `IsPosDef2`.

## Main Declarations

- `AbelianSurfaceDegenerations.imMatrix`: Imaginary part matrix $\operatorname{Im}(Z) \in \mathrm{Mat}_2(\mathbb{R})$.
- `AbelianSurfaceDegenerations.reMatrix`: Real part matrix $\operatorname{Re}(Z) \in \mathrm{Mat}_2(\mathbb{R})$.
- `AbelianSurfaceDegenerations.SiegelHalfSpace2`: Structure representing elements of $\mathbb{H}_2$.
- `AbelianSurfaceDegenerations.diagPeriod`: Diagonal period matrix $Z_{\mathrm{diag}}(y_1, y_2)$.
- `AbelianSurfaceDegenerations.imMatrix_diagPeriod`: Imaginary part of a diagonal period matrix.
- `AbelianSurfaceDegenerations.diagPeriod_symm`: Symmetry of diagonal period matrices.
- `AbelianSurfaceDegenerations.diagPeriod_in_Siegel`: Proof that $Z_{\mathrm{diag}}(y_1, y_2) \in \mathbb{H}_2$ for $y_1, y_2 > 0$.
- `AbelianSurfaceDegenerations.canonicalSiegelPoint`: Canonical point constructor in $\mathbb{H}_2$.
-/

namespace AbelianSurfaceDegenerations

/-- Imaginary part of a $2 \times 2$ complex matrix as a real matrix. -/
def imMatrix (Z : Matrix (Fin 2) (Fin 2) ℂ) : Matrix (Fin 2) (Fin 2) ℝ :=
  fun i j => (Z i j).im

/-- Real part of a $2 \times 2$ complex matrix as a real matrix. -/
def reMatrix (Z : Matrix (Fin 2) (Fin 2) ℂ) : Matrix (Fin 2) (Fin 2) ℝ :=
  fun i j => (Z i j).re

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
  exact ⟨hy1, by dsimp [det2]; nlinarith, rfl⟩

/-- Canonical point constructor for $\mathbb{H}_2$. -/
def canonicalSiegelPoint (y1 y2 : ℝ) (hy1 : y1 > 0) (hy2 : y2 > 0) : SiegelHalfSpace2 :=
  ⟨diagPeriod y1 y2, diagPeriod_symm y1 y2, diagPeriod_in_Siegel y1 y2 hy1 hy2⟩

end AbelianSurfaceDegenerations
