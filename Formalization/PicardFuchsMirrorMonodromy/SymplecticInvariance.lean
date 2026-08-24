/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SymplecticTriangleRepresentations
import Formalization.PicardFuchsMirrorMonodromy.CuspMonodromy
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FinCases

open scoped Matrix
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Symplectic Bilinear Invariance & Griffiths Transversality

This submodule formalizes the infinitesimal and finite symplectic invariance properties of the
Picard-Fuchs monodromy operators on the homology lattice $\mathbb{Z}^4$, certifying Griffiths
transversality and the polarization pairing invariance.

## Mathematical Overview

### 1. Infinitesimal Symplectic Invariance (Lie Algebra $\mathfrak{sp}_4(\mathbb{Z})$)
A matrix $M \in \mathrm{Mat}_4(\mathbb{Z})$ belongs to the symplectic Lie algebra $\mathfrak{sp}_4(\mathbb{Z})$
with respect to the standard symplectic form $J = \begin{pmatrix} 0 & I_2 \\ -I_2 & 0 \end{pmatrix}$ if:
$$M^T J + J M = 0$$
For the $S_6$-polarized form $\Omega_6$, the condition is $M^T \Omega_6 + \Omega_6 M = 0$.

We formally verify that both nilpotent log-monodromy operators $N$ and $N_{S_6}$ satisfy:
- `isInfinitesimalSymplectic_N`: $N^T J + J N = 0$
- `isInfinitesimalSymplectic_S6_N`: $N_{S_6}^T \Omega_6 + \Omega_6 N_{S_6} = 0$

### 2. Finite Symplectic Group Invariance ($\mathrm{Sp}_4(\mathbb{Z})$)
The parabolic cusp monodromy transformations $T_0$ and $T_{0, S_6}$ satisfy the finite group invariance:
- $T_0^T J T_0 = J$ (`isSymplectic_T0`)
- $T_{0, S_6}^T \Omega_6 T_{0, S_6} = \Omega_6$ (`isSymplectic_S6_T0`)

### 3. Griffiths Transversality on the Symplectic Bilinear Pairing
The standard symplectic pairing on $\mathbb{Z}^4$ is $\langle v, w \rangle_J = v^T J w$.
Infinitesimal invariance yields the skew-adjoint property of $N$:
$$\langle N v, w \rangle_J + \langle v, N w \rangle_J = 0$$
and finite invariance yields:
$$\langle T_0 v, T_0 w \rangle_J = \langle v, w \rangle_J$$

Analogous identities hold for the polarized $S_6$ pairing $\langle v, w \rangle_{\Omega_6}$.

## Main Declarations

- `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplectic`: Symplectic Lie algebra predicate.
- `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplecticOmega6`: Polarized Lie algebra predicate.
- `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_N`: Verification for $N$.
- `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_S6_N`: Verification for $N_{S_6}$.
- `PicardFuchsMirrorMonodromy.symplecticPairing`: Standard bilinear form $\langle v, w \rangle_J$.
- `PicardFuchsMirrorMonodromy.symplecticPairing_skew`: Skew-symmetry $\langle v, w \rangle = -\langle w, v \rangle$.
- `PicardFuchsMirrorMonodromy.symplecticPairing_N_invariant`: Infinitesimal invariance $\langle N v, w \rangle + \langle v, N w \rangle = 0$.
- `PicardFuchsMirrorMonodromy.symplecticPairing_T0_invariant`: Finite invariance $\langle T_0 v, T_0 w \rangle = \langle v, w \rangle$.
- `PicardFuchsMirrorMonodromy.symplecticPairingOmega6`: Polarized form $\langle v, w \rangle_{\Omega_6}$.
- `PicardFuchsMirrorMonodromy.symplecticPairingOmega6_N_invariant`, `symplecticPairingOmega6_T0_invariant`: $S_6$ pairing invariance.
-/

namespace PicardFuchsMirrorMonodromy

/-- Infinitesimal symplectic condition for matrices in $\mathfrak{sp}_4(\mathbb{Z})$:
    $M^T J + J M = 0$. -/
def IsInfinitesimalSymplectic (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * J + J * M = 0

/-- Infinitesimal symplectic condition for the $S_6$ polarized form $\Omega_6$:
    $M^T \Omega_6 + \Omega_6 M = 0$. -/
def IsInfinitesimalSymplecticOmega6 (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * Omega6 + Omega6 * M = 0

/-- The nilpotent operator $N$ is an infinitesimal symplectic transformation: $N^T J + J N = 0$. -/
theorem isInfinitesimalSymplectic_N : IsInfinitesimalSymplectic N := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The nilpotent operator $N_{S_6}$ is an infinitesimal symplectic transformation for $\Omega_6$. -/
theorem isInfinitesimalSymplectic_S6_N : IsInfinitesimalSymplecticOmega6 ModularFamilyS6.N := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Parabolic cusp monodromy $T_0$ is symplectic: $T_0^T J T_0 = J$. -/
theorem isSymplectic_T0 : IsSymplectic T0 :=
  SymplecticTriangleRepresentations.isSymplectic_T0

/-- Parabolic cusp monodromy $T_{0, S_6}$ preserves $\Omega_6$: $T_0^T \Omega_6 T_0 = \Omega_6$. -/
theorem isSymplectic_S6_T0 :
    ModularFamilyS6.T0ᵀ * Omega6 * ModularFamilyS6.T0 = Omega6 :=
  SymplecticTriangleRepresentations.isSymplectic_Omega6_T0

/-- The symplectic bilinear pairing on $\mathbb{Z}^4$: $\langle v, w \rangle_J = v_0 w_2 + v_1 w_3 - v_2 w_0 - v_3 w_1$. -/
def symplecticPairing (v w : Fin 4 → ℤ) : ℤ :=
  v 0 * w 2 + v 1 * w 3 - v 2 * w 0 - v 3 * w 1

/-- Coordinate expansion of the standard symplectic bilinear pairing. -/
theorem symplecticPairing_def (v w : Fin 4 → ℤ) :
    symplecticPairing v w = v 0 * w 2 + v 1 * w 3 - v 2 * w 0 - v 3 * w 1 := rfl

/-- Skew-symmetry of the symplectic pairing: $\langle v, w \rangle_J = -\langle w, v \rangle_J$. -/
theorem symplecticPairing_skew (v w : Fin 4 → ℤ) :
    symplecticPairing v w = -symplecticPairing w v := by
  dsimp [symplecticPairing]; ring

/-- The symplectic pairing of any vector with itself vanishes: $\langle v, v \rangle_J = 0$. -/
theorem symplecticPairing_self_zero (v : Fin 4 → ℤ) :
    symplecticPairing v v = 0 := by
  dsimp [symplecticPairing]; ring

/-- Infinitesimal symplectic invariance (Griffiths transversality) of the pairing under $N$:
    $\langle N v, w \rangle_J + \langle v, N w \rangle_J = 0$. -/
theorem symplecticPairing_N_invariant (v w : Fin 4 → ℤ) :
    symplecticPairing (N *ᵥ v) w + symplecticPairing v (N *ᵥ w) = 0 := by
  rw [mulVec_N, mulVec_N]; dsimp [symplecticPairing]; ring

/-- Finite symplectic invariance of the pairing under $T_0$:
    $\langle T_0 v, T_0 w \rangle_J = \langle v, w \rangle_J$. -/
theorem symplecticPairing_T0_invariant (v w : Fin 4 → ℤ) :
    symplecticPairing (T0 *ᵥ v) (T0 *ᵥ w) = symplecticPairing v w := by
  rw [mulVec_T0, mulVec_T0]; dsimp [symplecticPairing]; ring

/-- The polarized $S_6$ symplectic bilinear pairing on $\mathbb{Z}^4$: $\langle v, w \rangle_{\Omega_6}$. -/
def symplecticPairingOmega6 (v w : Fin 4 → ℤ) : ℤ :=
  v 0 * w 3 + 6 * v 1 * w 2 - 6 * v 2 * w 1 - v 3 * w 0

/-- Coordinate expansion of the polarized $S_6$ symplectic bilinear pairing. -/
theorem symplecticPairingOmega6_def (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 v w = v 0 * w 3 + 6 * v 1 * w 2 - 6 * v 2 * w 1 - v 3 * w 0 := rfl

/-- Skew-symmetry of the polarized $S_6$ symplectic pairing. -/
theorem symplecticPairingOmega6_skew (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 v w = -symplecticPairingOmega6 w v := by
  dsimp [symplecticPairingOmega6]; ring

/-- Infinitesimal symplectic invariance of the $S_6$ pairing under $N_{S_6}$:
    $\langle N v, w \rangle_{\Omega_6} + \langle v, N w \rangle_{\Omega_6} = 0$. -/
theorem symplecticPairingOmega6_N_invariant (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 (ModularFamilyS6.N *ᵥ v) w +
    symplecticPairingOmega6 v (ModularFamilyS6.N *ᵥ w) = 0 := by
  rw [mulVec_S6_N, mulVec_S6_N]; dsimp [symplecticPairingOmega6]; ring

/-- Finite symplectic invariance of the $S_6$ pairing under $T_{0, S_6}$:
    $\langle T_0 v, T_0 w \rangle_{\Omega_6} = \langle v, w \rangle_{\Omega_6}$. -/
theorem symplecticPairingOmega6_T0_invariant (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 (ModularFamilyS6.T0 *ᵥ v) (ModularFamilyS6.T0 *ᵥ w) =
    symplecticPairingOmega6 v w := by
  rw [mulVec_S6_T0, mulVec_S6_T0]; dsimp [symplecticPairingOmega6]; ring

end PicardFuchsMirrorMonodromy
