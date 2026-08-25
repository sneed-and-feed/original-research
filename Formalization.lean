import Formalization.TriangleModularGroup
import Formalization.SeifertSphereFibrations
import Formalization.GeneralSeifertClassification
import Formalization.SymplecticTriangleRepresentations
import Formalization.BrieskornManifolds
import Formalization.OrbifoldSpectralZeta
import Formalization.AbelianSurfaceDegenerations
import Formalization.BrieskornSU2CharacterVariety
import Formalization.PicardFuchsMirrorMonodromy
import Formalization.UniversalMonodromyWeightFiltration

/-!
# Original Research Formalization Suite: Triangle Groups, Moduli & Seifert Homology Spheres

This repository contains original machine-checked mathematical research formalized in Lean 4
and Mathlib, organized into modular submodule trees matching the architecture of `lean-theorems-3`.

## Module Index & Submodule Directory Trees

1. **`Formalization.TriangleModularGroup`**:
   - `Basic.lean`: Discrete matrix representation of the hyperbolic triangle group $\Delta(3,4,\infty)$ in $\mathrm{GL}_4(\mathbb{Z})$ ($T_1^3 = I_4, T_2^4 = I_4, (T_1 T_2) T_0 = I_4$) and unipotent cusp monodromy $N = T_0 - I_4$ ($N^2 = 0$).
   - `LatticeAction.lean`: Nilpotent action on the lattice basis $(\gamma, u, w, \delta)$: $N\gamma = 0, Nu = 0, Nw = -u, N\delta = \gamma$.
   - `SeifertInvariant.lean`: Seifert invariant evaluation $|12\ell_0 - 4\ell_1 - 3\ell_2| = 1$ for $(\ell_0, \ell_1, \ell_2) = (0, 1, -1) \implies \pi_1(X) \cong 0$.

2. **`Formalization.SeifertSphereFibrations`**:
   - `Basic.lean`: Foundational Seifert invariant order formula $O(a_1, a_2; \ell_0, \ell_1, \ell_2) = a_1 a_2 \ell_0 - a_2 \ell_1 - a_1 \ell_2$ and Bézout witness constructor.
   - `CoprimeSolvability.lean`: Constructive Bézout existence theorem (`coprime_exists_sphere`) and divisibility obstruction theorem (`noncoprime_obstruction`).
   - `CanonicalFamilies.lean`: Explicit certified sphere-yielding solutions for $(2,3,\infty), (3,4,\infty), (2,5,\infty), (3,5,\infty)$.
   - `CompactThreePoint.lean`: Compact 3-point Seifert 3-manifolds over $S^2(a_1, a_2, a_3)$ (`pairwise_coprime_exists_sphere3`, `noncoprime_obstruction3_12`) and Poincaré $\Sigma(2,3,5)$ / Brieskorn $\Sigma(2,3,7)$ certificates.

3. **`Formalization.GeneralSeifertClassification`**:
   - `Cofactors.lean`: Generalized $k$-point Seifert invariant order $O_k(a; \ell_0, \ell) = (\prod a_i)\ell_0 - \sum A_j \ell_j$, cofactors $A_j = \prod_{i \ne j} a_i$, and cofactor GCD $\gcd(A_1, \dots, A_k)$.
   - `Solvability.lean`: Master Diophantine Solvability Theorem ($|O_k| = 1 \iff \gcd(A_1,\dots,A_k) = 1$) and Pairwise Coprimality Sufficiency Theorem.
   - `Obstructions.lean`: Common divisor and non-coprime pair obstructions preventing homology sphere solutions.
   - `Certificates.lean`: Machine-checked classifications and certificates for 3-point ($\Sigma(2,3,5), \Sigma(2,3,7), \Sigma(2,3,11)$, obstruction $\Sigma(2,4,6)$) and 4-point families ($\Sigma(2,3,5,7), \Sigma(2,3,5,11)$, obstruction $\Sigma(2,3,4,5)$).

4. **`Formalization.SymplecticTriangleRepresentations`**:
   - `Basic.lean`: Canonical non-degenerate skew-symmetric symplectic form $J \in \mathrm{Mat}_4(\mathbb{Z})$ ($J^T = -J, J^2 = -I_4$) and symplectic predicate `IsSymplectic`.
   - `Representations.lean`: Symplectic representations of $(3,4,\infty)$ ($T_1, T_2, T_0$) and $(2,3,\infty)$ ($S_1, S_2, S_0$) in $\mathrm{Sp}_4(\mathbb{Z})$.
   - `MonodromyClassification.lean`: Classification of unipotent cusp monodromies (Type I, Type II, Type III) and machine-checked proofs that $(3,4,\infty)$ and $(2,3,\infty)$ are Type II.
   - `WeightFiltration.lean`: Monodromy weight filtration $W_0 \subseteq W_1 \subseteq W_2$ and polarized symplectic form $\Omega_6$ for the geometric $S_6$-family.

5. **`Formalization.AbelianSurfaceDegenerations`**:
   - `SiegelSpace.lean`: Siegel upper half-space $\mathbb{H}_2$ ($g=2$), positive definiteness `IsPosDef2`, diagonal basepoints, $\mathrm{Sp}_4(\mathbb{Z})$ block decompositions, and fractional linear transformations.
   - `NilpotentOrbit.lean`: Schmid's Nilpotent Orbit Theorem, cusp shift matrix $N_\tau$, period map $\tau_{\text{nilp}}$, and monodromy periodicity.
   - `BoundaryStratification.lean`: Boundary stratification $\overline{\mathcal{A}_2} = \mathcal{A}_2 \cup \Delta_1 \cup \Delta_0$, toric rank classification (0, 1, 2), and semi-abelian boundary extension $\Delta_1$.
   - `PicardStratification.lean`: Néron–Severi rank stratification $\rho(A_{\text{gen}}) = 1$, CM jump points $\rho(A_{t_1}) = \rho(A_{t_2}) = 4 \ge 2$, and splitting $A_{t_i} \sim E \times E$.
   - `NilpotentOrbitAsymptotics.lean`: Matrix exponential $\exp(z N)$, group law $\exp((z_1+z_2)N)$, symplectic invariance $(\exp(z N))^T J_{\mathbb{C}} \exp(z N) = J_{\mathbb{C}}$, $2 \times 2$ block projections, FLT translation compatibility, bundled `SchmidAsymptoticEstimate`, and limit elliptic parameter isolation.
   - `CompleteBoundaryStratification.lean`: Baily–Borel stratification $\mathcal{A}_2^* = \mathcal{A}_2 \sqcup \mathcal{A}_1 \sqcup \mathcal{A}_0$ (dims 3, 1, 0; codims 0, 2, 3), Toroidal compactification $\overline{\mathcal{A}_2}^{\text{tor}} = \mathcal{A}_2 \cup \Delta_1 \cup \Delta_0$ (codims 0, 1, 2), semi-abelian fiber rank conservation, and master cusp boundary classifications for all 6 triangle groups and CY3 MUM cusps.
   - `WeightFiltrationCoupling.lean`: Graded homology pieces $\operatorname{Gr}_1^W, \operatorname{Gr}_2^W$ ($2+2=4$), quadratic energy function $E_v(z)$, exact linear growth formula $E_v(z) = E_v(0) + (\operatorname{Im} z) v_0^2$, stationarity on $\ker(N_\tau)$, Hodge-Riemann pairing compatibility, and master moduli degeneration coupling theorem.

6. **`Formalization.BrieskornManifolds`**:
   - `Basic.lean`: Brieskorn polynomials $f_a(z) = \sum z_j^{a_j}$, singularity links $\Sigma(a)$, and real dimensions $2n-3$.
   - `SphereCriterion.lean`: Brieskorn graph $G(a)$, isolated vertices, and the Brieskorn–Hirzebruch sphere criterion.
   - `ExoticSpheres.lean`: The 28 Milnor–Kervaire exotic 7-spheres $\Sigma(2,2,2,3,6k-1)$ generating $\Theta_7 \cong \mathbb{Z}/28\mathbb{Z}$.
   - `MilnorSignature.lean`: Milnor fiber signature $\sigma(p,q,r) = N_+ - N_-$, Casson invariant formula $\lambda(\Sigma(p,q,r)) = \frac{1}{8}|\sigma(p,q,r)|$, and certified values for $\Sigma(2,3,5), \Sigma(2,3,7), \Sigma(2,3,11), \Sigma(2,5,7)$.

7. **`Formalization.OrbifoldSpectralZeta`**:
   - `GaussBonnet.lean`: Signature $(p, q, \infty)$ 1-cusped 2-orbifolds $\mathcal{O}(p,q,\infty)$, Euler characteristic $\chi_{\text{orb}}$, Gauss–Bonnet area $\operatorname{Area} = 2\pi(1 - 1/p - 1/q)$, and certified areas.
   - `ScatteringDeterminant.lean`: Eisenstein scattering determinant $\phi(s)$, functional equation $\phi(s)\phi(1-s)=1$, and critical line unitarity $|\phi(1/2+ir)|=1$.
   - `ResidueProduct.lean`: Residue-area product formula $\operatorname{Res}_{s=1}\phi(s) \cdot \operatorname{Area} = 2\pi$.
   - `SelbergTrace.lean`: Orbifold Selberg trace formula, Maass spectrum, continuous spectrum, conjugacy classes, and Selberg zeta $\mathcal{Z}_{\mathcal{O}}(s).$

8. **`Formalization.BrieskornSU2CharacterVariety`**:
   - `Basic.lean`: Irreducible $SU(2)$ character varieties of Brieskorn homology 3-spheres $\Sigma(p,q,r)$ and central fiber condition $h \mapsto -I$.
   - `SphericalAngles.lean`: Diophantine spherical triangle angle inequalities, `IsSphericalAngleTriple`, and representation set `IrredSU2RepSet`.
   - `RepresentationCounts.lean`: Certified representation counts for $\Sigma(2,3,5), \Sigma(2,3,7), \Sigma(2,3,11), \Sigma(2,5,7)$.
   - `CassonInvariant.lean`: Gauge-theoretic Casson invariant $\lambda_{SU(2)} = \frac{1}{2}\#\mathcal{R}^*$ and exact identification with Milnor signature Casson invariant.
   - `FrickeVogt.lean`: Fricke–Vogt trace variety $\Phi(t_x, t_y, t_z) = 0$ and trace hypersurface discriminant identities.

9. **`Formalization.PicardFuchsMirrorMonodromy`**:
   - `DifferentialOperator.lean`: Order-4 hypergeometric Picard–Fuchs operator $\mathcal{L}_4$, symbol expansion, and Calabi–Yau self-duality sum $\sum \alpha_i = 2$.
   - `CuspMonodromy.lean`: Nilpotent cusp monodromy $N = T_0 - I_4$ and index-2 unipotence (Type II vs Type III MUM).
   - `SymplecticInvariance.lean`: Griffiths transversality: infinitesimal symplectic Lie algebra invariance $N^T J + J N = 0$ and $N^T \Omega_6 + \Omega_6 N = 0$.
   - `YukawaInstantons.lean`: Classical Yukawa coupling $C_{zzz}(z)$ and multi-instanton BPS expansions $C_{ttt}(q)$, with quintic certificates.

10. **`Formalization.UniversalMonodromyWeightFiltration`**:
    - `DeligneFormula.lean`: Kernel and image powers, `DeligneSummand`, and `DeligneWeightSpace`.
    - `FiltrationProperties.lean`: Shift property $N(W_l) \subseteq W_{l-2}$, monotonicity $W_{l-1} \subseteq W_l$, and top space $W_{2k} = V$.
    - `Filtrations4D.lean`: Explicit 2-step Type II filtration for $(3,4,\infty)$ and explicit 4-step Type III MUM filtration.
    - `HodgeRiemannPairing.lean`: Hodge–Riemann symplectic polarization pairing $Q_N(v,w) = \langle v, N w \rangle_J$, symmetry, and strict positivity on primitive generators.
-/
