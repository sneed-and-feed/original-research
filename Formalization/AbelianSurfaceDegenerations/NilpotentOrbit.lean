/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

open scoped Matrix
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Schmid's Nilpotent Orbit Theorem for Cusp Period Monodromy

This submodule formalizes Schmid's Nilpotent Orbit Theorem (1973) specialized to the parabolic
cusp degeneration of the $(3,4,\infty)$ family of polarized abelian surfaces.

## Mathematical Overview

### 1. The Nilpotent Monodromy and Period Shift
Under the unipotent cusp monodromy $T_0 = I_4 + N$, the period matrix $\tau(t)$ on the punctured disk
$\Delta^*$ has logarithmic asymptotic expansion given by the nilpotent orbit:
$$\tau_{\mathrm{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$$
where $z = \frac{1}{2\pi i} \log t \in \mathbb{H}$ is the coordinate on the universal cover of the punctured disk,
$\tau_0 \in \mathbb{H}_2$ is the base period matrix, and
$$N_\tau = \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}$$
is the rank-1 period shift operator associated to the Type II monodromy operator $N$.

### 2. Positivity and Periodicity
Schmid's Nilpotent Orbit Theorem guarantees that:
1. **Positivity**: For any basepoint $\tau_0 \in \mathbb{H}_2$ and any $z \in \mathbb{C}$ with $\operatorname{Im}(z) \ge 0$,
   the matrix $\tau_{\mathrm{nilp}}(\tau_0, z)$ has strictly positive definite imaginary part:
   $$\operatorname{Im}(\tau_{\mathrm{nilp}}(\tau_0, z)) = \operatorname{Im}(\tau_0) + (\operatorname{Im} z) N_\tau > 0$$
   hence $\tau_{\mathrm{nilp}}(\tau_0, z) \in \mathbb{H}_2$.
2. **Monodromy Periodicity**:
   $$\tau_{\mathrm{nilp}}(\tau_0, z + 1) = \tau_{\mathrm{nilp}}(\tau_0, z) + N_\tau$$
   reflecting the unipotent monodromy transformation around the cusp.

## Main Declarations

- `AbelianSurfaceDegenerations.N_tau`: Real $2 \times 2$ period shift operator $\begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}$.
- `AbelianSurfaceDegenerations.N_tau_C`: Complex embedding of $N_\tau$.
- `AbelianSurfaceDegenerations.N_tau_symm`, `AbelianSurfaceDegenerations.N_tau_C_symm`: Symmetry proofs.
- `AbelianSurfaceDegenerations.nilpotentOrbit`: Nilpotent orbit period map $\tau_{\mathrm{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$.
- `AbelianSurfaceDegenerations.imMatrix_nilpotentOrbit`: Formula for $\operatorname{Im}(\tau_{\mathrm{nilp}}(\tau_0, z))$.
- `AbelianSurfaceDegenerations.nilpotent_orbit_in_Siegel`: Machine-checked proof that $\tau_{\mathrm{nilp}}(\tau_0, z) \in \mathbb{H}_2$ for $\operatorname{Im}(z) \ge 0$.
- `AbelianSurfaceDegenerations.nilpotentOrbit_symm`: Symmetry preservation under nilpotent shift.
- `AbelianSurfaceDegenerations.nilpotentOrbitSiegel`: Canonical bundle element in $\mathbb{H}_2$.
- `AbelianSurfaceDegenerations.nilpotent_orbit_monodromy_periodicity`: Monodromy shift relation $\tau(z+1) = \tau(z) + N_\tau$.
- `AbelianSurfaceDegenerations.nilpotentOrbitReal`: Real ray parametrization $\tau_0 + i s N_\tau$ for $s \ge 0$.
- `AbelianSurfaceDegenerations.nilpotent_orbit_real_in_Siegel`: Positivity along the real ray.
-/

namespace AbelianSurfaceDegenerations

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

end AbelianSurfaceDegenerations
