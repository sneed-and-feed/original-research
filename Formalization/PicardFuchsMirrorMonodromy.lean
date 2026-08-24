/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.PicardFuchsMirrorMonodromy.DifferentialOperator
import Formalization.PicardFuchsMirrorMonodromy.CuspMonodromy
import Formalization.PicardFuchsMirrorMonodromy.SymplecticInvariance
import Formalization.PicardFuchsMirrorMonodromy.YukawaInstantons

open scoped Matrix BigOperators
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Order-4 Picard-Fuchs Differential Equations & Yukawa Couplings for $\Delta(p,q,\infty)$

This root aggregator module formalizes the analytical, differential-geometric, and mirror-symmetric
structures of the order-4 Picard-Fuchs system for the modular families $\Delta(3,4,\infty)$ and $\Delta(2,3,\infty)$,
connecting the Picard-Fuchs differential operator to the Frobenius cusp monodromy, symplectic Lie algebra
invariance, Griffiths transversality, and classical and multi-instanton Yukawa couplings.

## Mathematical Summary

### 1. Picard-Fuchs Differential Operator $\mathcal{L}_4$
In the logarithmic derivative coordinate $\theta = z \frac{d}{dz}$, the standard order-4
hypergeometric Picard-Fuchs differential equation is:
$$\mathcal{L}_4 = \theta^4 - z(\theta + \alpha_1)(\theta + \alpha_2)(\theta + \alpha_3)(\theta + \alpha_4)$$
where $\alpha = (\alpha_1, \alpha_2, \alpha_3, \alpha_4) \in \mathbb{Q}^4$ are the local Riemann exponents.
- Geometric/mirror family $(3,4,\infty)$: $\alpha = (1/12, 5/12, 7/12, 11/12)$.
- Modular family $(3,4,\infty)$: $\alpha = (1/3, 2/3, 1/4, 3/4)$.
- Modular family $(2,3,\infty)$: $\alpha = (1/6, 5/6, 1/6, 5/6)$.
- Calabi-Yau self-duality sum condition: $\sum_{i=1}^4 \alpha_i = 2$.
- Indicial polynomial at the cusp $z = 0$ is $I_0(\lambda) = \lambda^4$, exhibiting a unique quadruple root at $\lambda = 0$.

### 2. Frobenius Local Monodromy at Cusp $z = 0$
- Parabolic cusp monodromy $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ and nilpotent log-monodromy operator $N = T_0 - I_4$.
- Machine-checked proof that $N$ matches `SymplecticTriangleRepresentations.N` and `ModularFamilyS6.N`.
- Index-2 unipotence: $N^2 = 0$ for the abelian surface modular family $\Delta(3,4,\infty)$ (Type II degeneration).
- Action on basis vectors: $N \gamma = 0$, $N u = 0$, $N w = -u$, $N \delta = \gamma$.
- Calabi-Yau 3-fold MUM (Maximally Unipotent Monodromy): $N_{\mathrm{MUM}}^4 = 0$ and $N_{\mathrm{MUM}}^3 \ne 0$ (Type III degeneration).
- Mutual exclusion and classification between Type I, Type II, and Type III monodromies.

### 3. Symplectic Bilinear Invariance & Griffiths Transversality
- Symplectic Lie algebra condition: $N^T J + J N = 0$ for standard form $J$.
- Symplectic Lie algebra condition: $N^T \Omega_6 + \Omega_6 N = 0$ for the $S_6$-polarized form.
- Symplectic group invariance: $T_0^T J T_0 = J$ and $T_0^T \Omega_6 T_0 = \Omega_6$.
- Symplectic pairing $\langle v, w \rangle_J = v^T J w$ satisfies skew-symmetry and infinitesimal invariance:
  $$\langle N v, w \rangle_J + \langle v, N w \rangle_J = 0$$
- Polarized pairing $\langle v, w \rangle_{\Omega_6}$ satisfies infinitesimal and finite invariance.

### 4. Classical Yukawa Coupling & Multi-Instanton Mirror Map
- Special Geometry Yukawa coupling function $C_{zzz}(z, \kappa_0, \mu) = \frac{\kappa_0}{z^3 (1 - \mu z)}$.
- Regularized cusp function $\kappa_{\mathrm{reg}}(z) = \frac{\kappa_0}{1 - \mu z}$ (order-3 pole at $z = 0$).
- Conifold regularized function $\kappa_{\mathrm{con}}(z) = \frac{\kappa_0}{z^3}$ (discriminant singularity at $z = 1/\mu$).
- Multi-instanton BPS / Gromov-Witten expansion:
  $$C_{ttt}(q, K_0, n) = K_0 + \sum_{d=1}^M \frac{d^3 n_d q^d}{1 - q^d}$$
- Machine-checked certificates for degree 1, degree 2, Quintic Calabi-Yau 3-fold ($n_1 = 2875, n_2 = 609250$), and modular $(3,4,\infty)$ family.

## Module Architecture & Index

This module is partitioned into 4 cohesive submodules:

1. **`Formalization.PicardFuchsMirrorMonodromy.DifferentialOperator`**:
   - `PicardFuchsMirrorMonodromy.e1`, `e2`, `e3`, `e4`: Elementary symmetric polynomials.
   - `PicardFuchsMirrorMonodromy.pfSymbol`: Algebraic symbol $\mathcal{L}_4(\theta, z)$.
   - `PicardFuchsMirrorMonodromy.pfSymbol_expansion`: Full polynomial expansion in powers of $\theta$.
   - `PicardFuchsMirrorMonodromy.alpha_3_4_infty`, `alpha_3_4_mod`, `alpha_2_3_infty`: Parameter tuples.
   - `PicardFuchsMirrorMonodromy.sum_alpha_3_4_infty`, `sum_alpha_3_4_mod`, `sum_alpha_2_3_infty`: Self-duality sum certificates $\sum \alpha_i = 2$.
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

3. **`Formalization.PicardFuchsMirrorMonodromy.SymplecticInvariance`**:
   - `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplectic`: Symplectic Lie algebra predicate.
   - `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplecticOmega6`: Polarized Lie algebra predicate.
   - `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_N`: Lie algebra verification for $N$.
   - `PicardFuchsMirrorMonodromy.isInfinitesimalSymplectic_S6_N`: Lie algebra verification for $N_{S_6}$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing`: Standard bilinear form $\langle v, w \rangle_J$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing_skew`: Skew-symmetry $\langle v, w \rangle = -\langle w, v \rangle$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing_N_invariant`: Infinitesimal invariance $\langle N v, w \rangle + \langle v, N w \rangle = 0$.
   - `PicardFuchsMirrorMonodromy.symplecticPairing_T0_invariant`: Finite invariance $\langle T_0 v, T_0 w \rangle = \langle v, w \rangle$.
   - `PicardFuchsMirrorMonodromy.symplecticPairingOmega6`: Polarized form $\langle v, w \rangle_{\Omega_6}$.
   - `PicardFuchsMirrorMonodromy.symplecticPairingOmega6_N_invariant`, `symplecticPairingOmega6_T0_invariant`: $S_6$ pairing invariance.

4. **`Formalization.PicardFuchsMirrorMonodromy.YukawaInstantons`**:
   - `PicardFuchsMirrorMonodromy.C_zzz`, `Yukawa`: Classical Special Geometry Yukawa coupling.
   - `PicardFuchsMirrorMonodromy.regularizedYukawa`, `conifoldRegularizedYukawa`: Singularity regularizations.
   - `PicardFuchsMirrorMonodromy.yukawa_cusp_factorization`, `regularizedYukawa_at_cusp`: Cusp pole behaviors.
   - `PicardFuchsMirrorMonodromy.yukawa_conifold_factorization`, `conifoldRegularizedYukawa_at_conifold`: Conifold pole behaviors.
   - `PicardFuchsMirrorMonodromy.instantonTerm`: Degree-$d$ instanton summand.
   - `PicardFuchsMirrorMonodromy.C_ttt`, `instantonYukawa`: Finite instanton expansion sum.
   - `PicardFuchsMirrorMonodromy.C_ttt_zero`: Classical intersection limit at $q = 0$.
   - `PicardFuchsMirrorMonodromy.instantonTerm_deg1`, `instantonTerm_deg2`: Low-degree formulas.
   - `PicardFuchsMirrorMonodromy.quintic_instanton_k1`, `quintic_instanton_k2`: Quintic mirror certificates.
   - `PicardFuchsMirrorMonodromy.modular_34_instanton_k1`, `modular_34_instanton_k2`: Modular family certificates.

## References

- Candelas, P., de la Ossa, X. C., Green, P. S., & Parkes, L. (1991). *A pair of Calabi-Yau manifolds as an exactly soluble superconformal theory*. Nuclear Physics B, 359(1), 21–74.
- Griffiths, P. A. (1970). *Periods of integrals on algebraic manifolds: Summary of main results and discussion of open problems*. Bulletin of the American Mathematical Society, 76(2), 228–296.
- Morrison, D. R. (1993). *Mirror symmetry and rational curves on quintic threefolds: A guide for mathematicians*. Journal of the American Mathematical Society, 6(1), 223–247.
- Schmid, W. (1973). *Variation of Hodge structure: the singularities of the period mapping*. Inventiones Mathematicae, 22(3), 211–319.
- Deligne, P. (1971). *Théorie de Hodge: II*. Publications Mathématiques de l'IHÉS, 40, 5–57.
-/
