/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornSU2CharacterVariety.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Prod
import Mathlib.Data.Finset.Interval
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Diophantine Spherical Angle Triples & Representation Search Space

This submodule formalizes the Diophantine spherical triangle angle predicate `IsSphericalAngleTriple`,
its decidability and boolean decision procedure `isSphericalAngleBool`, the candidate search space
`candidateRepFinset`, and the finite set of irreducible $SU(2)$ representations `IrredSU2RepSet`
for Brieskorn homology 3-spheres $\Sigma(p, q, r)$.

## Key Definitions and Results

- `IsSphericalAngleTriple`: Predicate defining rotation parameters $(a, b, c)$ satisfying $1 \le a < p$,
  $1 \le b < q$, $1 \le c < r$, odd parity, and cross-multiplied spherical triangle inequalities.
- `IsDiophantineAngleTriple`: Alias for `IsSphericalAngleTriple`.
- `isSphericalAngleBool`: Boolean evaluation function for finset filtering.
- `sphericalAngleTriple_odd_sum`: Odd sum parity lemma for $p = 2$ and odd $q, r$.
- `candidateRepFinset`: Cartesian product finset $\prod_{i=1}^3 [1, p_i - 1]$.
- `candidateRepFinset_card`: Cardinality formula $(p - 1)(q - 1)(r - 1)$.
- `IrredSU2RepSet`: Filtered finset of irreducible $SU(2)$ representations.
- `irredRepCount`: Representation count $\#\mathcal{R}^*(\Sigma(p, q, r))$.
-/

namespace BrieskornSU2

open Finset

/-- A triple $(a, b, c)$ is a spherical angle triple for $\Sigma(p, q, r)$ if it lies
    in the range $1 \le a < p$, $1 \le b < q$, $1 \le c < r$, has odd components,
    and satisfies the strict spherical triangle inequalities. -/
def IsSphericalAngleTriple (p q r a b c : ℕ) : Prop :=
  1 ≤ a ∧ a < p ∧
  1 ≤ b ∧ b < q ∧
  1 ≤ c ∧ c < r ∧
  a % 2 = 1 ∧ b % 2 = 1 ∧ c % 2 = 1 ∧
  a * q * r + b * p * r > c * p * q ∧
  a * q * r + c * p * q > b * p * r ∧
  b * p * r + c * p * q > a * q * r ∧
  a * q * r + b * p * r + c * p * q < 2 * (p * q * r)

/-- Alias for Diophantine spherical angle triple. -/
abbrev IsDiophantineAngleTriple (p q r a b c : ℕ) : Prop :=
  IsSphericalAngleTriple p q r a b c

instance (p q r a b c : ℕ) : Decidable (IsSphericalAngleTriple p q r a b c) := by
  dsimp [IsSphericalAngleTriple]
  infer_instance

/-- Decidable boolean filter for spherical angle triples under cross-multiplication. -/
def isSphericalAngleBool (p q r : ℕ) (pt : ℕ × ℕ × ℕ) : Bool :=
  let (a, (b, c)) := pt
  let M := p * q * r
  let Sa := a * q * r
  let Sb := b * p * r
  let Sc := c * p * q
  (a % 2 == 1) && (b % 2 == 1) && (c % 2 == 1) &&
  (Sa + Sb > Sc) &&
  (Sa + Sc > Sb) &&
  (Sb + Sc > Sa) &&
  (Sa + Sb + Sc < 2 * M)

/-- For even $p = 2$ and odd $q, r$, any spherical angle triple satisfies the odd sum condition. -/
theorem sphericalAngleTriple_odd_sum {p q r a b c : ℕ} (hp : p = 2) (hq : q % 2 = 1) (hr : r % 2 = 1)
    (h : IsSphericalAngleTriple p q r a b c) :
    (a * q * r + b * p * r + c * p * q) % 2 = 1 := by
  have : a = 1 := by linarith [h.1, h.2.1, hp]
  rw [hp, this, show 1 * q * r + b * 2 * r + c * 2 * q = q * r + (b * r + c * q) * 2 by ring,
    Nat.add_mul_mod_self_right, Nat.mul_mod, hq, hr]

/-! ### Finset of Irreducible SU(2) Representations -/

/-- The finite search space $\prod_{i=1}^3 [1, p_i - 1]$ of candidate representation parameters. -/
def candidateRepFinset (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  Finset.Ico 1 p ×ˢ (Finset.Ico 1 q ×ˢ Finset.Ico 1 r)

/-- The total number of candidate tuples before angle and parity filtering. -/
theorem candidateRepFinset_card (p q r : ℕ) :
    (candidateRepFinset p q r).card = (p - 1) * (q - 1) * (r - 1) := by
  simp [candidateRepFinset, mul_assoc]

/-- The finite set of irreducible $SU(2)$ representations $\mathcal{R}^*(\Sigma(p, q, r))$,
    identified with the Diophantine spherical angle solution set. -/
def IrredSU2RepSet (p q r : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (candidateRepFinset p q r).filter (fun pt => isSphericalAngleBool p q r pt)

/-- The number of irreducible $SU(2)$ representations of $\Sigma(p, q, r)$. -/
def irredRepCount (p q r : ℕ) : ℕ :=
  (IrredSU2RepSet p q r).card

end BrieskornSU2
