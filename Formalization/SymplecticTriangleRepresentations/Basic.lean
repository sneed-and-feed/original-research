/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases

open scoped Matrix

/-!
# Foundational Symplectic Form & $\mathrm{Sp}_4(\mathbb{Z})$ Predicate

This submodule formalizes the canonical standard symplectic pairing $J \in \mathrm{Mat}_4(\mathbb{Z})$,
its algebraic involution and skew-symmetry properties, and the predicate defining the integral
symplectic group $\mathrm{Sp}_4(\mathbb{Z})$.

## Mathematical Overview

The standard symplectic form on $V \cong \mathbb{Z}^4$ is represented by the block skew-symmetric matrix
$$J = \begin{pmatrix} 0 & I_2 \\ -I_2 & 0 \end{pmatrix} = \begin{pmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ -1 & 0 & 0 & 0 \\ 0 & -1 & 0 & 0 \end{pmatrix} \in \mathrm{Mat}_4(\mathbb{Z})$$
satisfying the core algebraic axioms:
1. **Skew-symmetry**: $J^T = -J$.
2. **Complex Structure / Almost Complex Involution**: $J^2 = -I_4$.
3. **Invertibility**: $J (-J) = I_4$, so $J^{-1} = -J = J^T$.

An integral matrix $M \in \mathrm{Mat}_4(\mathbb{Z})$ belongs to the symplectic group $\mathrm{Sp}_4(\mathbb{Z})$
if and only if it preserves the symplectic form $J$:
$$\mathrm{IsSymplectic}(M) \iff M^T J M = J$$

The identity matrix $I_4$ is symplectic, and the symplectic condition is closed under matrix multiplication:
$$\mathrm{IsSymplectic}(A) \wedge \mathrm{IsSymplectic}(B) \implies \mathrm{IsSymplectic}(A B)$$

## Main Declarations

- `SymplecticTriangleRepresentations.J`: Standard skew-symmetric symplectic matrix in $\mathrm{Mat}_4(\mathbb{Z})$.
- `SymplecticTriangleRepresentations.J_transpose`: Proof that $J^T = -J$.
- `SymplecticTriangleRepresentations.J_squared`: Proof that $J^2 = -I_4$.
- `SymplecticTriangleRepresentations.J_mul_neg_J`: Proof that $J (-J) = I_4$.
- `SymplecticTriangleRepresentations.IsSymplectic`: Predicate $M^T J M = J$ defining $\mathrm{Sp}_4(\mathbb{Z})$.
- `SymplecticTriangleRepresentations.isSymplectic_one`: Symplectic property for the identity matrix $I_4$.
- `SymplecticTriangleRepresentations.isSymplectic_mul`: Preservation of the symplectic condition under matrix multiplication.
-/

namespace SymplecticTriangleRepresentations

open Matrix

/-! ### 1. The Standard Symplectic Form $J$ -/

/-- The standard non-degenerate skew-symmetric symplectic form $J \in \mathrm{Mat}_4(\mathbb{Z})$. -/
def J : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0,  0,  1,  0],
    ![ 0,  0,  0,  1],
    ![-1,  0,  0,  0],
    ![ 0, -1,  0,  0]]

/-- $J$ is skew-symmetric: $J^T = -J$. -/
theorem J_transpose : Jᵀ = -J := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $J$ squares to $-I_4$: $J^2 = -I_4$. -/
theorem J_squared : J * J = -1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- $J$ has inverse $-J$: $J * (-J) = I_4$. -/
theorem J_mul_neg_J : J * (-J) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Symplectic group predicate on $\mathrm{Mat}_4(\mathbb{Z})$: $M^T J M = J$. -/
def IsSymplectic (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * J * M = J

/-- The identity matrix is symplectic. -/
theorem isSymplectic_one : IsSymplectic 1 := by
  simp [IsSymplectic]

/-- Product of symplectic matrices is symplectic. -/
theorem isSymplectic_mul (A B : Matrix (Fin 4) (Fin 4) ℤ)
    (hA : IsSymplectic A) (hB : IsSymplectic B) :
    IsSymplectic (A * B) := by
  dsimp [IsSymplectic] at *
  calc (A * B)ᵀ * J * (A * B)
    _ = Bᵀ * (Aᵀ * J * A) * B := by simp only [transpose_mul, mul_assoc]
    _ = J := by rw [hA, hB]

end SymplecticTriangleRepresentations
