/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornManifolds.Basic
import Formalization.BrieskornManifolds.SphereCriterion
import Formalization.BrieskornManifolds.ExoticSpheres
import Formalization.BrieskornManifolds.MilnorSignature

/-!
# Brieskorn Manifolds, Topological Spheres, Exotic 7-Spheres & Casson Invariants

This master root module aggregates the complete formalization of **Brieskorn manifolds**
$\Sigma(a_1, \dots, a_n)$, the **Brieskorn–Hirzebruch sphere criterion** (1966), the 28 exotic
7-spheres of Brieskorn and Milnor–Kervaire in $\Theta_7 \cong \mathbb{Z}/28\mathbb{Z}$, and the
**Casson invariant** formula for Brieskorn homology 3-spheres via the signature of the Milnor fiber
intersection form.

## Mathematical Summary

### 1. Brieskorn Polynomials & Singularity Links
For exponent tuples $a = (a_0, \dots, a_{n-1}) \in \mathbb{N}^n$ with $a_i \ge 2$, the Brieskorn
polynomial is
$$f_a(z) = \sum_{j=0}^{n-1} z_j^{a_j} \in \mathbb{C}[z_0, \dots, z_{n-1}].$$
The affine Brieskorn variety is the hypersurface $V(a) = f_a^{-1}(0) \subset \mathbb{C}^n$, having an
isolated singularity at the origin $0 \in \mathbb{C}^n$. The Brieskorn manifold $\Sigma(a)$ is defined
as the singularity link
$$\Sigma(a) = V(a) \cap S^{2n-1} \subset \mathbb{C}^n,$$
which is a compact, smooth, closed oriented manifold of real dimension $2n - 3$.

### 2. Brieskorn Graph & Sphere Criterion (Brieskorn 1966, Milnor 1968)
The Brieskorn graph $G(a)$ has vertices $\{0, \dots, n-1\}$ and edges between $i \ne j$ whenever
$\gcd(a_i, a_j) > 1$. A vertex $i$ is isolated in $G(a)$ if $\gcd(a_i, a_j) = 1$ for all $j \ne i$.
The Brieskorn–Hirzebruch sphere criterion states that for $n \ge 3$, $\Sigma(a)$ is homeomorphic to
the standard topological sphere $S^{2n-3}$ if:
- $G(a)$ contains at least 2 isolated vertices, OR
- $G(a)$ contains at least 1 isolated vertex and one connected component consisting of an odd
  number of vertices with pairwise $\gcd = 2$.

### 3. The 28 Exotic 7-Spheres of Brieskorn & Milnor–Kervaire
In 1966, Egbert Brieskorn proved that the 1-parameter family in $\mathbb{C}^5$
$$\Sigma(2, 2, 2, 3, 6k - 1) \subset \mathbb{C}^5 \quad (k \ge 1)$$
consists entirely of topological 7-spheres homeomorphic to $S^7$, yet their diffeomorphism types
generate the entire Kervaire–Milnor group of homotopy spheres
$$\Theta_7 \cong b P_8 \cong \mathbb{Z}/28\mathbb{Z}.$$
The smooth invariant $\kappa(k) \equiv k \pmod{28}$ classifies the smooth structure:
- $k = 28$ gives the standard smooth structure $S^7_{\mathrm{std}}$.
- $k \in \{1, \dots, 27\}$ realize all 27 exotic smooth structures.

### 4. Milnor Fiber Signature & Casson Invariant of Brieskorn 3-Spheres
For pairwise coprime triples $(p, q, r)$, $\Sigma(p, q, r)$ is an integral homology 3-sphere.
The Milnor fiber intersection form has signature $\sigma(p, q, r) = N_+ - N_-$, computed via the
interior lattice $I(p, q, r) = (0, p) \times (0, q) \times (0, r)$ and scaled weight function
$S(x, y, z) = x q r + y p r + z p q$.
The Casson invariant satisfies:
$$\lambda(\Sigma(p, q, r)) = \frac{1}{8} |\sigma(p, q, r)|.$$
We certify the classical evaluations:
- $\Sigma(2, 3, 5)$: $\sigma = -8 \implies \lambda = 1$ (Poincaré homology 3-sphere)
- $\Sigma(2, 3, 7)$: $\sigma = -8 \implies \lambda = 1$
- $\Sigma(2, 3, 11)$: $\sigma = -16 \implies \lambda = 2$
- $\Sigma(2, 5, 7)$: $\sigma = -16 \implies \lambda = 2$

## Module Tree Structure & Index

1. **`Formalization.BrieskornManifolds.Basic`**:
   - `brieskornPoly`: Algebraic polynomial $f_a(z) = \sum z_j^{a_j}$.
   - `brieskornHypersurface`: Zero locus $V(a) = f_a^{-1}(0)$.
   - `complexNormSq`, `unitSphere`: Ambient Euclidean metric and unit sphere $S^{2n-1} \subset \mathbb{C}^n$.
   - `BrieskornLink`: Intersection link $\Sigma(a) = V(a) \cap S^{2n-1}$.
   - `linkRealDimension`, `linkDimension_five`, `linkDimension_three`: Dimension identities $\dim_{\mathbb{R}} \Sigma(a) = 2n-3$.
   - `brieskornGraphEdge`: Graph edge relation $\gcd(a_i, a_j) > 1$.
   - `isIsolated`, `hasTwoIsolated`: Isolated vertex predicates in $G(a)$.

2. **`Formalization.BrieskornManifolds.SphereCriterion`**:
   - `brieskornSphereCondition`: Brieskorn–Hirzebruch topological sphere criterion.
   - `sphere_condition_of_two_isolated`: Sufficiency of having two isolated vertices.

3. **`Formalization.BrieskornManifolds.ExoticSpheres`**:
   - `coprime_two_six_k_sub_one`, `coprime_three_six_k_sub_one`: Arithmetic coprimality lemmas.
   - `brieskornExoticExponents`: Exponent tuple family $E(k) = (2, 2, 2, 3, 6k-1)$.
   - `exotic_vertex_three_isolated`, `exotic_vertex_four_isolated`: Verification of isolated vertices.
   - `exotic_exponents_two_isolated`: Proof of 2 isolated vertices in $G(E(k))$.
   - `exotic_exponents_isBrieskornSphere`: Proof that $\Sigma(E(k))$ is a topological sphere for all $k \ge 1$.
   - `theta7Order`, `milnorKervaireInvariant`: Invariant $\kappa(k) \in \mathbb{Z}/28\mathbb{Z}$.
   - `milnorKervaire_surjective`: Surjectivity of $\kappa$ onto $\Theta_7$.
   - `exotic_spheres_generate_all`: $\{E(1), \dots, E(28)\}$ generates all 28 differential structures.
   - `exotic_spheres_pairwise_distinct`: Pairwise distinct diffeomorphism classes for $k \in [1, 28]$.
   - `isStandardSmoothStructure`, `isExoticSmoothStructure`: Standard vs exotic predicates.
   - `k_28_is_standard`: Identification of standard 7-sphere at $k = 28$.
   - `k_1_to_27_are_exotic`: Verification of 27 exotic smooth 7-spheres for $k \in \{1, \dots, 27\}$.

4. **`Formalization.BrieskornManifolds.MilnorSignature`**:
   - `PairwiseCoprime3`: Pairwise coprimality predicate for exponent triples.
   - `brieskornThreeExponents`: 3-variable exponent map.
   - `pairwise_coprime_all_isolated`: All vertices isolated under pairwise coprimality.
   - `pairwise_coprime_isBrieskornSphere`: Proof that coprime $\Sigma(p, q, r)$ are topological spheres.
   - `brieskornLattice`, `brieskornLattice_card`: Interior lattice and Milnor number $\mu = (p-1)(q-1)(r-1)$.
   - `latticeWeight`, `posLattice`, `negLattice`: Eigenspace decomposition of Milnor fiber.
   - `brieskornSignature`: Intersection signature $\sigma(p, q, r) = N_+ - N_-$.
   - `cassonInvariant`, `cassonInvariantNat`: Casson invariant formulas $\lambda = \frac{1}{8}|\sigma|$.
   - `signature_2_3_5`, `casson_2_3_5`, `cassonNat_2_3_5`: Poincaré sphere evaluations ($\sigma = -8, \lambda = 1$).
   - `signature_2_3_7`, `casson_2_3_7`, `cassonNat_2_3_7`: $\Sigma(2, 3, 7)$ evaluations ($\sigma = -8, \lambda = 1$).
   - `signature_2_3_11`, `casson_2_3_11`, `cassonNat_2_3_11`: $\Sigma(2, 3, 11)$ evaluations ($\sigma = -16, \lambda = 2$).
   - `signature_2_5_7`, `casson_2_5_7`, `cassonNat_2_5_7`: $\Sigma(2, 5, 7)$ evaluations ($\sigma = -16, \lambda = 2$).

## Historical References

- Brieskorn, E. (1966). *Beispiele zur Differentialtopologie von Singularitäten*. Inventiones Mathematicae, 2(1), 1–14.
- Hirzebruch, F. (1968). *Singularities and exotic spheres*. Séminaire Bourbaki, 10(314), 13–32.
- Kervaire, M. A., & Milnor, J. W. (1963). *Groups of homotopy spheres: I*. Annals of Mathematics, 77(3), 504–537.
- Milnor, J. (1968). *Singular Points of Complex Hypersurfaces*. Annals of Mathematics Studies 61, Princeton University Press.
- Casson, A. (1985). *An invariant for homology 3-spheres*. MSRI Lectures.
- Fintushel, R., & Stern, R. J. (1990). *Instanton homology of Seifert fibred homology three spheres*. Proceedings of the London Mathematical Society, 3(1), 109–137.
-/
