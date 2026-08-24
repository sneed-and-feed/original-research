import Formalization.TriangleModularGroup
import Formalization.SeifertSphereFibrations
import Formalization.GeneralSeifertClassification
import Formalization.SymplecticTriangleRepresentations
import Formalization.BrieskornManifolds
import Formalization.OrbifoldSpectralZeta
import Formalization.AbelianSurfaceDegenerations

/-!
# Original Research Formalization Suite: Triangle Groups & Seifert Homology Spheres

This repository contains original machine-checked mathematical research formalized in Lean 4
and Mathlib.

## Module Index

1. **`Formalization.TriangleModularGroup`**:
   - Discrete matrix representation of the hyperbolic triangle group $\Delta(3,4,\infty)$ in $\mathrm{GL}_4(\mathbb{Z})$.
   - Verification of group relations $T_1^3 = I_4$, $T_2^4 = I_4$, $(T_1 T_2) T_0 = I_4$.
   - Unipotent cusp monodromy $N = T_0 - I_4$ satisfying $N^2 = 0$.
   - Nilpotent action on the basis $(\gamma, u, w, \delta)$: $N\gamma = 0, Nu = 0, Nw = -u, N\delta = \gamma$.
   - Evaluation of the $(3,4,\infty)$ Seifert order invariant $|12(0) - 4(1) - 3(-1)| = 1 \implies \pi_1(X) \cong 0$.

2. **`Formalization.SeifertSphereFibrations`**:
   - General Diophantine classification of sphere-yielding Seifert fibrations over $S^2(a_1, a_2, \infty)$ and $S^2(a_1, a_2, a_3)$.
   - Constructive Bézout existence theorem (`coprime_exists_sphere`, `coprime_witnesses_isHomotopySphere`) via `Int.gcdA` and `Int.gcdB`.
   - Divisibility obstruction theorem (`noncoprime_obstruction`): common factors $d > 1$ preclude any homology sphere.
   - Classification of canonical hyperbolic triangle families: $(2,3,\infty)$, $(3,4,\infty)$, $(2,5,\infty)$, $(3,5,\infty)$.
   - Pairwise coprime solvability for 3-point compact Seifert 3-manifolds (`pairwise_coprime_exists_sphere3`).
   - Formal certificates for Poincaré $\Sigma(2,3,5)$ and Brieskorn $\Sigma(2,3,7)$ homology spheres.

3. **`Formalization.GeneralSeifertClassification`**:
   - Generalized $k$-point Seifert invariant order formula $O_k(a; \ell_0, \ell) = (\prod a_i)\ell_0 - \sum A_j \ell_j$.
   - Cofactor products $A_j = \prod_{i \ne j} a_i$ and cofactor GCD $\gcd(A_1, \dots, A_k)$.
   - Master Diophantine Solvability Theorem: $|O_k(a; \ell_0, \ell)| = 1 \iff \gcd(A_1, \dots, A_k) = 1$.
   - Pairwise Coprimality Sufficiency Theorem: pairwise coprime $\implies \gcd(A_1, \dots, A_k) = 1 \implies \exists \vec{\ell}, |O_k| = 1$.
   - Common Divisor Obstruction: $\gcd(a_i, a_j) = d > 1 \implies d \mid A_m$ for all $m \implies d \mid O_k$ and no homology sphere is possible.
   - Concrete classifications and certificates for 3-point ($\Sigma(2,3,5), \Sigma(2,3,7), \Sigma(2,3,11)$, obstruction $\Sigma(2,4,6)$) and 4-point families ($\Sigma(2,3,5,7), \Sigma(2,3,5,11)$, obstruction $\Sigma(2,3,4,5)$).
   - List-based invariant formulations and verification tests.

4. **`Formalization.SymplecticTriangleRepresentations`**:
   - Canonical non-degenerate skew-symmetric symplectic form $J \in \mathrm{Mat}_4(\mathbb{Z})$ ($J^T = -J, J^2 = -I_4$) and symplectic predicate `IsSymplectic`.
   - Symplectic representation of $\Delta(3,4,\infty)$ in $\mathrm{Sp}_4(\mathbb{Z})$: order 3 ($T_1^3 = I_4$), order 4 ($T_2^4 = I_4$), and parabolic monodromy $T_0 = (T_1 T_2)^{-1}$.
   - Symplectic representation of $(2,3,\infty)$ modular family in $\mathrm{Sp}_4(\mathbb{Z})$: order 2 ($S_1^2 = I_4$), order 3 ($S_2^3 = I_4$), and parabolic monodromy $S_0 = (S_1 S_2)^{-1}$.
   - Classification of unipotent cusp monodromies (Type I: $N=0$, Type II: $N \ne 0, N^2=0$, Type III: $N^2 \ne 0, N^4=0$) and machine-proof that $(3,4,\infty)$ is strictly Type II.
   - Monodromy weight filtration $W_0 = \{0\} \subset W_1 = \operatorname{im} N \subset W_2 = \mathbb{Z}^4$ with verified inclusion chain.
   - Polarized skew-symmetric symplectic form $\Omega_6$ preserving the $S_6$ Seifert family from `TriangleModularGroup`.

5. **`Formalization.BrieskornManifolds`**:
   - Brieskorn polynomial $f_a(z) = \sum z_j^{a_j}$, singularity link $\Sigma(a) = f_a^{-1}(0) \cap S^{2n-1}$, and real dimension $2n-3$.
   - Brieskorn graph $G(a)$, isolated vertices, and the Brieskorn Sphere Criterion (Brieskorn 1966, Milnor 1968).
   - The 28 Milnor-Kervaire exotic 7-spheres $\Sigma(2,2,2,3,6k-1)$ ($k \in \{1,\dots,28\}$) generating $b P_8 \cong \Theta_7 \cong \mathbb{Z}/28\mathbb{Z}$.
   - Exact Milnor fiber signature $\sigma(p,q,r) = N_+ - N_-$ and Dedekind sum Casson invariant formula $\lambda(\Sigma(p,q,r)) = \frac{1}{8} |\sigma(p,q,r)|$.
   - Certified Casson invariant values: $\lambda(\Sigma(2,3,5)) = 1$, $\lambda(\Sigma(2,3,7)) = 1$, $\lambda(\Sigma(2,3,11)) = 2$, $\lambda(\Sigma(2,5,7)) = 2$.

6. **`Formalization.OrbifoldSpectralZeta`**:
   - Signature $(p, q, \infty)$ for 1-cusped hyperbolic 2-orbifolds $\mathcal{O}(p, q, \infty) = \Delta(p, q, \infty) \backslash \mathbb{H}$.
   - Orbifold Euler characteristic $\chi_{\text{orb}}(\mathbb{P}^1(p, q, \infty)) = 1/p + 1/q - 1$ and Gauss–Bonnet area $\operatorname{Area}(\mathcal{O}) = 2\pi(1 - 1/p - 1/q)$.
   - Machine-certified areas: $(3,4,\infty) \implies 5\pi/6$, $(2,3,\infty) \implies \pi/3$, $(2,5,\infty) \implies 3\pi/5$, $(3,5,\infty) \implies 7\pi/15$.
   - Eisenstein scattering determinant $\phi(s)$: functional equation $\phi(s)\phi(1-s) = 1$, critical line unitarity $|\phi(1/2+ir)| = 1$, residue $\operatorname{Res}_{s=1} \phi(s) = 1/\mu_{\text{orb}}$.
   - Orbifold Selberg trace formula decomposing discrete Maass cusp spectrum, continuous Eisenstein scattering, and geometric conjugacy classes (identity, elliptic cone points of orders $p, q$, parabolic cusp, hyperbolic geodesics).
   - Selberg zeta function $\mathcal{Z}_{\mathcal{O}}(s)$ Euler product and spectral eigenvalue duality $s(1-s) = 1/4 + r^2$.

7. **`Formalization.AbelianSurfaceDegenerations`**:
   - Siegel Upper Half-Space $\mathbb{H}_2$ for $g=2$: symmetric complex $2 \times 2$ matrices with positive definite imaginary part.
   - Fractional linear transformations in $\mathrm{Sp}_4(\mathbb{Z})$ and symplectic block invariance theorems.
   - Nilpotent Orbit Theorem (Schmid 1973) for unipotent cusp degeneration: period map $\tau_{\text{nilp}}(\tau_0, z) = \tau_0 + z N_\tau \in \mathbb{H}_2$ and monodromy periodicity.
   - Kodaira–Mumford toric degeneration of abelian surfaces at the boundary $\partial \overline{\mathcal{A}_2}$: toric rank 1 semi-abelian extension $0 \to \mathbb{G}_m \to A_0 \to E \to 0$ in $\Delta_1 \cong \mathcal{A}_1$.
   - Néron–Severi rank / Picard number stratification: $\rho(A_{\text{gen}}) = 1$, jumps $\rho(A_{t_1}) = 4 \ge 2$ and $\rho(A_{t_2}) = 4 \ge 2$ with complex multiplication and splitting $A_{t_i} \sim E \times E$.
-/
