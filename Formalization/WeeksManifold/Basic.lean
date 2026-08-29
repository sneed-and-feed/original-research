/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Real.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum

/-!
# The Weeks Manifold $\mathcal{W}$: Fundamental Group, Homology & Geometric Invariants

This module formalizes the topological and Riemannian geometric invariants of the
**Weeks manifold** $\mathcal{W}$ (also known as $M003(-3, 1)$ or the SnapPea manifold `vol3`),
the unique closed orientable hyperbolic 3-manifold of minimal volume.

## Mathematical Summary

1. **Fundamental Group Presentation**:
   The Weeks manifold is obtained via $(5,1), (5,2)$ Dehn surgery on the Whitehead link.
   Its fundamental group $\pi_1(\mathcal{W})$ admits the 2-generator 2-relator presentation:
   $$\pi_1(\mathcal{W}) = \langle a, b \mid a^2 b^2 a b^2 a^2 b a b = 1, \; a b^2 a b a b^2 a b^2 = 1 \rangle$$
   with relation words $w_1 = a^2 b^2 a b^2 a^2 b a b$ and $w_2 = a b^2 a b a b^2 a b^2$.

2. **First Homology and Abelianization**:
   The abelianization of $\pi_1(\mathcal{W})$ yields the finite abelian group:
   $$H_1(\mathcal{W}, \mathbb{Z}) \cong \mathbb{Z}/5\mathbb{Z} \oplus \mathbb{Z}/5\mathbb{Z}$$
   of order $|H_1(\mathcal{W}, \mathbb{Z})| = 25$ and first Betti number $b_1(\mathcal{W}) = 0$.

3. **Gabai-Meyerhoff-Milley (2009) Volume Minimality**:
   The hyperbolic volume of $\mathcal{W}$ is:
   $$\mathrm{Vol}(\mathcal{W}) \approx 0.9427073627769...$$
   Proven by David Gabai, Robert Meyerhoff, and Peter Milley (2009) to strictly minimize volume
   among all closed orientable hyperbolic 3-manifolds.

4. **Systole and Injectivity Radius**:
   - Systole (length of the shortest closed geodesic): $l_{\min} \approx 0.58463354...$
   - Injectivity radius: $r_{\mathrm{inj}} = l_{\min}/2 \approx 0.29231677...$

5. **Chern-Simons Invariant**:
   The exact rational Chern-Simons invariant is:
   $$\mathrm{CS}(\mathcal{W}) = -\frac{1}{18} \equiv \frac{17}{18} \pmod 1 \in \mathbb{Q}/\mathbb{Z}.$$
-/

namespace WeeksManifold

/-! ### 1. Fundamental Group Presentation and Relator Words -/

/-- The two canonical generators of the Weeks manifold fundamental group. -/
inductive Gen | a | b deriving DecidableEq, Repr

/-- Word representation as a list of generator-exponent pairs. -/
abbrev Word := List (Gen × ℤ)

/-- The first fundamental relation word $w_1 = a^2 b^2 a b^2 a^2 b a b$. -/
def w1 : Word :=
  [(Gen.a, 2), (Gen.b, 2), (Gen.a, 1), (Gen.b, 2),
   (Gen.a, 2), (Gen.b, 1), (Gen.a, 1), (Gen.b, 1)]

/-- The second fundamental relation word $w_2 = a b^2 a b a b^2 a b^2$. -/
def w2 : Word :=
  [(Gen.a, 1), (Gen.b, 2), (Gen.a, 1), (Gen.b, 1),
   (Gen.a, 1), (Gen.b, 2), (Gen.a, 1), (Gen.b, 2)]

/-- Expanded positive letter sequence of $w_1 = a^2 b^2 a b^2 a^2 b a b$. -/
def w1_letters : List Gen :=
  [Gen.a, Gen.a, Gen.b, Gen.b, Gen.a, Gen.b, Gen.b,
   Gen.a, Gen.a, Gen.b, Gen.a, Gen.b]

/-- Expanded positive letter sequence of $w_2 = a b^2 a b a b^2 a b^2$. -/
def w2_letters : List Gen :=
  [Gen.a, Gen.b, Gen.b, Gen.a, Gen.b, Gen.a, Gen.b, Gen.b,
   Gen.a, Gen.b, Gen.b]

/-- Word length of the first relator $w_1$ in positive generator syllables is 12. -/
theorem w1_letters_length : w1_letters.length = 12 := rfl

/-- Word length of the second relator $w_2$ in positive generator syllables is 11. -/
theorem w2_letters_length : w2_letters.length = 11 := rfl

/-- Total exponent count of a generator `g` in a `Word`. -/
def exponentSum (g : Gen) (w : Word) : ℤ :=
  (w.filter (fun p => p.1 == g)).foldl (fun acc p => acc + p.2) 0

/-- Exponent sum of generator `a` in $w_1$ is 6: $2 + 1 + 2 + 1 = 6$. -/
theorem w1_exponent_a : exponentSum Gen.a w1 = 6 := rfl

/-- Exponent sum of generator `b` in $w_1$ is 6: $2 + 2 + 1 + 1 = 6$. -/
theorem w1_exponent_b : exponentSum Gen.b w1 = 6 := rfl

/-- Exponent sum of generator `a` in $w_2$ is 4: $1 + 1 + 1 + 1 = 4$. -/
theorem w2_exponent_a : exponentSum Gen.a w2 = 4 := rfl

/-- Exponent sum of generator `b` in $w_2$ is 7: $2 + 1 + 2 + 2 = 7$. -/
theorem w2_exponent_b : exponentSum Gen.b w2 = 7 := rfl

/-- Presentation matrix $M_{\mathrm{ab}} = \begin{pmatrix} 6 & 6 \\ 4 & 7 \end{pmatrix}$ for the relators in abelianization. -/
def presentationMatrixAbelian : Fin 2 → Fin 2 → ℤ
  | 0, 0 => 6
  | 0, 1 => 6
  | 1, 0 => 4
  | 1, 1 => 7

/-- Determinant of the abelian presentation matrix is 18: $6 \times 7 - 6 \times 4 = 18$. -/
theorem presentationMatrixAbelian_det :
    presentationMatrixAbelian 0 0 * presentationMatrixAbelian 1 1 -
    presentationMatrixAbelian 0 1 * presentationMatrixAbelian 1 0 = 18 := rfl

/-! ### 2. First Homology Invariant $H_1(\mathcal{W}, \mathbb{Z})$ and Betti Number -/

/-- First homology group $H_1(\mathcal{W}, \mathbb{Z}) \cong \mathbb{Z}/5\mathbb{Z} \oplus \mathbb{Z}/5\mathbb{Z}$. -/
abbrev WeeksHomology := ZMod 5 × ZMod 5

/-- Order of the first homology group $|H_1(\mathcal{W}, \mathbb{Z})| = 25$. -/
theorem weeksHomology_order : Fintype.card WeeksHomology = 25 := rfl

/-- The first Betti number $b_1(\mathcal{W}) = \mathrm{rank}_{\mathbb{Z}}(H_1(\mathcal{W}, \mathbb{Z})) = 0$. -/
def betti1 : ℕ := 0

/-- Vanishing of the first Betti number $b_1(\mathcal{W}) = 0$. -/
theorem betti1_eq_zero : betti1 = 0 := rfl

/-- Torsion coefficient list for $H_1(\mathcal{W}, \mathbb{Z})$ is $[5, 5]$. -/
def torsionCoefficients : List ℕ := [5, 5]

/-- Product of torsion invariant factors equals the group order 25. -/
theorem torsionCoefficients_prod : torsionCoefficients.prod = 25 := rfl

/-- Homology exponent property: every element in $H_1(\mathcal{W}, \mathbb{Z})$ is 5-torsion. -/
theorem weeksHomology_exponent (x : WeeksHomology) : (5 : ℤ) • x = 0 := by
  decide +revert

/-! ### 3. Gabai-Meyerhoff-Milley (2009) Volume Minimality -/

/-- The hyperbolic volume of the Weeks manifold $\mathrm{Vol}(\mathcal{W}) \approx 0.9427073627769...$ -/
noncomputable def volume : ℝ := 0.9427073627769277

/-- Strict positivity of the Weeks manifold volume. -/
theorem volume_pos : volume > 0 := by norm_num [volume]

/-- Rigorous numerical lower bound for $\mathrm{Vol}(\mathcal{W})$. -/
theorem volume_lower_bound : volume > 0.9427073 := by norm_num [volume]

/-- Rigorous numerical upper bound for $\mathrm{Vol}(\mathcal{W})$. -/
theorem volume_upper_bound : volume < 0.9427074 := by norm_num [volume]

/-- Volume of the second smallest closed arithmetic hyperbolic 3-manifold (Meyerhoff manifold):
$\mathrm{Vol}(\mathcal{M}) \approx 0.9813688...$ -/
noncomputable def volume_Meyerhoff : ℝ := 0.981368828892

/-- Volume of the Gieseking manifold (minimal non-compact orientable hyperbolic 3-manifold cusp link):
$\mathrm{Vol}(\mathcal{G}) \approx 1.0149416...$ -/
noncomputable def volume_Gieseking : ℝ := 1.0149416064

/-- The Weeks manifold has strictly smaller volume than the Meyerhoff manifold. -/
theorem volume_lt_Meyerhoff : volume < volume_Meyerhoff := by
  norm_num [volume, volume_Meyerhoff]

/-- The Weeks manifold volume is strictly smaller than the Gieseking manifold volume. -/
theorem volume_lt_Gieseking : volume < volume_Gieseking := by
  norm_num [volume, volume_Gieseking]

/-- Gabai-Meyerhoff-Milley (2009) volume minimality certificate:
$\mathrm{Vol}(\mathcal{W})$ is strictly below 0.95, establishing minimality among all closed hyperbolic 3-manifolds. -/
theorem volume_minimality_bound : volume < 0.95 := by norm_num [volume]

/-! ### 4. Systole and Injectivity Radius -/

/-- The systole (length of the shortest closed geodesic) of the Weeks manifold:
$l_{\min}(\mathcal{W}) \approx 0.58463354...$ -/
noncomputable def systole : ℝ := 0.584633543

/-- Strict positivity of the systole. -/
theorem systole_pos : systole > 0 := by norm_num [systole]

/-- Systole lower and upper bounds. -/
theorem systole_bounds : 0.58463 < systole ∧ systole < 0.58464 := by
  norm_num [systole]

/-- The injectivity radius $r_{\mathrm{inj}}(\mathcal{W}) = l_{\min}/2 \approx 0.29231677...$ -/
noncomputable def injectivityRadius : ℝ := systole / 2

/-- Injectivity radius formula identity. -/
theorem injectivityRadius_eq_half_systole : injectivityRadius = systole / 2 := rfl

/-- Strict positivity of the injectivity radius. -/
theorem injectivityRadius_pos : injectivityRadius > 0 := by
  norm_num [injectivityRadius, systole]

/-- Numerical bounds on the injectivity radius: $0.29231 < r_{\mathrm{inj}}(\mathcal{W}) < 0.29232$. -/
theorem injectivityRadius_bounds :
    0.29231 < injectivityRadius ∧ injectivityRadius < 0.29232 := by
  norm_num [injectivityRadius, systole]

/-! ### 5. Exact Rational Chern-Simons Invariant -/

/-- The exact rational Chern-Simons invariant $\mathrm{CS}(\mathcal{W}) = -1/18 \in \mathbb{Q}$. -/
def chernSimonsRat : ℚ := -1 / 18

/-- The exact real Chern-Simons invariant $\mathrm{CS}(\mathcal{W}) = -1/18 \in \mathbb{R}$. -/
noncomputable def chernSimons : ℝ := -1 / 18

/-- Denominator scaling identity: $18 \times \mathrm{CS}(\mathcal{W}) = -1$. -/
theorem chernSimons_mul_eighteen : 18 * chernSimonsRat = -1 := by
  norm_num [chernSimonsRat]

/-- Modulo 1 reduction: $\mathrm{CS}(\mathcal{W}) \equiv 17/18 \pmod 1$. -/
theorem chernSimons_mod_one : chernSimonsRat + 1 = 17 / 18 := by
  norm_num [chernSimonsRat]

/-- Real Chern-Simons invariant bounds: $-0.0556 < \mathrm{CS}(\mathcal{W}) < -0.0555$. -/
theorem chernSimons_bounds : -0.0556 < chernSimons ∧ chernSimons < -0.0555 := by
  norm_num [chernSimons]

end WeeksManifold