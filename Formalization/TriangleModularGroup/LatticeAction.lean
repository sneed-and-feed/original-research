import Formalization.TriangleModularGroup.Basic

open scoped Matrix


/-!
# Lattice Basis Vectors & Nilpotent Monodromy Action

This submodule defines the standard basis vectors $(\gamma, u, w, \delta)$ of the lattice
$V \cong \mathbb{Z}^4$ and formalizes the action of the nilpotent operator $N = T_0 - I_4$.

## Mathematical Overview

For the $(3,4,\infty)$ modular representation, the basis of $V \cong \mathbb{Z}^4$ is:
- $\gamma = (1, 0, 0, 0)^T$ (invariant cycle)
- $u = (0, 1, 0, 0)^T$ (invariant cycle)
- $w = (0, 0, 1, 0)^T$ (pre-image under $N$ mapping to $-u$)
- $\delta = (0, 0, 0, 1)^T$ (pre-image under $N$ mapping to $\gamma$)

The nilpotent monodromy matrix $N$ acts linearly via:
- $N\gamma = 0$
- $Nu = 0$
- $Nw = -u$
- $N\delta = \gamma$

## Main Declarations

- `ModularFamilyS6.gamma`: Standard basis vector $(1, 0, 0, 0)^T$.
- `ModularFamilyS6.u`: Standard basis vector $(0, 1, 0, 0)^T$.
- `ModularFamilyS6.w`: Standard basis vector $(0, 0, 1, 0)^T$.
- `ModularFamilyS6.delta`: Standard basis vector $(0, 0, 0, 1)^T$.
- `ModularFamilyS6.N_act_gamma`: $N\gamma = 0$.
- `ModularFamilyS6.N_act_u`: $Nu = 0$.
- `ModularFamilyS6.N_act_w`: $Nw = -u$.
- `ModularFamilyS6.N_act_delta`: $N\delta = \gamma$.
-/

namespace ModularFamilyS6

open Matrix

/-- The first standard basis vector $\gamma = (1, 0, 0, 0)^T \in \mathbb{Z}^4$. -/
def gamma : Fin 4 → ℤ := ![1, 0, 0, 0]

/-- The second standard basis vector $u = (0, 1, 0, 0)^T \in \mathbb{Z}^4$. -/
def u : Fin 4 → ℤ := ![0, 1, 0, 0]

/-- The third standard basis vector $w = (0, 0, 1, 0)^T \in \mathbb{Z}^4$. -/
def w : Fin 4 → ℤ := ![0, 0, 1, 0]

/-- The fourth standard basis vector $\delta = (0, 0, 0, 1)^T \in \mathbb{Z}^4$. -/
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

end ModularFamilyS6
