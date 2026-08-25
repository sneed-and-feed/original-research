/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace
import Formalization.AbelianSurfaceDegenerations.NilpotentOrbit
import Formalization.AbelianSurfaceDegenerations.BoundaryStratification
import Formalization.AbelianSurfaceDegenerations.PicardStratification

open scoped Matrix
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Abelian Surface Degenerations, Siegel Moduli $\mathcal{A}_2$, & Picard Stratification

This root aggregator module formalizes the degeneration of polarized abelian surfaces and their period matrices
over the modular curve $\mathcal{X}(3,4,\infty)$, connecting the Siegel upper half-space $\mathbb{H}_2$,
$\mathrm{Sp}_4(\mathbb{Z})$ fractional linear actions, Schmid's Nilpotent Orbit Theorem, Kodaira–Mumford
boundary stratification of $\partial \overline{\mathcal{A}_2}$, and the Néron–Severi rank / Picard number
stratification $\rho(A_t)$.

## Mathematical Overview

### 1. Siegel Upper Half-Space $\mathbb{H}_2$
The Siegel upper half-space of genus $g=2$ parameterizes principally polarized abelian surfaces (PPAS)
$A \cong \mathbb{C}^2 / (\mathbb{Z}^2 \oplus Z \mathbb{Z}^2)$:
$$\mathbb{H}_2 = \{ Z \in \mathrm{Mat}_2(\mathbb{C}) \mid Z^T = Z, \, \operatorname{Im}(Z) > 0 \}$$
For a real symmetric $2 \times 2$ matrix $Y = \operatorname{Im}(Z)$, positive definiteness $Y > 0$ is
characterized by the Sylvester condition:
$$\mathrm{IsPosDef2}(Y) \iff Y_{00} > 0 \wedge \det(Y) > 0 \wedge Y_{01} = Y_{10}$$
which machine-verifies that $Y_{11} > 0$, $\operatorname{Tr}(Y) > 0$, and the quadratic form $v^T Y v > 0$
for all non-zero vectors $v \in \mathbb{R}^2 \setminus \{0\}$.

### 2. $\mathrm{Sp}_4(\mathbb{Z})$ Fractional Linear Transformation
A symplectic matrix $M \in \mathrm{Sp}_4(\mathbb{Z})$ partitioned into $2 \times 2$ blocks
$M = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$ acts transitively on $\mathbb{H}_2$ via the
matrix fractional linear transformation:
$$M \cdot Z = (A Z + B)(C Z + D)^{-1}$$
satisfying the block symplectic relations $A^T C = C^T A$, $B^T D = D^T B$, and $A^T D - C^T B = I_2$.
Translations $Z \mapsto Z + B$ for real symmetric $B$ preserve the imaginary part $\operatorname{Im}(Z)$
and map $\mathbb{H}_2$ into itself.

### 3. Nilpotent Orbit Theorem (Schmid 1973)
Around the parabolic cusp $t = 0$, the period map has unipotent monodromy $T_0 = I_4 + N$ where
$N^2 = 0, N \ne 0$. The period matrix is approximated by the nilpotent orbit:
$$\tau_{\mathrm{nilp}}(\tau_0, z) = \tau_0 + z N_\tau, \quad N_\tau = \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}$$
where $z = \frac{1}{2\pi i} \log t \in \mathbb{H}$. We provide machine-checked proofs that:
1. $\tau_{\mathrm{nilp}}(\tau_0, z) \in \mathbb{H}_2$ for all $z \in \mathbb{C}$ with $\operatorname{Im}(z) \ge 0$.
2. $\tau_{\mathrm{nilp}}(\tau_0, z+1) = \tau_{\mathrm{nilp}}(\tau_0, z) + N_\tau$ (Monodromy Periodicity).

### 4. Kodaira–Mumford Boundary Stratification of $\partial \overline{\mathcal{A}_2}$
The Satake / toroidal compactification $\overline{\mathcal{A}_2} = \mathcal{A}_2 \cup \Delta_1 \cup \Delta_0$
is stratified by the toric rank $r \in \{0, 1, 2\}$ of the semi-abelian reduction:
- $\mathcal{A}_2$ (toric rank 0, abelian rank 2): smooth abelian surfaces.
- $\Delta_1 \cong \mathcal{A}_1$ (toric rank 1, abelian rank 1): semi-abelian extensions $0 \to \mathbb{G}_m \to A_0 \to E \to 0$.
- $\Delta_0 \cong \mathcal{A}_0$ (toric rank 2, abelian rank 0): 2-tori $\mathbb{G}_m^2$.

The $(3,4,\infty)$ cusp monodromy $N$ is proven to be strictly Type II ($N \ne 0, N^2 = 0$), certifying
that the degenerating fiber lands in $\Delta_1$ with limit elliptic curve parameter $\tau_{22} \in \mathbb{H}_1$.

### 5. Néron–Severi / Picard Number Stratification $\rho(A_t)$
The Picard number $\rho(A_t) = \operatorname{rank} \mathrm{NS}(A_t)$ satisfies $1 \le \rho(A_t) \le 4$:
- Generic fiber: $\operatorname{End}^0(A_{\mathrm{gen}}) \cong \mathbb{Q}$, simple, $\rho(A_{\mathrm{gen}}) = 1$.
- Order 3 fiber $t_1$: automorphism $T_1$ induces CM by $\mathbb{Z}[\zeta_3]$, splitting $A_{t_1} \sim E_{\zeta_3} \times E_{\zeta_3}$, $\rho(A_{t_1}) = 4 \ge 2$.
- Order 4 fiber $t_2$: automorphism $T_2$ induces CM by $\mathbb{Z}[i]$, splitting $A_{t_2} \sim E_i \times E_i$, $\rho(A_{t_2}) = 4 \ge 2$.

The Master Néron–Severi Stratification Theorem formally certifies the Picard rank jumps $\Delta \rho = 3 \ge 1$.

## Module Architecture & Index

This module is partitioned into 4 cohesive submodules:

1. **`Formalization.AbelianSurfaceDegenerations.SiegelSpace`**:
   - `AbelianSurfaceDegenerations.imMatrix`, `reMatrix`: Real matrix projections of complex matrices.
   - `AbelianSurfaceDegenerations.det2`, `trace2`, `quadForm`: Matrix algebraic invariants.
   - `AbelianSurfaceDegenerations.IsPosDef2`: Positive definiteness predicate for $2 \times 2$ matrices.
   - `AbelianSurfaceDegenerations.posDef_implies_M11_pos`: $M_{11} > 0$ under positive definiteness.
   - `AbelianSurfaceDegenerations.posDef_implies_trace_pos`: $\operatorname{Tr}(M) > 0$ under positive definiteness.
   - `AbelianSurfaceDegenerations.quadForm_scaled_identity`: Algebraic completion of squares identity.
   - `AbelianSurfaceDegenerations.posDef_quadForm_pos`: Strict positivity $v^T M v > 0$ for $v \ne 0$.
   - `AbelianSurfaceDegenerations.SiegelHalfSpace2`: Genus-2 Siegel upper half-space structure.
   - `AbelianSurfaceDegenerations.diagPeriod`, `diagPeriod_in_Siegel`: Canonical diagonal period points.
   - `AbelianSurfaceDegenerations.blockA`, `blockB`, `blockC`, `blockD`: $2 \times 2$ block projections.
   - `AbelianSurfaceDegenerations.T1_block_*`, `T2_block_*`, `T0_block_*`: Symplectic block relations.
   - `AbelianSurfaceDegenerations.det2C`, `adjugate2C`, `inv2C`: Inversion formulas for $2 \times 2$ complex matrices.
   - `AbelianSurfaceDegenerations.fltAction`: Fractional linear transformation.
   - `AbelianSurfaceDegenerations.translation_in_Siegel`: Translation invariance of $\mathbb{H}_2$.

2. **`Formalization.AbelianSurfaceDegenerations.NilpotentOrbit`**:
   - `AbelianSurfaceDegenerations.N_tau`, `N_tau_C`: Nilpotent period shift matrices.
   - `AbelianSurfaceDegenerations.nilpotentOrbit`: Nilpotent orbit period map $\tau_{\mathrm{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$.
   - `AbelianSurfaceDegenerations.imMatrix_nilpotentOrbit`: Imaginary part expansion.
   - `AbelianSurfaceDegenerations.nilpotent_orbit_in_Siegel`: Positivity theorem for $\operatorname{Im}(z) \ge 0$.
   - `AbelianSurfaceDegenerations.nilpotent_orbit_monodromy_periodicity`: Monodromy periodicity $\tau(z+1) = \tau(z) + N_\tau$.
   - `AbelianSurfaceDegenerations.nilpotentOrbitReal`, `nilpotent_orbit_real_in_Siegel`: Real ray parametrization and positivity.

3. **`Formalization.AbelianSurfaceDegenerations.BoundaryStratification`**:
   - `AbelianSurfaceDegenerations.BoundaryStratum`: Inductive stratification (`Interior`, `BoundaryDelta1`, `BoundaryDelta0`).
   - `AbelianSurfaceDegenerations.toricRank`, `abelianRank`: Invariant rank dimensions.
   - `AbelianSurfaceDegenerations.semiabelian_dim_conservation`: Rank conservation $\operatorname{toricRank}(s) + \operatorname{abelianRank}(s) = 2$.
   - `AbelianSurfaceDegenerations.stratumOfMonodromy`: Classification mapping.
   - `AbelianSurfaceDegenerations.cusp_34_in_Delta1`: Proof that $(3,4,\infty)$ cusp monodromy lands in $\Delta_1$.
   - `AbelianSurfaceDegenerations.cusp_34_toric_rank_eq_one`, `cusp_34_abelian_rank_eq_one`: Rank certifications.
   - `AbelianSurfaceDegenerations.limitEllipticParameter`, `limitEllipticParameter_in_H1`: Limit elliptic curve parameter in $\mathbb{H}_1$.

4. **`Formalization.AbelianSurfaceDegenerations.PicardStratification`**:
   - `AbelianSurfaceDegenerations.EndomorphismAlgebraType`: Endomorphism algebra classification.
   - `AbelianSurfaceDegenerations.picardNumberOfType`: Exact Picard number mapping.
   - `AbelianSurfaceDegenerations.picard_number_bounds`: Universal bounds $1 \le \rho(A) \le 4$.
   - `AbelianSurfaceDegenerations.BaseCurvePoint`: Modular base curve point type.
   - `AbelianSurfaceDegenerations.fiberEndomorphismType`, `fiberPicardNumber`: Fiber invariants.
   - `AbelianSurfaceDegenerations.generic_fiber_picard_eq_one`: Generic Picard number $\rho = 1$.
   - `AbelianSurfaceDegenerations.order3_fiber_picard_eq_four`, `order4_fiber_picard_eq_four`: Special CM fiber Picard numbers $\rho = 4$.
   - `AbelianSurfaceDegenerations.picard_strict_increase_order3`, `picard_strict_increase_order4`: Strict rank inequalities.
   - `AbelianSurfaceDegenerations.master_neron_severi_stratification`: Master Néron–Severi stratification theorem.
   - `AbelianSurfaceDegenerations.TriangleBaseCurvePoint`: Parameterized base curve points for signature $(p,q,\infty)$.
   - `AbelianSurfaceDegenerations.generalizedFiberEndomorphismType`: Fiber endomorphism algebra for signature $(p,q,\infty)$.
   - `AbelianSurfaceDegenerations.generalizedFiberPicardNumber`: Fiber Picard number for signature $(p,q,\infty)$.
   - `AbelianSurfaceDegenerations.generic_fiber_picard_eq_one_gen`: $\rho(A_{\mathrm{gen}}) = 1$ in general.
   - `AbelianSurfaceDegenerations.order_p_fiber_picard_ge_two`, `order_q_fiber_picard_ge_two`: Picard number bounds at elliptic points.
   - `AbelianSurfaceDegenerations.picard_jump_order_p_ge_one`, `picard_jump_order_q_ge_one`: Jump theorems $\Delta \rho \ge 1$.
   - `AbelianSurfaceDegenerations.picard_strict_increase_order_p`, `picard_strict_increase_order_q`: Strict jumps $\rho(A_{\mathrm{gen}}) < \rho(A_{t_i})$.
   - `AbelianSurfaceDegenerations.master_generalized_neron_severi_stratification`: Master stratification theorem for general $(p,q,\infty)$.
   - `AbelianSurfaceDegenerations.stratification_23`, `stratification_24`, `stratification_25`, `stratification_34`, `stratification_35`, `stratification_44`: Concrete certified instances for triangle signatures.

## References

- Birkenhake, C., & Lange, H. (2004). *Complex Abelian Varieties* (2nd ed.). Grundlehren der mathematischen Wissenschaften, 302, Springer-Verlag.
- Deligne, P. (1971). *Théorie de Hodge: II*. Publications Mathématiques de l'IHÉS, 40, 5–57.
- Faltings, G., & Chai, C.-L. (1990). *Degeneration of Abelian Varieties*. Ergebnisse der Mathematik und ihrer Grenzgebiete, 22, Springer-Verlag.
- Mumford, D. (1977). *Hirzebruch's proportionality theorem in the non-compact case*. Inventiones Mathematicae, 42(1), 239–272.
- Schmid, W. (1973). *Variation of Hodge structure: the singularities of the period mapping*. Inventiones Mathematicae, 22(3), 211–319.
-/
