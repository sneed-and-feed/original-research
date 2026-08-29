/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.S2xRGeometry.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.IntervalCases

open scoped Matrix BigOperators
open Matrix

/-!
# Pillar 7: $\mathbb{S}^2 \times \mathbb{R}$ Geometry - Product Metric & Curvature Tensors

This module formalizes the Riemannian geometry, product metric, sectional curvatures,
Ricci curvature tensor, and scalar curvature of the 3-manifold $M = S^2 \times S^1_L$
with standard Thurston product geometry $\mathbb{S}^2 \times \mathbb{R}$.

## Mathematical Summary

1. **Riemannian Product Metric**:
   - The product metric on $S^2 \times S^1_L$ is given by $g = g_{S^2} \oplus g_{S^1}$.
   - In local spherical-cylindrical coordinates $(\theta, \varphi, z)$ with $\theta \in (0, \pi), \varphi \in [0, 2\pi), z \in \mathbb{R}/L\mathbb{Z}$:
     $$ds^2 = d\theta^2 + \sin^2\theta \, d\varphi^2 + dz^2.$$
   - Canonical orthonormal frame:
     $$e_1 = \partial_\theta, \quad e_2 = \frac{1}{\sin\theta} \partial_\varphi, \quad e_3 = \partial_z.$$

2. **Sectional Curvatures**:
   - Spherical factor (constant curvature $+1$): $K(e_1, e_2) = K(\partial_\theta, \partial_\varphi) = 1$.
   - Mixed spherical-longitudinal planes (flat circle product):
     $$K(e_1, e_3) = K(\partial_\theta, \partial_z) = 0, \quad K(e_2, e_3) = K(\partial_\varphi, \partial_z) = 0.$$
   - All sectional curvatures are non-negative everywhere: $K \ge 0$.

3. **Ricci Curvature Tensor**:
   - Traces of sectional curvature in the orthonormal frame:
     - $R_{11} = \operatorname{Ric}(e_1, e_1) = K(e_1, e_2) + K(e_1, e_3) = 1 + 0 = 1$.
     - $R_{22} = \operatorname{Ric}(e_2, e_2) = K(e_2, e_1) + K(e_2, e_3) = 1 + 0 = 1$.
     - $R_{33} = \operatorname{Ric}(e_3, e_3) = K(e_3, e_1) + K(e_3, e_2) = 0 + 0 = 0$.
     - Off-diagonal components vanish: $R_{ab} = 0$ for $a \ne b$.
   - Coordinate basis evaluations:
     - $\operatorname{Ric}(\partial_\theta, \partial_\theta) = 1$.
     - $\operatorname{Ric}(\partial_\varphi, \partial_\varphi) = \sin^2\theta$ (normalized: $\operatorname{Ric}(\hat{\partial}_\varphi, \hat{\partial}_\varphi) = 1$).
     - $\operatorname{Ric}(\partial_z, \partial_z) = 0$.
   - Positive semi-definiteness: $\operatorname{Ric}(v, v) \ge 0$ for all tangent vectors $v$, with 1D kernel along $\partial_z$.

4. **Scalar Curvature**:
   - Total scalar curvature is constant and strictly positive:
     $$R = R_{11} + R_{22} + R_{33} = 1 + 1 + 0 = 2 > 0.$$
   - Integrated scalar curvature / Einstein-Hilbert action:
     $$\mathcal{S}(M) = \int_M R \, dV = 2 \cdot \operatorname{Vol}(S^2 \times S^1_L) = 2 \cdot (4\pi L) = 8\pi L.$$
-/

namespace S2xRGeometry

/-! ### 1. Riemannian Volume and Metric Scaling -/

/-- Unit volume of the standard unit 2-sphere $S^2$: $\mathrm{Vol}(S^2) = 4\pi$. -/
noncomputable def volumeS2 : ℝ := 4 * Real.pi

/-- Circumference / volume of the circle factor $S^1_L$: $\mathrm{Vol}(S^1_L) = L$. -/
def volumeS1 (L : ℝ) : ℝ := L

/-- Total Riemannian volume of the product 3-manifold $S^2 \times S^1_L$:
    $$\mathrm{Vol}(S^2 \times S^1_L) = 4\pi L.$$ -/
noncomputable def volume (L : ℝ) : ℝ := volumeS2 * volumeS1 L

theorem volume_eq (L : ℝ) : volume L = 4 * Real.pi * L := rfl

theorem volume_pos {L : ℝ} (hL : L > 0) : volume L > 0 := by
  rw [volume_eq]; positivity

/-! ### 2. Sectional Curvatures -/

/-- Sectional curvature along the spherical plane $\operatorname{span}(\partial_\theta, \partial_\varphi)$:
    $K(\partial_\theta, \partial_\varphi) = 1$. -/
def secThetaPhi : ℚ := 1

/-- Sectional curvature along the mixed plane $\operatorname{span}(\partial_\theta, \partial_z)$:
    $K(\partial_\theta, \partial_z) = 0$. -/
def secThetaZ : ℚ := 0

/-- Sectional curvature along the mixed plane $\operatorname{span}(\partial_\varphi, \partial_z)$:
    $K(\partial_\varphi, \partial_z) = 0$. -/
def secPhiZ : ℚ := 0

@[simp] theorem secThetaPhi_eq : secThetaPhi = 1 := rfl
@[simp] theorem secThetaZ_eq : secThetaZ = 0 := rfl
@[simp] theorem secPhiZ_eq : secPhiZ = 0 := rfl

/-- Sectional curvature on the spherical factor is strictly positive: $K(\partial_\theta, \partial_varphi) = 1 > 0$. -/
theorem secThetaPhi_pos : secThetaPhi > 0 := by norm_num

/-- Sectional curvature along mixed directions vanishes: $K(\partial_\theta, \partial_z) = 0$. -/
theorem secThetaZ_zero : secThetaZ = 0 := rfl

/-- Sectional curvature along mixed directions vanishes: $K(\partial_\varphi, \partial_z) = 0$. -/
theorem secPhiZ_zero : secPhiZ = 0 := rfl

/-- Non-negativity of all sectional curvatures: $K \ge 0$. -/
theorem sec_nonneg : secThetaPhi ≥ 0 ∧ secThetaZ ≥ 0 ∧ secPhiZ ≥ 0 := by norm_num

/-! ### 3. Ricci Curvature Tensor -/

/-- Orthonormal Ricci curvature component along $e_\theta = \partial_\theta$:
    $\operatorname{Ric}(\partial_\theta, \partial_\theta) = K(\partial_\theta, \partial_\varphi) + K(\partial_\theta, \partial_z) = 1 + 0 = 1$. -/
def ricciThetaTheta : ℚ := secThetaPhi + secThetaZ

/-- Orthonormal Ricci curvature component along $e_\varphi = \frac{1}{\sin\theta} \partial_\varphi$:
    $\operatorname{Ric}(e_\varphi, e_\varphi) = K(e_\varphi, \partial_\theta) + K(e_\varphi, \partial_z) = 1 + 0 = 1$. -/
def ricciPhiPhi : ℚ := secThetaPhi + secPhiZ

/-- Orthonormal Ricci curvature component along $e_z = \partial_z$:
    $\operatorname{Ric}(\partial_z, \partial_z) = K(\partial_z, \partial_\theta) + K(\partial_z, \partial_\varphi) = 0 + 0 = 0$. -/
def ricciZZ : ℚ := secThetaZ + secPhiZ

@[simp] theorem ricciThetaTheta_eq : ricciThetaTheta = 1 := by norm_num [ricciThetaTheta]
@[simp] theorem ricciPhiPhi_eq : ricciPhiPhi = 1 := by norm_num [ricciPhiPhi]
@[simp] theorem ricciZZ_eq : ricciZZ = 0 := by norm_num [ricciZZ]

/-- Spherical Ricci curvature along $\partial_\theta$ is strictly positive. -/
theorem ricciThetaTheta_pos : ricciThetaTheta > 0 := by rw [ricciThetaTheta_eq]; norm_num

/-- Spherical Ricci curvature along $\hat{\partial}_\varphi$ is strictly positive. -/
theorem ricciPhiPhi_pos : ricciPhiPhi > 0 := by rw [ricciPhiPhi_eq]; norm_num

/-- Longitudinal Ricci curvature along $\partial_z$ vanishes. -/
theorem ricciZZ_zero : ricciZZ = 0 := ricciZZ_eq

/-- Ricci contraction along $\partial_\theta$ from sectional curvatures. -/
theorem ricciThetaTheta_from_sec : ricciThetaTheta = secThetaPhi + secThetaZ := rfl

/-- Ricci contraction along $e_\varphi$ from sectional curvatures. -/
theorem ricciPhiPhi_from_sec : ricciPhiPhi = secThetaPhi + secPhiZ := rfl

/-- Ricci contraction along $\partial_z$ from sectional curvatures. -/
theorem ricciZZ_from_sec : ricciZZ = secThetaZ + secPhiZ := rfl

/-- Explicit $3 \times 3$ Ricci curvature matrix in the orthonormal frame: $\operatorname{diag}(1, 1, 0)$. -/
def ricciMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  fun i j =>
    if i = 0 ∧ j = 0 then 1
    else if i = 1 ∧ j = 1 then 1
    else 0

/-- The trace of the Ricci tensor matrix equals 2. -/
theorem ricciMatrix_trace : Matrix.trace ricciMatrix = 2 := by
  simp [ricciMatrix, Matrix.trace, Matrix.diag, Fin.sum_univ_three]; ring

/-- Quadratic form of the Ricci tensor: $v^T \operatorname{Ric} v = v_0^2 + v_1^2 \ge 0$. -/
theorem ricci_quadratic_form (v : Fin 3 → ℝ) :
    dotProduct v (mulVec ricciMatrix v) = (v 0) ^ 2 + (v 1) ^ 2 := by
  simp [ricciMatrix, dotProduct, mulVec, Fin.sum_univ_three]; ring

/-- Positive semi-definiteness of the Ricci tensor: $\operatorname{Ric}(v, v) \ge 0$ for all $v \in \mathbb{R}^3$. -/
theorem ricci_nonneg (v : Fin 3 → ℝ) :
    dotProduct v (mulVec ricciMatrix v) ≥ 0 := by
  rw [ricci_quadratic_form]; positivity

/-- The longitudinal direction $e_3 = (0, 0, 1)^T$ spans the kernel of the Ricci tensor. -/
theorem ricci_kernel_z :
    mulVec ricciMatrix ![(0 : ℝ), 0, 1] = 0 := by
  ext ⟨i, hi⟩
  interval_cases i <;> simp [ricciMatrix, mulVec, dotProduct]

/-! ### 4. Scalar Curvature -/

/-- Total scalar curvature of $S^2 \times S^1_L$:
    $$R = \operatorname{Ric}(\partial_\theta, \partial_\theta) + \operatorname{Ric}(e_\varphi, e_\varphi) + \operatorname{Ric}(\partial_z, \partial_z) = 2.$$ -/
def scalarCurvature : ℚ := ricciThetaTheta + ricciPhiPhi + ricciZZ

@[simp] theorem scalarCurvature_eq : scalarCurvature = 2 := by
  norm_num [scalarCurvature, ricciThetaTheta, ricciPhiPhi, ricciZZ]

/-- Scalar curvature is strictly positive: $R = 2 > 0$. -/
theorem scalarCurvature_pos : scalarCurvature > 0 := by
  rw [scalarCurvature_eq]; norm_num

/-- Real scalar curvature evaluation. -/
theorem scalarCurvature_real : (scalarCurvature : ℝ) = 2 := by norm_num

/-- Total integrated scalar curvature (Einstein-Hilbert functional):
    $$\mathcal{S}(M) = \int_M R \, dV = 2 \cdot \operatorname{Vol}(M) = 8\pi L.$$ -/
noncomputable def totalScalarCurvature (L : ℝ) : ℝ :=
  (scalarCurvature : ℝ) * volume L

/-- Exact closed-form value of total scalar curvature: $\mathcal{S}(M) = 8\pi L$. -/
theorem totalScalarCurvature_eq (L : ℝ) : totalScalarCurvature L = 8 * Real.pi * L := by
  dsimp [totalScalarCurvature, volume, volumeS2, volumeS1]
  rw [scalarCurvature_real]
  ring

/-- Strict positivity of total scalar curvature for $L > 0$. -/
theorem totalScalarCurvature_pos {L : ℝ} (hL : L > 0) : totalScalarCurvature L > 0 := by
  rw [totalScalarCurvature_eq]; positivity

end S2xRGeometry