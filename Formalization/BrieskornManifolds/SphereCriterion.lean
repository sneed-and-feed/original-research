/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornManifolds.Basic
import Mathlib.Data.Finset.Card

/-!
# The Brieskorn–Hirzebruch Sphere Criterion

This module formalizes the topological sphere criterion of Brieskorn (1966) and Milnor (1968)
for singularity links $\Sigma(a_1, \dots, a_n)$.

## Main Results

- `Brieskorn.brieskornSphereCondition`: The Brieskorn-Hirzebruch topological sphere condition:
  either $G(a)$ has $\ge 2$ isolated vertices, or $G(a)$ has $\ge 1$ isolated vertex and an odd
  connected component with pairwise gcd equal to 2.
- `Brieskorn.sphere_condition_of_two_isolated`: Proof that having two isolated vertices is sufficient
  for $\Sigma(a)$ to satisfy the topological sphere criterion.
-/

namespace Brieskorn

open Finset

/-- The Brieskorn Sphere Criterion (Brieskorn 1966, Milnor 1968):
    $\Sigma(a_1, \dots, a_n)$ is a topological sphere $S^{2n-3}$ (for $n \ge 3$) if
    the Brieskorn graph $G(a)$ has at least two isolated vertices, or one isolated vertex
    and an odd connected component of pairwise gcd 2. -/
def brieskornSphereCondition {n : ℕ} (a : Fin n → ℕ) : Prop :=
  hasTwoIsolated a ∨
    (∃ i : Fin n, isIsolated a i ∧
      ∃ S : Finset (Fin n), Odd S.card ∧ (∀ j ∈ S, a j = 2) ∧ (∀ j ∉ S, j ≠ i → Nat.Coprime (a j) 2))

/-- Having two isolated vertices is sufficient for the Brieskorn sphere criterion. -/
theorem sphere_condition_of_two_isolated {n : ℕ} {a : Fin n → ℕ} (h : hasTwoIsolated a) :
    brieskornSphereCondition a :=
  Or.inl h

end Brieskorn
