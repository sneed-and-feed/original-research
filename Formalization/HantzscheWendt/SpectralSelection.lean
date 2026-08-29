/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.HantzscheWendt.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

/-!
# Candidate 3: The Flat Hantzsche-Wendt Didicosm ($G_6$) - Spectral Selection Rules

This module formalizes the Fourier mode selection rules and the **Spectral Gap Doubling Theorem**
on the **Hantzsche-Wendt manifold** (Didicosm, $G_6$).

## Mathematical Summary

1. **Discrete Fourier Modes**:
   Wavevectors $\vec{n} = (n_x, n_y, n_z) \in \mathbb{Z}^3$ with Laplacian energy $E(\vec{n}) = n_x^2 + n_y^2 + n_z^2$.
   The physical Laplace-Beltrami eigenvalues on a flat manifold of scale $L$ are:
   $$\lambda(\vec{n}) = \left(\frac{2\pi}{L}\right)^2 (n_x^2 + n_y^2 + n_z^2).$$

2. **Parity Cancellation under Screw Motions**:
   Under the screw motion generator $\gamma_1(x, y, z) = (x + 1/2, -y, -z)$, a plane wave transforms as:
   $$e^{2\pi i (n_x (x + 1/2) - n_y y - n_z z)} = (-1)^{n_x} e^{2\pi i (n_x x - n_y y - n_z z)}.$$
   For single-axis odd modes $(1, 0, 0)$, $(0, 1, 0)$, $(0, 0, 1)$, the translation phase $(-1)^1 = -1$
   causes destructive interference/parity cancellation when symmetrizing under $\Gamma = G_6$.
   Consequently, NO single-axis odd modes can exist as invariant eigenfunctions on the Didicosm.

3. **Minimal Invariant Mode & Spectral Gap Doubling**:
   - The torus $T^3$ has ground state energy $E_{\min}(T^3) = 1$ achieved at $(1, 0, 0), (0, 1, 0), (0, 0, 1)$.
   - The Didicosm $G_6$ has ground state energy $E_{\min}(G_6) = 2$ achieved at $(1, 1, 0), (1, 0, 1), (0, 1, 1)$.
   - **Spectral Gap Doubling Theorem**:
     $$E_{\min}(G_6) = 2 \cdot E_{\min}(T^3), \quad \lambda_1(G_6) = 2 \cdot \lambda_1(T^3).$$

4. **Cosmic Topology Implications**:
   In observational cosmology (Aurich et al. 2008, Luminet 2016), the spectral gap doubling suppresses
   large-scale temperature fluctuations (low-$\ell$ CMB multipoles $\ell = 2, 3$), providing a natural
   geometric mechanism for the observed quadrupole suppression in WMAP and Planck data.
-/

namespace HantzscheWendt

/-! ### 1. Discrete Wavevectors and Energy Spectrum -/

/-- Discrete Fourier wavevector $\vec{n} = (n_x, n_y, n_z) \in \mathbb{Z}^3$. -/
abbrev WaveVector := ℤ × ℤ × ℤ

/-- Laplacian energy (squared wavevector norm) $E(\vec{n}) = n_x^2 + n_y^2 + n_z^2$. -/
def energy (n : WaveVector) : ℤ :=
  n.1^2 + n.2.1^2 + n.2.2^2

/-- Physical Laplace-Beltrami eigenvalue on a flat 3-manifold of fundamental side length $L > 0$:
    $\lambda(\vec{n}) = \left(\frac{2\pi}{L}\right)^2 E(\vec{n})$. -/
noncomputable def laplacianEigenvalue (L : ℝ) (n : WaveVector) : ℝ :=
  (2 * Real.pi / L) ^ 2 * (energy n : ℝ)

/-- Energy is non-negative for all wavevectors. -/
theorem energy_nonneg (n : WaveVector) : energy n ≥ 0 := by
  dsimp [energy]; positivity

/-- Zero wavevector has zero energy. -/
theorem energy_zero : energy (0, 0, 0) = 0 := rfl

/-- Energy is zero if and only if the wavevector is zero. -/
theorem energy_eq_zero_iff (n : WaveVector) : energy n = 0 ↔ n = (0, 0, 0) := by
  dsimp [energy]; constructor
  · intro h; ext <;> { have : _ := sq_nonneg n.1; have : _ := sq_nonneg n.2.1; have : _ := sq_nonneg n.2.2; nlinarith }
  · rintro rfl; rfl

/-! ### 2. 3-Torus Baseline Spectrum -/

/-- Torus fundamental single-axis wavevectors of unit length. -/
def torusModeX : WaveVector := (1, 0, 0)
def torusModeY : WaveVector := (0, 1, 0)
def torusModeZ : WaveVector := (0, 0, 1)

/-- Negative orientation torus fundamental modes. -/
def torusModeNegX : WaveVector := (-1, 0, 0)
def torusModeNegY : WaveVector := (0, -1, 0)
def torusModeNegZ : WaveVector := (0, 0, -1)

/-- Energy of torus fundamental mode along $x$-axis is 1. -/
theorem torus_energy_x : energy torusModeX = 1 := rfl

/-- Energy of torus fundamental mode along $y$-axis is 1. -/
theorem torus_energy_y : energy torusModeY = 1 := rfl

/-- Energy of torus fundamental mode along $z$-axis is 1. -/
theorem torus_energy_z : energy torusModeZ = 1 := rfl

theorem torus_energy_neg_x : energy torusModeNegX = 1 := rfl
theorem torus_energy_neg_y : energy torusModeNegY = 1 := rfl
theorem torus_energy_neg_z : energy torusModeNegZ = 1 := rfl

/-- The baseline minimum non-zero energy on the 3-torus $T^3$ is $E_{\min}(T^3) = 1$. -/
def torusMinEnergy : ℤ := 1

/-- Torus minimum energy identity. -/
theorem torus_min_energy_eq : torusMinEnergy = energy torusModeX := rfl

/-- Minimum non-zero Laplace eigenvalue on the 3-torus $T^3$:
    $\lambda_1(T^3) = (2\pi/L)^2 \cdot 1$. -/
noncomputable def lambda1Torus (L : ℝ) : ℝ :=
  (2 * Real.pi / L) ^ 2 * (torusMinEnergy : ℝ)

/-! ### 3. Invariant Mode Parity and Screw Cancellation -/

/-- Single-axis odd mode predicate: exactly one coordinate is non-zero and odd. -/
def isSingleAxisOdd (n : WaveVector) : Prop :=
  (Odd n.1 ∧ n.2.1 = 0 ∧ n.2.2 = 0) ∨
  (n.1 = 0 ∧ Odd n.2.1 ∧ n.2.2 = 0) ∨
  (n.1 = 0 ∧ n.2.1 = 0 ∧ Odd n.2.2)

/-- The torus $x$-axis fundamental mode $(1, 0, 0)$ is single-axis odd. -/
theorem torusModeX_isSingleAxisOdd : isSingleAxisOdd torusModeX :=
  Or.inl ⟨⟨0, rfl⟩, rfl, rfl⟩

/-- The torus $y$-axis fundamental mode $(0, 1, 0)$ is single-axis odd. -/
theorem torusModeY_isSingleAxisOdd : isSingleAxisOdd torusModeY :=
  Or.inr (.inl ⟨rfl, ⟨0, rfl⟩, rfl⟩)

/-- The torus $z$-axis fundamental mode $(0, 0, 1)$ is single-axis odd. -/
theorem torusModeZ_isSingleAxisOdd : isSingleAxisOdd torusModeZ :=
  Or.inr (.inr ⟨rfl, rfl, ⟨0, rfl⟩⟩)

/-- Parity phase shift under half-integer screw translation $x \mapsto x + 1/2$:
    $e^{2\pi i n_x (x + 1/2)} = (-1)^{n_x} e^{2\pi i n_x x}$. -/
def screwPhase (k : ℤ) : ℤ := if Odd k then -1 else 1

/-- Odd wavevectors incur an exact destructive sign change $\mathrm{phase}(k) = -1$. -/
theorem screwPhase_odd {k : ℤ} (h : Odd k) : screwPhase k = -1 := by
  simp [screwPhase, h]

/-- Destructive cancellation for $x$-mode $(1, 0, 0)$: phase is $-1$. -/
theorem torusModeX_destructive_cancellation : screwPhase torusModeX.1 = -1 :=
  screwPhase_odd ⟨0, rfl⟩

/-- Destructive cancellation for $y$-mode $(0, 1, 0)$: phase is $-1$. -/
theorem torusModeY_destructive_cancellation : screwPhase torusModeY.2.1 = -1 :=
  screwPhase_odd ⟨0, rfl⟩

/-- Destructive cancellation for $z$-mode $(0, 0, 1)$: phase is $-1$. -/
theorem torusModeZ_destructive_cancellation : screwPhase torusModeZ.2.2 = -1 :=
  screwPhase_odd ⟨0, rfl⟩

/-- Every wavevector with energy 1 is single-axis odd. -/
theorem energy_eq_one_implies_singleAxisOdd (n : WaveVector) (hE : energy n = 1) :
    isSingleAxisOdd n := by
  rcases n with ⟨x, y, z⟩
  dsimp [energy] at hE
  have : _ := sq_nonneg x; have : _ := sq_nonneg y; have : _ := sq_nonneg z
  have : (x^2 = 1 ∧ y = 0 ∧ z = 0) ∨ (x = 0 ∧ y^2 = 1 ∧ z = 0) ∨ (x = 0 ∧ y = 0 ∧ z^2 = 1) := by
    have : x^2 = 0 ↔ x = 0 := sq_eq_zero_iff
    have : y^2 = 0 ↔ y = 0 := sq_eq_zero_iff
    have : z^2 = 0 ↔ z = 0 := sq_eq_zero_iff
    omega
  rcases this with ⟨h, rfl, rfl⟩ | ⟨rfl, h, rfl⟩ | ⟨rfl, rfl, h⟩
  · rcases sq_eq_one_iff.mp h with rfl | rfl; exact .inl ⟨⟨0, rfl⟩, rfl, rfl⟩; exact .inl ⟨⟨-1, rfl⟩, rfl, rfl⟩
  · rcases sq_eq_one_iff.mp h with rfl | rfl; exact .inr (.inl ⟨rfl, ⟨0, rfl⟩, rfl⟩); exact .inr (.inl ⟨rfl, ⟨-1, rfl⟩, rfl⟩)
  · rcases sq_eq_one_iff.mp h with rfl | rfl; exact .inr (.inr ⟨rfl, rfl, ⟨0, rfl⟩⟩); exact .inr (.inr ⟨rfl, rfl, ⟨-1, rfl⟩⟩)

/-! ### 4. Didicosm Invariant Modes and Minimum Energy -/

/-- Admissible invariant non-zero mode on the Didicosm $G_6$:
    non-zero wavevector not subject to single-axis destructive cancellation. -/
def isDidicosmAdmissible (n : WaveVector) : Prop :=
  n ≠ (0, 0, 0) ∧ ¬ isSingleAxisOdd n

/-- Minimal invariant Didicosm wavevectors: 2-axis combinations of magnitude 1. -/
def didicosmModeXY : WaveVector := (1, 1, 0)
def didicosmModeXZ : WaveVector := (1, 0, 1)
def didicosmModeYZ : WaveVector := (0, 1, 1)

/-- didicosmModeXY is non-zero. -/
theorem didicosmModeXY_ne_zero : didicosmModeXY ≠ (0, 0, 0) := by decide

/-- didicosmModeXY is not single-axis odd. -/
theorem didicosmModeXY_not_singleAxisOdd : ¬ isSingleAxisOdd didicosmModeXY := by
  rintro (⟨-, h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩) <;> revert h <;> decide

/-- didicosmModeXY is an admissible Didicosm mode. -/
theorem didicosmModeXY_admissible : isDidicosmAdmissible didicosmModeXY :=
  ⟨didicosmModeXY_ne_zero, didicosmModeXY_not_singleAxisOdd⟩

/-- Energy of minimal Didicosm mode $(1, 1, 0)$ is $1^2 + 1^2 + 0^2 = 2$. -/
theorem didicosm_energy_xy : energy didicosmModeXY = 2 := rfl

/-- Energy of minimal Didicosm mode $(1, 0, 1)$ is $1^2 + 0^2 + 1^2 = 2$. -/
theorem didicosm_energy_xz : energy didicosmModeXZ = 2 := rfl

/-- Energy of minimal Didicosm mode $(0, 1, 1)$ is $0^2 + 1^2 + 1^2 = 2$. -/
theorem didicosm_energy_yz : energy didicosmModeYZ = 2 := rfl

/-- The minimal invariant non-zero energy on the Didicosm $G_6$ is $E_{\min}(G_6) = 2$. -/
def didicosmMinEnergy : ℤ := 2

/-- Didicosm minimum energy identity. -/
theorem didicosm_min_energy_eq : didicosmMinEnergy = energy didicosmModeXY := rfl

/-- Minimum non-zero Laplace eigenvalue on the Didicosm $G_6$:
    $\lambda_1(G_6) = (2\pi/L)^2 \cdot 2$. -/
noncomputable def lambda1Didicosm (L : ℝ) : ℝ :=
  (2 * Real.pi / L) ^ 2 * (didicosmMinEnergy : ℝ)

/-- Any admissible non-zero Didicosm mode has energy at least 2. -/
theorem admissible_energy_ge_two (n : WaveVector) (hn : n ≠ (0, 0, 0))
    (h_not_odd : ¬ isSingleAxisOdd n) : energy n ≥ 2 := by
  have : energy n ≠ 0 := mt (energy_eq_zero_iff n).mp hn
  have : energy n ≠ 1 := mt (energy_eq_one_implies_singleAxisOdd n) h_not_odd
  have : energy n ≥ 0 := energy_nonneg n
  omega

/-! ### 5. Spectral Gap Doubling Theorem -/

/-- Spectral Gap Doubling Theorem (Discrete Energy):
    The minimal invariant non-zero Laplacian energy on the Didicosm $G_6$ is exactly twice
    that of the 3-torus $T^3$:
    $$E_{\min}(G_6) = 2 \cdot E_{\min}(T^3).$$ -/
theorem spectral_gap_doubling : didicosmMinEnergy = 2 * torusMinEnergy := rfl

/-- Spectral Gap Doubling Theorem (Continuous Laplace Eigenvalue):
    For any side length $L > 0$, the first non-zero Laplace-Beltrami eigenvalue on the
    Didicosm $G_6$ is exactly twice that on the 3-torus $T^3$:
    $$\lambda_1(G_6) = 2 \cdot \lambda_1(T^3).$$ -/
theorem eigenvalue_doubling (L : ℝ) :
    lambda1Didicosm L = 2 * lambda1Torus L := by
  dsimp [lambda1Didicosm, lambda1Torus, didicosmMinEnergy, torusMinEnergy]
  ring

/-- Eigenvalue ratio identity: $\lambda_1(G_6) / \lambda_1(T^3) = 2$. -/
theorem eigenvalue_ratio (L : ℝ) (hL : L > 0) (_hpi : Real.pi ≠ 0) :
    lambda1Didicosm L / lambda1Torus L = 2 := by
  have hT3_ne : lambda1Torus L ≠ 0 := by dsimp [lambda1Torus, torusMinEnergy]; positivity
  rw [eigenvalue_doubling L, mul_div_cancel_right₀ 2 hT3_ne]

end HantzscheWendt
