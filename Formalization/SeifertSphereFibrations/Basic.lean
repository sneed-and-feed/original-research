/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Int.GCD
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Tactic.Ring

/-!
# Foundational Definitions and Bézout Invariants for 2-Orbifold Seifert Fibrations

This submodule formalizes the core Seifert invariant formula for 3-manifolds fibered
over a 2-orbifold base $S^2(a_1, a_2, \infty)$ with two conical singularities of orders
$a_1, a_2$ and one parabolic cusp, along with the fundamental homotopy sphere condition
and explicit Bézout twist witnesses.

## Mathematical Overview

For a Seifert fibration over $S^2(a_1, a_2, \infty)$ with fiber translation parameters
$(\ell_0, \ell_1, \ell_2) \in \mathbb{Z}^3$, the central Seifert invariant is given by:
$$O(a_1, a_2; \ell_0, \ell_1, \ell_2) = a_1 a_2 \ell_0 - a_2 \ell_1 - a_1 \ell_2$$

The manifold has trivial first homology / is a homotopy sphere when:
$$|O(a_1, a_2; \ell_0, \ell_1, \ell_2)| = 1$$

## Main Declarations

- `SeifertFibration.seifertOrder`: Order formula $a_1 a_2 \ell_0 - a_2 \ell_1 - a_1 \ell_2$.
- `SeifertFibration.IsHomotopySphere`: Predicate $|O(a_1, a_2; \ell_0, \ell_1, \ell_2)| = 1$.
- `SeifertFibration.coprimeWitnesses`: Explicit Bézout witness triple $(0, -\operatorname{gcdB}(a_1, a_2), -\operatorname{gcdA}(a_1, a_2))$.
- `SeifertFibration.seifertOrder_bezout`: Evaluates the order on Bézout witnesses to $\gcd(a_1, a_2)$.
- `SeifertFibration.seifertOrder_coprimeWitnesses`: Wrapper showing `coprimeWitnesses` produces $\gcd(a_1, a_2)$.
-/

namespace SeifertFibration

/-- The Seifert invariant order formula for 2 orbifold cone points $(a_1, a_2)$ and 1 cusp. -/
def seifertOrder (a1 a2 l0 l1 l2 : ℤ) : ℤ :=
  a1 * a2 * l0 - a2 * l1 - a1 * l2

/-- Homotopy sphere condition: the Seifert order has absolute value equal to 1. -/
def IsHomotopySphere (a1 a2 l0 l1 l2 : ℤ) : Prop :=
  |seifertOrder a1 a2 l0 l1 l2| = 1

/-- Explicit Bézout witness constructor for translation twists from $(a_1, a_2)$. -/
def coprimeWitnesses (a1 a2 : ℤ) : ℤ × ℤ × ℤ :=
  (0, -Int.gcdB a1 a2, -Int.gcdA a1 a2)

/-- The Seifert order evaluated at the explicit Bézout witnesses reproduces $\gcd(a_1, a_2)$. -/
theorem seifertOrder_bezout (a1 a2 : ℤ) :
    seifertOrder a1 a2 0 (-Int.gcdB a1 a2) (-Int.gcdA a1 a2) = (a1.gcd a2 : ℤ) := by
  dsimp [seifertOrder]
  rw [Int.gcd_eq_gcd_ab]
  ring

/-- The explicit witness function evaluates to $\gcd(a_1, a_2)$. -/
theorem seifertOrder_coprimeWitnesses (a1 a2 : ℤ) :
    let (l0, l1, l2) := coprimeWitnesses a1 a2
    seifertOrder a1 a2 l0 l1 l2 = (a1.gcd a2 : ℤ) := by
  exact seifertOrder_bezout a1 a2

end SeifertFibration
