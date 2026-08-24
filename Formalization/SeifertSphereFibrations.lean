import Formalization.SeifertSphereFibrations.Basic
import Formalization.SeifertSphereFibrations.CoprimeSolvability
import Formalization.SeifertSphereFibrations.CanonicalFamilies
import Formalization.SeifertSphereFibrations.CompactThreePoint

/-!
# Diophantine Classification of Sphere-Yielding Seifert Fibrations

This root aggregator module formalizes the Diophantine classification of sphere-yielding
Seifert fibrations over 2-orbifold bases with a cusp $S^2(a_1, a_2, \infty)$ and compact
3-point Seifert fibered homology spheres over $S^2(a_1, a_2, a_3)$.

## Mathematical Overview

### 1. Two-Orbifold Point + 1 Cusp Seifert Invariants
A Seifert fibered 3-manifold with base orbifold $S^2(a_1, a_2, \infty)$ (two conical singularities
with cone angles $2\pi/a_1, 2\pi/a_2$ and one parabolic cusp) has fundamental group presentation
governed by the central Seifert invariant:
$$O(a_1, a_2; \ell_0, \ell_1, \ell_2) = a_1 a_2 \ell_0 - a_2 \ell_1 - a_1 \ell_2$$
The manifold is a homotopy sphere (or trivial fundamental group contractible cycle) if and only if:
$$|O(a_1, a_2; \ell_0, \ell_1, \ell_2)| = 1$$

### 2. Main Theorems

1. **Coprime Solvability / Bézout Existence (`coprime_exists_sphere`)**:
   For any integers $a_1, a_2$ with $\gcd(a_1, a_2) = 1$, there exist integer translation twists
   $(\ell_0, \ell_1, \ell_2)$ such that $|O(a_1, a_2; \ell_0, \ell_1, \ell_2)| = 1$, explicitly constructed
   via Bézout coefficients $(\ell_0, \ell_1, \ell_2) = (0, -\operatorname{gcdB}(a_1, a_2), -\operatorname{gcdA}(a_1, a_2))$.

2. **Non-Coprime Obstruction (`noncoprime_obstruction`)**:
   If $d > 1$ divides both $a_1$ and $a_2$, then $d \mid O(a_1, a_2; \ell_0, \ell_1, \ell_2)$ for all
   translation twists $(\ell_0, \ell_1, \ell_2)$, precluding any homotopy sphere solutions.

3. **Canonical Hyperbolic Triangle Families**:
   Explicit sphere-yielding solutions for the canonical modular/hyperbolic families:
   - $(2, 3, \infty)$ with $(0, 1, -1) \implies |6(0) - 3(1) - 2(-1)| = |-1| = 1$.
   - $(3, 4, \infty)$ with $(0, 1, -1) \implies |12(0) - 4(1) - 3(-1)| = |-1| = 1$.
   - $(2, 5, \infty)$ with $(0, 1, -2) \implies |10(0) - 5(1) - 2(-2)| = |-1| = 1$.
   - $(3, 5, \infty)$ with $(0, 1, -2) \implies |15(0) - 5(1) - 3(-2)| = |1| = 1$.

4. **Extension to 3-Point Compact Seifert Fibrations (`pairwise_coprime_exists_sphere3`)**:
   For compact Seifert fibrations over $S^2(a_1, a_2, a_3)$, the order formula:
   $$O_3(a_1, a_2, a_3; \ell_0, \ell_1, \ell_2, \ell_3) = a_1 a_2 a_3 \ell_0 - a_2 a_3 \ell_1 - a_1 a_3 \ell_2 - a_1 a_2 \ell_3$$
   admits a sphere solution if $(a_1, a_2, a_3)$ are pairwise coprime.
   This covers the classical Brieskorn spheres $\Sigma(2, 3, 5)$ and $\Sigma(2, 3, 7)$.

## Module Architecture & Index

This module is organized into the following submodules:

1. `Formalization.SeifertSphereFibrations.Basic`:
   - `SeifertFibration.seifertOrder`: Order formula $a_1 a_2 \ell_0 - a_2 \ell_1 - a_1 \ell_2$.
   - `SeifertFibration.IsHomotopySphere`: Homotopy sphere predicate.
   - `SeifertFibration.coprimeWitnesses`: Explicit Bézout witness constructor.
   - `SeifertFibration.seifertOrder_bezout`: Order evaluation to $\gcd(a_1, a_2)$.
   - `SeifertFibration.seifertOrder_coprimeWitnesses`: Evaluation theorem on witnesses.

2. `Formalization.SeifertSphereFibrations.CoprimeSolvability`:
   - `SeifertFibration.coprime_exists_sphere`: Solvability theorem when $\gcd(a_1, a_2) = 1$.
   - `SeifertFibration.coprime_witnesses_isHomotopySphere`: Constructive certification.
   - `SeifertFibration.coprime_natAbs_exists_sphere`: Nat.Coprime formulation.
   - `SeifertFibration.dvd_seifertOrder`: Common divisor divisibility lemma.
   - `SeifertFibration.not_dvd_one_of_gt_one`, `SeifertFibration.not_dvd_neg_one_of_gt_one`: Non-divisibility lemmas.
   - `SeifertFibration.noncoprime_obstruction`: Homotopy sphere obstruction for non-coprime orders.

3. `Formalization.SeifertSphereFibrations.CanonicalFamilies`:
   - `SeifertFibration.sphere_2_3_infty`: Solution for $(2, 3, \infty)$.
   - `SeifertFibration.sphere_3_4_infty`: Solution for $(3, 4, \infty)$.
   - `SeifertFibration.sphere_2_5_infty`: Solution for $(2, 5, \infty)$.
   - `SeifertFibration.sphere_3_5_infty`: Solution for $(3, 5, \infty)$.

4. `Formalization.SeifertSphereFibrations.CompactThreePoint`:
   - `SeifertFibration.seifertOrder3`: Order formula for 3-point compact fibrations.
   - `SeifertFibration.IsHomotopySphere3`: Homotopy sphere predicate for 3-point fibrations.
   - `SeifertFibration.coprime_mul_of_coprime_pair`: Coprimality lemma.
   - `SeifertFibration.seifertOrder3_bezout`: Iterated Bézout evaluation formula.
   - `SeifertFibration.pairwise_coprime_exists_sphere3`: Pairwise coprime existence theorem.
   - `SeifertFibration.dvd_seifertOrder3_of_dvd_12`: Divisibility lemma for 3-point fibrations.
   - `SeifertFibration.noncoprime_obstruction3_12`: Non-coprime obstruction theorem for 3-point fibrations.
   - `SeifertFibration.brieskorn_sphere_2_3_5`: Poincaré sphere $\Sigma(2, 3, 5)$.
   - `SeifertFibration.brieskorn_sphere_2_3_7`: Brieskorn sphere $\Sigma(2, 3, 7)$.

## References

- Brieskorn, E. (1966). *Beispiele zur Differentialtopologie von Singularitäten*. Inventiones Mathematicae, 2(1), 1–14.
- Milnor, J. (1975). *On the 3-dimensional Brieskorn manifolds $M(p,q,r)$*. Annals of Mathematics Studies, 84, 175–225.
- Neumann, W. D. (1981). *A calculus for plumbing applied to the topology of complex surface singularities and degenerating complex curves*. Transactions of the American Mathematical Society, 268(2), 299–344.
- Seifert, H. (1933). *Topologie dreidimensionaler gefaserter Räume*. Acta Mathematica, 60(1), 147–238.
-/
