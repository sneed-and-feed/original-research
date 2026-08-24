/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

open scoped BigOperators

/-!
# Foundational Definitions for Brieskorn Manifolds & Singularity Links

This module formalizes the foundational definitions of Brieskorn polynomials, affine hypersurfaces,
singularity links in complex Euclidean space $\mathbb{C}^n$, their real dimension $2n - 3$, and
the graph-theoretic structure $G(a)$ associated to exponent tuples $a \in \mathbb{N}^n$.

## Main Definitions

- `Brieskorn.brieskornPoly`: The algebraic polynomial $f_a(z) = \sum_{j=0}^{n-1} z_j^{a_j}$.
- `Brieskorn.brieskornHypersurface`: The zero locus $V(a) = f_a^{-1}(0) \subset \mathbb{C}^n$.
- `Brieskorn.complexNormSq`: The squared Euclidean norm on $\mathbb{C}^n$.
- `Brieskorn.unitSphere`: The ambient unit sphere $S^{2n-1} \subset \mathbb{C}^n$.
- `Brieskorn.BrieskornLink`: The singularity link $\Sigma(a) = V(a) \cap S^{2n-1}$.
- `Brieskorn.linkRealDimension`: The real dimension $2n - 3$.
- `Brieskorn.brieskornGraphEdge`: Edge relation in the Brieskorn graph $G(a)$, $i \ne j \wedge \gcd(a_i, a_j) > 1$.
- `Brieskorn.isIsolated`: Predicate that vertex $i$ is isolated in $G(a)$ ($\gcd(a_i, a_j) = 1$ for all $j \ne i$).
- `Brieskorn.hasTwoIsolated`: Predicate that $G(a)$ has at least two distinct isolated vertices.
-/

namespace Brieskorn

open Finset

/-! ### 1. Brieskorn Polynomials and Singularity Links -/

/-- The algebraic Brieskorn polynomial $f_a(z) = \sum_{j=0}^{n-1} z_j^{a_j}$ in $\mathbb{C}^n$. -/
def brieskornPoly {n : ℕ} (a : Fin n → ℕ) (z : Fin n → ℂ) : ℂ :=
  ∑ i, (z i) ^ (a i)

/-- The affine Brieskorn hypersurface $V(a) = f_a^{-1}(0) \subset \mathbb{C}^n$. -/
def brieskornHypersurface {n : ℕ} (a : Fin n → ℕ) : Set (Fin n → ℂ) :=
  { z | brieskornPoly a z = 0 }

/-- The squared Euclidean norm on $\mathbb{C}^n$. -/
def complexNormSq {n : ℕ} (z : Fin n → ℂ) : ℝ :=
  ∑ i, Complex.normSq (z i)

/-- The unit sphere $S^{2n-1} \subset \mathbb{C}^n$. -/
def unitSphere (n : ℕ) : Set (Fin n → ℂ) :=
  { z | complexNormSq z = 1 }

/-- The Brieskorn manifold $\Sigma(a_1, \dots, a_n) = V(a) \cap S^{2n-1}$. -/
def BrieskornLink {n : ℕ} (a : Fin n → ℕ) : Set (Fin n → ℂ) :=
  brieskornHypersurface a ∩ unitSphere n

/-- Real dimension of the Brieskorn singularity link $\Sigma(a_1, \dots, a_n)$, which is $2n - 3$. -/
def linkRealDimension (n : ℕ) : ℕ :=
  2 * n - 3

/-- For $n = 5$ variables, the Brieskorn link has real dimension 7. -/
theorem linkDimension_five : linkRealDimension 5 = 7 := rfl

/-- For $n = 3$ variables, the Brieskorn link has real dimension 3. -/
theorem linkDimension_three : linkRealDimension 3 = 3 := rfl

/-! ### 2. Foundational Brieskorn Graph Definitions -/

/-- An edge in the Brieskorn graph $G(a)$ exists between vertices $i \ne j$ when $\gcd(a_i, a_j) > 1$. -/
def brieskornGraphEdge {n : ℕ} (a : Fin n → ℕ) (i j : Fin n) : Prop :=
  i ≠ j ∧ ¬ Nat.Coprime (a i) (a j)

/-- A vertex $i$ in the Brieskorn graph $G(a)$ is isolated if $\gcd(a_i, a_j) = 1$ for all $j \ne i$. -/
def isIsolated {n : ℕ} (a : Fin n → ℕ) (i : Fin n) : Prop :=
  ∀ j : Fin n, j ≠ i → Nat.Coprime (a i) (a j)

/-- The Brieskorn graph $G(a)$ has at least two distinct isolated vertices. -/
def hasTwoIsolated {n : ℕ} (a : Fin n → ℕ) : Prop :=
  ∃ i j : Fin n, i ≠ j ∧ isIsolated a i ∧ isIsolated a j

end Brieskorn
