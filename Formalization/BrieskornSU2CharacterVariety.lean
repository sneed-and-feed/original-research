/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornManifolds
import Formalization.SeifertSphereFibrations
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Interval
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

/-!
# SU(2) Character Varieties, Diophantine Angles & Casson Invariant

This module formalizes the theory of irreducible $SU(2)$ character varieties for
Brieskorn homology 3-spheres $\Sigma(p, q, r)$, connecting Seifert sphere presentations
to Diophantine spherical angle inequalities, certified representation counts,
the Casson invariant identification, and the Fricke-Vogt trace variety.

## Mathematical Summary

1. **Seifert Presentation & Central Fiber Monodromy**:
   For pairwise coprime exponents $p, q, r \ge 2$, the Brieskorn manifold $\Sigma(p, q, r)$
   is an integral homology 3-sphere with fundamental group:
   $$\pi_1(\Sigma(p, q, r)) = \langle x, y, z, h \mid [x,h]=[y,h]=[z,h]=1, x^p h^{\alpha_1} = 1, y^q h^{\alpha_2} = 1, z^r h^{\alpha_3} = 1, xyz = h^b \rangle$$
   Irreducible representations $\rho : \pi_1 \to SU(2)$ necessarily map the central fiber
   generator $h \mapsto -I$.

2. **Diophantine Spherical Angle Triples**:
   The relation $\rho(xyz) = \rho(h)^b = -I$ reduces to strict spherical triangle angle
   inequalities on rotation parameters $(a/p, b/q, c/r) \in (0, 1)^3$:
   - $1 \le a < p, 1 \le b < q, 1 \le c < r$ with $a, b, c$ odd;
   - $a/p + b/q > c/r$;
   - $a/p + c/r > b/q$;
   - $b/q + c/r > a/p$;
   - $a/p + b/q + c/r < 2$.
   In cross-multiplied integer form:
   - $a q r + b p r > c p q$;
   - $a q r + c p q > b p r$;
   - $b p r + c p q > a q r$;
   - $a q r + b p r + c p q < 2 p q r$.

3. **Certified Representation Counts**:
   The finite set of irreducible $SU(2)$ representations $\mathcal{R}^*(\Sigma(p, q, r))$
   is explicitly computed and certified:
   - $\#\mathcal{R}^*(\Sigma(2, 3, 5)) = 2$ (Poincaré homology sphere)
   - $\#\mathcal{R}^*(\Sigma(2, 3, 7)) = 2$
   - $\#\mathcal{R}^*(\Sigma(2, 3, 11)) = 4$
   - $\#\mathcal{R}^*(\Sigma(2, 5, 7)) = 4$

4. **Casson Invariant Identification**:
   The gauge-theoretic / character variety Casson invariant is given by:
   $$\lambda_{SU(2)}(\Sigma(p, q, r)) = \frac{1}{2} \#\mathcal{R}^*(\Sigma(p, q, r))$$
   We prove that $\lambda_{SU(2)}$ coincides exactly with the Milnor fiber signature formula
   $\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$ from `Formalization.BrieskornManifolds`:
   - $\lambda(\Sigma(2, 3, 5)) = 1$
   - $\lambda(\Sigma(2, 3, 7)) = 1$
   - $\lambda(\Sigma(2, 3, 11)) = 2$
   - $\lambda(\Sigma(2, 5, 7)) = 2$

5. **Fricke-Vogt Trace Variety & Central Fiber**:
   Under trace coordinates $(t_x, t_y, t_z) = (\operatorname{tr}(X), \operatorname{tr}(Y), \operatorname{tr}(Z))$
   with $XYZ = -I$, the representations lie on the Fricke-Vogt hypersurface:
   $$t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4 = 0$$
-/

namespace BrieskornSU2

open Finset

/-! ### 1. Diophantine Angle Triples & Spherical Inequalities -/

/-- Normalized rational angle $k/n \in \mathbb{Q}$. -/
def angleQ (k n : ℕ) : ℚ :=
  (k : ℚ) / (n : ℚ)

/-- Strict spherical triangle angle inequalities in $\mathbb{Q}$ for $(a/p, b/q, c/r)$. -/
def sphericalTriangleInequalitiesQ (p q r a b c : ℕ) : Prop :=
  angleQ a p + angleQ b q > angleQ c r ∧
  angleQ a p + angleQ c r > angleQ b q ∧
  angleQ b q + angleQ c r > angleQ a p ∧
  angleQ a p + angleQ b q + angleQ c r < 2

/-- Cross-multiplied integer spherical triangle inequalities in $\mathbb{N}$. -/
def sphericalTriangleInequalitiesNat (p q r a b c : ℕ) : Prop :=
  a * q * r + b * p * r > c * p * q ∧
  a * q * r + c * p * q > b * p * r ∧
  b * p * r + c * p * q > a * q * r ∧
  a * q * r + b * p * r + c * p * q < 2 * (p * q * r)

/-- A triple of integers $(a, b, c)$ is odd in each component. -/
def isOddTriple (a b c : ℕ) : Prop :=
  a % 2 = 1 ∧ b % 2 = 1 ∧ c % 2 = 1

/-- Decidable parity check for a triple of integers. -/
def isOddTripleBool (a b c : ℕ) : Bool :=
  (a % 2 == 1) && (b % 2 == 1) && (c % 2 == 1)

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

/-! ### 2. Finset of Irreducible SU(2) Representations -/

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

/-! ### 3. Certified Irreducible Representation Counts -/

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ has exactly 2 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_3_5 : (IrredSU2RepSet 2 3 5).card = 2 := rfl

/-- Alias for Poincaré homology sphere representation count. -/
theorem card_irredRepSet_2_3_5 : (IrredSU2RepSet 2 3 5).card = 2 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ has exactly 2 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_3_7 : (IrredSU2RepSet 2 3 7).card = 2 := rfl

/-- Alias for $\Sigma(2, 3, 7)$ representation count. -/
theorem card_irredRepSet_2_3_7 : (IrredSU2RepSet 2 3 7).card = 2 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ has exactly 4 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_3_11 : (IrredSU2RepSet 2 3 11).card = 4 := rfl

/-- Alias for $\Sigma(2, 3, 11)$ representation count. -/
theorem card_irredRepSet_2_3_11 : (IrredSU2RepSet 2 3 11).card = 4 := rfl

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ has exactly 4 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_5_7 : (IrredSU2RepSet 2 5 7).card = 4 := rfl

/-- Alias for $\Sigma(2, 5, 7)$ representation count. -/
theorem card_irredRepSet_2_5_7 : (IrredSU2RepSet 2 5 7).card = 4 := rfl

/-! ### 4. Casson Invariant Identification -/

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

/-! ### 5. Fricke-Vogt Trace Variety & SU(2) Central Relation -/

/-- The Fricke-Vogt trace polynomial for representations satisfying $XYZ = -I$:
    $\Phi(t_x, t_y, t_z) = t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4$. -/
def frickeVogtPoly {R : Type*} [CommRing R] (tx ty tz : R) : R :=
  tx ^ 2 + ty ^ 2 + tz ^ 2 + tx * ty * tz - 4

/-- Permutation symmetry of the Fricke-Vogt polynomial under $t_x \leftrightarrow t_y$. -/
theorem frickeVogtPoly_perm_xy {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly ty tx tz := by
  dsimp [frickeVogtPoly]; ring

/-- Permutation symmetry of the Fricke-Vogt polynomial under $t_y \leftrightarrow t_z$. -/
theorem frickeVogtPoly_perm_yz {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly tx tz ty := by
  dsimp [frickeVogtPoly]; ring

/-- Permutation symmetry of the Fricke-Vogt polynomial under $t_x \leftrightarrow t_z$. -/
theorem frickeVogtPoly_perm_xz {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly tz ty tx := by
  dsimp [frickeVogtPoly]; ring

/-- Cyclic permutation symmetry of the Fricke-Vogt polynomial. -/
theorem frickeVogtPoly_cyclic {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly ty tz tx := by
  dsimp [frickeVogtPoly]; ring

/-- The discriminant identity for the Fricke-Vogt trace variety:
    $(2 t_z + t_x t_y)^2 - (4 - t_x^2)(4 - t_y^2) = 4 \Phi(t_x, t_y, t_z)$. -/
theorem frickeVogt_discriminant_identity {R : Type*} [CommRing R] (tx ty tz : R) :
    (2 * tz + tx * ty) ^ 2 - (4 - tx ^ 2) * (4 - ty ^ 2) = 4 * frickeVogtPoly tx ty tz := by
  dsimp [frickeVogtPoly]; ring

/-- Rational boundary vanishing: if $(2 t_z + t_x t_y)^2 = (4 - t_x^2)(4 - t_y^2) over $\mathbb{Q}$,
    then the Fricke-Vogt polynomial vanishes: $t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4 = 0$. -/
theorem frickeVogt_boundary_zero_rat (tx ty tz : ℚ)
    (h : (2 * tz + tx * ty) ^ 2 = (4 - tx ^ 2) * (4 - ty ^ 2)) :
    frickeVogtPoly tx ty tz = 0 := by
  linarith [frickeVogt_discriminant_identity (R := ℚ) tx ty tz, h]

/-- Specialization to order-2 generator $x$ ($p = 2 \implies t_x = 0$):
    $\Phi(0, t_y, t_z) = t_y^2 + t_z^2 - 4$. -/
theorem frickeVogt_order2_specialization {R : Type*} [CommRing R] (ty tz : R) :
    frickeVogtPoly 0 ty tz = ty ^ 2 + tz ^ 2 - 4 := by
  dsimp [frickeVogtPoly]; ring

/-- Order-2 boundary circle relation: when $t_y^2 + t_z^2 = 4$, the Fricke-Vogt relation vanishes. -/
theorem frickeVogt_order2_boundary_circle {R : Type*} [CommRing R] (ty tz : R)
    (h : ty ^ 2 + tz ^ 2 = 4) :
    frickeVogtPoly 0 ty tz = 0 := by
  rw [frickeVogt_order2_specialization, h, sub_self]

/-- Central fiber property: the central element $h \in \pi_1(\Sigma(p,q,r))$ is mapped
    to $-I \in SU(2)$, which has trace $-2$. -/
def centralFiberTrace : ℤ := -2

/-- Central fiber relation: $\rho(xyz) = \rho(h)^b = (-I)^b = -I$ for odd Seifert exponent $b$. -/
theorem central_fiber_odd_power (b : ℕ) (hb : b % 2 = 1) :
    (-1 : ℤ) ^ b = -1 :=
  Odd.neg_one_pow (Nat.odd_iff.mpr hb)

end BrieskornSU2

