/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.UniversalMonodromyWeightFiltration.DeligneFormula
import Formalization.UniversalMonodromyWeightFiltration.FiltrationProperties
import Formalization.UniversalMonodromyWeightFiltration.Filtrations4D
import Formalization.UniversalMonodromyWeightFiltration.HodgeRiemannPairing

open scoped Matrix
open Matrix UniversalMonodromyWeightFiltration

set_option linter.unusedSectionVars false

/-!
# Deligne-Schmid Mixed Hodge Weight Filtration $W_\bullet(N)$ & Symplectic Monodromy

This root aggregator module formalizes Deligne's canonical weight filtration formula for nilpotent monodromy
operators $N$ on cohomology and integral lattices, establishing the universal filtration axioms, explicit
4D matrix computations for Type II and Type III geometric degenerations, and Hodge-Riemann polarization pairings.

## Mathematical Summary

### 1. Deligne's Canonical Subspace Formula
For any nilpotent operator $N \in \mathrm{End}(V)$ with $N^{k+1} = 0$:
$$W_l(N, k) = \sum_{j=0}^k \left( \ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k}) \right)$$
Formalized via set unions over general commutative ring coefficients $R$.

### 2. Universal Filtration Properties
- **Monotonicity**: $W_l(N, k) \subseteq W_{l+1}(N, k)$ and $W_{l_1}(N, k) \subseteq W_{l_2}(N, k)$ for $l_1 \le l_2$.
- **Extremal Exhaustion**: $0 \in W_l$ for all $l$, and $W_{2k}(N, k) = V$ (the full space).
- **Fundamental Weight Shift**: $N(W_l(N, k)) \subseteq W_{l-2}(N, k)$.

### 3. Explicit Weight 2 Filtration for $(3,4,\infty)$ Modular Monodromy
For $N = T_0 - I_4 \in \mathrm{Mat}_4(\mathbb{Z})$ (Type II degeneration of abelian surfaces, $N^2 = 0$):
- $W_0 = \{0\}$
- $W_1 = \operatorname{im}(N) = \ker(N^2) \cap \operatorname{im}(N) \subseteq \ker(N)$ (rank 2 isotropic subspace)
- $W_2 = \mathbb{Z}^4 = \ker(N^2)$ (full space)
- Explicit basis action: $N\gamma = 0$, $Nu = -\gamma$, $Nw = \delta$, $N\delta = 0$.
- $S_6$-family action: $N_{S_6}\gamma = 0$, $N_{S_6}u = 0$, $N_{S_6}w = -u$, $N_{S_6}\delta = \gamma$.

### 4. Explicit Weight 3 Filtration for Type III MUM Monodromy
For $N_{\mathrm{MUM}}$ with $N_{\mathrm{MUM}}^4 = 0$ (CY3 Maximally Unipotent Monodromy):
- Complete chain: $W_0 = \{0\} \subset W_1 \subset W_2 \subset W_3 \subset W_4 = \mathbb{Z}^4$.
- Step shift inclusions: $N_{\mathrm{MUM}}(W_j) \subseteq W_{j-1}$ and $N_{\mathrm{MUM}}^2(W_j) \subseteq W_{j-2}$.

### 5. Hodge-Riemann Symplectic Polarization & Positivity Certificates
- Infinitesimal symplectic Lie algebra identities: $J N + N^T J = 0$ and $N^T J + J N = 0$.
- Polarized bilinear form: $Q_N(v, w) = \langle v, N w \rangle_J$.
- Symmetry: $Q_N(v, w) = Q_N(w, v)$ on $\mathbb{Z}^4$.
- Machine-checked strict positivity certificate: $Q_N(u+w, u+w) = 2 > 0$.
- $S_6$-family polarized form $Q_{N_{S_6}}$: symmetry, positivity $Q_{N_{S_6}}(w, w) = 6 > 0$, and non-degeneracy $Q_{N_{S_6}}(\delta, \delta) = -1 \ne 0$.

## Module Architecture & Index

This module is partitioned into 4 cohesive submodules:

1. **`Formalization.UniversalMonodromyWeightFiltration.DeligneFormula`**:
   - `UniversalMonodromyWeightFiltration.kerMat`, `UniversalMonodromyWeightFiltration.imMat`: Kernel and image subsets.
   - `UniversalMonodromyWeightFiltration.imPower`, `UniversalMonodromyWeightFiltration.kerPower`: Generalized matrix powers.
   - `UniversalMonodromyWeightFiltration.DeligneSummand`: The $(j, l, k)$-summand $\ker(N^{j+1}) \cap \operatorname{im}(N^{j - l + k})$.
   - `UniversalMonodromyWeightFiltration.DeligneWeightSpace`: The Deligne weight space $W_l(N, k)$.
   - `UniversalMonodromyWeightFiltration.zero_mem_kerPower`, `zero_mem_imPower`, `zero_mem_DeligneSummand`, `zero_mem_DeligneWeightSpace`: Zero vector inclusion.
   - `UniversalMonodromyWeightFiltration.imPower_anti`: Antitone inclusion of image powers.
   - `UniversalMonodromyWeightFiltration.DeligneSummand_subset_succ`, `DeligneWeightSpace_subset_succ`: Step inclusions.

2. **`Formalization.UniversalMonodromyWeightFiltration.FiltrationProperties`**:
   - `UniversalMonodromyWeightFiltration.DeligneWeightSpace_mono`, `DeligneWeightSpace_mono_le`: Monotonicity of the weight filtration.
   - `UniversalMonodromyWeightFiltration.N_mulVec_mem_kerPower_pred`: Operator step on kernel powers.
   - `UniversalMonodromyWeightFiltration.N_mulVec_mem_imPower_succ`: Operator step on image powers.
   - `UniversalMonodromyWeightFiltration.DeligneWeightSpace_top`: Top space theorem $W_{2k}(N, k) = V$.
   - `UniversalMonodromyWeightFiltration.DeligneWeightSpace_shift`: Fundamental shift theorem $N(W_l) \subseteq W_{l-2}$.

3. **`Formalization.UniversalMonodromyWeightFiltration.Filtrations4D`**:
   - `UniversalMonodromyWeightFiltration.W0_34`, `W1_34`, `W2_34`: Weight spaces for $(3,4,\infty)$ Type II degeneration.
   - `UniversalMonodromyWeightFiltration.W0_sub_W1`, `W1_sub_W2`, `weight_filtration_chain_34`: Verified chain inclusions.
   - `UniversalMonodromyWeightFiltration.N_act_W1_in_W0`, `N_act_W2_in_W1`, `N_act_W2_in_W0`: Step shifts for $(3,4,\infty)$.
   - `UniversalMonodromyWeightFiltration.N_act_gamma`, `N_act_u`, `N_act_w`, `N_act_delta`: Geometric basis action.
   - `UniversalMonodromyWeightFiltration.S6_N_act_gamma`, `S6_N_act_u`, `S6_N_act_w`, `S6_N_act_delta`: $S_6$ monodromy action.
   - `UniversalMonodromyWeightFiltration.W_MUM_0` through `W_MUM_4`: Weight spaces for CY3 MUM.
   - `UniversalMonodromyWeightFiltration.W_MUM_complete_chain`: Complete 4-step chain for MUM.
   - `UniversalMonodromyWeightFiltration.mulVec_N_MUM`: Explicit matrix multiplication for $N_{\mathrm{MUM}}$.
   - `UniversalMonodromyWeightFiltration.N_MUM_act_W0` through `N_MUM_act_W4`: 1-step shifts $N(W_j) \subseteq W_{j-1}$.
   - `UniversalMonodromyWeightFiltration.N_MUM_shift_2_0`, `N_MUM_shift_3_1`, `N_MUM_shift_4_2`: 2-step shifts $N^2(W_j) \subseteq W_{j-2}$.

4. **`Formalization.UniversalMonodromyWeightFiltration.HodgeRiemannPairing`**:
   - `UniversalMonodromyWeightFiltration.J_N_plus_NT_J_zero`, `NT_J_plus_J_N_zero`: Infinitesimal symplectic Lie algebra identities.
   - `UniversalMonodromyWeightFiltration.Q_N`: Hodge-Riemann polarized form $\langle v, N w \rangle_J$.
   - `UniversalMonodromyWeightFiltration.Q_N_symm`: Symmetry of $Q_N$.
   - `UniversalMonodromyWeightFiltration.Q_N_u_w`, `Q_N_w_u`, `Q_N_u_u`, `Q_N_w_w`: Primitive evaluations.
   - `UniversalMonodromyWeightFiltration.Q_N_u_add_w_eval`, `Q_N_u_add_w_strictly_positive`: Strict positivity on $u+w$.
   - `UniversalMonodromyWeightFiltration.Q_N_S6`, `Q_N_S6_symm`: $S_6$ polarized form and symmetry.
   - `UniversalMonodromyWeightFiltration.Q_N_S6_w_pos`, `Q_N_S6_w_strictly_positive`: $S_6$ strict positivity on $w$.
   - `UniversalMonodromyWeightFiltration.Q_N_S6_delta_eval`, `Q_N_S6_delta_nondegenerate`: $S_6$ non-degeneracy on $\delta$.

## References

- Deligne, P. (1971). *Théorie de Hodge: II*. Publications Mathématiques de l'IHÉS, 40, 5–57.
- Schmid, W. (1973). *Variation of Hodge structure: the singularities of the period mapping*. Inventiones Mathematicae, 22(3), 211–319.
- Griffiths, P. A. (1970). *Periods of integrals on algebraic manifolds: Summary of main results and discussion of open problems*. Bulletin of the American Mathematical Society, 76(2), 228–296.
- Morrison, D. R. (1993). *Mirror symmetry and rational curves on quintic threefolds: A guide for mathematicians*. Journal of the American Mathematical Society, 6(1), 223–247.
-/
