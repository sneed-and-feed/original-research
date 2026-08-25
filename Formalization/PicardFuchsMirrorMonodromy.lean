/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.PicardFuchsMirrorMonodromy.DifferentialOperator
import Formalization.PicardFuchsMirrorMonodromy.CuspMonodromy
import Formalization.PicardFuchsMirrorMonodromy.MirrorMap
import Formalization.PicardFuchsMirrorMonodromy.SymplecticInvariance
import Formalization.PicardFuchsMirrorMonodromy.YukawaInstantons
import Formalization.PicardFuchsMirrorMonodromy.GriffithsTransversality

open scoped Matrix BigOperators
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Order-4 Picard-Fuchs Differential Equations, Mirror Symmetry & Monodromy for $\Delta(p,q,\infty)$

This root aggregator module formalizes the comprehensive analytical, differential-geometric,
symplectic, and mirror-symmetric structures of order-4 Picard-Fuchs systems for hyperbolic triangle
modular families $\Delta(p,q,\infty)$ and Calabi-Yau 3-fold mirror families (such as the Quintic and
Bicubic 3-folds).

It unifies the Picard-Fuchs differential operator $\mathcal{L}_4$, universal Calabi-Yau self-duality,
Frobenius cusp monodromy classifications (Type II vs Type III MUM), flat coordinate mirror map series
and $q$-reversions, multi-instanton BPS / genus-0 Gromov-Witten expansions, symplectic Lie algebra
invariance, Hodge filtration flags, and higher-dimensional Griffiths transversality.

## Mathematical Overview

### 1. Picard-Fuchs Differential Operator $\mathcal{L}_4$ & Calabi-Yau Self-Duality
In the logarithmic derivative coordinate $\theta = z \frac{d}{dz}$, the standard order-4
hypergeometric Picard-Fuchs differential equation is:
$$\mathcal{L}_4 = \theta^4 - z(\theta + \alpha_0)(\theta + \alpha_1)(\theta + \alpha_2)(\theta + \alpha_3)$$
where $\alpha = (\alpha_0, \alpha_1, \alpha_2, \alpha_3) \in \mathbb{Q}^4$ are the local Riemann exponents.

Its algebraic symbol expands in powers of $\theta$ via the elementary symmetric polynomials $e_k(\alpha)$:
$$\mathcal{L}_4(\theta, z) = (1 - z)\theta^4 - z(e_1(\alpha)\theta^3 + e_2(\alpha)\theta^2 + e_3(\alpha)\theta + e_4(\alpha))$$

A parameter tuple $\alpha \in \mathbb{Q}^4$ satisfies **Calabi-Yau self-duality** if:
$$(\alpha_0 + \alpha_3 = 1) \wedge (\alpha_1 + \alpha_2 = 1)$$
which universally implies:
1. $e_1(\alpha) = 2$ and $\sum_{i=0}^3 \alpha_i = 2$.
2. $e_3(\alpha) = e_2(\alpha) - 1$ (or $e_2(\alpha) - e_3(\alpha) = 1$).
3. $\mathcal{L}_4(\theta, z) = (1 - z)\theta^4 - z(2\theta^3 + e_2(\alpha)\theta^2 + (e_2(\alpha)-1)\theta + e_4(\alpha))$.
4. Conifold specialization ($z = 1$): $\mathcal{L}_4(\theta, 1) = -(2\theta^3 + e_2(\alpha)\theta^2 + (e_2(\alpha)-1)\theta + e_4(\alpha))$.
5. Indicial polynomial at the cusp $z = 0$: $I_0(\theta) = \mathcal{L}_4(\theta, 0) = \theta^4$, exhibiting a unique quadruple root at $\theta = 0$.

All 6 triangle modular families and Calabi-Yau 3-fold families are certified:
- $\Delta(3,4,\infty)$ (Geometric): $\alpha = (1/12, 5/12, 7/12, 11/12)$, $e = (2, 95/72, 23/72, 385/20736)$.
- $\Delta(3,4,\infty)$ (Modular): $\alpha = (1/3, 2/3, 1/4, 3/4)$, $e = (2, 203/144, 59/144, 1/24)$.
- $\Delta(2,3,\infty)$: $\alpha = (1/6, 5/6, 1/6, 5/6)$, $e = (2, 23/18, 5/18, 25/1296)$.
- $\Delta(2,4,\infty)$: $\alpha = (1/8, 3/8, 5/8, 7/8)$, $e = (2, 43/32, 11/32, 105/4096)$.
- $\Delta(2,5,\infty)$: $\alpha = (1/10, 3/10, 7/10, 9/10)$, $e = (2, 13/10, 3/10, 189/10000)$.
- $\Delta(3,5,\infty)$: $\alpha = (1/15, 4/15, 11/15, 14/15)$, $e = (2, 283/225, 58/225, 616/50625)$.
- $\Delta(4,4,\infty)$: $\alpha = (1/8, 3/8, 5/8, 7/8)$, $e = (2, 43/32, 11/32, 105/4096)$.
- Quintic 3-Fold: $\alpha = (1/5, 2/5, 3/5, 4/5)$, $e = (2, 7/5, 2/5, 24/625)$.
- Bicubic 3-Fold: $\alpha = (1/3, 2/3, 1/3, 2/3)$, $e = (2, 13/9, 4/9, 4/81)$.

### 2. Frobenius Local Cusp Monodromy & Degeneration Classification
Around the cusp $z = 0$, the Frobenius solutions transform by the unipotent monodromy $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$:
- Nilpotent log-monodromy operator $N = T_0 - I_4 \in \mathfrak{sp}_4(\mathbb{Z})$.
- Machine-checked verification matching `SymplecticTriangleRepresentations.N` and `ModularFamilyS6.N`.
- **Type II Degeneration** (Abelian surface modular families $\Delta(3,4,\infty)$):
  $N \ne 0$ and $N^2 = 0$ (nilpotency index 2). Action on geometric basis:
  $$N \gamma = 0, \quad N u = 0, \quad N w = -u, \quad N \delta = \gamma$$
  Action on standard basis: $N e_0 = 0, N e_1 = -e_0, N e_2 = e_3, N e_3 = 0$.
- **Type III Degeneration** (Calabi-Yau 3-Fold MUM):
  $N_{\mathrm{MUM}}^3 \ne 0$ and $N_{\mathrm{MUM}}^4 = 0$ (nilpotency index 4).
- Complete mutual exclusion and classification between Type I, Type II, and Type III degenerations.

### 3. Flat Mirror Map Series, $q$-Inversion & Matrix Exponentials
Near the cusp $z = 0$, the Frobenius period expansions are:
- Holomorphic period: $w_0(z) = 1 + c_1 z + c_2 z^2 + \mathcal{O}(z^3)$.
- Logarithmic companion period: $w_1(z) = w_0(z) \log z + \tilde{w}_1(z)$, where $\tilde{w}_1(z) = b_1 z + b_2 z^2 + \mathcal{O}(z^3)$.
- Regular quotient: $\Delta t(z) = (b_1 - c_1) z$.
- Flat coordinate and instanton coordinate:
  $$t(z) = \frac{1}{2\pi i} \frac{w_1(z)}{w_0(z)} = \frac{1}{2\pi i}\log z + \Delta t(z), \qquad q(z) = \exp(2\pi i t) = z(1 + q_1 z + q_2 z^2 + \mathcal{O}(z^3))$$
- Inverse mirror map series $z(q) = q(1 + z_1 q + z_2 q^2 + \mathcal{O}(q^3))$ with exact algebraic inversion formulas:
  $$z_1 = -q_1, \qquad z_2 = 2 q_1^2 - q_2$$
- Machine-checked proofs that $z(q(z)) = z + \mathcal{O}(z^4)$ and $q(z(q)) = q + \mathcal{O}(q^4)$.
- Under analytic continuation $z \mapsto e^{2\pi i} z$, the flat coordinate translates as $t \mapsto t + 1$, corresponding to the matrix exponential $\exp(N)$:
  - Type II: $\exp(N) = I_4 + N$, with $(I_4 + N)^2 = I_4 + 2N$.
  - Type III: $\exp(N) = I_4 + N + \frac{1}{2} N^2 + \frac{1}{6} N^3$.
- Certified mirror map coefficients:
  - Quintic 3-fold: $q_1 = 770, q_2 = 293275 \implies z_1 = -770, z_2 = 892525$.
  - Modular $\Delta(3,4,\infty)$: $q_1 = 4, q_2 = 18 \implies z_1 = -4, z_2 = 14$.
  - Modular $\Delta(2,3,\infty)$: $q_1 = 2, q_2 = 5 \implies z_1 = -2, z_2 = 3$.

### 4. Multi-Instanton BPS & Genus-0 Gromov-Witten Expansions
- Classical Special Geometry Yukawa coupling function $C_{zzz}(z, \kappa_0, \mu) = \frac{\kappa_0}{z^3 (1 - \mu z)}$.
- Regularized cusp function $\kappa_{\mathrm{reg}}(z) = z^3 C_{zzz}(z) = \frac{\kappa_0}{1 - \mu z}$ (order-3 pole at $z = 0$).
- Conifold regularized function $\kappa_{\mathrm{con}}(z) = (1 - \mu z) C_{zzz}(z) = \frac{\kappa_0}{z^3}$ (discriminant singularity at $z = 1/\mu$).
- Multi-covering Aspinwall-Morrison formula:
  $$N_d = \sum_{k \mid d} \frac{n_{d/k}}{k^3} \qquad \Longleftrightarrow \qquad n_d = \sum_{k \mid d} \mu(k) \frac{N_{d/k}}{k^3}$$
- Proven roundtrip inversion `bpsFromGW_gwFromBPS` through degree 4.
- BPS instanton sum $C_{ttt}(q, K_0, n) = K_0 + \sum_{d=1}^M \frac{d^3 n_d q^d}{1 - q^d}$ vs Gromov-Witten polynomial $C_{\mathrm{GW}}(q, K_0, N) = K_0 + \sum_{d=1}^M d^3 N_d q^d$.
- Exact order-by-order asymptotic equivalence $C_{ttt}(q) = C_{\mathrm{GW}}(q) + \mathcal{O}(q^{M+1})$ certified for $M = 1, 2, 3$.
- BPS integrality (`IsBPSIntegral`) and strict positivity (`IsBPSPositive`) certificates:
  - Quintic 3-fold ($\kappa_0 = 5$): $n_1 = 2875, n_2 = 609250, n_3 = 317206375$; $N_1 = 2875, N_2 = 4876875/8, N_3 = 8564575000/27$.
  - Modular $\Delta(3,4,\infty)$ ($\kappa_0 = 1$): $n_1 = 4, n_2 = -2, n_3 = 0$; $N_1 = 4, N_2 = -3/2, N_3 = 4/27$.
  - Modular $\Delta(2,3,\infty)$ ($\kappa_0 = 1$): $n_1 = 2, n_2 = 1, n_3 = 0$; $N_1 = 2, N_2 = 5/4, N_3 = 2/27$.
  - Modular $\Delta(2,5,\infty)$ ($\kappa_0 = 1$): $n_1 = 1, n_2 = 3, n_3 = -1$; $N_1 = 1, N_2 = 25/8, N_3 = -26/27$.

### 5. Symplectic Lie Algebra Invariance & Bilinear Pairings
- Infinitesimal symplectic Lie algebra condition: $N^T J + J N = 0$ for standard form $J$.
- Polarized Lie algebra condition: $N^T \Omega_6 + \Omega_6 N = 0$ for the $S_6$-polarized form.
- Finite symplectic group invariance: $T_0^T J T_0 = J$ and $T_{0, S_6}^T \Omega_6 T_{0, S_6} = \Omega_6$.
- Symplectic pairing $\langle v, w \rangle_J = v^T J w$ satisfies skew-symmetry, diagonal vanishing, and infinitesimal invariance:
  $$\langle N v, w \rangle_J + \langle v, N w \rangle_J = 0$$
- Polarized pairing $\langle v, w \rangle_{\Omega_6}$ satisfies infinitesimal and finite invariance.

### 6. Higher-Dimensional Griffiths Transversality & PVHS Generalization
- Dimension-independent symplectic forms $J_{2g} = \begin{pmatrix} 0 & I_g \\ -I_g & 0 \end{pmatrix} \in \mathrm{Mat}_{2g}(\mathbb{Z})$ ($g \in \{1, 2, 3\}$):
  $J_{2g}^T = -J_{2g}$ and $J_{2g}^2 = -I_{2g}$.
- Generalized Lie algebra $\mathfrak{sp}_{2g}(\mathbb{Z})$ predicate `IsInfinitesimalSymplecticGen J M` ($M^T J + J M = 0$) and group predicate `IsSymplecticGen J T` ($T^T J T = J$).
- Generalized symplectic bilinear pairing $\langle v, w \rangle_J = v \cdot (J w)$ on $\mathbb{Z}^{2g}$, satisfying skew-symmetry, diagonal vanishing, infinitesimal invariance, and finite invariance.
- 4-dimensional Hodge filtration flag $F^3 \subset F^2 \subset F^1 \subset F^0 = \mathbb{Z}^4$ by coordinate vanishing:
  $$F^3 = \{v \mid v_1=v_2=v_3=0\}, \quad F^2 = \{v \mid v_2=v_3=0\}, \quad F^1 = \{v \mid v_3=0\}, \quad F^0 = \mathbb{Z}^4$$
- Griffiths transversality condition for an operator $M$: $M(F^p) \subseteq F^{p-1}$ for all $p \in \{1, 2, 3\}$.
- Hodge-Riemann bilinear relations: $F^3 \perp F^1$ under $\Omega_6$, $F^2 \perp F^2$ (Lagrangian property) under both $J_4$ and $\Omega_6$.
- Machine-checked operator verifications:
  - Griffiths transversality for $N_{\mathrm{MUM}}$ (CY3 MUM), $N$ ($(3,4,\infty)$), and $N_{S_6}$ ($S_6$ modular family).
  - Parabolic unipotent generators $N_2, T_{0,2} \in \mathrm{Sp}_2(\mathbb{Z}) = \mathrm{SL}_2(\mathbb{Z})$ for $g=1$.
  - Parabolic unipotent generators $N_6, T_{0,6} \in \mathrm{Sp}_6(\mathbb{Z})$ for $g=3$.

## Module Architecture & Index

This module is partitioned into 6 cohesive submodules:

1. **`Formalization.PicardFuchsMirrorMonodromy.DifferentialOperator`**:
   - `PicardFuchsMirrorMonodromy.e1`, `e2`, `e3`, `e4`: Elementary symmetric polynomials on $\mathbb{Q}^4$.
   - `PicardFuchsMirrorMonodromy.pfSymbol`, `pfSymbol_expansion`: Algebraic symbol $\mathcal{L}_4(\theta, z)$.
   - `PicardFuchsMirrorMonodromy.IsCalabiYauSelfDual`: Calabi-Yau self-duality predicate $(\alpha_0+\alpha_3=1)\wedge(\alpha_1+\alpha_2=1)$.
   - `PicardFuchsMirrorMonodromy.self_dual_e1`, `self_dual_sum`: Master self-duality sum theorems ($e_1=2$, $\sum \alpha_i=2$).
   - `PicardFuchsMirrorMonodromy.self_dual_e3_eq_e2_sub_one`, `self_dual_e2_sub_e3`: Master $e_3 = e_2 - 1$ theorem.
   - `PicardFuchsMirrorMonodromy.pfSymbol_self_dual`, `pfSymbol_self_dual_at_one`: Self-dual Picard-Fuchs operator symbol formulas.
   - Parameter tuples & evaluations for $(3,4,\infty)$ geom & mod, $(2,3,\infty)$, $(2,4,\infty)$, $(2,5,\infty)$, $(3,5,\infty)$, $(4,4,\infty)$, Quintic, and Bicubic.
   - `PicardFuchsMirrorMonodromy.indicialPoly`, `indicialPoly_eq`: Indicial polynomial $I_0(\theta) = \theta^4$.

2. **`Formalization.PicardFuchsMirrorMonodromy.CuspMonodromy`**:
   - `PicardFuchsMirrorMonodromy.T0`, `PicardFuchsMirrorMonodromy.N`: Cusp monodromy and nilpotent operator.
   - `PicardFuchsMirrorMonodromy.N_unipotent_index_2`: Proof that $N^2 = 0$.
   - `PicardFuchsMirrorMonodromy.ModularFamilyS6_N_unipotent_index_2`: Proof that $N_{S_6}^2 = 0$.
   - `PicardFuchsMirrorMonodromy.N_act_gamma`, `N_act_u`, `N_act_w`, `N_act_delta`: Action on geometric basis.
   - `PicardFuchsMirrorMonodromy.mulVec_N`, `mulVec_T0`: Matrix-vector multiplication formulas.
   - `PicardFuchsMirrorMonodromy.N_MUM`: Canonical $4 \times 4$ MUM matrix.
   - `PicardFuchsMirrorMonodromy.N_MUM_is_typeIII`: Proof that $N_{\mathrm{MUM}}$ is Type III.
   - `PicardFuchsMirrorMonodromy.N_is_typeII`, `N_not_typeIII`: Classification for $(3,4,\infty)$ monodromy.

3. **`Formalization.PicardFuchsMirrorMonodromy.MirrorMap`**:
   - `PicardFuchsMirrorMonodromy.w0`, `w1_tilde`, `delta_t`: Truncated holomorphic and logarithmic period expansions.
   - `PicardFuchsMirrorMonodromy.q_series`, `z_series`: Flat coordinate mirror map and inverse series.
   - `PicardFuchsMirrorMonodromy.mirror_inversion_sub_z`, `mirror_inversion_sub_q`: Exact algebraic reversion theorems modulo $\mathcal{O}(z^4)$ and $\mathcal{O}(q^4)$.
   - `PicardFuchsMirrorMonodromy.inverseMirrorZ1`, `inverseMirrorZ2`: Inversion coefficients $z_1 = -q_1, z_2 = 2q_1^2 - q_2$.
   - `PicardFuchsMirrorMonodromy.PeriodVector`, `periodVector`, `periodVectorZ`: Period vector types and constructors.
   - `PicardFuchsMirrorMonodromy.expTypeII`, `expTypeIII`: Matrix exponentials for Type II ($I + N$) and Type III ($I + N + \frac{1}{2}N^2 + \frac{1}{6}N^3$).
   - `PicardFuchsMirrorMonodromy.expTypeIII_N_MUM_matrix`, `expTypeIII_N_MUM_act`: Explicit MUM monodromy action on period vectors.
   - `PicardFuchsMirrorMonodromy.monodromyShiftT`, `IsMonodromyInvariant`: Flat coordinate translation $t \mapsto t + 1$.
   - `PicardFuchsMirrorMonodromy.quintic_mirror_map_inversion`: Quintic 3-fold certificate ($z_1 = -770, z_2 = 892525$).
   - `PicardFuchsMirrorMonodromy.modular_34_mirror_map_inversion`: $\Delta(3,4,\infty)$ certificate ($z_1 = -4, z_2 = 14$).
   - `PicardFuchsMirrorMonodromy.modular_23_mirror_map_inversion`: $\Delta(2,3,\infty)$ certificate ($z_1 = -2, z_2 = 3$).

4. **`Formalization.PicardFuchsMirrorMonodromy.YukawaInstantons`**:
   - `PicardFuchsMirrorMonodromy.C_zzz`, `Yukawa`: Classical Special Geometry Yukawa coupling $\frac{\kappa_0}{z^3 (1 - \mu z)}$.
   - `PicardFuchsMirrorMonodromy.regularizedYukawa`, `conifoldRegularizedYukawa`: Singularity regularizations.
   - `PicardFuchsMirrorMonodromy.yukawa_cusp_factorization`, `regularizedYukawa_at_cusp`: Cusp pole behaviors.
   - `PicardFuchsMirrorMonodromy.yukawa_conifold_factorization`, `conifoldRegularizedYukawa_at_conifold`: Conifold pole behaviors.
   - `PicardFuchsMirrorMonodromy.instantonTerm`: Degree-$d$ instanton summand $\frac{d^3 n_d q^d}{1 - q^d}$.
   - `PicardFuchsMirrorMonodromy.C_ttt`, `instantonYukawa`: Finite instanton expansion sum.
   - `PicardFuchsMirrorMonodromy.gwFromBPS`, `bpsFromGW`: Aspinwall-Morrison multi-covering and Möbius inversion.
   - `PicardFuchsMirrorMonodromy.bpsFromGW_gwFromBPS_1`–`4`: Roundtrip inversion theorems.
   - `PicardFuchsMirrorMonodromy.C_GW`, `gwYukawa`: Polynomial Gromov-Witten Yukawa series.
   - `PicardFuchsMirrorMonodromy.instanton_gw_equivalence_deg1`–`3`: Truncated $q$-expansion equivalences.
   - `PicardFuchsMirrorMonodromy.IsBPSIntegral`, `IsBPSPositive`, `IsBPSNonNegative`: Integrality and positivity predicates.
   - Certified counts for Quintic ($d=1,2,3$), $(3,4,\infty)$, $(2,3,\infty)$, and $(2,5,\infty)$.

5. **`Formalization.PicardFuchsMirrorMonodromy.SymplecticInvariance`**:
   - `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplectic`: Symplectic Lie algebra predicate $M^T J + J M = 0$.
   - `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplecticOmega6`: Polarized Lie algebra predicate $M^T \Omega_6 + \Omega_6 M = 0$.
   - `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_N`: Lie algebra verification for $N$.
   - `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_S6_N`: Lie algebra verification for $N_{S_6}$.
   - `PicardFuchsMirrorMonodromy.isSymplectic_T0`, `isSymplectic_S6_T0`: Finite group invariance $T_0^T J T_0 = J$ and $T_0^T \Omega_6 T_0 = \Omega_6$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing`: Standard bilinear form $\langle v, w \rangle_J$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing_skew`, `symplecticPairing_self_zero`: Skew-symmetry and diagonal vanishing.
   - `PicardFuchsMirrorMonodromy.symplecticPairing_N_invariant`: Infinitesimal invariance $\langle N v, w \rangle + \langle v, N w \rangle = 0$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing_T0_invariant`: Finite invariance $\langle T_0 v, T_0 w \rangle = \langle v, w \rangle$.
   - `PicardFuchsMirrorMonodromy.symplecticPairingOmega6`: Polarized form $\langle v, w \rangle_{\Omega_6}$.
   - `PicardFuchsMirrorMonodromy.symplecticPairingOmega6_N_invariant`, `symplecticPairingOmega6_T0_invariant`: $S_6$ pairing invariance.

6. **`Formalization.PicardFuchsMirrorMonodromy.GriffithsTransversality`**:
   - `PicardFuchsMirrorMonodromy.J2`, `J4`, `J6`: Dimension-independent symplectic forms in dimensions 2, 4, 6.
   - `PicardFuchsMirrorMonodromy.J2_transpose`, `J2_squared`, `J4_transpose`, `J4_squared`, `J6_transpose`, `J6_squared`: Symplectic axioms $J^T = -J, J^2 = -I$.
   - `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplecticGen`, `IsSymplecticGen`: Generalized symplectic predicates for $\mathrm{Mat}_n(\mathbb{Z})$.
   - `PicardFuchsMirrorMonodromy.symplecticPairingGen`: Generalized bilinear pairing $v \cdot (J w)$.
   - `PicardFuchsMirrorMonodromy.symplecticPairingGen_skew`, `symplecticPairingGen_self_zero`: Generalized skew-symmetry and diagonal vanishing.
   - `PicardFuchsMirrorMonodromy.symplecticPairingGen_M_invariant`, `symplecticPairingGen_T_invariant`: Generalized infinitesimal and finite invariance.
   - `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_iff_gen`, `isSymplectic_iff_gen`, `isInfinitesimalSymplecticOmega6_iff_gen`: Specialized equivalences.
   - `PicardFuchsMirrorMonodromy.InF3`, `InF2`, `InF1`, `InF0`: Hodge filtration subspaces in $\mathbb{Z}^4$.
   - `PicardFuchsMirrorMonodromy.hodge_filtration_chain`: Inclusion chain $F^3 \subseteq F^2 \subseteq F^1 \subseteq F^0$.
   - `PicardFuchsMirrorMonodromy.SatisfiesGriffithsTransversality`: Griffiths transversality predicate $M(F^p) \subseteq F^{p-1}$.
   - `PicardFuchsMirrorMonodromy.hodge_riemann_orthogonality_F3_F1_Omega6`: Hodge-Riemann orthogonality $F^3 \perp F^1$.
   - `PicardFuchsMirrorMonodromy.hodge_riemann_lagrangian_F2_Omega6`, `hodge_lagrangian_F2`: Lagrangian property $F^2 \perp F^2$.
   - `PicardFuchsMirrorMonodromy.N_MUM_satisfies_GriffithsTransversality`: Transversality verification for $N_{\mathrm{MUM}}$.
   - `PicardFuchsMirrorMonodromy.N_satisfies_GriffithsTransversality`: Transversality verification for $N$.
   - `PicardFuchsMirrorMonodromy.ModularFamilyS6_N_satisfies_GriffithsTransversality`: Transversality verification for $N_{S_6}$.
   - `PicardFuchsMirrorMonodromy.N2`, `T0_2`, `N6`, `T0_6`: Parabolic generators for $g=1$ in $\mathrm{Sp}_2(\mathbb{Z})$ and $g=3$ in $\mathrm{Sp}_6(\mathbb{Z})$.
   - `PicardFuchsMirrorMonodromy.isInfinitesimalSymplecticGen_J2_N2`, `isSymplecticGen_J2_T0_2`, `isInfinitesimalSymplecticGen_J6_N6`, `isSymplecticGen_J6_T0_6`: Dimension 2 and 6 certificates.

## References

- Candelas, P., de la Ossa, X. C., Green, P. S., & Parkes, L. (1991). *A pair of Calabi-Yau manifolds as an exactly soluble superconformal theory*. Nuclear Physics B, 359(1), 21–74.
- Griffiths, P. A. (1970). *Periods of integrals on algebraic manifolds: Summary of main results and discussion of open problems*. Bulletin of the American Mathematical Society, 76(2), 228–296.
- Morrison, D. R. (1993). *Mirror symmetry and rational curves on quintic threefolds: A guide for mathematicians*. Journal of the American Mathematical Society, 6(1), 223–247.
- Schmid, W. (1973). *Variation of Hodge structure: the singularities of the period mapping*. Inventiones Mathematicae, 22(3), 211–319.
- Deligne, P. (1971). *Théorie de Hodge: II*. Publications Mathématiques de l'IHÉS, 40, 5–57.
-/
