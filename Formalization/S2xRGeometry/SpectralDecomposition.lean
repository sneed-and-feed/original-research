/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.S2xRGeometry.Basic
import Formalization.S2xRGeometry.Geometry
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

open scoped Real

/-!
# Pillar 7: $\mathbb{S}^2 \times \mathbb{R}$ Geometry - Spectral Decomposition & Laplace-Beltrami Spectrum

This module formalizes the spectral decomposition of the Laplace-Beltrami operator on the
compact 3-manifold $M = S^2 \times S^1_L$ (with circle circumference $L > 0$).

## Mathematical Summary

1. **Splitting of the Laplace-Beltrami Operator**:
   - For the product metric $g = g_{S^2} \oplus g_{S^1_L}$, the Laplace-Beltrami operator splits additively:
     $$\Delta_{S^2 \times S^1} = \Delta_{S^2} \otimes I + I \otimes \Delta_{S^1_L}.$$
   - Eigenfunctions factor into spherical harmonics and Fourier modes:
     $$\psi_{\ell, m, n}(\theta, \varphi, z) = Y_{\ell, m}(\theta, \varphi) e^{i \frac{2\pi n}{L} z}, \quad \ell \in \mathbb{N}, \; m \in \{-\ell, \dots, \ell\}, \; n \in \mathbb{Z}.$$

2. **Factor Spectra**:
   - **$S^2$ Factor**:
     $$\Delta_{S^2} Y_{\ell, m} = \ell(\ell + 1) Y_{\ell, m}, \quad \mu_\ell = \ell(\ell + 1), \quad d_{S^2}(\ell) = 2\ell + 1.$$
   - **$S^1_L$ Circle Factor**:
     $$\Delta_{S^1_L} e^{i \frac{2\pi n}{L} z} = \left(\frac{2\pi n}{L}\right)^2 e^{i \frac{2\pi n}{L} z}, \quad \nu_n = \left(\frac{2\pi n}{L}\right)^2, \quad d_{S^1}(n) = 2 - \delta_{n, 0}.$$

3. **Joint Spectrum & Spectral Degeneracies**:
   - Joint eigenvalues:
     $$\lambda_{\ell, n}(L) = \ell(\ell + 1) + \left(\frac{2\pi n}{L}\right)^2, \quad \ell \in \mathbb{N}, \; n \in \mathbb{Z}.$$
   - Spectral degeneracy:
     $$d(\ell, n) = d_{S^2}(\ell) \cdot d_{S^1}(n) = (2\ell + 1)(2 - \delta_{n, 0}).$$
   - Ground state: $(\ell, n) = (0, 0) \implies \lambda_{0, 0} = 0$, with multiplicity $d(0, 0) = 1$.

4. **Ground State Spectral Gap $\lambda_1(L)$**:
   - The first non-zero eigenvalue arises from either the lowest spherical excitation $(\ell=1, n=0)$
     or the lowest longitudinal excitation $(\ell=0, n=1)$:
     - $\lambda_{1, 0} = 1(1+1) + 0 = 2$ with degeneracy $d(1, 0) = 3$.
     - $\lambda_{0, 1} = 0 + (2\pi/L)^2 = 4\pi^2/L^2$ with degeneracy $d(0, 1) = 2$.
   - Hence, the exact spectral gap is:
     $$\lambda_1(L) = \min\left(2, \, \frac{4\pi^2}{L^2}\right) > 0.$$

5. **Critical Length & Phase Crossover**:
   - Critical circle circumference: $L_c = \pi\sqrt{2}$.
   - For short circles ($L < \pi\sqrt{2}$): $4\pi^2/L^2 > 2 \implies \lambda_1(L) = 2$ (sphere-dominated).
   - For long circles ($L > \pi\sqrt{2}$): $4\pi^2/L^2 < 2 \implies \lambda_1(L) = 4\pi^2/L^2$ (circle-dominated / Kaluza-Klein threshold).
   - At the critical crossover point $L = L_c$: $4\pi^2/L_c^2 = 2$, and the eigenspaces coalesce into a 5-dimensional eigenspace ($3 + 2 = 5$).
-/

namespace S2xRGeometry

/-! ### 1. Factor Spectra -/

/-- Eigenvalue of the 2-sphere Laplacian $\Delta_{S^2}$ for angular momentum quantum number $\ell \in \mathbb{N}$:
    $$\mu_\ell = \ell(\ell + 1).$$ -/
def sphereEigenvalue (ell : ℕ) : ℝ :=
  (ell : ℝ) * ((ell : ℝ) + 1)

/-- Angular degeneracy on $S^2$: $d_{S^2}(\ell) = 2\ell + 1$. -/
def sphereDegeneracy (ell : ℕ) : ℕ :=
  2 * ell + 1

@[simp] theorem sphereEigenvalue_zero : sphereEigenvalue 0 = 0 := by
  dsimp [sphereEigenvalue]; ring

@[simp] theorem sphereEigenvalue_one : sphereEigenvalue 1 = 2 := by
  dsimp [sphereEigenvalue]; ring

@[simp] theorem sphereDegeneracy_zero : sphereDegeneracy 0 = 1 := rfl
@[simp] theorem sphereDegeneracy_one : sphereDegeneracy 1 = 3 := rfl

/-- Eigenvalue of the circle Laplacian $\Delta_{S^1}$ with circumference $L > 0$ for Fourier mode $n \in \mathbb{Z}$:
    $$\nu_n = \left(\frac{2\pi n}{L}\right)^2.$$ -/
noncomputable def circleEigenvalue (L : ℝ) (n : ℤ) : ℝ :=
  (2 * Real.pi * (n : ℝ) / L) ^ 2

/-- Longitudinal degeneracy on $S^1$: $d_{S^1}(n) = 1$ if $n = 0$, else $2$. -/
def circleDegeneracy (n : ℕ) : ℕ :=
  if n = 0 then 1 else 2

@[simp] theorem circleDegeneracy_zero : circleDegeneracy 0 = 1 := rfl
@[simp] theorem circleDegeneracy_pos {n : ℕ} (hn : n > 0) : circleDegeneracy n = 2 := by
  dsimp [circleDegeneracy]; split_ifs <;> omega

/-! ### 2. Joint Eigenvalues and Degeneracies -/

/-- Exact joint Laplace-Beltrami eigenvalues on $S^2 \times S^1_L$ for angular mode $\ell \in \mathbb{N}$ and circle mode $n \in \mathbb{Z}$:
    $$\lambda_{\ell, n}(L) = \ell(\ell + 1) + \left(\frac{2\pi n}{L}\right)^2.$$ -/
noncomputable def jointEigenvalue (L : ℝ) (ell : ℕ) (n : ℤ) : ℝ :=
  sphereEigenvalue ell + circleEigenvalue L n

/-- Natural-indexed joint eigenvalues on $S^2 \times S^1_L$ for $\ell, n \in \mathbb{N}$:
    $$\lambda_{\ell, n}(L) = \ell(\ell + 1) + \left(\frac{2\pi n}{L}\right)^2.$$ -/
noncomputable def jointEigenvalueNat (L : ℝ) (ell n : ℕ) : ℝ :=
  jointEigenvalue L ell (n : ℤ)

/-- Spectral degeneracy of the joint eigenvalue $(\ell, n)$ on $S^2 \times S^1$:
    $$d(\ell, n) = (2\ell + 1)(2 - \delta_{n, 0}).$$ -/
def spectralDegeneracy (ell n : ℕ) : ℕ :=
  sphereDegeneracy ell * circleDegeneracy n

/-- Equivalent formula for spectral degeneracy: $d(\ell, n) = (2\ell + 1)(2 - \delta_{n,0})$. -/
theorem spectralDegeneracy_eq_formula (ell n : ℕ) :
    spectralDegeneracy ell n = (2 * ell + 1) * (if n = 0 then 1 else 2) := rfl

/-- Ground state eigenvalue is 0 at $(\ell, n) = (0, 0)$. -/
theorem jointEigenvalue_zero_zero (L : ℝ) : jointEigenvalueNat L 0 0 = 0 := by
  dsimp [jointEigenvalueNat, jointEigenvalue, sphereEigenvalue, circleEigenvalue]; ring

/-- Ground state degeneracy is 1. -/
theorem spectralDegeneracy_zero_zero : spectralDegeneracy 0 0 = 1 := rfl

/-- First spherical excited state eigenvalue: $\lambda_{1, 0}(L) = 2$. -/
theorem jointEigenvalue_one_zero (L : ℝ) : jointEigenvalueNat L 1 0 = 2 := by
  dsimp [jointEigenvalueNat, jointEigenvalue, sphereEigenvalue, circleEigenvalue]; ring

/-- Degeneracy of the first spherical excited state: $d(1, 0) = 3$. -/
theorem spectralDegeneracy_one_zero : spectralDegeneracy 1 0 = 3 := rfl

/-- First longitudinal excited state eigenvalue: $\lambda_{0, 1}(L) = 4\pi^2 / L^2$. -/
theorem jointEigenvalue_zero_one (L : ℝ) :
    jointEigenvalueNat L 0 1 = 4 * Real.pi ^ 2 / L ^ 2 := by
  dsimp [jointEigenvalueNat, jointEigenvalue, sphereEigenvalue, circleEigenvalue]; ring

/-- Degeneracy of the first longitudinal excited state: $d(0, 1) = 2$. -/
theorem spectralDegeneracy_zero_one : spectralDegeneracy 0 1 = 2 := rfl

/-! ### 3. Ground State Spectral Gap -/

/-- The ground state spectral gap (first non-zero eigenvalue) on $S^2 \times S^1_L$:
    $$\lambda_1(L) = \min\left(2, \, \frac{4\pi^2}{L^2}\right).$$ -/
noncomputable def spectralGap (L : ℝ) : ℝ :=
  min 2 (4 * Real.pi ^ 2 / L ^ 2)

/-- Strict positivity of the spectral gap $\lambda_1(L) > 0$ for all $L > 0$. -/
theorem spectralGap_pos {L : ℝ} (hL : L > 0) : spectralGap L > 0 :=
  lt_min (by norm_num) (by positivity)

/-- Critical circle length separating sphere-dominated and circle-dominated spectral gaps:
    $$L_c = \pi \sqrt{2}.$$ -/
noncomputable def criticalLength : ℝ := Real.pi * Real.sqrt 2

/-- At the critical circle length $L = \pi \sqrt{2}$, the two lowest excited levels match: $4\pi^2 / L_c^2 = 2$. -/
theorem circle_gap_at_critical :
    4 * Real.pi ^ 2 / criticalLength ^ 2 = 2 := by
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  have hsqrt2 : (Real.sqrt 2) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have : criticalLength ^ 2 = 2 * Real.pi ^ 2 := by
    simp [criticalLength, mul_pow, hsqrt2]; ring
  rw [this]
  have : 4 * Real.pi ^ 2 / (2 * Real.pi ^ 2) = (4 / 2) * (Real.pi ^ 2 / Real.pi ^ 2) := by ring
  rw [this, div_self (pow_ne_zero 2 hpi)]
  norm_num

/-- At the critical length, the spectral gap is exactly 2. -/
theorem spectralGap_at_critical : spectralGap criticalLength = 2 := by
  simp [spectralGap, circle_gap_at_critical]

/-- Sphere-dominated regime: when $4\pi^2 / L^2 \ge 2$ (short circle $L \le \pi\sqrt{2}$), $\lambda_1(L) = 2$. -/
theorem spectralGap_sphere_dominated {L : ℝ} (h : 4 * Real.pi ^ 2 / L ^ 2 ≥ 2) :
    spectralGap L = 2 :=
  min_eq_left h

/-- Circle-dominated regime: when $4\pi^2 / L^2 \le 2$ (large circle $L \ge \pi\sqrt{2}$), $\lambda_1(L) = 4\pi^2 / L^2$. -/
theorem spectralGap_circle_dominated {L : ℝ} (h : 4 * Real.pi ^ 2 / L ^ 2 ≤ 2) :
    spectralGap L = 4 * Real.pi ^ 2 / L ^ 2 :=
  min_eq_right h

/-- Spectral gap lower bound for all non-zero modes $(\ell, n) \ne (0, 0)$. -/
theorem jointEigenvalue_ge_spectralGap (L : ℝ) (hL : L > 0) (ell n : ℕ) (h_nonzero : ell ≠ 0 ∨ n ≠ 0) :
    jointEigenvalueNat L ell n ≥ spectralGap L := by
  rcases h_nonzero with h | h
  · have : (ell : ℝ) ≥ 1 := by exact_mod_cast (Nat.succ_le_of_lt (Nat.pos_of_ne_zero h))
    have h_sph : sphereEigenvalue ell ≥ 2 := by
      dsimp [sphereEigenvalue]; nlinarith
    have h_circ : circleEigenvalue L (n : ℤ) ≥ 0 := by
      dsimp [circleEigenvalue]; positivity
    have : jointEigenvalueNat L ell n ≥ 2 := by
      dsimp [jointEigenvalueNat, jointEigenvalue]; linarith
    exact le_trans (min_le_left 2 _) this
  · have hn : (n : ℝ) ≥ 1 := by exact_mod_cast (Nat.succ_le_of_lt (Nat.pos_of_ne_zero h))
    have h_circ : circleEigenvalue L (n : ℤ) ≥ 4 * Real.pi ^ 2 / L ^ 2 := by
      dsimp [circleEigenvalue]; push_cast
      have : (2 * Real.pi * (n : ℝ) / L) ^ 2 = (4 * Real.pi ^ 2 / L ^ 2) * (n : ℝ) ^ 2 := by ring
      rw [this]
      have : (n : ℝ) ^ 2 ≥ 1 := by nlinarith
      have : 4 * Real.pi ^ 2 / L ^ 2 > 0 := by positivity
      nlinarith
    have h_sph : sphereEigenvalue ell ≥ 0 := by
      dsimp [sphereEigenvalue]; positivity
    have : jointEigenvalueNat L ell n ≥ 4 * Real.pi ^ 2 / L ^ 2 := by
      dsimp [jointEigenvalueNat, jointEigenvalue]; linarith
    exact le_trans (min_le_right 2 _) this

end S2xRGeometry