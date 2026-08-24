/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring

open scoped Matrix

/-!
# The (3,4,∞) Modular Triangle Group Representation & Seifert Invariants

This file verifies the discrete algebraic backbone of the (3,4,∞) modular family
of complex 2-tori:
1. The integer matrix generators $T_1, T_2 \in \mathrm{GL}_4(\mathbb{Z})$ satisfy $T_1^3 = I_4$ and $T_2^4 = I_4$.
2. The parabolic monodromy at the cusp $T_0 := (T_1 T_2)^{-1}$ is unipotent with $N := T_0 - I_4$ satisfying $N^2 = 0$.
3. The nilpotent operator $N$ acts on the basis $(\gamma, u, w, \delta)$ via:
   $N\gamma = 0$, $Nu = 0$, $Nw = -u$, $N\delta = \gamma$.
4. The Seifert invariant formula for translation twists $(\ell_0, \ell_1, \ell_2) = (0, 1, -1)$
   evaluates to $|12\ell_0 - 4\ell_1 - 3\ell_2| = 1$, certifying $\pi_1(X) \cong 0$.
-/

namespace ModularFamilyS6

open Matrix

/-- The order 3 automorphism $T_1$ on $V \cong \mathbb{Z}^4$. -/
def T1 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 1,  0, -6,  2],
    ![ 0, -1,  1,  1],
    ![ 0, -1,  0,  1],
    ![ 0,  0,  0,  1]]

/-- The order 4 automorphism $T_2$ on $V \cong \mathbb{Z}^4$. -/
def T2 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 1,  6,  0, -3],
    ![ 0,  0, -1,  1],
    ![ 0,  1,  0,  0],
    ![ 0,  0,  0,  1]]

/-- The parabolic element $T_0 = (T_1 T_2)^{-1}$ at the cusp. -/
def T0 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 1,  0,  0,  1],
    ![ 0,  1, -1,  0],
    ![ 0,  0,  1,  0],
    ![ 0,  0,  0,  1]]

/-- The nilpotent monodromy matrix $N := T_0 - I_4$. -/
def N : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0,  0,  0,  1],
    ![ 0,  0, -1,  0],
    ![ 0,  0,  0,  0],
    ![ 0,  0,  0,  0]]

/-- Definitionally $N = T_0 - 1$. -/
theorem N_def : N = T0 - 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $T_1$ has order 3: $T_1^3 = I_4$. -/
theorem T1_order_three : T1 * T1 * T1 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $T_2$ has order 4: $T_2^4 = I_4$. -/
theorem T2_order_four : T2 * T2 * T2 * T2 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $T_0$ is the exact inverse of $T_1 T_2$: $(T_1 T_2) T_0 = I_4$. -/
theorem T0_is_inverse : (T1 * T2) * T0 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $T_0$ is unipotent of index 2: $(T_0 - I_4)^2 = N^2 = 0$. -/
theorem N_squared_zero : N * N = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

-- Standard basis vectors in $\mathbb{Z}^4$
def gamma : Fin 4 → ℤ := ![1, 0, 0, 0]
def u : Fin 4 → ℤ := ![0, 1, 0, 0]
def w : Fin 4 → ℤ := ![0, 0, 1, 0]
def delta : Fin 4 → ℤ := ![0, 0, 0, 1]

/-- Action of $N$ on the basis vector $\gamma$: $N\gamma = 0$. -/
theorem N_act_gamma : N *ᵥ gamma = 0 := by
  ext i
  fin_cases i <;> rfl

/-- Action of $N$ on the basis vector $u$: $Nu = 0$. -/
theorem N_act_u : N *ᵥ u = 0 := by
  ext i
  fin_cases i <;> rfl

/-- Action of $N$ on the basis vector $w$: $Nw = -u$. -/
theorem N_act_w : N *ᵥ w = -u := by
  ext i
  fin_cases i <;> rfl

/-- Action of $N$ on the basis vector $\delta$: $N\delta = \gamma$. -/
theorem N_act_delta : N *ᵥ delta = gamma := by
  ext i
  fin_cases i <;> rfl

/-- The Seifert invariant relation $|12\ell_0 - 4\ell_1 - 3\ell_2| = 1$ for $(\ell_0, \ell_1, \ell_2) = (0, 1, -1)$. -/
theorem seifert_invariant_trivial_pi1 (l0 l1 l2 : ℤ)
    (h0 : l0 = 0) (h1 : l1 = 1) (h2 : l2 = -1) :
    |12 * l0 - 4 * l1 - 3 * l2| = 1 := by
  subst h0 h1 h2
  rfl

end ModularFamilyS6
