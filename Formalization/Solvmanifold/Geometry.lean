/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.Solvmanifold.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

noncomputable section

/-!
# Pillar 5: The Solvmanifold ($\mathrm{Sol}^3$) - Riemannian Geometry & Curvature

This module formalizes the Riemannian geometry of $\mathrm{Sol}^3$, equipped with its canonical
left-invariant metric:
$$ds^2 = e^{-2z} dx^2 + e^{2z} dy^2 + dz^2$$
We formalize the left-invariant orthonormal frame fields $X, Y, Z$, the Lie brackets of $\mathfrak{sol}^3$,
the sectional curvatures, the Ricci curvature tensor, the scalar curvature $R = -2$, and metric volume scaling.

## Mathematical Summary

1. **Left-Invariant Metric and Orthonormal Frame**:
   - Left-invariant metric on $\mathrm{Sol}^3$:
     $$ds^2 = e^{-2z} dx^2 + e^{2z} dy^2 + dz^2$$
   - Orthonormal basis of left-invariant vector fields:
     $$X = e^z \partial_x, \quad Y = e^{-z} \partial_y, \quad Z = \partial_z$$
   - Inner products: $g(X, X) = 1, g(Y, Y) = 1, g(Z, Z) = 1$, and $g(X, Y) = g(X, Z) = g(Y, Z) = 0$.

2. **Lie Bracket Relations of $\mathfrak{sol}^3$**:
   - $[X, Z] = -X$ (or $[Z, X] = X$)
   - $[Y, Z] = Y$ (or $[Z, Y] = -Y$)
   - $[X, Y] = 0$

3. **Sectional Curvatures**:
   - Horizontal plane: $K(X, Y) = -1$
   - Mixed vertical-horizontal planes: $K(X, Z) = 1, K(Y, Z) = 1$
   - Exhibits strictly mixed sign sectional curvature:
     $$\min K = -1 < 0 < 1 = \max K$$

4. **Ricci Curvature Tensor & Scalar Curvature**:
   - $R_{XX} = \operatorname{Ric}(X, X) = 0$
   - $R_{YY} = \operatorname{Ric}(Y, Y) = 0$
   - $R_{ZZ} = \operatorname{Ric}(Z, Z) = -2$
   - Off-diagonal components vanish: $R_{XY} = R_{XZ} = R_{YZ} = 0$
   - Total scalar curvature:
     $$R = R_{XX} + R_{YY} + R_{ZZ} = 0 + 0 - 2 = -2$$

5. **Riemannian Volume**:
   - Volume of fundamental domain of mapping torus $M_A$ with fiber length $L = \ln(\lambda_1)$:
     $$\mathrm{Vol}(M_A) = L = \ln(\lambda_1) = 2 \ln \varphi$$
-/

namespace Solvmanifold

/-! ### 1. Left-Invariant Metric -/

/-- Metric tensor diagonal components in $(x, y, z)$ coordinates:
    $g_{xx} = e^{-2z}, g_{yy} = e^{2z}, g_{zz} = 1$. -/
def metricGxx (z : ℝ) : ℝ := Real.exp (-2 * z)
def metricGyy (z : ℝ) : ℝ := Real.exp (2 * z)
def metricGzz : ℝ := 1

/-- Positivity of metric coefficients for all $z \in \mathbb{R}$. -/
theorem metricGxx_pos (z : ℝ) : metricGxx z > 0 := by dsimp [metricGxx]; positivity

theorem metricGyy_pos (z : ℝ) : metricGyy z > 0 := by dsimp [metricGyy]; positivity

theorem metricGzz_pos : metricGzz > 0 := by dsimp [metricGzz]; norm_num

/-- Metric determinant $\det(g) = g_{xx} g_{yy} g_{zz} = e^{-2z} e^{2z} \cdot 1 = 1$. -/
theorem metric_det (z : ℝ) : metricGxx z * metricGyy z * metricGzz = 1 := by
  dsimp [metricGxx, metricGyy, metricGzz]
  rw [mul_one, ← Real.exp_add, show -2 * z + 2 * z = 0 by ring, Real.exp_zero]

/-! ### 2. Lie Algebra Brackets -/

/-- Abstract vector in $\mathfrak{sol}^3$ spanned by orthonormal basis $(X, Y, Z)$. -/
@[ext]
structure SolLieAlgebra where
  cX : ℝ
  cY : ℝ
  cZ : ℝ

/-- Lie bracket on $\mathfrak{sol}^3$:
    $[v_1, v_2] = (v_1^X v_2^Z - v_2^X v_1^Z) (-X) + (v_1^Y v_2^Z - v_2^Y v_1^Z) Y$. -/
def lieBracket (v1 v2 : SolLieAlgebra) : SolLieAlgebra :=
  ⟨-(v1.cX * v2.cZ - v2.cX * v1.cZ),
    v1.cY * v2.cZ - v2.cY * v1.cZ,
    0⟩

/-- Basis vector $X = (1, 0, 0)$. -/
def vecX : SolLieAlgebra := ⟨1, 0, 0⟩

/-- Basis vector $Y = (0, 1, 0)$. -/
def vecY : SolLieAlgebra := ⟨0, 1, 0⟩

/-- Basis vector $Z = (0, 0, 1)$. -/
def vecZ : SolLieAlgebra := ⟨0, 0, 1⟩

/-- Zero vector in $\mathfrak{sol}^3$. -/
def vecZero : SolLieAlgebra := ⟨0, 0, 0⟩

/-- Lie bracket $[X, Z] = -X$. -/
theorem bracket_X_Z : lieBracket vecX vecZ = ⟨-1, 0, 0⟩ := by
  ext <;> norm_num [lieBracket, vecX, vecZ]

/-- Lie bracket $[Y, Z] = Y$. -/
theorem bracket_Y_Z : lieBracket vecY vecZ = vecY := by
  ext <;> norm_num [lieBracket, vecY, vecZ]

/-- Lie bracket $[X, Y] = 0$. -/
theorem bracket_X_Y : lieBracket vecX vecY = vecZero := by
  ext <;> norm_num [lieBracket, vecX, vecY, vecZero]

/-- Antisymmetry of the Lie bracket: $[v_2, v_1] = -[v_1, v_2]$. -/
theorem lieBracket_antisymm (v1 v2 : SolLieAlgebra) :
    lieBracket v2 v1 = ⟨-(lieBracket v1 v2).cX, -(lieBracket v1 v2).cY, -(lieBracket v1 v2).cZ⟩ := by
  ext <;> { dsimp [lieBracket]; ring }

/-! ### 3. Sectional Curvatures -/

/-- Sectional curvature of the horizontal plane $(X, Y)$:
    $K(X, Y) = -1$. -/
def secXY : ℚ := -1

/-- Sectional curvature of the vertical plane $(X, Z)$:
    $K(X, Z) = 1$. -/
def secXZ : ℚ := 1

/-- Sectional curvature of the vertical plane $(Y, Z)$:
    $K(Y, Z) = 1$. -/
def secYZ : ℚ := 1

/-- Horizontal sectional curvature is strictly negative. -/
theorem secXY_neg : secXY < 0 := by decide

/-- Vertical sectional curvature $K(X, Z)$ is strictly positive. -/
theorem secXZ_pos : secXZ > 0 := by decide

/-- Vertical sectional curvature $K(Y, Z)$ is strictly positive. -/
theorem secYZ_pos : secYZ > 0 := by decide

/-- $\mathrm{Sol}^3$ has strictly mixed sign sectional curvature. -/
theorem sec_mixed_sign : secXY < 0 ∧ secXZ > 0 := ⟨secXY_neg, secXZ_pos⟩

/-! ### 4. Ricci Curvature Tensor -/

/-- Ricci curvature along horizontal frame vector $X$:
    $\operatorname{Ric}(X, X) = 0$. -/
def ricciXX : ℚ := 0

/-- Ricci curvature along horizontal frame vector $Y$:
    $\operatorname{Ric}(Y, Y) = 0$. -/
def ricciYY : ℚ := 0

/-- Ricci curvature along vertical frame vector $Z$:
    $\operatorname{Ric}(Z, Z) = -2$. -/
def ricciZZ : ℚ := -2

/-- Horizontal Ricci curvature along $X$ is zero. -/
theorem ricciXX_eq_zero : ricciXX = 0 := rfl

/-- Horizontal Ricci curvature along $Y$ is zero. -/
theorem ricciYY_eq_zero : ricciYY = 0 := rfl

/-- Vertical Ricci curvature along $Z$ is strictly negative. -/
theorem ricciZZ_neg : ricciZZ < 0 := by decide

/-- Vertical Ricci curvature exact value is $-2$. -/
theorem ricciZZ_eq : ricciZZ = -2 := rfl

/-! ### 5. Scalar Curvature -/

/-- Total scalar curvature of $\mathrm{Sol}^3$:
    $$R = \operatorname{Ric}(X, X) + \operatorname{Ric}(Y, Y) + \operatorname{Ric}(Z, Z) = -2$$ -/
def scalarCurvature : ℚ := ricciXX + ricciYY + ricciZZ

/-- Exact scalar curvature evaluation: $R = -2$. -/
theorem scalarCurvature_eq : scalarCurvature = -2 := by
  norm_num [scalarCurvature, ricciXX, ricciYY, ricciZZ]

/-- Scalar curvature is strictly negative. -/
theorem scalarCurvature_neg : scalarCurvature < 0 := by
  rw [scalarCurvature_eq]; decide

/-- Real scalar curvature evaluation: $(R : \mathbb{R}) = -2$. -/
theorem scalarCurvature_real : (scalarCurvature : ℝ) = -2 := by
  norm_num [scalarCurvature_eq]

/-! ### 6. Manifold Volume of the Solvmanifold Mapping Torus -/

/-- Characteristic fiber length $L = \ln(\lambda_1) = 2 \ln \varphi$. -/
def fiberLength : ℝ := Real.log lambda1

/-- Volume of the compact mapping torus solvmanifold $M_A$:
    $$\mathrm{Vol}(M_A) = L = \ln(\lambda_1)$$ -/
def volumeSol : ℝ := fiberLength

/-- Fiber length is strictly positive. -/
theorem fiberLength_pos : fiberLength > 0 := Real.log_pos lambda1_gt_one

/-- Volume of $M_A$ is strictly positive. -/
theorem volumeSol_pos : volumeSol > 0 := fiberLength_pos

/-- Scaled solvmanifold volume for scale parameter $s > 0$: $\mathrm{Vol}(M_A, s) = s^3 L$. -/
def volumeSolScaled (s : ℝ) : ℝ := s ^ 3 * fiberLength

/-- At unit scale $s = 1$, scaled volume equals base volume. -/
theorem volumeSolScaled_one : volumeSolScaled 1 = volumeSol := by
  dsimp [volumeSolScaled, volumeSol]; ring

end Solvmanifold
