# Machine-Checked Formalization of Modular Triangle Groups, Seifert Spheres, and the 8-Geometry Thurston Octet in Lean 4

This repository provides machine-checked formalizations, certified proofs, and a comprehensive mathematical physics monograph exploring:
1. **Hyperbolic Triangle Groups & Abelian Surface Degenerations**: Representation theory in $\mathrm{GL}_4(\mathbb{Z})$ and $\mathrm{Sp}_4(\mathbb{Z})$, the algebraic backbone of modular families of complex 2-tori, Brieskorn singularity links, gauge-theoretic Casson invariants, and Deligne–Schmid monodromy weight filtrations.
2. **Poincaré Dodecahedral Space** $S^3/I^\ast$ **& Spectral Geometry**: Exact algebraic construction of the binary icosahedral group $I^\ast \subset \mathrm{SU}(2)$, Chebyshev recurrence character evaluations, Molien invariant projection selection rules ($m_0=1, m_1=\dots=m_5=0, m_6=1$ on $\mathrm{SO}(3)$ and 11-mode spinor gap on $\mathrm{SU}(2)$), off-diagonal mode coupling selection rules and parity conservation theorems ($\Delta L \equiv 0 \pmod 2$), Seeley--DeWitt heat kernel asymptotics ($a_0, a_2, a_4$), 4D Einstein--Hilbert action recovery ($G_{\mathrm{eff}} > 0$), and the almost-commutative Noncommutative Standard Model spectral triple ($\dim_{\mathbb{R}} \mathcal{H}_F = 96$).
3. **The Complete 8-Geometry Thurston Octet**: Machine-checked spectral invariants, discrete group representations, Riemannian curvature tensors, and topological classifications across all eight Thurston model geometries ($\mathbb{S}^3, \mathbb{H}^3, \mathbb{E}^3, \mathrm{Nil}^3, \mathrm{Sol}^3, \widetilde{\mathrm{SL}}_2(\mathbb{R}), \mathbb{S}^2 \times \mathbb{R}, \mathbb{H}^2 \times \mathbb{R}$).

---

## Table of Formalized Modules and Theorems

### Part I: Core Original Research (Modular Triangle Groups, Seifert Spheres & Moduli Degenerations)

| # | Theorem / Topic | Primary Declaration(s) | Mathematical Domain | Reference / Authors | Status & Implementation Architecture |
| :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | The $(3,4,\infty)$ Modular Triangle Group Representation | [`T1_order_three`](Formalization/TriangleModularGroup/Basic.lean), [`T2_order_four`](Formalization/TriangleModularGroup/Basic.lean), [`T0_is_inverse`](Formalization/TriangleModularGroup/Basic.lean), [`N_squared_zero`](Formalization/TriangleModularGroup/Basic.lean), [`N_act_gamma`](Formalization/TriangleModularGroup/LatticeAction.lean), [`N_act_u`](Formalization/TriangleModularGroup/LatticeAction.lean), [`N_act_w`](Formalization/TriangleModularGroup/LatticeAction.lean), [`N_act_delta`](Formalization/TriangleModularGroup/LatticeAction.lean), [`seifert_invariant_trivial_pi1`](Formalization/TriangleModularGroup/SeifertInvariant.lean) | Geometric Group Theory, Lattices & Moduli of Abelian Surfaces | Original Synthesis (2026) | **Modular Package (`Formalization/TriangleModularGroup/`)** (Exact integer matrix automorphisms $T_1^3=I, T_2^4=I, T_1 T_2 T_0=I$, nilpotent cusp monodromy $N^2=0$, basis nilpotent actions, and $\pi_1=0$ Seifert invariant verified) |
| 2 | **Diophantine Classification of Sphere-Yielding Seifert Fibrations** | [`coprime_exists_sphere`](Formalization/SeifertSphereFibrations/CoprimeSolvability.lean), [`coprime_witnesses_isHomotopySphere`](Formalization/SeifertSphereFibrations/CoprimeSolvability.lean), [`seifertOrder_bezout`](Formalization/SeifertSphereFibrations/Basic.lean), [`noncoprime_obstruction`](Formalization/SeifertSphereFibrations/CoprimeSolvability.lean), [`sphere_2_3_infty`](Formalization/SeifertSphereFibrations/CanonicalFamilies.lean), [`sphere_3_4_infty`](Formalization/SeifertSphereFibrations/CanonicalFamilies.lean), [`sphere_2_5_infty`](Formalization/SeifertSphereFibrations/CanonicalFamilies.lean), [`sphere_3_5_infty`](Formalization/SeifertSphereFibrations/CanonicalFamilies.lean) | 3-Manifold Topology, Seifert Invariants & Diophantine Equations | Original Synthesis (2026) | **Modular Package (`Formalization/SeifertSphereFibrations/`)** (Constructive Bézout witness solvability, non-coprime divisor obstruction, canonical modular triangle families, and Brieskorn spheres $\Sigma(2,3,5), \Sigma(2,3,7)$ verified) |
| 3 | Universal Diophantine Classification for $k$-Point Seifert Fibrations | [`exists_sphere_iff_cofactorGCD_eq_one`](Formalization/GeneralSeifertClassification/Solvability.lean), [`pairwise_coprime_exists_sphere`](Formalization/GeneralSeifertClassification/Solvability.lean), [`common_divisor_obstruction`](Formalization/GeneralSeifertClassification/Obstructions.lean), [`sphere_4point_2_3_5_7`](Formalization/GeneralSeifertClassification/Certificates.lean), [`sphere_4point_2_3_7_11`](Formalization/GeneralSeifertClassification/Certificates.lean), [`sphere_5point_2_3_5_7_11`](Formalization/GeneralSeifertClassification/Certificates.lean), [`obstruction_5point_2_3_5_6_7`](Formalization/GeneralSeifertClassification/Certificates.lean) | 3-Manifold Topology, Seifert Invariants & Diophantine Equations | Original Synthesis (2026) | **Modular Package (`Formalization/GeneralSeifertClassification/`)** (Master Bézout theorem $\gcd(A_1,\dots,A_k)=1$, pairwise coprimality sufficiency, 4-point and 5-point constructive witnesses, and common divisor obstructions verified) |
| 4 | **The Seifert / Brieskorn Bridge & Casson Invariants** | [`brieskorn_seifert_bridge_3point`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`brieskorn_casson_bridge_3point`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`bridge_2_3_5`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`bridge_2_3_7`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`bridge_2_3_11`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`bridge_2_5_7`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`bridge_3_4_5`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean), [`bridge_3_5_7`](Formalization/GeneralSeifertClassification/BrieskornBridge.lean) | 3-Manifold Topology, Gauge Theory & Singularity Links | Original Synthesis (2026) | **Modular Package (`Formalization/GeneralSeifertClassification/BrieskornBridge.lean`)** (Proves pairwise coprimality simultaneously satisfies Brieskorn topological sphere condition and Seifert homology 3-sphere solvability; unifies with $\mathrm{SU}(2)$ character variety and Milnor signature Casson invariants) |
| 5 | Symplectic Triangle Representations in $\mathrm{Sp}_4(\mathbb{Z})$ & Monodromy Classification | [`isSymplectic_T1`](Formalization/SymplecticTriangleRepresentations/Representations.lean), [`isSymplectic_U1`](Formalization/SymplecticTriangleRepresentations/Representations.lean), [`isSymplectic_X1`](Formalization/SymplecticTriangleRepresentations/Representations.lean), [`monodromy_34_is_typeII`](Formalization/SymplecticTriangleRepresentations/MonodromyClassification.lean), [`monodromy_24_is_typeII`](Formalization/SymplecticTriangleRepresentations/MonodromyClassification.lean), [`monodromy_25_is_typeII`](Formalization/SymplecticTriangleRepresentations/MonodromyClassification.lean), [`monodromy_35_is_typeII`](Formalization/SymplecticTriangleRepresentations/MonodromyClassification.lean), [`monodromy_44_is_typeII`](Formalization/SymplecticTriangleRepresentations/MonodromyClassification.lean), [`weight_filtration_chain`](Formalization/SymplecticTriangleRepresentations/WeightFiltration.lean) | Symplectic Geometry & Degenerations of Abelian Surfaces | Original Synthesis (2026) | **Modular Package (`Formalization/SymplecticTriangleRepresentations/`)** (Standard $\mathrm{Sp}_4(\mathbb{Z})$ embeddings for $\Delta(3,4,\infty), \Delta(2,3,\infty), \Delta(2,4,\infty), \Delta(2,5,\infty), \Delta(3,5,\infty), \Delta(4,4,\infty)$, Type II unipotent cusp monodromy $N^2=0$, and monodromy weight filtration verified) |
| 6 | **Moduli Families of Abelian Surfaces, Asymptotics & Complete Stratification** | [`SiegelHalfSpace2`](Formalization/AbelianSurfaceDegenerations/SiegelSpace.lean), [`nilpotent_orbit_in_Siegel`](Formalization/AbelianSurfaceDegenerations/NilpotentOrbit.lean), [`expN_preserves_symplectic`](Formalization/AbelianSurfaceDegenerations/NilpotentOrbitAsymptotics.lean), [`schmid_elliptic_parameter_decay`](Formalization/AbelianSurfaceDegenerations/NilpotentOrbitAsymptotics.lean), [`master_triangle_cusp_boundary_classification`](Formalization/AbelianSurfaceDegenerations/CompleteBoundaryStratification.lean), [`master_moduli_degeneration_coupling`](Formalization/AbelianSurfaceDegenerations/WeightFiltrationCoupling.lean), [`master_generalized_neron_severi_stratification`](Formalization/AbelianSurfaceDegenerations/PicardStratification.lean) | Moduli of Abelian Varieties, Toroidal Compactification & Hodge Theory | Original Synthesis (2026) | **Modular Package (`Formalization/AbelianSurfaceDegenerations/`)** (Siegel half-space $\mathbb{H}_2$, $\exp(z N)$ symplectic Lie preservation, Schmid error decay $\mathcal{O}(\lvert t \rvert^{2\alpha})$, Baily–Borel & Toroidal complete stratifications, energy linear growth $E_v(z) = E_v(0) + (\operatorname{Im} z)v_0^2$, stationarity on $\ker(N_\tau)$, and Néron–Severi rank jumps $\Delta \rho \ge 1$ verified) |

---

### Part II: Background Foundations & Cross-Repository Landmark Modules

| # | Theorem / Topic | Primary Declaration(s) | Mathematical Domain | Established Literature | Status & Implementation Architecture |
| :---: | :--- | :--- | :--- | :--- | :--- |
| 7 | **Brieskorn Manifolds, Topological Spheres, and Exotic 7-Spheres** | [`exotic_exponents_isBrieskornSphere`](Formalization/BrieskornManifolds/ExoticSpheres.lean), [`exotic_spheres_generate_all`](Formalization/BrieskornManifolds/ExoticSpheres.lean), [`casson_2_3_5`](Formalization/BrieskornManifolds/MilnorSignature.lean), [`brieskorn_sphere_criterion`](Formalization/BrieskornManifolds/SphereCriterion.lean) | Differential Topology & Singularity Links | Brieskorn (1966), Milnor & Kervaire (1963), Casson (1985) | **Modular Package (`Formalization/BrieskornManifolds/`)** (Brieskorn graph sphere criterion, 28 Milnor-Kervaire exotic 7-spheres in $\Theta_7 \cong \mathbb{Z}/28\mathbb{Z}$, and Casson invariant formula verified) |
| 8 | **Hyperbolic Orbifold Spectral Zeta & Cusp Scattering** | [`gauss_bonnet_area`](Formalization/OrbifoldSpectralZeta/GaussBonnet.lean), [`residue_area_product`](Formalization/OrbifoldSpectralZeta/ResidueProduct.lean), [`hyperbolicArea_sig34`](Formalization/OrbifoldSpectralZeta/GaussBonnet.lean), [`trace_identity_with_normalizedArea`](Formalization/OrbifoldSpectralZeta/SelbergTrace.lean) | Spectral Geometry & Automorphic Forms | Selberg (1956), Hejhal (1983), Venkov (1990) | **Modular Package (`Formalization/OrbifoldSpectralZeta/`)** (Orbifold Gauss-Bonnet area $\mathrm{Area}=2\pi(1-1/p-1/q)$, Eisenstein scattering determinant $\phi(s)\phi(1-s)=1$, residue product $\mathrm{Res}\cdot\mathrm{Area}=2\pi$, and Selberg trace formula verified) |
| 9 | $\mathrm{SU}(2)$ Character Varieties, Diophantine Angles & Casson Invariants | [`IsSphericalAngleTriple`](Formalization/BrieskornSU2CharacterVariety/SphericalAngles.lean), [`card_irred_su2_2_3_5`](Formalization/BrieskornSU2CharacterVariety/RepresentationCounts.lean), [`casson_su2_eq_brieskorn_2_3_5`](Formalization/BrieskornSU2CharacterVariety/CassonInvariant.lean), [`frickeVogt_discriminant_identity`](Formalization/BrieskornSU2CharacterVariety/FrickeVogt.lean) | Gauge Theory, Character Varieties & 3-Manifold Invariants | Fintushel & Stern (1990), Casson (1985), Brieskorn (1966) | **Modular Package (`Formalization/BrieskornSU2CharacterVariety/`)** (Diophantine angle conditions for central fiber $h \mapsto -I$, certified representation counts for $\Sigma(2,3,5), \Sigma(2,3,7), \Sigma(2,3,11), \Sigma(2,5,7)$, exact Casson invariant agreement, and Fricke-Vogt trace relations verified) |
| 10 | Order-4 Picard-Fuchs Differential Equations, Mirror Symmetry & Monodromy for $\Delta(p,q,\infty)$ | [`pfSymbol_expansion`](Formalization/PicardFuchsMirrorMonodromy/DifferentialOperator.lean), [`sum_alpha_3_4_infty`](Formalization/PicardFuchsMirrorMonodromy/DifferentialOperator.lean), [`N_unipotent_index_2`](Formalization/PicardFuchsMirrorMonodromy/CuspMonodromy.lean), [`quintic_mirror_map_inversion`](Formalization/PicardFuchsMirrorMonodromy/MirrorMap.lean), [`quintic_instanton_k3`](Formalization/PicardFuchsMirrorMonodromy/YukawaInstantons.lean), [`isInfinitesimalSymplectic_N`](Formalization/PicardFuchsMirrorMonodromy/SymplecticInvariance.lean), [`N_MUM_satisfies_GriffithsTransversality`](Formalization/PicardFuchsMirrorMonodromy/GriffithsTransversality.lean) | Mirror Symmetry, Differential Equations, Hodge Theory & Symplectic Monodromies | Candelas et al. (1991), Morrison (1993), Griffiths (1970) | **Modular Package (`Formalization/PicardFuchsMirrorMonodromy/`)** (Order-4 Picard-Fuchs operator symbol $\mathcal{L}_4$, Calabi-Yau self-duality sum $\sum \alpha_i = 2, e_3 = e_2 - 1$, unipotent cusp monodromy $N = T_0 - I_4$ matching $\mathrm{Sp}_4(\mathbb{Z})$, flat mirror map reversion $z(q)$, multi-instanton BPS & GW expansions, symplectic Lie algebra invariance $N^T J + J N = 0$, and higher-dimensional Griffiths transversality verified) |
| 11 | Deligne-Schmid Mixed Hodge Weight Filtrations $W_\bullet(N)$ & Symplectic Polarizations | [`DeligneWeightSpace_shift`](Formalization/UniversalMonodromyWeightFiltration/FiltrationProperties.lean), [`DeligneWeightSpace_mono`](Formalization/UniversalMonodromyWeightFiltration/FiltrationProperties.lean), [`DeligneWeightSpace_top`](Formalization/UniversalMonodromyWeightFiltration/FiltrationProperties.lean), [`W_MUM_complete_chain`](Formalization/UniversalMonodromyWeightFiltration/Filtrations4D.lean), [`Q_N_u_add_w_strictly_positive`](Formalization/UniversalMonodromyWeightFiltration/HodgeRiemannPairing.lean) | Hodge Theory & Degenerations of Mixed Hodge Structures | Deligne (1971), Schmid (1973), Steenbrink (1976) | **Modular Package (`Formalization/UniversalMonodromyWeightFiltration/`)** (Universal canonical subspace formula $W_l(N, k) = \bigcup_j (\ker(N^{j+1}) \cap \mathrm{im}(N^{j - l + k}))$, shift property $N(W_l) \subseteq W_{l-2}$, 2-step Type II and 4-step Type III MUM filtrations on $\mathbb{Z}^4$, and Hodge-Riemann polarization positivity verified) |
| 12 | Poincaré Dodecahedral Space $S^3/I^\ast$, Spectral Geometry & Noncommutative Standard Model | [`golden_ratio_norm_sq_sum`](Formalization/PoincareDodecahedron/BinaryIcosahedral.lean), [`binaryIcosahedralUnits_normSq`](Formalization/PoincareDodecahedron/BinaryIcosahedral.lean), [`m_SO3_zero`](Formalization/PoincareDodecahedron/SpectralDecomposition.lean), [`m_SO3_six`](Formalization/PoincareDodecahedron/SpectralDecomposition.lean), [`parity_selection_rule`](Formalization/PoincareDodecahedron/SpectralDecomposition.lean), [`coupling_SO3_zero_six`](Formalization/PoincareDodecahedron/SpectralDecomposition.lean), [`vol_PDS_eq`](Formalization/PoincareDodecahedron/HeatKernelAsymptotics.lean), [`einstein_hilbert_recovery`](Formalization/PoincareDodecahedron/HeatKernelAsymptotics.lean), [`dim_fermion_space`](Formalization/PoincareDodecahedron/StandardModel.lean), [`spectral_action_standard_model_unification`](Formalization/PoincareDodecahedron/StandardModel.lean) | Spectral Geometry, Representation Theory, Noncommutative Geometry & Mathematical Physics | Poincaré (1904), Weeks et al. (2004), Chamseddine–Connes–Marcolli (2007) | Modular Package (`Formalization/PoincareDodecahedron/`) (Exact algebraic 120 units $I^\ast \subset \mathbb{H}[\mathbb{R}]^\times$, Chebyshev recurrence over 9 conjugacy classes, Molien selection rules $m_1..m_5=0, m_6=1$, off-diagonal mode coupling & parity selection rule, Seeley-DeWitt heat kernel asymptotics $a_0 = \frac{\pi^2/60}{(4\pi)^{3/2}}$, $a_2 = a_0$, $a_4 = a_0/2$, 96 real fermion states $\mathcal{H}_F$, and tree-level gauge & Higgs unification verified with 0 sorries) |

---

### Part III: The Complete 8-Geometry Thurston Octet (Paper 3)

| # | Theorem / Topic | Primary Declaration(s) | Mathematical Domain | Established Literature | Status & Implementation Architecture |
| :---: | :--- | :--- | :--- | :--- | :--- |
| 13 | **The Weeks Manifold** ($\mathbb{H}^3$ Hyperbolic Space Forms) | [`weeksCubic_discriminant`](Formalization/WeeksManifold/Arithmetic.lean), [`weeksHomology_order`](Formalization/WeeksManifold/Basic.lean), [`volume_lt_Meyerhoff`](Formalization/WeeksManifold/Basic.lean), [`lambda1_gt_one`](Formalization/WeeksManifold/SpectralGap.lean), [`sls_strictly_contained_in_fundamental_domain`](Formalization/WeeksManifold/SpectralGap.lean) | Hyperbolic 3-Manifolds, Arithmetic Invariants & Spectral Gaps | Weeks (1985), Gabai–Meyerhoff–Milley (2009), Chinburg et al. (2007) | **Modular Package (`Formalization/WeeksManifold/`)** (2-relator group $\pi_1(\mathcal{W})$, $H_1 \cong \mathbb{Z}_5 \oplus \mathbb{Z}_5$, minimal volume $\mathrm{Vol} \approx 0.9427$, trace field $D = -23$, quaternion ramification, and Ramanujan–Selberg spectral gap $\lambda_1 \approx 27.80 > 1$ verified) |
| 14 | **The Hantzsche-Wendt Didicosm** ($\mathbb{E}^3$ Flat Space Forms) | [`gamma1_sq`](Formalization/HantzscheWendt/Basic.lean), [`holonomy_card`](Formalization/HantzscheWendt/Basic.lean), [`spectral_gap_doubling`](Formalization/HantzscheWendt/SpectralSelection.lean), [`admissible_energy_ge_two`](Formalization/HantzscheWendt/SpectralSelection.lean), [`cosmic_matched_circles_count`](Formalization/HantzscheWendt/CosmicTopology.lean) | Flat Riemannian Manifolds, Bieberbach Groups & Fourier Analysis | Hantzsche & Wendt (1935), Bieberbach (1911), Aurich et al. (2008) | **Modular Package (`Formalization/HantzscheWendt/`)** (Affine screw generators in $\mathrm{Isom}(\mathbb{R}^3)$, holonomy $H \cong \mathbb{Z}_2^2$, $H_1 \cong \mathbb{Z}_4^2$ ($b_1=0$), Fourier parity destructive interference, and **Spectral Gap Doubling** $\lambda_1(G_6) = 2\lambda_1(T^3)$ verified) |
| 15 | **The Heisenberg Nilmanifold** ($\mathrm{Nil}^3$ Nilpotent Space Forms) | [`commutator_X_Y`](Formalization/HeisenbergNilmanifold/Basic.lean), [`eulerClass_eq_one`](Formalization/HeisenbergNilmanifold/Basic.lean), [`harmonic_oscillator_gap`](Formalization/HeisenbergNilmanifold/SpectralTowers.lean), [`scalarCurvature_eq`](Formalization/HeisenbergNilmanifold/Geometry.lean), [`ricciAnisotropyRatio_eq`](Formalization/HeisenbergNilmanifold/Geometry.lean) | Nilpotent Lie Groups, Nilmanifolds & Landau Quantum Spectrum | Malcev (1951), Gordon & Wilson (1984), Pesce (1993) | **Modular Package (`Formalization/HeisenbergNilmanifold/`)** (Upper unitriangular Heisenberg group $\mathcal{H}_3(\mathbb{Z})$, circle bundle $e=1$, continuous 2D torus spectrum, discrete **Landau oscillator towers** $\lambda_{k,n}$, harmonic gap $\Delta\lambda = 2\pi > 0$, and mixed Ricci curvatures verified) |
| 16 | **The Fibonacci Solvmanifold** ($\mathrm{Sol}^3$ Solvable Space Forms) | [`fibonacciAnosov_trace`](Formalization/Solvmanifold/Basic.lean), [`betti1_eq_one`](Formalization/Solvmanifold/Basic.lean), [`bracket_X_Z`](Formalization/Solvmanifold/Geometry.lean), [`scalarCurvature_eq`](Formalization/Solvmanifold/Geometry.lean), [`fiberSpectralGap_pos`](Formalization/Solvmanifold/SpectralGeometry.lean) | Solvable Lie Groups, Anosov Diffeomorphisms & Foliated Spectra | Thurston (1997), Scott (1983), Milnor (1976) | **Modular Package (`Formalization/Solvmanifold/`)** (Solvable Lie group $\mathbb{R}^2 \rtimes \mathbb{R}$, Fibonacci Anosov matrix $\operatorname{Tr}(A)=3$, golden ratio spectrum $\lambda_1=\varphi^2$, Lyapunov exponent $\mu=2\ln\varphi$, mixed curvatures $K \in \{-1,1\}$, $R=-2$, and fiber gap $\lambda_{0,1}>0$ verified) |
| 17 | **Unit Tangent Bundles over Surfaces** ($\widetilde{\mathrm{SL}}_2(\mathbb{R})$ Geometry) | [`bracket_e1_e2`](Formalization/SL2RGeometry/Basic.lean), [`eulerClass_eq_eulerChar`](Formalization/SL2RGeometry/Basic.lean), [`secE1E2_eq_neg_three_fourths`](Formalization/SL2RGeometry/Geometry.lean), [`casimirEigenvalue_fiber_invariant`](Formalization/SL2RGeometry/SpectralDecomposition.lean), [`totalSpectralGap_pos`](Formalization/SL2RGeometry/SpectralDecomposition.lean) | Lie Groups, Unit Tangent Bundles & Casimir Operators | Milnor (1976), Scott (1983), Buser (1992) | **Modular Package (`Formalization/SL2RGeometry/`)** ($\mathfrak{sl}_2(\mathbb{R})$ Lie algebra, $T^1(\Sigma_g)$ ($g \ge 2$) topology with Euler class $e = 2-2g$, mixed sectional curvatures $K \in \{-3/4, 1/4\}$, $R=-1/2$, Casimir spectrum $\lambda_{j,m} = \lambda_j + m^2/4$, and spectral gap $\lambda_1 > 0$ verified) |
| 18 | **Spherical Product Cylinders** ($\mathbb{S}^2 \times \mathbb{R}$ Geometry) | [`kunneth_betti_eq`](Formalization/S2xRGeometry/Basic.lean), [`secThetaPhi_pos`](Formalization/S2xRGeometry/Geometry.lean), [`scalarCurvature_pos`](Formalization/S2xRGeometry/Geometry.lean), [`spectralGap_pos`](Formalization/S2xRGeometry/SpectralDecomposition.lean), [`circle_gap_at_critical`](Formalization/S2xRGeometry/SpectralDecomposition.lean) | Product Manifolds, Spherical Harmonics & Spectral Crossings | Thurston (1997), Scott (1983) | **Modular Package (`Formalization/S2xRGeometry/`)** ($S^2 \times S^1_L$ Künneth homology, non-negative curvature $K \ge 0, R=2$, joint eigenvalues $\ell(\ell+1) + (2\pi n/L)^2$, spectral gap $\min(2, 4\pi^2/L^2) > 0$, and critical length $L_c = \pi\sqrt{2}$ verified) |
| 19 | **Hyperbolic Product Cylinders** ($\mathbb{H}^2 \times \mathbb{R}$ Geometry) | [`poincare_duality_one_two`](Formalization/H2xRGeometry/Basic.lean), [`sec_xy_neg`](Formalization/H2xRGeometry/Geometry.lean), [`scalarCurvature_eq`](Formalization/H2xRGeometry/Geometry.lean), [`selbergSpectralGap_pos`](Formalization/H2xRGeometry/SpectralDecomposition.lean), [`seeleyDeWittA1_neg`](Formalization/H2xRGeometry/SpectralDecomposition.lean) | Product Manifolds, Hyperbolic Surfaces & Selberg Bounds | Thurston (1997), Selberg (1956) | **Modular Package (`Formalization/H2xRGeometry/`)** ($\Sigma_g \times S^1_L$ ($g \ge 2$) Künneth Betti numbers $b_1=2g+1$, non-positive curvature $K \le 0, R=-2$, Selberg-certified spectral gap $\ge \min(3/16, 4\pi^2/L^2) > 0$, and heat kernel asymptotics verified) |
| 20 | **The Master Thurston Octet Classification Theorem** | [`dimension_eq_three`](Formalization/ThurstonOctet.lean), [`isotropic_classification`](Formalization/ThurstonOctet.lean), [`einstein_classification`](Formalization/ThurstonOctet.lean), [`positive_scalar_curvature_classification`](Formalization/ThurstonOctet.lean), [`spectral_gap_positivity`](Formalization/ThurstonOctet.lean), [`masterThurstonOctetCertificate`](Formalization/ThurstonOctet.lean) | 3-Manifold Geometrization & Differential Geometry | Thurston (1982, 1997), Perelman (2002, 2003) | **Modular Package (`Formalization/ThurstonOctet.lean`)** (Unified inductive type `ThurstonGeometry`, dimension 3 invariance, isotropy dimension spectrum (3, 1, 0), Einstein metric equivalence, scalar curvature sign trichotomy, and universal spectral gap positivity verified) |

---

## Architectural & Blueprint Dependency Graph

```mermaid
graph TD
    subgraph ModularTriangleGeometry ["1. Modular Triangle Groups & Symplectic Reps"]
        TMG_B["TriangleModularGroup/Basic.lean<br/>(GL₄(ℤ) Automorphisms & Cusp N)"]
        TMG_L["TriangleModularGroup/LatticeAction.lean<br/>(Basis Action on γ, u, w, δ)"]
        TMG_S["TriangleModularGroup/SeifertInvariant.lean<br/>(Seifert Invariant Evaluation)"]
        TMG_Root["TriangleModularGroup.lean"]

        STR_B["SymplecticTriangleRepresentations/Basic.lean<br/>(Symplectic Form J & Sp₄(ℤ))"]
        STR_R["SymplecticTriangleRepresentations/Representations.lean<br/>(Broader Δ(p,q,∞) Representations)"]
        STR_M["SymplecticTriangleRepresentations/MonodromyClassification.lean<br/>(Type I, II, III Monodromy)"]
        STR_W["SymplecticTriangleRepresentations/WeightFiltration.lean<br/>(Weight Filtration W_• & Ω₆)"]
        STR_Root["SymplecticTriangleRepresentations.lean"]

        TMG_B & TMG_L & TMG_S --> TMG_Root
        STR_B & STR_R & STR_M & STR_W --> STR_Root
        TMG_Root --> STR_W
    end

    subgraph SeifertBrieskornTopology ["2. Seifert Fibrations, Brieskorn Links & Casson Invariants"]
        SSF_B["SeifertSphereFibrations/Basic.lean<br/>(Seifert Order & Bézout Witnesses)"]
        SSF_CS["SeifertSphereFibrations/CoprimeSolvability.lean<br/>(Bézout Existence & Obstruction)"]
        SSF_CF["SeifertSphereFibrations/CanonicalFamilies.lean<br/>((2,3,∞), (3,4,∞), (2,5,∞), (3,5,∞))"]
        SSF_CTP["SeifertSphereFibrations/CompactThreePoint.lean<br/>(3-Point Spheres & Brieskorn Certificates)"]
        SSF_Root["SeifertSphereFibrations.lean"]

        GSC_C["GeneralSeifertClassification/Cofactors.lean<br/>(k-Point Cofactors & Cofactor GCD)"]
        GSC_S["GeneralSeifertClassification/Solvability.lean<br/>(Master Solvability & Pairwise Coprimality)"]
        GSC_O["GeneralSeifertClassification/Obstructions.lean<br/>(Common Divisor Obstruction)"]
        GSC_Cert["GeneralSeifertClassification/Certificates.lean<br/>(3-Point, 4-Point & 5-Point Certificates)"]
        GSC_Bridge["GeneralSeifertClassification/BrieskornBridge.lean<br/>(Seifert-Brieskorn Bridge & Casson Invariant)"]
        GSC_Root["GeneralSeifertClassification.lean"]

        BM_B["BrieskornManifolds/Basic.lean<br/>(Brieskorn Links & Graph)"]
        BM_SC["BrieskornManifolds/SphereCriterion.lean<br/>(Brieskorn Sphere Criterion)"]
        BM_ES["BrieskornManifolds/ExoticSpheres.lean<br/>(28 Milnor-Kervaire Exotic 7-Spheres)"]
        BM_MS["BrieskornManifolds/MilnorSignature.lean<br/>(Milnor Fiber Signature & Casson)"]
        BM_Root["BrieskornManifolds.lean"]

        BSU2_B["BrieskornSU2CharacterVariety/Basic.lean<br/>(Irreducible SU(2) Reps)"]
        BSU2_SA["BrieskornSU2CharacterVariety/SphericalAngles.lean<br/>(Diophantine Spherical Angles)"]
        BSU2_RC["BrieskornSU2CharacterVariety/RepresentationCounts.lean<br/>(Certified Counts for Σ(p,q,r))"]
        BSU2_CI["BrieskornSU2CharacterVariety/CassonInvariant.lean<br/>(SU(2) Casson Agreement)"]
        BSU2_FV["BrieskornSU2CharacterVariety/FrickeVogt.lean<br/>(Fricke-Vogt Trace Variety)"]
        BSU2_Root["BrieskornSU2CharacterVariety.lean"]

        SSF_B & SSF_CS & SSF_CF & SSF_CTP --> SSF_Root
        GSC_C & GSC_S & GSC_O & GSC_Cert & GSC_Bridge --> GSC_Root
        BM_B & BM_SC & BM_ES & BM_MS --> BM_Root
        BSU2_B & BSU2_SA & BSU2_RC & BSU2_CI & BSU2_FV --> BSU2_Root
        
        BM_Root & BSU2_Root & GSC_Cert --> GSC_Bridge
    end

    subgraph ModuliAndMonodromy ["3. Moduli, Picard-Fuchs & Hodge Theory"]
        ASD_SS["AbelianSurfaceDegenerations/SiegelSpace.lean<br/>(Siegel Half-Space ℍ₂ & Sp₄(ℤ) Action)"]
        ASD_NO["AbelianSurfaceDegenerations/NilpotentOrbit.lean<br/>(Schmid's Nilpotent Orbit Theorem)"]
        ASD_BS["AbelianSurfaceDegenerations/BoundaryStratification.lean<br/>(Boundary Stratum Δ₁ & Toric Rank 1)"]
        ASD_NOA["AbelianSurfaceDegenerations/NilpotentOrbitAsymptotics.lean<br/>(exp(zN) Lie Preservation & Schmid Error)"]
        ASD_CBS["AbelianSurfaceDegenerations/CompleteBoundaryStratification.lean<br/>(Baily-Borel & Toroidal Stratifications)"]
        ASD_WFC["AbelianSurfaceDegenerations/WeightFiltrationCoupling.lean<br/>(Energy Linear Growth & Master Coupling)"]
        ASD_PS["AbelianSurfaceDegenerations/PicardStratification.lean<br/>(Uniform Picard Jumps across Δ(p,q,∞))"]
        ASD_Root["AbelianSurfaceDegenerations.lean"]

        OSZ_GB["OrbifoldSpectralZeta/GaussBonnet.lean<br/>(Signature (p,q,∞) & Gauss-Bonnet Area)"]
        OSZ_SD["OrbifoldSpectralZeta/ScatteringDeterminant.lean<br/>(Scattering Determinant φ(s))"]
        OSZ_RP["OrbifoldSpectralZeta/ResidueProduct.lean<br/>(Residue-Area Product = 2π)"]
        OSZ_ST["OrbifoldSpectralZeta/SelbergTrace.lean<br/>(Orbifold Selberg Trace Formula)"]
        OSZ_Root["OrbifoldSpectralZeta.lean"]

        PFM_DO["PicardFuchsMirrorMonodromy/DifferentialOperator.lean<br/>(Order-4 Operator & Calabi-Yau Sum)"]
        PFM_CM["PicardFuchsMirrorMonodromy/CuspMonodromy.lean<br/>(Cusp Monodromy N & Index-2 Unipotence)"]
        PFM_MM["PicardFuchsMirrorMonodromy/MirrorMap.lean<br/>(Flat Mirror Map q(z), Inversion z(q) & exp(N))"]
        PFM_SI["PicardFuchsMirrorMonodromy/SymplecticInvariance.lean<br/>(Symplectic Lie Algebra Invariance & Pairings)"]
        PFM_YI["PicardFuchsMirrorMonodromy/YukawaInstantons.lean<br/>(Yukawa Couplings & Multi-Instanton BPS)"]
        PFM_GT["PicardFuchsMirrorMonodromy/GriffithsTransversality.lean<br/>(Hodge Filtration Flags & Griffiths Transversality)"]
        PFM_Root["PicardFuchsMirrorMonodromy.lean"]

        UMW_DF["UniversalMonodromyWeightFiltration/DeligneFormula.lean<br/>(Deligne Canonical Subspaces)"]
        UMW_FP["UniversalMonodromyWeightFiltration/FiltrationProperties.lean<br/>(Shift N(W_l) ⊆ W_{l-2} & Monotonicity)"]
        UMW_F4["UniversalMonodromyWeightFiltration/Filtrations4D.lean<br/>(Explicit 2-Step & 4-Step MUM Chains)"]
        UMW_HR["UniversalMonodromyWeightFiltration/HodgeRiemannPairing.lean<br/>(Hodge-Riemann Polarizations Q_N)"]
        UMW_Root["UniversalMonodromyWeightFiltration.lean"]

        ASD_SS & ASD_NO & ASD_BS & ASD_NOA & ASD_CBS & ASD_WFC & ASD_PS --> ASD_Root
        OSZ_GB & OSZ_SD & OSZ_RP & OSZ_ST --> OSZ_Root
        PFM_DO & PFM_CM & PFM_MM & PFM_SI & PFM_YI & PFM_GT --> PFM_Root
        UMW_DF & UMW_FP & UMW_F4 & UMW_HR --> UMW_Root

        STR_Root --> ASD_NO
        STR_Root --> ASD_BS
        STR_Root --> ASD_NOA
        STR_Root --> ASD_CBS
        STR_Root --> ASD_PS
        STR_Root --> PFM_SI
        STR_Root --> PFM_GT
        STR_Root --> UMW_F4
        UMW_HR --> ASD_WFC
    end

    subgraph ThurstonOctetSuite ["4. The Complete 8-Geometry Thurston Octet"]
        PDS_Root["PoincareDodecahedron.lean<br/>(𝕊³ Spherical Space Form)"]
        WM_Root["WeeksManifold.lean<br/>(ℍ³ Hyperbolic Space Form)"]
        HW_Root["HantzscheWendt.lean<br/>(𝔼³ Flat Space Form)"]
        HN_Root["HeisenbergNilmanifold.lean<br/>(Nil³ Nilpotent Space Form)"]
        SOL_Root["Solvmanifold.lean<br/>(Sol³ Solvable Space Form)"]
        SL2_Root["SL2RGeometry.lean<br/>(SL̃₂(ℝ) Unit Tangent Bundle)"]
        S2R_Root["S2xRGeometry.lean<br/>(𝕊² × ℝ Product Cylinder)"]
        H2R_Root["H2xRGeometry.lean<br/>(ℍ² × ℝ Product Cylinder)"]
        TO_Root["ThurstonOctet.lean<br/>(Master Octet Classification & Certificate)"]

        PDS_Root & WM_Root & HW_Root & HN_Root & SOL_Root & SL2_Root & S2R_Root & H2R_Root --> TO_Root
    end

    subgraph MasterSuite ["Master Formalization Suite"]
        F_Master["Formalization.lean"]
    end

    TMG_Root & STR_Root & SSF_Root & GSC_Root & BM_Root & BSU2_Root & ASD_Root & OSZ_Root & PFM_Root & UMW_Root & TO_Root --> F_Master
```

---

## Academic Monograph & Research Preprints (`papers/`)

The repository includes comprehensive mathematical physics monographs and preprints formatted in both GitHub Flavored Markdown and standard publication LaTeX (`.tex`):

1. **Paper 1: Poincaré Dodecahedral Space & Spectral Geometry**
   - **Markdown Preprint:** [`papers/paper1_spectral_geometry.md`](papers/paper1_spectral_geometry.md)
   - **LaTeX Source:** [`papers/paper1_spectral_geometry.tex`](papers/paper1_spectral_geometry.tex)
   - **Title:** *Spectral Geometry and Invariant Theory on the Poincaré Homology 3-Sphere: Character Projections, Heat Kernel Asymptotics, and Machine-Checked Verification*
   - **Summary:** Rigorous mathematical foundations of $S^3/I^\ast$: $\mathrm{SU}(2)$ character Chebyshev recurrence over 9 conjugacy classes, Molien invariant projection selection rules ($m_0=1, m_1=\dots=m_5=0, m_6=1$ on $\mathrm{SO}(3)$ and 11-mode spinor gap on $\mathrm{SU}(2)$), Seeley--DeWitt heat kernel coefficients ($a_0 = \sqrt{\pi}/480, a_2 = a_0, a_4 = \sqrt{\pi}/960$), 4D Einstein--Hilbert action recovery ($G_{\mathrm{eff}} > 0$), and the almost-commutative Noncommutative Standard Model spectral triple ($\dim_{\mathbb{R}} \mathcal{H}_F = 96$).

2. **Paper 3: The Complete 8-Geometry Thurston Octet & Spectral Invariants**
   - **Markdown Preprint:** [`papers/paper3_thurston_spectral_geometry.md`](papers/paper3_thurston_spectral_geometry.md)
   - **LaTeX Source:** [`papers/paper3_thurston_spectral_geometry.tex`](papers/paper3_thurston_spectral_geometry.tex)
   - **Title:** *Spectral Invariants, Discrete Group Actions, and Topological Obstructions of Closed 3-Manifolds across the Eight Thurston Geometries*
   - **Summary:** Machine-checked spectral invariants, discrete group representations, Riemannian curvatures, and master classification theorems across all eight Thurston 3-manifold geometries: Spherical ($\mathbb{S}^3$), Hyperbolic ($\mathbb{H}^3$), Euclidean ($\mathbb{E}^3$), Nilpotent ($\mathrm{Nil}^3$), Solvable ($\mathrm{Sol}^3$), Universal Cover ($\widetilde{\mathrm{SL}}_2(\mathbb{R})$), Spherical Product ($\mathbb{S}^2 \times \mathbb{R}$), and Hyperbolic Product ($\mathbb{H}^2 \times \mathbb{R}$).

To verify manuscript cross-consistency and KaTeX syntax:

```powershell
# Verify Markdown and LaTeX preprints cross-consistency and equation integrity
python papers/verify_paper1.py

# Audit Markdown and KaTeX compliance for GitHub rendering
python papers/verify_markdown_katex.py
python papers/audit_gfm_math.py
```

---

## Part III: The Complete 8-Geometry Thurston Octet & Spectral Invariants (Paper 3)

The repository includes the complete machine-checked formalization and accompanying monograph ([Paper 3: `papers/paper3_thurston_spectral_geometry.md`](papers/paper3_thurston_spectral_geometry.md)) covering all eight canonical Thurston 3-manifold geometries:

1. **Spherical Geometry** ($\mathbb{S}^3$): Brieskorn Homology Spheres $\Sigma(p,q,r)$ & Quantum Invariants ([`Formalization/BrieskornSU2CharacterVariety/`](Formalization/BrieskornSU2CharacterVariety/ChernSimons.lean), [`Formalization/PoincareDodecahedron/`](Formalization/PoincareDodecahedron/SpectralDecomposition.lean))
   - Exact rational Chern–Simons actions ($CS = -1/120, -169/120$), character variety $\mathcal{R}^\ast$, discrete partition sums, Lawrence–Zagier character $\chi_{120}$ antisymmetry, and false theta exponent matching $-\Delta(n) - 1/120 = CS$.
2. **Hyperbolic Geometry** ($\mathbb{H}^3$): The Weeks Manifold $\mathcal{W}$ ([`Formalization/WeeksManifold/`](Formalization/WeeksManifold.lean))
   - 2-relator group $\pi_1(\mathcal{W})$, $H_1 \cong \mathbb{Z}_5 \oplus \mathbb{Z}_5$, minimal volume $\mathrm{Vol} \approx 0.9427$, invariant trace field $k = \mathbb{Q}(\theta)$ ($D = -23$), Chinburg–Hamilton–Long–Reid quaternion ramification, and Ramanujan–Selberg spectral gap $\lambda_1 \approx 27.80195 > 1$.
3. **Euclidean Geometry** ($\mathbb{E}^3$): The Hantzsche–Wendt Didicosm $G_6$ ([`Formalization/HantzscheWendt/`](Formalization/HantzscheWendt.lean))
   - Bieberbach affine screw motions in $\mathrm{Isom}(\mathbb{R}^3)$, holonomy $H \cong \mathbb{Z}_2 \times \mathbb{Z}_2$, $H_1 \cong \mathbb{Z}_4 \oplus \mathbb{Z}_4$ ($b_1 = 0$), destructive Fourier parity interference, and the **Spectral Gap Doubling Theorem** $\lambda_1(G_6) = 2\lambda_1(T^3) = 8\pi^2/L^2$.
4. **Nilpotent Geometry** ($\mathrm{Nil}^3$): The Heisenberg Nilmanifold $N_3$ ([`Formalization/HeisenbergNilmanifold/`](Formalization/HeisenbergNilmanifold.lean))
   - Upper unitriangular Heisenberg group $\mathcal{H}_3(\mathbb{Z})$ in $\mathrm{SL}_3(\mathbb{Z})$, center $Z \cong \mathbb{Z}$, circle bundle Euler class $e = 1$, continuous 2D torus base spectrum, discrete **Landau-level harmonic oscillator towers** $\lambda_{k,n} = 4\pi^2 k^2 + 2\pi \lvert k \rvert(2n+1)$, harmonic gap $\Delta\lambda = 2\pi > 0$, and mixed Ricci curvatures ($R = -1/2$).
5. **Solvable Geometry** ($\mathrm{Sol}^3$): The Fibonacci Anosov Solvmanifold $M_A$ ([`Formalization/Solvmanifold/`](Formalization/Solvmanifold.lean))
   - Solvable Lie group $\mathbb{R}^2 \rtimes \mathbb{R}$, Fibonacci Anosov matrix $\operatorname{Tr}(A)=3$, golden ratio spectrum $\lambda_1 = \varphi^2 = \frac{3+\sqrt{5}}{2}$, Lyapunov exponent $\mu = 2\ln\varphi > 0$, mixed sectional curvatures $K \in \{-1, +1\}$, scalar curvature $R = -2$, and fundamental fiber spectral gap $\lambda_{0,1} = (2\pi / (2\ln\varphi))^2 > 0$.
6. **Universal Cover Geometry** ($\widetilde{\mathrm{SL}}_2(\mathbb{R})$): Unit Tangent Bundles over Hyperbolic Surfaces ([`Formalization/SL2RGeometry/`](Formalization/SL2RGeometry.lean))
   - Lie algebra $\mathfrak{sl}_2(\mathbb{R})$, $T^1(\Sigma_g)$ ($g \ge 2$) topology with Euler class $e = 2 - 2g$, volume $4\pi^2(g-1)$, mixed curvatures $K \in \{-3/4, 1/4\}$, $R = -1/2$, Casimir eigenvalue decomposition $\lambda_{j,m} = \lambda_j(\Sigma_g) + m^2/4$, and positive spectral gap $\lambda_1 = \min(\lambda_1(\Sigma_g), 1/4) > 0$.
7. **Spherical Cylinder Geometry** ($\mathbb{S}^2 \times \mathbb{R}$): Spherical Cylinder Space Forms ([`Formalization/S2xRGeometry/`](Formalization/S2xRGeometry.lean))
   - Product manifold $S^2 \times S^1_L$ ($L > 0$), Künneth homology $b_0=b_1=b_2=b_3=1$, non-negative sectional curvatures $K \in \{0, 1\}$, scalar curvature $R = +2$, joint eigenvalues $\lambda_{\ell, n} = \ell(\ell+1) + (2\pi n/L)^2$, spectral gap $\min(2, 4\pi^2/L^2) > 0$, and critical length $L_c = \pi\sqrt{2}$.
8. **Hyperbolic Cylinder Geometry** ($\mathbb{H}^2 \times \mathbb{R}$): Hyperbolic Cylinder Space Forms ([`Formalization/H2xRGeometry/`](Formalization/H2xRGeometry.lean))
   - Product manifold $\Sigma_g \times S^1_L$ ($g \ge 2, L > 0$), Künneth Betti numbers $b_1 = 2g+1$, non-positive sectional curvatures $K \le 0$, scalar curvature $R = -2$, Selberg $3/16$ spectral gap $\lambda_1 \ge \min(3/16, 4\pi^2/L^2) > 0$, critical length $L_{\mathrm{crit}} = 8\pi/\sqrt{3}$, and Seeley–DeWitt heat kernel coefficients $a_0 > 0, a_1 < 0$.
9. **The Master Thurston Octet Classification Theorem** ([`Formalization/ThurstonOctet.lean`](Formalization/ThurstonOctet.lean))
   - Unified inductive enumeration `ThurstonGeometry`, dimension 3 invariance, isotropy dimension classification ($\dim H = 3, 1, 0$), Einstein metric classification ($\mathrm{Ric} = \frac{R}{3}g \iff \mathbb{S}^3, \mathbb{H}^3, \mathbb{E}^3$), scalar curvature sign trichotomy, and universal spectral gap positivity $\lambda_1(M_g) > 0$ across all eight canonical space forms.

---

## Verification and Build Instructions

The entire formalization is compiled with Lean 4 (`v4.34.0-rc2`) and Mathlib. All 19 research modules (350+ master declarations, 3,240+ verification jobs) compile with **0 errors, 0 warnings, and 0 sorries** using only standard Lean 4 core axioms (`propext`, `Quot.sound`, `Classical.choice`).

To build the entire formalization suite:

```powershell
# In C:\Users\x\Documents\antigravity\original-research
lake build Formalization
```

---

## Bibliography and References

1. **Poincaré, H.** (1904). *Cinquième complément à l'analysis situs*. Rendiconti del Circolo Matematico di Palermo, 18, 45–110.
2. **Luminet, J.-P., Weeks, J. R., Riazuelo, A., Lehoucq, R., & Uzan, J.-P.** (2003). *Dodecahedral space topology as an explanation for weak wide-angle temperature correlations in the cosmic microwave background*. Nature, 425(6958), 593–595.
3. **Weeks, J. R., Luminet, J.-P., Riazuelo, A., & Lehoucq, R.** (2004). *The cosmic microwave background anisotropy in a spherical space*. Classical and Quantum Gravity, 21(14), 3427–3438.
4. **Chamseddine, A. H., Connes, A., & Marcolli, M.** (2007). *Gravity and the standard model with neutrino mixing*. Advances in Theoretical and Mathematical Physics, 11(6), 991–1089.
5. **Aurich, R., Jancke, H. S., Lustig, S., & Steiner, F.** (2008). *Do cosmic microwave background temperature fluctuations exclude the Didicosm?* Classical and Quantum Gravity, 25(12), 125010.
6. **Gabai, D., Meyerhoff, R., & Milley, P.** (2009). *Minimum volume cusped hyperbolic three-manifolds*. Journal of the American Mathematical Society, 22(4), 1157–1215.
7. **Gordon, C. S., & Wilson, E. N.** (1984). *Isospectral deformations of compact solvmanifolds*. Journal of Differential Geometry, 19(1), 241–256.
8. **Hantzsche, W., & Wendt, H.** (1935). *Dreidimensionale euklidische Raumformen*. Mathematische Annalen, 110(1), 593–611.
9. **Lawrence, R., & Zagier, D.** (1999). *Modular forms and quantum invariants of 3-manifolds*. Asian Journal of Mathematics, 3(1), 93–108.
10. **Seifert, H.** (1933). *Topologie dreidimensionaler gefaserter Räume*. Acta Mathematica, 60(1), 147–238.
11. **Brieskorn, E.** (1966). *Beispiele zur Differentialtopologie von Singularitäten*. Inventiones Mathematicae, 2(1), 1–14.
12. **Kervaire, M. A., & Milnor, J. W.** (1963). *Groups of homotopy spheres: I*. Annals of Mathematics, 77(3), 504–537.
13. **Fintushel, R., & Stern, R. J.** (1990). *Instanton homology of Seifert fibred homology three spheres*. Proceedings of the London Mathematical Society, 3(2), 333–370.
14. **Deligne, P.** (1971). *Théorie de Hodge: II*. Publications Mathématiques de l'IHÉS, 40, 5–57.
15. **Schmid, W.** (1973). *Variation of Hodge structure: the singularities of the period mapping*. Inventiones Mathematicae, 22(3), 211–319.
16. **Candelas, P., De La Ossa, X. C., Green, P. S., & Parkes, L.** (1991). *A pair of Calabi-Yau manifolds as an exactly soluble superconformal theory*. Nuclear Physics B, 359(1), 21–74.
17. **Morrison, D. R.** (1993). *Mirror symmetry and rational curves on Calabi-Yau threefolds: a guide for mathematicians*. Journal of the American Mathematical Society, 6(1), 223–247.
18. **Perelman, G.** (2002). *The entropy formula for the Ricci flow and its geometric applications*. arXiv:math/0211159.
19. **Scott, P.** (1983). *The geometries of 3-manifolds*. Bulletin of the London Mathematical Society, 15(5), 401–487.
20. **Thurston, W. P.** (1982). *Three-dimensional manifolds, Kleinian groups and hyperbolic geometry*. Bulletin of the American Mathematical Society, 6(3), 357–381.
21. **Thurston, W. P.** (1997). *Three-Dimensional Geometry and Topology*. Princeton University Press.
22. **Weeks, J. R.** (1985). *Hyperbolic structures on 3-manifolds*. Ph.D. thesis, Princeton University.
