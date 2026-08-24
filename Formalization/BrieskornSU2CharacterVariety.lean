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

/-!
# SU(2) Character Varieties, Diophantine Angles & Casson Invariant Suite

This master module aggregates the complete formalization of the theory of irreducible
$SU(2)$ character varieties for Brieskorn homology 3-spheres $\Sigma(p, q, r)$, connecting
Seifert sphere presentations to Diophantine spherical triangle angle inequalities, certified
representation counts, the gauge-theoretic Casson invariant identification, and the Fricke-Vogt
trace variety.

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

## Historical References

- Casson, A. (1985). *Three-manifold invariants by gauge theory and representation spaces*.
- Fintushel, R., & Stern, R. J. (1990). *Instanton homology of Seifert fibred homology three spheres*.
  Proceedings of the London Mathematical Society, 61(1), 109–137.
- Fricke, R., & Klein, F. (1897). *Vorlesungen über die Theorie der automorphen Functionen*. Teubner.
- Vogt, H. (1889). *Sur les invariants fondamentaux des équations différentielles linéaires du second ordre*.
  Annales Scientifiques de l'École Normale Supérieure, 6, 3–72.
- Brieskorn, E. (1966). *Beispiele zur Differentialtopologie von Singularitäten*. Inventiones Mathematicae, 2(1), 1–14.
- Milnor, J. (1968). *Singular Points of Complex Hypersurfaces*. Annals of Mathematics Studies, PUP.
-/
