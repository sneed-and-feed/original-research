/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornSU2CharacterVariety.RepresentationCounts
import Formalization.BrieskornManifolds
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum

/-!
# Gauge-Theoretic Casson Invariant & Agreement with Milnor Signature

This submodule formalizes the gauge-theoretic Casson invariant computed from the
irreducible $SU(2)$ character variety:
$$\lambda_{SU(2)}(\Sigma(p, q, r)) = \frac{1}{2} \#\mathcal{R}^*(\Sigma(p, q, r))$$
and proves exact agreement (both integer and rational) with the Milnor fiber signature
Casson invariant $\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$ from
`Formalization.BrieskornManifolds`.

## Key Theorems

- Integer evaluation:
  - `cassonSU2_2_3_5`: $\lambda_{SU(2)}(\Sigma(2, 3, 5)) = 1$.
  - `cassonSU2_2_3_7`: $\lambda_{SU(2)}(\Sigma(2, 3, 7)) = 1$.
  - `cassonSU2_2_3_11`: $\lambda_{SU(2)}(\Sigma(2, 3, 11)) = 2$.
  - `cassonSU2_2_5_7`: $\lambda_{SU(2)}(\Sigma(2, 5, 7)) = 2$.
- Integer identification with Milnor signature:
  - `casson_su2_eq_brieskorn_2_3_5`, `casson_su2_eq_brieskorn_2_3_7`,
    `casson_su2_eq_brieskorn_2_3_11`, `casson_su2_eq_brieskorn_2_5_7`.
- Rational identification with Milnor signature:
  - `cassonRat_su2_eq_brieskorn_2_3_5`, `cassonRat_su2_eq_brieskorn_2_3_7`,
    `cassonRat_su2_eq_brieskorn_2_3_11`, `cassonRat_su2_eq_brieskorn_2_5_7`.
-/

namespace BrieskornSU2

/-- Integer Casson invariant computed from the $SU(2)$ character variety:
    $\lambda_{SU(2)}(\Sigma(p, q, r)) = \frac{1}{2} \#\mathcal{R}^*(\Sigma(p, q, r))$. -/
def cassonSU2 (p q r : ℕ) : ℕ :=
  (IrredSU2RepSet p q r).card / 2

/-- Alias for integer Casson invariant from $SU(2)$. -/
def cassonFromSU2 (p q r : ℕ) : ℕ :=
  cassonSU2 p q r

/-- Rational Casson invariant computed from the $SU(2)$ character variety. -/
def cassonFromSU2Rat (p q r : ℕ) : ℚ :=
  ((IrredSU2RepSet p q r).card : ℚ) / 2

/-- Character variety Casson invariant for $\Sigma(2, 3, 5)$ is 1. -/
theorem cassonSU2_2_3_5 : cassonSU2 2 3 5 = 1 := rfl

/-- Character variety Casson invariant for $\Sigma(2, 3, 7)$ is 1. -/
theorem cassonSU2_2_3_7 : cassonSU2 2 3 7 = 1 := rfl

/-- Character variety Casson invariant for $\Sigma(2, 3, 11)$ is 2. -/
theorem cassonSU2_2_3_11 : cassonSU2 2 3 11 = 2 := rfl

/-- Character variety Casson invariant for $\Sigma(2, 5, 7)$ is 2. -/
theorem cassonSU2_2_5_7 : cassonSU2 2 5 7 = 2 := rfl

/-- Integer agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 3, 5)$. -/
theorem casson_su2_eq_brieskorn_2_3_5 :
    cassonSU2 2 3 5 = Brieskorn.cassonInvariantNat 2 3 5 := rfl

/-- Integer agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 3, 7)$. -/
theorem casson_su2_eq_brieskorn_2_3_7 :
    cassonSU2 2 3 7 = Brieskorn.cassonInvariantNat 2 3 7 := rfl

/-- Integer agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 3, 11)$. -/
theorem casson_su2_eq_brieskorn_2_3_11 :
    cassonSU2 2 3 11 = Brieskorn.cassonInvariantNat 2 3 11 := rfl

/-- Integer agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 5, 7)$. -/
theorem casson_su2_eq_brieskorn_2_5_7 :
    cassonSU2 2 5 7 = Brieskorn.cassonInvariantNat 2 5 7 := rfl

/-- Rational agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 3, 5)$. -/
theorem cassonRat_su2_eq_brieskorn_2_3_5 :
    cassonFromSU2Rat 2 3 5 = Brieskorn.cassonInvariant 2 3 5 := by
  norm_num [cassonFromSU2Rat, card_irred_su2_2_3_5, Brieskorn.casson_2_3_5]

/-- Rational agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 3, 7)$. -/
theorem cassonRat_su2_eq_brieskorn_2_3_7 :
    cassonFromSU2Rat 2 3 7 = Brieskorn.cassonInvariant 2 3 7 := by
  norm_num [cassonFromSU2Rat, card_irred_su2_2_3_7, Brieskorn.casson_2_3_7]

/-- Rational agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 3, 11)$. -/
theorem cassonRat_su2_eq_brieskorn_2_3_11 :
    cassonFromSU2Rat 2 3 11 = Brieskorn.cassonInvariant 2 3 11 := by
  norm_num [cassonFromSU2Rat, card_irred_su2_2_3_11, Brieskorn.casson_2_3_11]

/-- Rational agreement between $SU(2)$ character variety Casson invariant and
    Milnor fiber signature Casson invariant for $\Sigma(2, 5, 7)$. -/
theorem cassonRat_su2_eq_brieskorn_2_5_7 :
    cassonFromSU2Rat 2 5 7 = Brieskorn.cassonInvariant 2 5 7 := by
  norm_num [cassonFromSU2Rat, card_irred_su2_2_5_7, Brieskorn.casson_2_5_7]

end BrieskornSU2
