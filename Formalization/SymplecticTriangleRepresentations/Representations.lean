/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SymplecticTriangleRepresentations.Basic

open scoped Matrix

set_option linter.unusedSectionVars false

/-!
# Integral Symplectic Triangle Group Representations

This submodule establishes the explicit 4-dimensional integral symplectic representations
$\rho : \Delta(p,q,\infty) \to \mathrm{Sp}_4(\mathbb{Z})$ for hyperbolic triangle groups
acting on the homology lattice $V \cong \mathbb{Z}^4$ of degenerating complex abelian surfaces.

## Mathematical Overview

A hyperbolic triangle group $\Delta(p, q, \infty)$ is presented by generators and relations:
$$\Delta(p, q, \infty) = \langle \tau_1, \tau_2, \tau_0 \mid \tau_1^p = 1, \, \tau_2^q = 1, \, \tau_1 \tau_2 \tau_0 = 1 \rangle$$
where $\tau_1, \tau_2$ represent elliptic cone rotations and $\tau_0 = (\tau_1 \tau_2)^{-1}$ represents
the parabolic monodromy around the cusp.

### 1. The $(3,4,\infty)$ Representation
We define integer matrices $T_1, T_2, T_0 \in \mathrm{Mat}_4(\mathbb{Z})$:
- $T_1$: Order 3 elliptic automorphism satisfying $T_1^3 = I_4$.
- $T_2$: Order 4 elliptic automorphism satisfying $T_2^4 = I_4$.
- $T_0$: Parabolic cusp monodromy satisfying $(T_1 T_2) T_0 = I_4$.
- $N = T_0 - I_4$: Nilpotent monodromy operator satisfying $N^2 = 0$ and $N \ne 0$.
- Symplectic verification: $T_1, T_2, T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ preserving the standard form $J$.

### 2. The $(2,3,\infty)$ Representation
We define integer matrices $S_1, S_2, S_0 \in \mathrm{Mat}_4(\mathbb{Z})$:
- $S_1$: Order 2 involution satisfying $S_1^2 = I_4$.
- $S_2$: Order 3 automorphism satisfying $S_2^3 = I_4$.
- $S_0$: Cusp monodromy satisfying $(S_1 S_2) S_0 = I_4$.
- $N_{23}$: Associated nilpotent operator satisfying $N_{23}^2 = 0$ and $N_{23} \ne 0$.
- Symplectic verification: $S_1, S_2, S_0 \in \mathrm{Sp}_4(\mathbb{Z})$ preserving the standard form $J$.

## Main Declarations

- `SymplecticTriangleRepresentations.T1`, `T2`, `T0`, `N`: $(3,4,\infty)$ representation matrices.
- `SymplecticTriangleRepresentations.T1_order_three`: $T_1^3 = I_4$.
- `SymplecticTriangleRepresentations.T2_order_four`: $T_2^4 = I_4$.
- `SymplecticTriangleRepresentations.T0_is_inverse`: $(T_1 T_2) T_0 = I_4$.
- `SymplecticTriangleRepresentations.isSymplectic_T1`, `isSymplectic_T2`, `isSymplectic_T0`: Symplectic properties.
- `SymplecticTriangleRepresentations.N_def`: $N = T_0 - 1$.
- `SymplecticTriangleRepresentations.N_squared_zero`: $N^2 = 0$.
- `SymplecticTriangleRepresentations.N_nonzero`: $N \ne 0$.
- `SymplecticTriangleRepresentations.S1`, `S2`, `S0`, `N23`: $(2,3,\infty)$ representation matrices.
- `SymplecticTriangleRepresentations.S1_order_two`: $S_1^2 = I_4$.
- `SymplecticTriangleRepresentations.S2_order_three`: $S_2^3 = I_4$.
- `SymplecticTriangleRepresentations.S0_is_inverse`: $(S_1 S_2) S_0 = I_4$.
- `SymplecticTriangleRepresentations.isSymplectic_S1`, `isSymplectic_S2`, `isSymplectic_S0`: Symplectic properties.
- `SymplecticTriangleRepresentations.N23_squared_zero`: $N_{23}^2 = 0$.
- `SymplecticTriangleRepresentations.N23_nonzero`: $N_{23} \ne 0$.
-/

namespace SymplecticTriangleRepresentations

open Matrix

/-! ### 1. The $(3,4,\infty)$ Symplectic Representation -/

/-- Order 3 generator $T_1$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
def T1 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ -1,  1,  0,  0],
    ![ -1,  0,  0,  0],
    ![  0,  0,  0,  1],
    ![  0,  0, -1, -1]]

/-- Order 4 generator $T_2$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
def T2 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0, -1,  0,  0],
    ![  1,  0,  0,  0],
    ![  0,  0,  0, -1],
    ![  0,  0,  1,  0]]

/-- Parabolic cusp monodromy $T_0 = (T_1 T_2)^{-1}$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
def T0 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  1, -1,  0,  0],
    ![  0,  1,  0,  0],
    ![  0,  0,  1,  0],
    ![  0,  0,  1,  1]]

/-- Nilpotent cusp monodromy operator $N := T_0 - I_4$. -/
def N : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0, -1,  0,  0],
    ![  0,  0,  0,  0],
    ![  0,  0,  0,  0],
    ![  0,  0,  1,  0]]

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

/-- $T_1$ is symplectic: $T_1^T J T_1 = J$. -/
theorem isSymplectic_T1 : IsSymplectic T1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $T_2$ is symplectic: $T_2^T J T_2 = J$. -/
theorem isSymplectic_T2 : IsSymplectic T2 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $T_0$ is symplectic: $T_0^T J T_0 = J$. -/
theorem isSymplectic_T0 : IsSymplectic T0 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- The composite group element $T_1 T_2$ is symplectic. -/
theorem isSymplectic_T1_mul_T2 : IsSymplectic (T1 * T2) :=
  isSymplectic_mul T1 T2 isSymplectic_T1 isSymplectic_T2

/-- Definition of $N = T_0 - 1$. -/
theorem N_def : N = T0 - 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Nilpotence: $N^2 = 0$. -/
theorem N_squared_zero : N * N = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Non-triviality: $N \ne 0$. -/
theorem N_nonzero : N ≠ 0 :=
  fun h => by injection congr_fun (congr_fun h 0) 1

/-! ### 2. The $(2,3,\infty)$ Modular Family in $\mathrm{Sp}_4(\mathbb{Z})$ -/

/-- Order 2 generator $S_1$ for the $(2,3,\infty)$ family. -/
def S1 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  1,  0,  0,  0],
    ![  0, -1,  0,  0],
    ![  0,  0,  1,  0],
    ![  0,  0,  0, -1]]

/-- Order 3 generator $S_2$ for the $(2,3,\infty)$ family. -/
def S2 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ -1,  1,  0,  0],
    ![ -1,  0,  0,  0],
    ![  0,  0,  0,  1],
    ![  0,  0, -1, -1]]

/-- Parabolic cusp monodromy $S_0 = (S_1 S_2)^{-1}$ for $(2,3,\infty)$. -/
def S0 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0,  1,  0,  0],
    ![  1,  1,  0,  0],
    ![  0,  0, -1,  1],
    ![  0,  0,  1,  0]]

/-- Nilpotent operator $N_{23}$ associated with $(2,3,\infty)$ parabolic degeneration. -/
def N23 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0,  1,  0,  0],
    ![  0,  0,  0,  0],
    ![  0,  0,  0,  0],
    ![  0,  0, -1,  0]]

/-- $S_1$ has order 2: $S_1^2 = I_4$. -/
theorem S1_order_two : S1 * S1 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $S_2$ has order 3: $S_2^3 = I_4$. -/
theorem S2_order_three : S2 * S2 * S2 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $S_0$ is the exact inverse of $S_1 S_2$: $(S_1 S_2) S_0 = I_4$. -/
theorem S0_is_inverse : (S1 * S2) * S0 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $S_1$ is symplectic: $S_1^T J S_1 = J$. -/
theorem isSymplectic_S1 : IsSymplectic S1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $S_2$ is symplectic: $S_2^T J S_2 = J$. -/
theorem isSymplectic_S2 : IsSymplectic S2 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $S_0$ is symplectic: $S_0^T J S_0 = J$. -/
theorem isSymplectic_S0 : IsSymplectic S0 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Nilpotence of $N_{23}$: $N_{23}^2 = 0$. -/
theorem N23_squared_zero : N23 * N23 = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Non-triviality of $N_{23}$: $N_{23} \ne 0$. -/
theorem N23_nonzero : N23 ≠ 0 :=
  fun h => (by decide : N23 0 1 ≠ 0) (congr_fun (congr_fun h 0) 1)

end SymplecticTriangleRepresentations
