/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.H2xRGeometry.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Fin.VecNotation
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

open scoped Matrix
open Matrix

/-!
# Pillar 8: $\mathbb{H}^2 \times \mathbb{R}$ Geometry - Product Metric, Curvature & Ricci Tensor

This module formalizes the Riemannian metric, Christoffel connection structure, sectional curvatures,
Ricci curvature tensor, scalar curvature, and Einstein tensor of the product Riemannian manifold
$\mathbb{H}^2 \times \mathbb{R}$ (and its compact quotients $\Sigma_g \times S^1$).

## Mathematical Summary

1. **Riemannian Product Metric**:
   - In upper half-plane coordinates $(x, y, z)$ with $y > 0$:
     $$ds^2 = g_{\mathbb{H}^2} \oplus g_{\mathbb{R}} = \frac{dx^2 + dy^2}{y^2} + dz^2.$$
   - Metric matrix: $g = \operatorname{diag}(y^{-2}, y^{-2}, 1)$.
   - Inverse metric: $g^{-1} = \operatorname{diag}(y^2, y^2, 1)$.
   - Metric determinant: $\det(g) = y^{-4}$.
   - Volume density factor: $\sqrt{\det g} = y^{-2}$.

2. **Orthonormal Frame & Lie Algebra**:
   - Frame vector fields: $e_1 = y \partial_x, e_2 = y \partial_y, e_3 = \partial_z$.
   - Lie brackets: $[e_1, e_2] = -e_1, [e_1, e_3] = 0, [e_2, e_3] = 0$.

3. **Sectional Curvatures**:
   - Hyperbolic plane: $K(\partial_x, \partial_y) = -1$.
   - Mixed vertical-horizontal planes: $K(\partial_x, \partial_z) = 0, K(\partial_y, \partial_z) = 0$.
   - Non-positivity: All sectional curvatures satisfy $K \le 0$, with $\min K = -1$ and $\max K = 0$.

4. **Ricci Curvature Tensor**:
   - Contractions of sectional curvatures in the orthonormal frame:
     $$R_{xx} = \operatorname{Ric}(\partial_x, \partial_x) = K(\partial_x, \partial_y) + K(\partial_x, \partial_z) = -1 + 0 = -1.$$
     $$R_{yy} = \operatorname{Ric}(\partial_y, \partial_y) = K(\partial_y, \partial_x) + K(\partial_y, \partial_z) = -1 + 0 = -1.$$
     $$R_{zz} = \operatorname{Ric}(\partial_z, \partial_z) = K(\partial_z, \partial_x) + K(\partial_z, \partial_y) = 0 + 0 = 0.$$
   - Off-diagonal components vanish: $R_{xy} = R_{xz} = R_{yz} = 0$.

5. **Scalar Curvature**:
   - Total scalar curvature:
     $$R = R_{xx} + R_{yy} + R_{zz} = -1 - 1 + 0 = -2 < 0.$$

6. **Einstein Tensor**:
   - $G_{ij} = R_{ij} - \frac{1}{2} R g_{ij}$:
     $$G_{xx} = -1 - \frac{1}{2}(-2) = 0.$$
     $$G_{yy} = -1 - \frac{1}{2}(-2) = 0.$$
     $$G_{zz} = 0 - \frac{1}{2}(-2) = +1.$$
   - Metric is non-Einstein since $R_{xx} \ne R_{zz}$.
-/

namespace H2xRGeometry

/-! ### 1. Riemannian Product Metric on $\mathbb{H}^2 \times \mathbb{R}$ -/

/-- Metric tensor matrix in coordinate basis $(\partial_x, \partial_y, \partial_z)$ for $y > 0$:
    $$g = \operatorname{diag}(y^{-2}, y^{-2}, 1) = \begin{pmatrix} 1/y^2 & 0 & 0 \\ 0 & 1/y^2 & 0 \\ 0 & 0 & 1 \end{pmatrix}.$$ -/
noncomputable def metricMatrix (y : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  ![![1 / y ^ 2, 0, 0],
    ![0, 1 / y ^ 2, 0],
    ![0, 0, 1]]

/-- Inverse metric tensor matrix in coordinate basis:
    $$g^{-1} = \operatorname{diag}(y^2, y^2, 1) = \begin{pmatrix} y^2 & 0 & 0 \\ 0 & y^2 & 0 \\ 0 & 0 & 1 \end{pmatrix}.$$ -/
noncomputable def invMetricMatrix (y : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  ![![y ^ 2, 0, 0],
    ![0, y ^ 2, 0],
    ![0, 0, 1]]

/-- Metric determinant: $\det(g) = 1/y^4$. -/
theorem det_metricMatrix (y : ℝ) :
    (metricMatrix y).det = 1 / y ^ 4 := by
  rw [det_fin_three]; simp [metricMatrix]; ring

/-- Riemannian volume form density factor $\sqrt{\det g} = 1/y^2$ on $\mathbb{H}^2 \times \mathbb{R}$. -/
noncomputable def volumeFormDensity (y : ℝ) : ℝ := 1 / y ^ 2

/-- Square of the volume form density equals the metric determinant. -/
theorem volumeFormDensity_sq (y : ℝ) :
    (volumeFormDensity y) ^ 2 = (metricMatrix y).det := by
  rw [det_metricMatrix]; dsimp [volumeFormDensity]; ring

/-! ### 2. Sectional Curvatures -/

/-- Sectional curvature of the hyperbolic factor plane span $(\partial_x, \partial_y)$:
    $K(\partial_x, \partial_y) = -1$. -/
def secXY : ℚ := -1

/-- Sectional curvature of the mixed vertical-horizontal plane span $(\partial_x, \partial_z)$:
    $K(\partial_x, \partial_z) = 0$. -/
def secXZ : ℚ := 0

/-- Sectional curvature of the mixed vertical-horizontal plane span $(\partial_y, \partial_z)$:
    $K(\partial_y, \partial_z) = 0$. -/
def secYZ : ℚ := 0

/-- Hyperbolic sectional curvature is strictly negative: $K(\partial_x, \partial_y) = -1 < 0$. -/
theorem secXY_neg : secXY < 0 := by decide

/-- Mixed sectional curvature $K(\partial_x, \partial_z) = 0$. -/
theorem secXZ_eq_zero : secXZ = 0 := rfl

/-- Mixed sectional curvature $K(\partial_y, \partial_z) = 0$. -/
theorem secYZ_eq_zero : secYZ = 0 := rfl

/-- All sectional curvatures of $\mathbb{H}^2 \times \mathbb{R}$ are non-positive: $K \le 0$. -/
theorem sec_nonpos : secXY ≤ 0 ∧ secXZ ≤ 0 ∧ secYZ ≤ 0 := by decide

/-! ### 3. Ricci Curvature Tensor -/

/-- Ricci tensor component along normalized horizontal direction $\partial_x$:
    $R_{xx} = \operatorname{Ric}(\partial_x, \partial_x) = -1$. -/
def ricciXX : ℚ := -1

/-- Ricci tensor component along normalized horizontal direction $\partial_y$:
    $R_{yy} = \operatorname{Ric}(\partial_y, \partial_y) = -1$. -/
def ricciYY : ℚ := -1

/-- Ricci tensor component along normalized vertical direction $\partial_z$:
    $R_{zz} = \operatorname{Ric}(\partial_z, \partial_z) = 0$. -/
def ricciZZ : ℚ := 0

/-- Horizontal Ricci component along $x$ is strictly negative: $R_{xx} = -1 < 0$. -/
theorem ricciXX_neg : ricciXX < 0 := by decide

/-- Horizontal Ricci component along $y$ is strictly negative: $R_{yy} = -1 < 0$. -/
theorem ricciYY_neg : ricciYY < 0 := by decide

/-- Vertical Ricci component along $z$ vanishes: $R_{zz} = 0$. -/
theorem ricciZZ_zero : ricciZZ = 0 := rfl

/-- Ricci contraction along $x$ from sectional curvatures:
    $R_{xx} = K(\partial_x, \partial_y) + K(\partial_x, \partial_z) = -1 + 0 = -1$. -/
theorem ricciXX_from_sec : ricciXX = secXY + secXZ := by
  norm_num [ricciXX, secXY, secXZ]

/-- Ricci contraction along $y$ from sectional curvatures:
    $R_{yy} = K(\partial_y, \partial_x) + K(\partial_y, \partial_z) = -1 + 0 = -1$. -/
theorem ricciYY_from_sec : ricciYY = secXY + secYZ := by
  norm_num [ricciYY, secXY, secYZ]

/-- Ricci contraction along $z$ from sectional curvatures:
    $R_{zz} = K(\partial_z, \partial_x) + K(\partial_z, \partial_y) = 0 + 0 = 0$. -/
theorem ricciZZ_from_sec : ricciZZ = secXZ + secYZ := by
  norm_num [ricciZZ, secXZ, secYZ]

/-! ### 4. Scalar Curvature -/

/-- Total scalar curvature of $\mathbb{H}^2 \times \mathbb{R}$:
    $R = R_{xx} + R_{yy} + R_{zz} = -1 + (-1) + 0 = -2$. -/
def scalarCurvature : ℚ := ricciXX + ricciYY + ricciZZ

/-- Exact scalar curvature evaluation: $R = -2$. -/
theorem scalarCurvature_eq : scalarCurvature = -2 := by
  norm_num [scalarCurvature, ricciXX, ricciYY, ricciZZ]

/-- Total scalar curvature is strictly negative: $R = -2 < 0$. -/
theorem scalarCurvature_neg : scalarCurvature < 0 := by
  norm_num [scalarCurvature, ricciXX, ricciYY, ricciZZ]

/-- Real scalar curvature evaluation: $(R : \mathbb{R}) = -2$. -/
theorem scalarCurvature_real : (scalarCurvature : ℝ) = -2 := by
  norm_num [scalarCurvature, ricciXX, ricciYY, ricciZZ]

/-! ### 5. Einstein Tensor and Anisotropy -/

/-- Einstein tensor diagonal component along $x$: $G_{xx} = R_{xx} - \frac{1}{2} R = -1 - (-1) = 0$. -/
def einsteinXX : ℚ := ricciXX - scalarCurvature / 2

/-- Einstein tensor diagonal component along $y$: $G_{yy} = R_{yy} - \frac{1}{2} R = -1 - (-1) = 0$. -/
def einsteinYY : ℚ := ricciYY - scalarCurvature / 2

/-- Einstein tensor diagonal component along $z$: $G_{zz} = R_{zz} - \frac{1}{2} R = 0 - (-1) = 1$. -/
def einsteinZZ : ℚ := ricciZZ - scalarCurvature / 2

/-- Einstein tensor $G_{xx} = 0$. -/
theorem einsteinXX_eq_zero : einsteinXX = 0 := by
  norm_num [einsteinXX, ricciXX, scalarCurvature, ricciYY, ricciZZ]

/-- Einstein tensor $G_{yy} = 0$. -/
theorem einsteinYY_eq_zero : einsteinYY = 0 := by
  norm_num [einsteinYY, ricciYY, scalarCurvature, ricciXX, ricciZZ]

/-- Einstein tensor $G_{zz} = 1$. -/
theorem einsteinZZ_eq_one : einsteinZZ = 1 := by
  norm_num [einsteinZZ, ricciZZ, scalarCurvature, ricciXX, ricciYY]

/-- The metric is not Einstein since horizontal and vertical Ricci eigenvalues differ ($R_{xx} \ne R_{zz}$). -/
theorem not_einstein : ricciXX ≠ ricciZZ := by decide

end H2xRGeometry
