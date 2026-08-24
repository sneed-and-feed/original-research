import Formalization.GeneralSeifertClassification.Cofactors
import Formalization.GeneralSeifertClassification.Solvability
import Formalization.GeneralSeifertClassification.Obstructions
import Formalization.GeneralSeifertClassification.Certificates

/-!
# Universal Diophantine Classification for $k$-Point Seifert Fibrations & Homology Spheres

This root aggregator module formalizes the universal Diophantine classification of sphere-yielding
Seifert fibrations over base 2-orbifolds with an arbitrary number of conical singularities $k \ge 1$.

## Mathematical Background

For a Seifert fibered 3-manifold with base orbifold having $k$ conical points of multiplicities
$a = (a_1, a_2, \dots, a_k) \in \mathbb{Z}^k$ and central/fiber twist parameters
$\ell_0 \in \mathbb{Z}, \ell = (\ell_1, \dots, \ell_k) \in \mathbb{Z}^k$, the fundamental group
presentation gives the central Seifert order invariant:
$$O_k(a; \ell_0, \ell) = \left(\prod_{i=1}^k a_i\right) \ell_0 - \sum_{j=1}^k \left(\prod_{i \ne j} a_i\right) \ell_j$$
Defining the cofactor products $A_j = \prod_{i \ne j} a_i$, the order invariant simplifies to:
$$O_k(a; \ell_0, \ell) = \left(\prod_{i=1}^k a_i\right) \ell_0 - \sum_{j=1}^k A_j \ell_j$$

The 3-manifold is a homology sphere if and only if $|O_k(a; \ell_0, \ell)| = 1$.

## Key Results Formalized

1. **Generalized Seifert Invariants & Cofactors**:
   - `cofactor a j`: $A_j = \prod_{i \ne j} a_i$.
   - `mul_cofactor`: $a_j \cdot A_j = \prod_{i=1}^k a_i$.
   - `seifertOrder a l0 l`: $O_k(a; \ell_0, \ell)$.
   - `IsHomotopySphere a l0 l`: $|O_k(a; \ell_0, \ell)| = 1$.
   - `cofactorGCD a`: $\gcd(A_1, \dots, A_k)$.

2. **Master Diophantine Solvability Theorem (`exists_sphere_iff_cofactorGCD_eq_one`)**:
   $$\exists (\ell_0, \dots, \ell_k) \in \mathbb{Z}^{k+1}, \quad |O_k(a; \ell_0, \ell)| = 1 \iff \gcd(A_1, \dots, A_k) = 1$$

3. **Pairwise Coprimality Sufficiency Theorem (`pairwise_coprime_exists_sphere`)**:
   $$(\forall i \ne j, \gcd(a_i, a_j) = 1) \implies \gcd(A_1, \dots, A_k) = 1 \implies \exists \vec{\ell}, |O_k| = 1$$

4. **Common Divisor Obstruction (`common_divisor_obstruction`, `noncoprime_pair_obstruction`)**:
   If $\gcd(a_i, a_j) = d > 1$ for some pair $i \ne j$, then $d \mid A_m$ for all $m$, so $d \mid O_k$
   for all twists, precluding any homology sphere.

5. **Concrete Family Classifications & Certificates**:
   - 3-point families: Poincaré $\Sigma(2,3,5)$, Brieskorn $\Sigma(2,3,7)$, $\Sigma(2,3,11)$, and non-coprime obstruction $\Sigma(2,4,6)$.
   - 4-point families: $\Sigma(2,3,5,7)$, $\Sigma(2,3,5,11)$, and non-coprime obstruction $\Sigma(2,3,4,5)$.

## Module Architecture & Index

This module is organized into the following submodules:

1. `Formalization.GeneralSeifertClassification.Cofactors`:
   - `GeneralSeifert.cofactor`: Cofactor product $A_j = \prod_{i \ne j} a_i$.
   - `GeneralSeifert.mul_cofactor`, `GeneralSeifert.cofactor_mul`: Multiplicative cofactor identities.
   - `GeneralSeifert.seifertOrder`: Generalized order formula $(\prod a_i)\ell_0 - \sum A_j \ell_j$.
   - `GeneralSeifert.IsHomotopySphere`: Homotopy sphere predicate $|O_k| = 1$.
   - `GeneralSeifert.cofactorGCD`: Greatest common divisor $\gcd(A_1, \dots, A_k)$.
   - `GeneralSeifert.cofactorGCD_nonneg`, `GeneralSeifert.cofactorGCD_dvd`: Positivity and cofactor divisibility.
   - `GeneralSeifert.cofactorGCD_dvd_prod`, `GeneralSeifert.dvd_prod_of_dvd_all_cofactors`: Divisibility of total product.
   - `GeneralSeifert.dvd_seifertOrder_of_dvd_all_cofactors`, `GeneralSeifert.cofactorGCD_dvd_seifertOrder`: Divisibility of order invariant.

2. `Formalization.GeneralSeifertClassification.Solvability`:
   - `GeneralSeifert.exists_sphere_iff_cofactorGCD_eq_one`: Master Diophantine solvability equivalence.
   - `GeneralSeifert.PairwiseCoprime`: Pairwise coprimality predicate.
   - `GeneralSeifert.pairwise_coprime_implies_cofactorGCD_eq_one`: Coprimality implies $\gcd(A_1,\dots,A_k)=1$.
   - `GeneralSeifert.pairwise_coprime_exists_sphere`: Homology sphere existence for pairwise coprime multiplicities.
   - `GeneralSeifert.PairwiseCoprimeLt`, `GeneralSeifert.pairwiseCoprime_iff_pairwiseCoprimeLt`: Ordered coprimality and equivalence.
   - `GeneralSeifert.pairwise_coprime_lt_exists_sphere`: Solvability from ordered pairwise coprimality.

3. `Formalization.GeneralSeifertClassification.Obstructions`:
   - `GeneralSeifert.common_divisor_dvd_cofactor`: Common divisor divides all cofactors.
   - `GeneralSeifert.common_divisor_dvd_cofactorGCD`: Common divisor divides cofactor GCD.
   - `GeneralSeifert.common_divisor_dvd_seifertOrder`: Common divisor divides order invariant for all twists.
   - `GeneralSeifert.common_divisor_obstruction`: Common divisor obstruction theorem.
   - `GeneralSeifert.noncoprime_pair_obstruction`: Non-coprime pair obstruction theorem.

4. `Formalization.GeneralSeifertClassification.Certificates`:
   - `GeneralSeifert.vec3`, `GeneralSeifert.twist3`, `GeneralSeifert.vec4`, `GeneralSeifert.twist4`: Vector constructors.
   - `GeneralSeifert.sphere_3point_2_3_5`: Poincaré sphere certificate $\Sigma(2,3,5)$.
   - `GeneralSeifert.sphere_3point_2_3_7`: Brieskorn sphere certificate $\Sigma(2,3,7)$.
   - `GeneralSeifert.sphere_3point_2_3_11`: Brieskorn sphere certificate $\Sigma(2,3,11)$.
   - `GeneralSeifert.obstruction_3point_2_4_6`: Obstruction certificate for $\Sigma(2,4,6)$.
   - `GeneralSeifert.sphere_4point_2_3_5_7`: 4-point sphere certificate $\Sigma(2,3,5,7)$.
   - `GeneralSeifert.sphere_4point_2_3_5_11`: 4-point sphere certificate $\Sigma(2,3,5,11)$.
   - `GeneralSeifert.obstruction_4point_2_3_4_5`: Obstruction certificate for $\Sigma(2,3,4,5)$.
   - `GeneralSeifert.cofactorList`, `GeneralSeifert.seifertOrderList`, `GeneralSeifert.IsHomotopySphereList`: List-based definitions.
   - `GeneralSeifert.sphere_list_2_3_5`, `GeneralSeifert.sphere_list_2_3_7`, `GeneralSeifert.sphere_list_2_3_5_7`, `GeneralSeifert.sphere_list_2_3_5_11`: List-based certificates.

## References

- Brieskorn, E. (1966). *Beispiele zur Differentialtopologie von Singularitäten*. Inventiones Mathematicae, 2(1), 1–14.
- Milnor, J. (1975). *On the 3-dimensional Brieskorn manifolds $M(p,q,r)$*. Annals of Mathematics Studies, 84, 175–225.
- Neumann, W. D. (1981). *A calculus for plumbing applied to the topology of complex surface singularities and degenerating complex curves*. Transactions of the American Mathematical Society, 268(2), 299–344.
- Seifert, H. (1933). *Topologie dreidimensionaler gefaserter Räume*. Acta Mathematica, 60(1), 147–238.
-/
