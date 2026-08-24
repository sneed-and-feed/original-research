import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases

open scoped Matrix

set_option linter.unusedSectionVars false

/-!
# Foundational Matrix Generators & Relations for (3,4,∞)

This submodule formalizes the integer matrix generators $T_1, T_2 \in \mathrm{GL}_4(\mathbb{Z})$,
the parabolic monodromy $T_0 = (T_1 T_2)^{-1}$, and the nilpotent operator $N = T_0 - I_4$.

## Mathematical Overview

The triangle group $\Delta(3,4,\infty)$ acts on the lattice $V \cong \mathbb{Z}^4$ via:
- Order 3 generator $T_1$ with $T_1^3 = I_4$.
- Order 4 generator $T_2$ with $T_2^4 = I_4$.
- Parabolic generator $T_0$ satisfying $(T_1 T_2) T_0 = I_4$.
- Nilpotent monodromy operator $N = T_0 - I_4$ satisfying $N^2 = 0$ (index-2 unipotence).

## Main Declarations

- `ModularFamilyS6.T1`: Order 3 matrix in $\mathrm{GL}_4(\mathbb{Z})$.
- `ModularFamilyS6.T2`: Order 4 matrix in $\mathrm{GL}_4(\mathbb{Z})$.
- `ModularFamilyS6.T0`: Parabolic monodromy matrix at the cusp.
- `ModularFamilyS6.N`: Nilpotent operator $T_0 - I_4$.
- `ModularFamilyS6.N_def`: Verification $N = T_0 - 1$.
- `ModularFamilyS6.T1_order_three`: $T_1^3 = I_4$.
- `ModularFamilyS6.T2_order_four`: $T_2^4 = I_4$.
- `ModularFamilyS6.T0_is_inverse`: $(T_1 T_2) T_0 = I_4$.
- `ModularFamilyS6.N_squared_zero`: $N^2 = 0$.
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

end ModularFamilyS6
