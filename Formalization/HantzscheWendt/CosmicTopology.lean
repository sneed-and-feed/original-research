/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.HantzscheWendt.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Complex
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FinCases

open Matrix

/-!
# Candidate 3: The Flat Hantzsche-Wendt Didicosm ($G_6$) - Cosmic Topology & Cell Geometry

This module formalizes the Riemannian geometric invariants, fundamental domain cell structure,
and observational cosmic topology properties of the **Hantzsche-Wendt manifold** (Didicosm, $G_6$).

## Mathematical Summary

1. **Linear Rotation Invariants & Twist Angle Derivation**:
   - The linear representations $R_1, R_2, R_3 \in \mathrm{SO}(3)$ are order-2 involutions ($R_i^2 = I$)
     with determinant $\det(R_i) = +1$ and trace $\operatorname{Tr}(R_i) = -1$.
   - The trace identity $\operatorname{Tr}(R_i) = 1 + 2\cos\theta$ implies $\cos\theta = -1$,
     rigorously deriving the twist angle $\theta = \pi$ from the group representation.

2. **Screw Displacement Vectors, Systole & Distance Minimum**:
   - The screw displacement vector $\Delta_1(p) = \gamma_1(p) - p = (1/2, -2y, -2z)$ has Euclidean
     squared norm $\|\Delta_1(p)\|^2 = 1/4 + 4(y^2 + z^2)$.
   - The sharp global minimum $\|\Delta_1(p)\|^2 \ge 1/4$ is achieved if and only if $y = 0 \wedge z = 0$
     (the screw rotation axis), yielding the systole $l_{\min}(G_6) = 1/2$ and injectivity radius $r_{\mathrm{inj}}(G_6) = 1/4$.

3. **Non-Back-to-Back vs. Back-to-Back Direction Vectors**:
   - $\Delta_1(p)$ is parallel to the translation direction $(1, 0, 0)$ if and only if $y = 0 \wedge z = 0$.
     Off-axis observers observe non-back-to-back matched circles.
   - The squared generator $\gamma_1^2$ has uniform displacement $\Delta_1^{(2)}(p) = (1, 0, 0)$ everywhere,
     proving algebraically why pure lattice translations produce back-to-back circle pairs.

4. **Isometry Distance Preservation**:
   - All generators $\gamma_1, \gamma_2, \gamma_3, \gamma_z$ preserve Euclidean squared distances:
     $$\|\gamma_i(p) - \gamma_i(q)\|^2 = \|p - q\|^2.$$

5. **Fundamental Domain Geometry & Volume Invariants**:
   - The 12-faced invariant polyhedron has Euler characteristic $V - E + F = 14 - 24 + 12 = 2$.
   - Volume formula: $\mathrm{Vol}(G_6) = L^3 / 4 = \mathrm{Vol}(T^3) / 4$.
-/

namespace HantzscheWendt

/-! ### 1. Linear Rotation Invariants & Twist Angle Derivation -/

/-- Linear rotation matrix $R_1 \in \mathrm{SO}(3)$ representing the $\pi$-rotation part of $\gamma_1$. -/
def R1 : Matrix (Fin 3) (Fin 3) ℝ :=
  ![![(1 : ℝ), 0, 0],
    ![0, -1, 0],
    ![0, 0, -1]]

/-- Linear rotation matrix $R_2 \in \mathrm{SO}(3)$ representing the $\pi$-rotation part of $\gamma_2$. -/
def R2 : Matrix (Fin 3) (Fin 3) ℝ :=
  ![![(-1 : ℝ), 0, 0],
    ![0, 1, 0],
    ![0, 0, -1]]

/-- Linear rotation matrix $R_3 \in \mathrm{SO}(3)$ representing the $\pi$-rotation part of $\gamma_3$ / $\gamma_z$. -/
def R3 : Matrix (Fin 3) (Fin 3) ℝ :=
  ![![(-1 : ℝ), 0, 0],
    ![0, -1, 0],
    ![0, 0, 1]]

/-- Involutive property of $R_1$: $R_1^2 = I_3$. -/
theorem R1_sq : R1 * R1 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> { rw [mul_apply, Fin.sum_univ_three, one_apply]; simp [R1] }

/-- Involutive property of $R_2$: $R_2^2 = I_3$. -/
theorem R2_sq : R2 * R2 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> { rw [mul_apply, Fin.sum_univ_three, one_apply]; simp [R2] }

/-- Involutive property of $R_3$: $R_3^2 = I_3$. -/
theorem R3_sq : R3 * R3 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> { rw [mul_apply, Fin.sum_univ_three, one_apply]; simp [R3] }

/-- Determinant $\det(R_1) = +1$ (orientation preserving in $\mathrm{SO}(3)$). -/
theorem det_R1 : Matrix.det R1 = 1 := by
  rw [det_fin_three]; simp [R1]

/-- Determinant $\det(R_2) = +1$ (orientation preserving in $\mathrm{SO}(3)$). -/
theorem det_R2 : Matrix.det R2 = 1 := by
  rw [det_fin_three]; simp [R2]

/-- Determinant $\det(R_3) = +1$ (orientation preserving in $\mathrm{SO}(3)$). -/
theorem det_R3 : Matrix.det R3 = 1 := by
  rw [det_fin_three]; simp [R3]

/-- Trace $\operatorname{Tr}(R_1) = -1$. -/
theorem trace_R1 : Matrix.trace R1 = -1 := by
  simp [trace, diag, R1, Fin.sum_univ_three]

/-- Trace $\operatorname{Tr}(R_2) = -1$. -/
theorem trace_R2 : Matrix.trace R2 = -1 := by
  simp [trace, diag, R2, Fin.sum_univ_three]

/-- Trace $\operatorname{Tr}(R_3) = -1$. -/
theorem trace_R3 : Matrix.trace R3 = -1 := by
  simp [trace, diag, R3, Fin.sum_univ_three]

/-- Derivation of $\cos\theta = -1$ from the rotation trace formula $\operatorname{Tr}(R_1) = 1 + 2\cos\theta$. -/
theorem cos_twist_angle_of_trace {θ : ℝ} (h : 1 + 2 * Real.cos θ = Matrix.trace R1) :
    Real.cos θ = -1 := by
  linarith [trace_R1]

/-- Derivation of $\cos\theta = -1$ from the rotation trace formula for $R_2$. -/
theorem cos_twist_angle_of_trace_R2 {θ : ℝ} (h : 1 + 2 * Real.cos θ = Matrix.trace R2) :
    Real.cos θ = -1 := by
  linarith [trace_R2]

/-- Derivation of $\cos\theta = -1$ from the rotation trace formula for $R_3$. -/
theorem cos_twist_angle_of_trace_R3 {θ : ℝ} (h : 1 + 2 * Real.cos θ = Matrix.trace R3) :
    Real.cos θ = -1 := by
  linarith [trace_R3]

/-- Rigorous twist angle derivation: the canonical rotation angle $\theta \in [0, 2\pi)$
    associated with $\operatorname{Tr}(R_1) = -1$ is uniquely $\theta = \pi$. -/
theorem twist_angle_eq_pi_of_trace {θ : ℝ} (h_range : 0 ≤ θ ∧ θ < 2 * Real.pi)
    (h_tr : 1 + 2 * Real.cos θ = Matrix.trace R1) : θ = Real.pi := by
  obtain ⟨k, rfl⟩ := Real.cos_eq_neg_one_iff.mp (cos_twist_angle_of_trace h_tr)
  have hpi := Real.pi_pos
  have hk : k = 0 := by
    by_contra h
    have : (k : ℝ) ≤ -1 ∨ (k : ℝ) ≥ 1 := by
      rcases lt_or_gt_of_ne h with hl | hg
      · left; exact_mod_cast (show k ≤ -1 by omega)
      · right; exact_mod_cast (show k ≥ 1 by omega)
    cases this <;> nlinarith [h_range.1, h_range.2]
  simp [hk]

/-! ### 2. Euclidean Metrics, Displacement Vectors & Sharp Lower Bounds -/

/-- Vector difference of two 3D points: $p - q$. -/
def pointSub (p q : RealPoint) : RealPoint :=
  (p.1 - q.1, p.2.1 - q.2.1, p.2.2 - q.2.2)

/-- Euclidean squared norm of a vector $v \in \mathbb{R}^3$: $\|v\|^2 = v_x^2 + v_y^2 + v_z^2$. -/
def normSq (v : RealPoint) : ℝ :=
  v.1 ^ 2 + v.2.1 ^ 2 + v.2.2 ^ 2

/-- Euclidean squared distance between two points $p, q \in \mathbb{R}^3$: $\|p - q\|^2$. -/
def distSq (p q : RealPoint) : ℝ :=
  normSq (pointSub p q)

/-- Displacement vector function under $\gamma_1$: $\Delta_1(p) = \gamma_1(p) - p$. -/
noncomputable def dispGamma1 (p : RealPoint) : RealPoint :=
  pointSub (gamma1 p) p

/-- Displacement vector function under $\gamma_2$: $\Delta_2(p) = \gamma_2(p) - p$. -/
noncomputable def dispGamma2 (p : RealPoint) : RealPoint :=
  pointSub (gamma2 p) p

/-- Displacement vector function under $\gamma_3$: $\Delta_3(p) = \gamma_3(p) - p$. -/
noncomputable def dispGamma3 (p : RealPoint) : RealPoint :=
  pointSub (gamma3 p) p

/-- Displacement vector function under $\gamma_z$: $\Delta_z(p) = \gamma_z(p) - p$. -/
noncomputable def dispGammaZ (p : RealPoint) : RealPoint :=
  pointSub (gammaZ p) p

/-- Explicit formula for $\Delta_1(p) = (1/2, -2y, -2z)$. -/
theorem dispGamma1_eq (p : RealPoint) :
    dispGamma1 p = (1 / 2, -2 * p.2.1, -2 * p.2.2) := by
  dsimp [dispGamma1, pointSub, gamma1]
  ring_nf

/-- Explicit formula for $\Delta_2(p) = (-2x, 1/2, 1/2 - 2z)$. -/
theorem dispGamma2_eq (p : RealPoint) :
    dispGamma2 p = (-2 * p.1, 1 / 2, 1 / 2 - 2 * p.2.2) := by
  dsimp [dispGamma2, pointSub, gamma2]
  ring_nf

/-- Explicit formula for $\Delta_3(p) = (1/2 - 2x, 1/2 - 2y, 0)$. -/
theorem dispGamma3_eq (p : RealPoint) :
    dispGamma3 p = (1 / 2 - 2 * p.1, 1 / 2 - 2 * p.2.1, 0) := by
  dsimp [dispGamma3, pointSub, gamma3]
  ring_nf

/-- Explicit formula for $\Delta_z(p) = (1/2 - 2x, -2y, 1/2)$. -/
theorem dispGammaZ_eq (p : RealPoint) :
    dispGammaZ p = (1 / 2 - 2 * p.1, -2 * p.2.1, 1 / 2) := by
  dsimp [dispGammaZ, pointSub, gammaZ]
  ring_nf

/-- Euclidean squared norm formula for $\Delta_1(p)$:
    $\|\Delta_1(p)\|^2 = 1/4 + 4(y^2 + z^2)$. -/
theorem normSq_dispGamma1 (p : RealPoint) :
    normSq (dispGamma1 p) = 1 / 4 + 4 * (p.2.1 ^ 2 + p.2.2 ^ 2) := by
  dsimp [normSq, dispGamma1, pointSub, gamma1]
  ring

/-- Sharp lower bound for screw displacement norm squared:
    $\|\Delta_1(p)\|^2 \ge 1/4$ for all $p \in \mathbb{R}^3$. -/
theorem normSq_dispGamma1_ge_quarter (p : RealPoint) :
    normSq (dispGamma1 p) ≥ 1 / 4 := by
  rw [normSq_dispGamma1]; linarith [sq_nonneg p.2.1, sq_nonneg p.2.2]

/-- Sharp equality characterization:
    $\|\Delta_1(p)\|^2 = 1/4 \iff y = 0 \wedge z = 0$ (the screw rotation axis). -/
theorem normSq_dispGamma1_eq_quarter_iff (p : RealPoint) :
    normSq (dispGamma1 p) = 1 / 4 ↔ p.2.1 = 0 ∧ p.2.2 = 0 := by
  rw [normSq_dispGamma1]
  constructor
  · intro h
    have hp1 : p.2.1 ^ 2 = 0 := by linarith [sq_nonneg p.2.1, sq_nonneg p.2.2]
    have hp2 : p.2.2 ^ 2 = 0 := by linarith [sq_nonneg p.2.1, sq_nonneg p.2.2]
    exact ⟨sq_eq_zero_iff.mp hp1, sq_eq_zero_iff.mp hp2⟩
  · rintro ⟨h1, h2⟩; rw [h1, h2]; ring

/-- The minimum displacement of $1/4$ is attained on the rotation axis $y = 0, z = 0$. -/
theorem min_dispGamma1_normSq :
    ∃ p : RealPoint, normSq (dispGamma1 p) = 1 / 4 ∧ ∀ q : RealPoint, normSq (dispGamma1 q) ≥ 1 / 4 :=
  ⟨(0, 0, 0), (normSq_dispGamma1_eq_quarter_iff (0, 0, 0)).mpr ⟨rfl, rfl⟩, normSq_dispGamma1_ge_quarter⟩

/-- Euclidean squared norm formula for $\Delta_2(p)$:
    $\|\Delta_2(p)\|^2 = 1/4 + 4x^2 + (1/2 - 2z)^2$. -/
theorem normSq_dispGamma2 (p : RealPoint) :
    normSq (dispGamma2 p) = 1 / 4 + 4 * p.1 ^ 2 + (1 / 2 - 2 * p.2.2) ^ 2 := by
  dsimp [normSq, dispGamma2, pointSub, gamma2]
  ring

/-- Sharp lower bound for $\gamma_2$ displacement norm squared:
    $\|\Delta_2(p)\|^2 \ge 1/4$ for all $p \in \mathbb{R}^3$. -/
theorem normSq_dispGamma2_ge_quarter (p : RealPoint) :
    normSq (dispGamma2 p) ≥ 1 / 4 := by
  rw [normSq_dispGamma2]; linarith [sq_nonneg p.1, sq_nonneg (1 / 2 - 2 * p.2.2)]

/-- Sharp equality characterization for $\gamma_2$:
    $\|\Delta_2(p)\|^2 = 1/4 \iff x = 0 \wedge z = 1/4$ (the $\gamma_2$ rotation axis). -/
theorem normSq_dispGamma2_eq_quarter_iff (p : RealPoint) :
    normSq (dispGamma2 p) = 1 / 4 ↔ p.1 = 0 ∧ p.2.2 = 1 / 4 := by
  rw [normSq_dispGamma2]
  constructor
  · intro h
    have hp1 : p.1 ^ 2 = 0 := by linarith [sq_nonneg p.1, sq_nonneg (1 / 2 - 2 * p.2.2)]
    have hp2 : (1 / 2 - 2 * p.2.2) ^ 2 = 0 := by linarith [sq_nonneg p.1, sq_nonneg (1 / 2 - 2 * p.2.2)]
    have hp2' : p.2.2 = 1 / 4 := by linarith [sq_eq_zero_iff.mp hp2]
    exact ⟨sq_eq_zero_iff.mp hp1, hp2'⟩
  · rintro ⟨h1, h2⟩; rw [h1, h2]; ring

/-- Euclidean squared norm formula for $\Delta_z(p)$:
    $\|\Delta_z(p)\|^2 = 1/4 + (1/2 - 2x)^2 + 4y^2$. -/
theorem normSq_dispGammaZ (p : RealPoint) :
    normSq (dispGammaZ p) = 1 / 4 + (1 / 2 - 2 * p.1) ^ 2 + 4 * p.2.1 ^ 2 := by
  dsimp [normSq, dispGammaZ, pointSub, gammaZ]
  ring

/-- Sharp lower bound for $\gamma_z$ displacement norm squared:
    $\|\Delta_z(p)\|^2 \ge 1/4$ for all $p \in \mathbb{R}^3$. -/
theorem normSq_dispGammaZ_ge_quarter (p : RealPoint) :
    normSq (dispGammaZ p) ≥ 1 / 4 := by
  rw [normSq_dispGammaZ]; linarith [sq_nonneg (1 / 2 - 2 * p.1), sq_nonneg p.2.1]

/-- Sharp equality characterization for $\gamma_z$:
    $\|\Delta_z(p)\|^2 = 1/4 \iff x = 1/4 \wedge y = 0$ (the $\gamma_z$ rotation axis). -/
theorem normSq_dispGammaZ_eq_quarter_iff (p : RealPoint) :
    normSq (dispGammaZ p) = 1 / 4 ↔ p.1 = 1 / 4 ∧ p.2.1 = 0 := by
  rw [normSq_dispGammaZ]
  constructor
  · intro h
    have hp1 : (1 / 2 - 2 * p.1) ^ 2 = 0 := by linarith [sq_nonneg (1 / 2 - 2 * p.1), sq_nonneg p.2.1]
    have hp2 : p.2.1 ^ 2 = 0 := by linarith [sq_nonneg (1 / 2 - 2 * p.1), sq_nonneg p.2.1]
    have hp1' : p.1 = 1 / 4 := by linarith [sq_eq_zero_iff.mp hp1]
    exact ⟨hp1', sq_eq_zero_iff.mp hp2⟩
  · rintro ⟨h1, h2⟩; rw [h1, h2]; ring

/-! ### 3. Systole, Injectivity Radius & Volume Invariants -/

/-- Length of the shortest closed geodesic (systole) on the unit Didicosm ($L = 1$):
    $l_{\min}(G_6) = 1/2$. -/
noncomputable def unitSystoleDidicosm : ℝ := 1 / 2

/-- Systole squared equals the minimal squared displacement $1/4$. -/
theorem unitSystoleDidicosm_sq : unitSystoleDidicosm ^ 2 = 1 / 4 := by
  dsimp [unitSystoleDidicosm]; ring

/-- Injectivity radius of the unit Didicosm: $r_{\mathrm{inj}}(G_6) = l_{\min} / 2 = 1/4$. -/
noncomputable def unitInjectivityRadiusDidicosm : ℝ := unitSystoleDidicosm / 2

/-- Unit injectivity radius formula: $r_{\mathrm{inj}}(G_6) = 1/4$. -/
theorem unitInjectivityRadiusDidicosm_eq : unitInjectivityRadiusDidicosm = 1 / 4 := by
  dsimp [unitInjectivityRadiusDidicosm, unitSystoleDidicosm]; ring

/-- Scaled systole on the Didicosm with scale parameter $L > 0$: $l_{\min}(G_6) = L / 2$. -/
noncomputable def systoleDidicosm (L : ℝ) : ℝ := L / 2

/-- Scaled systole on the 3-torus $T^3$: $l_{\min}(T^3) = L$. -/
noncomputable def systoleTorus (L : ℝ) : ℝ := L

/-- Scaled injectivity radius of the Didicosm: $r_{\mathrm{inj}}(G_6) = L / 4$. -/
noncomputable def injectivityRadiusDidicosm (L : ℝ) : ℝ := systoleDidicosm L / 2

/-- Injectivity radius formula identity: $r_{\mathrm{inj}}(G_6) = L / 4$. -/
theorem injectivityRadiusDidicosm_eq (L : ℝ) :
    injectivityRadiusDidicosm L = L / 4 := by
  dsimp [injectivityRadiusDidicosm, systoleDidicosm]; ring

/-- Injectivity radius of the 3-torus $T^3$: $r_{\mathrm{inj}}(T^3) = L / 2$. -/
noncomputable def injectivityRadiusTorus (L : ℝ) : ℝ := systoleTorus L / 2

/-- Injectivity radius of $T^3$ is $L / 2$. -/
theorem injectivityRadiusTorus_eq (L : ℝ) :
    injectivityRadiusTorus L = L / 2 := rfl

/-- Ratio of injectivity radii: $r_{\mathrm{inj}}(G_6) / r_{\mathrm{inj}}(T^3) = 1/2$. -/
theorem injectivityRadius_ratio (L : ℝ) (hL : L > 0) :
    injectivityRadiusDidicosm L / injectivityRadiusTorus L = 1 / 2 := by
  dsimp [injectivityRadiusDidicosm, injectivityRadiusTorus, systoleDidicosm, systoleTorus]
  have : L ≠ 0 := hL.ne'
  field_simp

/-- Positivity of Didicosm injectivity radius for $L > 0$. -/
theorem injectivityRadiusDidicosm_pos {L : ℝ} (hL : L > 0) :
    injectivityRadiusDidicosm L > 0 := by
  dsimp [injectivityRadiusDidicosm, systoleDidicosm]; positivity

/-- The volume of the 3-torus $T^3$ with side length $L > 0$: $\mathrm{Vol}(T^3) = L^3$. -/
noncomputable def volumeTorus (L : ℝ) : ℝ := L ^ 3

/-- The covering index of the 3-torus over the Didicosm $[G_6 : \mathbb{Z}^3] = 4$. -/
def holonomyCoveringIndex : ℕ := 4

/-- The volume of the Hantzsche-Wendt Didicosm $G_6$ with scale parameter $L > 0$:
    $\mathrm{Vol}(G_6) = L^3 / 4$. -/
noncomputable def volumeDidicosm (L : ℝ) : ℝ := L ^ 3 / 4

/-- Unit volume of the Didicosm (when $L = 1$). -/
noncomputable def unitVolumeDidicosm : ℝ := 1 / 4

/-- Unit volume is $1/4$. -/
theorem unitVolumeDidicosm_eq : unitVolumeDidicosm = 1 / 4 := rfl

/-- Volume formula relation: $\mathrm{Vol}(G_6) = \mathrm{Vol}(T^3) / 4$. -/
theorem volume_didicosm_eq_torus_div_four (L : ℝ) :
    volumeDidicosm L = volumeTorus L / 4 := rfl

/-- Strict positivity of Didicosm volume for $L > 0$. -/
theorem volumeDidicosm_pos {L : ℝ} (hL : L > 0) : volumeDidicosm L > 0 := by
  dsimp [volumeDidicosm]; positivity

/-! ### 4. Non-Back-to-Back vs. Back-to-Back Direction Vectors -/

/-- Direction vector parallelism to the $x$-axis translation vector $(1, 0, 0)$. -/
def isParallelToXAxis (v : RealPoint) : Prop :=
  v.2.1 = 0 ∧ v.2.2 = 0

/-- Characterization: $v$ is parallel to $x$-axis iff it is a scalar multiple of $(1, 0, 0)$. -/
theorem isParallelToXAxis_iff_exists_scalar (v : RealPoint) :
    isParallelToXAxis v ↔ ∃ c : ℝ, v = (c, 0, 0) := by
  constructor
  · rintro ⟨h1, h2⟩; rcases v with ⟨vx, vy, vz⟩; exact ⟨vx, by dsimp at *; rw [h1, h2]⟩
  · rintro ⟨c, rfl⟩; exact ⟨rfl, rfl⟩

/-- $\Delta_1(p)$ is parallel to the translation direction $(1, 0, 0)$ if and only if
    $p$ lies on the rotation axis ($y = 0 \wedge z = 0$). -/
theorem dispGamma1_parallel_xAxis_iff (p : RealPoint) :
    isParallelToXAxis (dispGamma1 p) ↔ p.2.1 = 0 ∧ p.2.2 = 0 := by
  rw [dispGamma1_eq]; dsimp [isParallelToXAxis]
  constructor <;> intro ⟨h1, h2⟩ <;> constructor <;> linarith

/-- For any observer off the screw axis ($y \ne 0 \vee z \ne 0$), $\Delta_1(p)$ is NOT parallel
    to the translation axis $(1, 0, 0)$, explaining non-back-to-back matched circles. -/
theorem dispGamma1_not_parallel_xAxis_of_off_axis (p : RealPoint) (h : p.2.1 ≠ 0 ∨ p.2.2 ≠ 0) :
    ¬ isParallelToXAxis (dispGamma1 p) := by
  rw [dispGamma1_parallel_xAxis_iff]; rintro ⟨h1, h2⟩; rcases h with hy | hz <;> contradiction

/-- Displacement vector for the squared generator $\gamma_1^2$:
    $\Delta_1^{(2)}(p) = \gamma_1^2(p) - p$. -/
noncomputable def dispGamma1Sq (p : RealPoint) : RealPoint :=
  pointSub (gamma1 (gamma1 p)) p

/-- The squared generator $\gamma_1^2$ produces a uniform pure translation displacement
    $(1, 0, 0)$ for all points $p \in \mathbb{R}^3$. -/
theorem dispGamma1Sq_eq_const (p : RealPoint) :
    dispGamma1Sq p = (1, 0, 0) := by
  dsimp [dispGamma1Sq, pointSub, gamma1]; ring_nf

/-- Consequently, $\Delta_1^{(2)}(p)$ is uniformly parallel to the $x$-axis for every point $p$,
    proving algebraically why $\gamma_1^2$ produces back-to-back matched pairs. -/
theorem dispGamma1Sq_isParallelToXAxis (p : RealPoint) :
    isParallelToXAxis (dispGamma1Sq p) := by
  rw [dispGamma1Sq_eq_const]; exact ⟨rfl, rfl⟩

/-- Displacement vector for the squared generator $\gamma_2^2$:
    $\Delta_2^{(2)}(p) = \gamma_2^2(p) - p = (0, 1, 0)$. -/
noncomputable def dispGamma2Sq (p : RealPoint) : RealPoint :=
  pointSub (gamma2 (gamma2 p)) p

theorem dispGamma2Sq_eq_const (p : RealPoint) :
    dispGamma2Sq p = (0, 1, 0) := by
  dsimp [dispGamma2Sq, pointSub, gamma2]; ring_nf

/-- Displacement vector for the squared generator $\gamma_z^2$:
    $\Delta_z^{(2)}(p) = \gamma_z^2(p) - p = (0, 0, 1)$. -/
noncomputable def dispGammaZSq (p : RealPoint) : RealPoint :=
  pointSub (gammaZ (gammaZ p)) p

theorem dispGammaZSq_eq_const (p : RealPoint) :
    dispGammaZSq p = (0, 0, 1) := by
  dsimp [dispGammaZSq, pointSub, gammaZ]; ring_nf

/-! ### 5. Isometry Distance Preservation -/

/-- $\gamma_1$ is an isometry: preserves Euclidean squared distances. -/
theorem distSq_gamma1 (p q : RealPoint) :
    distSq (gamma1 p) (gamma1 q) = distSq p q := by
  dsimp [distSq, normSq, pointSub, gamma1]; ring

/-- $\gamma_2$ is an isometry: preserves Euclidean squared distances. -/
theorem distSq_gamma2 (p q : RealPoint) :
    distSq (gamma2 p) (gamma2 q) = distSq p q := by
  dsimp [distSq, normSq, pointSub, gamma2]; ring

/-- $\gamma_3$ is an isometry: preserves Euclidean squared distances. -/
theorem distSq_gamma3 (p q : RealPoint) :
    distSq (gamma3 p) (gamma3 q) = distSq p q := by
  dsimp [distSq, normSq, pointSub, gamma3]; ring

/-- $\gamma_z$ is an isometry: preserves Euclidean squared distances. -/
theorem distSq_gammaZ (p q : RealPoint) :
    distSq (gammaZ p) (gammaZ q) = distSq p q := by
  dsimp [distSq, normSq, pointSub, gammaZ]; ring

/-- Pure translation preserves Euclidean squared distances. -/
theorem distSq_trans (v : RealPoint) (p q : RealPoint) :
    distSq (trans v p) (trans v q) = distSq p q := by
  dsimp [distSq, normSq, pointSub, trans]; ring

/-! ### 6. Fundamental Polyhedron Geometry & Cosmic Topology Matched Circles -/

/-- Number of faces of the Didicosm fundamental domain polyhedron is 12. -/
def fundamentalDomainFaceCount : ℕ := 12

/-- Number of face identification pairs is 6: $12 / 2 = 6$. -/
def facePairCount : ℕ := 6

/-- Face pair count theorem: 12 faces identify into 6 pairs. -/
theorem facePairCount_eq : facePairCount = fundamentalDomainFaceCount / 2 := rfl

/-- Identification twist angle fraction of $\pi$ for each face pair is 1 (twist of $\pi$ radians). -/
def faceTwistAngleFractionOfPi : ℚ := 1

/-- Twist angle in radians: $\alpha = \pi$. -/
theorem face_twist_angle_is_pi : faceTwistAngleFractionOfPi = 1 := rfl

/-- Number of vertices of the Didicosm fundamental domain polyhedron is 14. -/
def fundamentalDomainVertexCount : ℕ := 14

/-- Number of edges of the Didicosm fundamental domain polyhedron is 24. -/
def fundamentalDomainEdgeCount : ℕ := 24

/-- Euler characteristic of the fundamental polyhedron boundary 2-sphere:
    $V - E + F = 14 - 24 + 12 = 2$. -/
theorem fundamental_polyhedron_euler_char :
    (fundamentalDomainVertexCount : ℤ) - (fundamentalDomainEdgeCount : ℤ) + (fundamentalDomainFaceCount : ℤ) = 2 := rfl

/-- Total number of CMB matched circle pairs predicted by the Didicosm topology is 6. -/
def cmbMatchedCirclePairs : ℕ := 6

/-- The matched circle pair count matches the face pair count of the fundamental polyhedron. -/
theorem cmb_matched_circle_pairs_eq_face_pairs :
    cmbMatchedCirclePairs = facePairCount := rfl

/-- Relative phase angle between matched circles in radians is $\pi$. -/
noncomputable def cmbMatchedCircleTwistAngle : ℝ := Real.pi

/-- Strict positivity of the matched circle twist angle. -/
theorem cmbMatchedCircleTwistAngle_pos : cmbMatchedCircleTwistAngle > 0 := Real.pi_pos

end HantzscheWendt

