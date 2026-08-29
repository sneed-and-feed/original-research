/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornSU2CharacterVariety.Basic
import Formalization.BrieskornSU2CharacterVariety.SphericalAngles
import Formalization.BrieskornSU2CharacterVariety.RepresentationCounts
import Formalization.BrieskornSU2CharacterVariety.CassonInvariant
import Formalization.BrieskornSU2CharacterVariety.FrickeVogt
import Formalization.BrieskornSU2CharacterVariety.ChernSimons

/-!
# SU(2) Character Varieties, Diophantine Angles & Casson Invariant Suite

This master module aggregates the complete formalization of the theory of irreducible
$SU(2)$ character varieties for Brieskorn homology 3-spheres $\Sigma(p, q, r)$, connecting
Seifert sphere presentations to Diophantine spherical triangle angle inequalities, certified
representation counts, the gauge-theoretic Casson invariant identification, the Fricke-Vogt
trace variety, and the exact Chern-Simons actions / Lawrence-Zagier false theta invariants.

## Mathematical Overview

### 1. Seifert Presentation & Central Fiber Monodromy
For pairwise coprime exponents $p, q, r \ge 2$, the Brieskorn manifold $\Sigma(p, q, r)$ is
an integral homology 3-sphere with fundamental group:
$$\pi_1(\Sigma(p, q, r)) = \langle x, y, z, h \mid [x,h]=[y,h]=[z,h]=1, x^p h^{\alpha_1} = 1, y^q h^{\alpha_2} = 1, z^r h^{\alpha_3} = 1, xyz = h^b \rangle$$
Irreducible representations $\rho : \pi_1 \to SU(2)$ necessarily map the central fiber
generator $h \mapsto -I$.

### 2. Diophantine Spherical Angle Triples
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

### 3. Certified Representation Counts
The finite set of irreducible $SU(2)$ representations $\mathcal{R}^*(\Sigma(p, q, r))$ is
explicitly computed and certified via native decision procedures:
- $\#\mathcal{R}^*(\Sigma(2, 3, 5)) = 2$ (Poincaré homology sphere)
- $\#\mathcal{R}^*(\Sigma(2, 3, 7)) = 2$
- $\#\mathcal{R}^*(\Sigma(2, 3, 11)) = 4$
- $\#\mathcal{R}^*(\Sigma(2, 5, 7)) = 4$

### 4. Casson Invariant Identification
The gauge-theoretic / character variety Casson invariant is given by:
$$\lambda_{SU(2)}(\Sigma(p, q, r)) = \frac{1}{2} \#\mathcal{R}^*(\Sigma(p, q, r))$$
We prove that $\lambda_{SU(2)}$ coincides exactly with the Milnor fiber signature formula
$\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|$ from `Formalization.BrieskornManifolds`:
- $\lambda(\Sigma(2, 3, 5)) = 1$
- $\lambda(\Sigma(2, 3, 7)) = 1$
- $\lambda(\Sigma(2, 3, 11)) = 2$
- $\lambda(\Sigma(2, 5, 7)) = 2$

### 5. Fricke-Vogt Trace Variety & Central Fiber
Under trace coordinates $(t_x, t_y, t_z) = (\operatorname{tr}(X), \operatorname{tr}(Y), \operatorname{tr}(Z))$
with $XYZ = -I$, representations lie on the Fricke-Vogt hypersurface:
$$\Phi(t_x, t_y, t_z) = t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4 = 0$$
satisfying the discriminant identity:
$$(2 t_z + t_x t_y)^2 - (4 - t_x^2)(4 - t_y^2) = 4 \Phi(t_x, t_y, t_z)$$

### 6. Chern-Simons Action & Lawrence-Zagier / Hikami False Theta Invariants
For rotation parameters $(a, b, c)$, the exact Chern-Simons action is:
$$CS(p, q, r; a, b, c) = -\frac{(a q r + b p r + c p q - p q r)^2}{4 p q r} \in \mathbb{Q}$$
- For $\Sigma(2, 3, 5)$: representations $(1, 1, 1)$ and $(1, 1, 3)$ yield $CS = -1/120$ and $-169/120$.
- For $\Sigma(2, 3, 7)$: representations $(1, 1, 3)$ and $(1, 1, 5)$ yield $CS = -121/168$ and $-529/168$.
- For $\Sigma(2, 3, 11)$: representations yield $CS = -49/264, -361/264, -961/264, -1849/264$.
- For $\Sigma(2, 5, 7)$: representations yield $CS = -81/280, -289/280, -1369/280, -3249/280$.
- Discrete Chern-Simons sums $\sum_{\rho \in \mathcal{R}^*} CS(\rho)$ are $-17/12, -325/84, -805/66, -1247/70$.
- The Lawrence-Zagier character $\chi_{120}$ satisfies $\chi_{120}(n + 120) = \chi_{120}(n)$ and
  $\chi_{120}(60 - n) = -\chi_{120}(n)$, with rational false theta exponents $\Delta(n) = \frac{n^2-1}{120}$
  matching the Chern-Simons action via $-\Delta(n) - 1/120 = -n^2/120 = CS(2, 3, 5; a, b, c)$.

## Module Tree Structure

1. **`Formalization.BrieskornSU2CharacterVariety.Basic`**:
   - `angleQ`: Normalized rational angle $k/n \in \mathbb{Q}$.
   - `sphericalTriangleInequalitiesQ`: Strict spherical triangle inequalities in $\mathbb{Q}$.
   - `sphericalTriangleInequalitiesNat`: Cross-multiplied integer form in $\mathbb{N}$.
   - `isOddTriple`, `isOddTripleBool`: Parity condition that $a, b, c$ are all odd.
   - `centralFiberTrace`: Trace $\operatorname{tr}(-I) = -2$.
   - `central_fiber_odd_power`: Parity evaluation $(-1)^b = -1$ for odd Seifert exponent $b$.

2. **`Formalization.BrieskornSU2CharacterVariety.SphericalAngles`**:
   - `IsSphericalAngleTriple`, `IsDiophantineAngleTriple`: Diophantine spherical angle predicate.
   - `isSphericalAngleBool`: Decidable boolean filter.
   - `sphericalAngleTriple_odd_sum`: Odd sum parity lemma.
   - `candidateRepFinset`: Cartesian product search space $\prod_{i=1}^3 [1, p_i - 1]$.
   - `candidateRepFinset_card`: Search space cardinality $(p - 1)(q - 1)(r - 1)$.
   - `IrredSU2RepSet`: Filtered finset of irreducible $SU(2)$ representations.
   - `irredRepCount`: Representation count $\#\mathcal{R}^*(\Sigma(p, q, r))$.

3. **`Formalization.BrieskornSU2CharacterVariety.RepresentationCounts`**:
   - `card_irred_su2_2_3_5`, `card_irredRepSet_2_3_5`: $\#\mathcal{R}^*(\Sigma(2, 3, 5)) = 2$.
   - `card_irred_su2_2_3_7`, `card_irredRepSet_2_3_7`: $\#\mathcal{R}^*(\Sigma(2, 3, 7)) = 2$.
   - `card_irred_su2_2_3_11`, `card_irredRepSet_2_3_11`: $\#\mathcal{R}^*(\Sigma(2, 3, 11)) = 4$.
   - `card_irred_su2_2_5_7`, `card_irredRepSet_2_5_7`: $\#\mathcal{R}^*(\Sigma(2, 5, 7)) = 4$.

4. **`Formalization.BrieskornSU2CharacterVariety.CassonInvariant`**:
   - `cassonSU2`, `cassonFromSU2`, `cassonFromSU2Rat`: Gauge-theoretic Casson invariant definitions.
   - `cassonSU2_2_3_5`, `cassonSU2_2_3_7`, `cassonSU2_2_3_11`, `cassonSU2_2_5_7`: Specific values.
   - `casson_su2_eq_brieskorn_2_3_5`, `casson_su2_eq_brieskorn_2_3_7`, `casson_su2_eq_brieskorn_2_3_11`,
     `casson_su2_eq_brieskorn_2_5_7`: Integer agreement with Milnor signature Casson invariant.
   - `cassonRat_su2_eq_brieskorn_2_3_5`, `cassonRat_su2_eq_brieskorn_2_3_7`, `cassonRat_su2_eq_brieskorn_2_3_11`,
     `cassonRat_su2_eq_brieskorn_2_5_7`: Rational agreement with Milnor signature Casson invariant.

5. **`Formalization.BrieskornSU2CharacterVariety.FrickeVogt`**:
   - `frickeVogtPoly`: Classical Fricke-Vogt trace polynomial $\Phi(t_x, t_y, t_z)$.
   - `frickeVogtPoly_perm_xy`, `frickeVogtPoly_perm_yz`, `frickeVogtPoly_perm_xz`, `frickeVogtPoly_cyclic`:
     Permutation and cyclic symmetries.
   - `frickeVogt_discriminant_identity`: Discriminant algebraic identity.
   - `frickeVogt_boundary_zero_rat`: Vanishing on discriminant boundary.
   - `frickeVogt_order2_specialization`, `frickeVogt_order2_boundary_circle`: Specialization to $p = 2$.

6. **`Formalization.BrieskornSU2CharacterVariety.ChernSimons`**:
   - `chernSimonsNum`, `chernSimonsRat`, `chernSimonsModInt`, `chernSimonsModOne`: Chern-Simons action definitions.
   - `irredRepSet_2_3_5_eq`, `irredRepSet_2_3_7_eq`, `irredRepSet_2_3_11_eq`, `irredRepSet_2_5_7_eq`: Explicit sets.
   - `chernSimons_2_3_5_rep1`, `chernSimons_2_3_5_rep2`: Poincaré sphere evaluations $(-1/120, -169/120)$.
   - `chernSimons_2_3_7_rep1`, `chernSimons_2_3_7_rep2`: $\Sigma(2, 3, 7)$ evaluations $(-121/168, -529/168)$.
   - `chernSimons_2_3_11_rep1`..`rep4`: $\Sigma(2, 3, 11)$ evaluations $(-49/264, -361/264, -961/264, -1849/264)$.
   - `chernSimons_2_5_7_rep1`..`rep4`: $\Sigma(2, 5, 7)$ evaluations $(-81/280, -289/280, -1369/280, -3249/280)$.
   - `chernSimonsSumRat_2_3_5`, `chernSimonsSumRat_2_3_7`, `chernSimonsSumRat_2_3_11`, `chernSimonsSumRat_2_5_7`: Sums.
   - `chi120`: Lawrence-Zagier Dirichlet-type false theta character of period 120.
   - `chi120_periodic_60`, `chi120_periodic_120`, `chi120_neg`: Periodicity and reflection antisymmetry.
   - `falseThetaExpRat`, `falseThetaExp_1`, `falseThetaExp_11`, `falseThetaExp_13`, `falseThetaExp_19`, `falseThetaExp_29`: Exponents.
   - `cs_eq_falseThetaExp_rel`, `cs_2_3_5_rep1_falseTheta_match`, `cs_2_3_5_rep2_falseTheta_match`: Chern-Simons matching.

## Historical References

- Casson, A. (1985). *Three-manifold invariants by gauge theory and representation spaces*.
- Fintushel, R., & Stern, R. J. (1990). *Instanton homology of Seifert fibred homology three spheres*.
  Proceedings of the London Mathematical Society, 61(1), 109–137.
- Fricke, R., & Klein, F. (1897). *Vorlesungen über die Theorie der automorphen Functionen*. Teubner.
- Hikami, K. (2003). *Quantum Invariants, Modular Forms, and Mock Theta Functions*.
  Letters in Mathematical Physics, 65(2), 105–123.
- Kirk, P. A., & Klassen, E. P. (1990). *Chern-Simons invariants of 3-manifolds and representation spaces of knot groups*.
  Mathematische Annalen, 287(1), 343–367.
- Lawrence, R., & Zagier, D. (1999). *Modular forms and quantum invariants of 3-manifolds*.
  Asian Journal of Mathematics, 3(1), 93–108.
- Vogt, H. (1889). *Sur les invariants fondamentaux des équations différentielles linéaires du second ordre*.
  Annales Scientifiques de l'École Normale Supérieure, 6, 3–72.
- Brieskorn, E. (1966). *Beispiele zur Differentialtopologie von Singularitäten*. Inventiones Mathematicae, 2(1), 1–14.
- Milnor, J. (1968). *Singular Points of Complex Hypersurfaces*. Annals of Mathematics Studies, PUP.
-/
