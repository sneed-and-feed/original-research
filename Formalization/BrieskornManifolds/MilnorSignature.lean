/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornManifolds.Basic
import Formalization.BrieskornManifolds.SphereCriterion
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Prod
import Mathlib.Data.Finset.Interval
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

/-!
# Milnor Fiber Intersection Forms & Casson Invariants of Brieskorn 3-Spheres

This module formalizes the Milnor lattice, eigenspace splitting, signature $\sigma(p, q, r)$,
and the Casson invariant formula $\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$ for Brieskorn
homology 3-spheres $\Sigma(p, q, r)$.

## Main Results

- `Brieskorn.PairwiseCoprime3`: Predicate that exponents $(p, q, r)$ are pairwise coprime.
- `Brieskorn.brieskornThreeExponents`: Exponent map for $\Sigma(p, q, r)$.
- `Brieskorn.pairwise_coprime_all_isolated`: All vertices of $G(p, q, r)$ are isolated under pairwise coprimality.
- `Brieskorn.pairwise_coprime_isBrieskornSphere`: $\Sigma(p, q, r)$ is a topological sphere.
- `Brieskorn.brieskornLattice`: The interior index set $I(p, q, r) \cong (0, p) \times (0, q) \times (0, r)$.
- `Brieskorn.brieskornLattice_card`: Cardinality equals the Milnor number $\mu = (p-1)(q-1)(r-1)$.
- `Brieskorn.latticeWeight`: Scaled weight function $S(x, y, z) = x q r + y p r + z p q$.
- `Brieskorn.posLattice` / `Brieskorn.negLattice`: Positive and negative eigenspace index sets.
- `Brieskorn.brieskornSignature`: Milnor fiber intersection signature $\sigma(p, q, r) = N_+ - N_-$.
- `Brieskorn.cassonInvariant`: Rational Casson invariant $\lambda = \frac{1}{8} |\sigma|$.
- `Brieskorn.cassonInvariantNat`: Integer Casson invariant $\lambda \in \mathbb{ℕ}$.
- Certified evaluations:
  - $\Sigma(2, 3, 5)$: $\sigma = -8$, $\lambda = 1$ (Poincaré homology sphere).
  - $\Sigma(2, 3, 7)$: $\sigma = -8$, $\lambda = 1$.
  - $\Sigma(2, 3, 11)$: $\sigma = -16$, $\lambda = 2$.
  - $\Sigma(2, 5, 7)$: $\sigma = -16$, $\lambda = 2$.
-/

namespace Brieskorn

open Finset

/-- A triple of exponents $(p, q, r)$ is pairwise coprime. -/
def PairwiseCoprime3 (p q r : ℕ) : Prop :=
  Nat.Coprime p q ∧ Nat.Coprime q r ∧ Nat.Coprime p r

/-- The Brieskorn exponent tuple for a 3-manifold $\Sigma(p, q, r)$. -/
def brieskornThreeExponents (p q r : ℕ) : Fin 3 → ℕ
  | ⟨0, _⟩ => p
  | ⟨1, _⟩ => q
  | ⟨2, _⟩ => r

/-- Pairwise coprimality of $(p, q, r)$ implies all vertices of $G(p, q, r)$ are isolated. -/
theorem pairwise_coprime_all_isolated (p q r : ℕ) (h : PairwiseCoprime3 p q r) (i : Fin 3) :
    isIsolated (brieskornThreeExponents p q r) i := by
  intro j hj
  fin_cases i <;> fin_cases j <;>
    first | contradiction | exact h.1 | exact h.1.symm | exact h.2.1 | exact h.2.1.symm | exact h.2.2 | exact h.2.2.symm

/-- Pairwise coprimality guarantees $\Sigma(p, q, r)$ is a topological sphere. -/
theorem pairwise_coprime_isBrieskornSphere (p q r : ℕ) (h : PairwiseCoprime3 p q r) :
    brieskornSphereCondition (brieskornThreeExponents p q r) :=
  sphere_condition_of_two_isolated ⟨0, 1, by decide, pairwise_coprime_all_isolated p q r h 0, pairwise_coprime_all_isolated p q r h 1⟩

/-- The discrete lattice of interior indices for $\Sigma(p, q, r)$:
    $I(p, q, r) = \{ (x, y, z) \in \mathbb{ℕ}^3 \mid 1 \le x < p, 1 \le y < q, 1 \le z < r \}$. -/
def brieskornLattice (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (Finset.Ioo 0 p) ×ˢ ((Finset.Ioo 0 q) ×ˢ (Finset.Ioo 0 r))

/-- Total number of interior lattice points in the Milnor fiber of $\Sigma(p, q, r)$,
    which equals the Milnor number $\mu = (p - 1)(q - 1)(r - 1)$. -/
theorem brieskornLattice_card (p q r : ℕ) :
    (brieskornLattice p q r).card = (p - 1) * (q - 1) * (r - 1) := by
  simp [brieskornLattice, mul_assoc]

/-- Scaled weight of a lattice point $(x, y, z)$ under common denominator $pqr$:
    $S(x, y, z) = x q r + y p r + z p q$. -/
def latticeWeight (p q r : ℕ) (pt : ℕ × ℕ × ℕ) : ℕ :=
  let (x, (y, z)) := pt
  x * q * r + y * p * r + z * p * q

/-- Positive eigenspace lattice points: $0 < S < pqr$ or $2pqr < S < 3pqr$. -/
def posLattice (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (brieskornLattice p q r).filter (fun pt =>
    let S := latticeWeight p q r pt
    let M := p * q * r
    (0 < S && S < M) || (2 * M < S && S < 3 * M))

/-- Negative eigenspace lattice points: $pqr < S < 2pqr$. -/
def negLattice (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (brieskornLattice p q r).filter (fun pt =>
    let S := latticeWeight p q r pt
    let M := p * q * r
    M < S && S < 2 * M)

/-- The signature $\sigma(p, q, r) = N_+ - N_-$ of the Milnor fiber intersection form. -/
def brieskornSignature (p q r : ℕ) : ℤ :=
  (posLattice p q r).card - (negLattice p q r).card

/-- The Casson invariant of the Brieskorn homology 3-sphere $\Sigma(p, q, r)$:
    $\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$. -/
def cassonInvariant (p q r : ℕ) : ℚ :=
  (Int.natAbs (brieskornSignature p q r) : ℚ) / 8

/-- Integer Casson invariant $\lambda(\Sigma(p, q, r)) \in \mathbb{ℕ}$. -/
def cassonInvariantNat (p q r : ℕ) : ℕ :=
  (Int.natAbs (brieskornSignature p q r)) / 8

/-! ### Certified Evaluations of Casson Invariants -/

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ is pairwise coprime. -/
theorem coprime_2_3_5 : PairwiseCoprime3 2 3 5 :=
  ⟨by decide, by decide, by decide⟩

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ has signature $\sigma = -8$. -/
theorem signature_2_3_5 : brieskornSignature 2 3 5 = -8 := rfl

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ has Casson invariant $\lambda = 1$. -/
theorem casson_2_3_5 : cassonInvariant 2 3 5 = 1 := by
  norm_num [cassonInvariant, (show brieskornSignature 2 3 5 = -8 from rfl)]

/-- Integer Casson invariant for $\Sigma(2, 3, 5)$. -/
theorem cassonNat_2_3_5 : cassonInvariantNat 2 3 5 = 1 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ is pairwise coprime. -/
theorem coprime_2_3_7 : PairwiseCoprime3 2 3 7 :=
  ⟨by decide, by decide, by decide⟩

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ has signature $\sigma = -8$. -/
theorem signature_2_3_7 : brieskornSignature 2 3 7 = -8 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ has Casson invariant $\lambda = 1$. -/
theorem casson_2_3_7 : cassonInvariant 2 3 7 = 1 := by
  norm_num [cassonInvariant, (show brieskornSignature 2 3 7 = -8 from rfl)]

/-- Integer Casson invariant for $\Sigma(2, 3, 7)$. -/
theorem cassonNat_2_3_7 : cassonInvariantNat 2 3 7 = 1 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ is pairwise coprime. -/
theorem coprime_2_3_11 : PairwiseCoprime3 2 3 11 :=
  ⟨by decide, by decide, by decide⟩

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ has signature $\sigma = -16$. -/
theorem signature_2_3_11 : brieskornSignature 2 3 11 = -16 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ has Casson invariant $\lambda = 2$. -/
theorem casson_2_3_11 : cassonInvariant 2 3 11 = 2 := by
  norm_num [cassonInvariant, (show brieskornSignature 2 3 11 = -16 from rfl)]

/-- Integer Casson invariant for $\Sigma(2, 3, 11)$. -/
theorem cassonNat_2_3_11 : cassonInvariantNat 2 3 11 = 2 := rfl

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ is pairwise coprime. -/
theorem coprime_2_5_7 : PairwiseCoprime3 2 5 7 :=
  ⟨by decide, by decide, by decide⟩

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ has signature $\sigma = -16$. -/
theorem signature_2_5_7 : brieskornSignature 2 5 7 = -16 := rfl

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ has Casson invariant $\lambda = 2$. -/
theorem casson_2_5_7 : cassonInvariant 2 5 7 = 2 := by
  norm_num [cassonInvariant, (show brieskornSignature 2 5 7 = -16 from rfl)]

/-- Integer Casson invariant for $\Sigma(2, 5, 7)$. -/
theorem cassonNat_2_5_7 : cassonInvariantNat 2 5 7 = 2 := rfl

end Brieskorn
