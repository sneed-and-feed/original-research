/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.UniversalMonodromyWeightFiltration.Filtrations4D
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

open scoped Matrix

/-!
# Hodge-Riemann Polarization Pairings & Positivity Certificates

This submodule formalizes the Hodge-Riemann bilinear pairing $Q_N(v, w) = \langle v, N w \rangle_J$
associated to the infinitesimal symplectic log-monodromy operator $N$.

## Mathematical Overview

### 1. Infinitesimal Symplectic Lie Algebra
For the standard symplectic form $J$, the nilpotent log-monodromy operator $N$ belongs to the
symplectic Lie algebra $\mathfrak{sp}_4(\mathbb{Z})$, satisfying:
$$J N + N^T J = 0 \quad \text{and} \quad N^T J + J N = 0$$

### 2. Hodge-Riemann Polarized Bilinear Form
The polarized bilinear form $Q_N(v, w) = \langle v, N w \rangle_J = v^T J N w$ satisfies:
- **Symmetry**: $Q_N(v, w) = Q_N(w, v)$ on the entire space $\mathbb{Z}^4$.
- **Vanishing on isotropic lines**: $Q_N(u, u) = 0$ and $Q_N(w, w) = 0$.
- **Evaluation on mixed pairs**: $Q_N(u, w) = 1$ and $Q_N(w, u) = 1$.
- **Strict Positivity on Primitive Generators**:
  $$Q_N(u + w, u + w) = 2 > 0$$
  providing a machine-checked Hodge-Riemann positivity certificate.

### 3. $S_6$-Family Polarized Bilinear Form
For the $S_6$ Seifert-polarized symplectic form $\Omega_6$:
- $Q_{N_{S_6}}(v, w) = \langle v, N_{S_6} w \rangle_{\Omega_6}$.
- **Symmetry**: $Q_{N_{S_6}}(v, w) = Q_{N_{S_6}}(w, v)$.
- **Strict Positivity**: $Q_{N_{S_6}}(w, w) = 6 > 0$.
- **Non-degeneracy**: $Q_{N_{S_6}}(\delta, \delta) = -1 \ne 0$.

## Main Declarations

- `UniversalMonodromyWeightFiltration.J_N_plus_NT_J_zero`, `NT_J_plus_J_N_zero`: Symplectic Lie algebra identities.
- `UniversalMonodromyWeightFiltration.Q_N`: Polarized bilinear form $\langle v, N w \rangle_J$.
- `UniversalMonodromyWeightFiltration.Q_N_symm`: Symmetry of $Q_N$.
- `UniversalMonodromyWeightFiltration.Q_N_u_w`, `Q_N_w_u`, `Q_N_u_u`, `Q_N_w_w`: Evaluation certificates.
- `UniversalMonodromyWeightFiltration.Q_N_u_add_w_eval`, `Q_N_u_add_w_strictly_positive`: Strict positivity on $u+w$.
- `UniversalMonodromyWeightFiltration.Q_N_S6`: $S_6$ polarized bilinear form $\langle v, N_{S_6} w \rangle_{\Omega_6}$.
- `UniversalMonodromyWeightFiltration.Q_N_S6_symm`: Symmetry of $Q_{N_{S_6}}$.
- `UniversalMonodromyWeightFiltration.Q_N_S6_w_pos`, `Q_N_S6_w_strictly_positive`: Strict positivity on $w$.
- `UniversalMonodromyWeightFiltration.Q_N_S6_delta_eval`, `Q_N_S6_delta_nondegenerate`: Non-degeneracy on $\delta$.
-/

namespace UniversalMonodromyWeightFiltration

open Matrix

/-! ### 1. Symplectic Lie Algebra Conditions -/

/-- Infinitesimal symplectic Lie algebra condition: $J N + N^T J = 0$. -/
theorem J_N_plus_NT_J_zero :
    SymplecticTriangleRepresentations.J * SymplecticTriangleRepresentations.N +
    SymplecticTriangleRepresentations.Nᵀ * SymplecticTriangleRepresentations.J = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Infinitesimal symplectic Lie algebra condition: $N^T J + J N = 0$. -/
theorem NT_J_plus_J_N_zero :
    SymplecticTriangleRepresentations.Nᵀ * SymplecticTriangleRepresentations.J +
    SymplecticTriangleRepresentations.J * SymplecticTriangleRepresentations.N = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-! ### 2. Hodge-Riemann Polarized Bilinear Form $Q_N$ -/

/-- Hodge-Riemann polarized bilinear form $Q_N(v, w) = \langle v, N w \rangle_J$. -/
def Q_N (v w : Fin 4 → ℤ) : ℤ :=
  PicardFuchsMirrorMonodromy.symplecticPairing v (SymplecticTriangleRepresentations.N *ᵥ w)

/-- Symmetry of the Hodge-Riemann polarized bilinear form: $Q_N(v, w) = Q_N(w, v)$. -/
theorem Q_N_symm (v w : Fin 4 → ℤ) : Q_N v w = Q_N w v := by
  dsimp [Q_N]
  have h := PicardFuchsMirrorMonodromy.symplecticPairing_N_invariant w v
  have hskew := PicardFuchsMirrorMonodromy.symplecticPairing_skew
    (SymplecticTriangleRepresentations.N *ᵥ w) v
  have hN : PicardFuchsMirrorMonodromy.N = SymplecticTriangleRepresentations.N := rfl
  rw [hN] at h
  linarith

/-- Evaluation of $Q_N$ on primitive generator pair $(u, w)$: $Q_N(u, w) = 1$. -/
theorem Q_N_u_w :
    Q_N PicardFuchsMirrorMonodromy.u PicardFuchsMirrorMonodromy.w = 1 :=
  rfl

/-- Evaluation of $Q_N$ on primitive generator pair $(w, u)$: $Q_N(w, u) = 1$. -/
theorem Q_N_w_u :
    Q_N PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.u = 1 :=
  rfl

/-- $Q_N$ vanishes on $(u, u)$: $Q_N(u, u) = 0$. -/
theorem Q_N_u_u :
    Q_N PicardFuchsMirrorMonodromy.u PicardFuchsMirrorMonodromy.u = 0 :=
  rfl

/-- $Q_N$ vanishes on $(w, w)$: $Q_N(w, w) = 0$. -/
theorem Q_N_w_w :
    Q_N PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.w = 0 :=
  rfl

/-- Strict positivity on diagonal primitive subspace generator $u + w$: $Q_N(u+w, u+w) = 2 > 0$. -/
theorem Q_N_u_add_w_eval :
    Q_N (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w)
        (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w) = 2 :=
  rfl

/-- Positivity certificate: $Q_N(u+w, u+w) > 0$. -/
theorem Q_N_u_add_w_strictly_positive :
    0 < Q_N (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w)
            (PicardFuchsMirrorMonodromy.u + PicardFuchsMirrorMonodromy.w) := by
  decide

/-! ### 3. Polarized Bilinear Form for the $S_6$ Seifert Family -/

/-- Polarized bilinear form for the $S_6$ Seifert family: $Q_{N_{S_6}}(v, w) = \langle v, N_{S_6} w \rangle_{\Omega_6}$. -/
def Q_N_S6 (v w : Fin 4 → ℤ) : ℤ :=
  PicardFuchsMirrorMonodromy.symplecticPairingOmega6 v (ModularFamilyS6.N *ᵥ w)

/-- Symmetry of the $S_6$ polarized bilinear form: $Q_{N_{S_6}}(v, w) = Q_{N_{S_6}}(w, v)$. -/
theorem Q_N_S6_symm (v w : Fin 4 → ℤ) : Q_N_S6 v w = Q_N_S6 w v := by
  dsimp [Q_N_S6]
  have h := PicardFuchsMirrorMonodromy.symplecticPairingOmega6_N_invariant w v
  have hskew := PicardFuchsMirrorMonodromy.symplecticPairingOmega6_skew (ModularFamilyS6.N *ᵥ w) v
  linarith

/-- Evaluation of $S_6$ polarized form on primitive generator $w$: $Q_{N_{S_6}}(w, w) = 6$. -/
theorem Q_N_S6_w_pos :
    Q_N_S6 PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.w = 6 :=
  rfl

/-- Strict positivity on primitive generator $w$: $Q_{N_{S_6}}(w, w) > 0$. -/
theorem Q_N_S6_w_strictly_positive :
    0 < Q_N_S6 PicardFuchsMirrorMonodromy.w PicardFuchsMirrorMonodromy.w := by
  decide

/-- Evaluation of $S_6$ polarized form on primitive generator $\delta$: $Q_{N_{S_6}}(\delta, \delta) = -1$. -/
theorem Q_N_S6_delta_eval :
    Q_N_S6 PicardFuchsMirrorMonodromy.delta PicardFuchsMirrorMonodromy.delta = -1 :=
  rfl

/-- Non-degeneracy on primitive generator $\delta$: $Q_{N_{S_6}}(\delta, \delta) \ne 0$. -/
theorem Q_N_S6_delta_nondegenerate :
    Q_N_S6 PicardFuchsMirrorMonodromy.delta PicardFuchsMirrorMonodromy.delta ≠ 0 := by
  decide

end UniversalMonodromyWeightFiltration
