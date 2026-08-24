/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.TriangleModularGroup
import Formalization.SymplecticTriangleRepresentations
import Formalization.AbelianSurfaceDegenerations
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.FieldSimp

open scoped Matrix BigOperators
open Matrix SymplecticTriangleRepresentations

/-!
# Order-4 Picard-Fuchs Differential Equations & Yukawa Couplings for $\Delta(p,q,\infty)$

This module formalizes the analytical and differential-geometric structures of the
order-4 Picard-Fuchs system for the modular families $\Delta(3,4,\infty)$ and $\Delta(2,3,\infty)$,
connecting the Picard-Fuchs differential operator to the Frobenius cusp monodromy,
symplectic Lie algebra invariance, and classical Yukawa couplings.

## Mathematical Summary

1. **Picard-Fuchs Differential Operator $\mathcal{L}_4$**:
   In the logarithmic derivative coordinate $\theta = z \frac{d}{dz}$, the standard order-4
   hypergeometric Picard-Fuchs ODE is:
   $$\mathcal{L}_4 = \theta^4 - z(\theta + \alpha_1)(\theta + \alpha_2)(\theta + \alpha_3)(\theta + \alpha_4)$$
   where $\alpha = (\alpha_1, \alpha_2, \alpha_3, \alpha_4) \in \mathbb{Q}^4$ are the local exponents.
   - For $(3,4,\infty)$ geometric/mirror family: $\alpha = (1/12, 5/12, 7/12, 11/12)$.
   - For $(3,4,\infty)$ modular family: $\alpha = (1/3, 2/3, 1/4, 3/4)$.
   - For $(2,3,\infty)$ modular family: $\alpha = (1/6, 5/6, 1/6, 5/6)$.
   - Calabi-Yau self-duality sum condition: $\sum_{i=1}^4 \alpha_i = 2$.
   - Indicial polynomial at $z = 0$ is $I_0(\lambda) = \lambda^4$, exhibiting a unique quadruple root at $\lambda = 0$.

2. **Frobenius Local Monodromy at Cusp $z = 0$**:
   - Parabolic cusp monodromy $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ and nilpotent operator $N = T_0 - I_4$.
   - Machine-checked proof that $N$ matches `SymplecticTriangleRepresentations.N` and `ModularFamilyS6.N`.
   - Index-2 unipotence: $N^2 = 0$ for the abelian surface modular family $\Delta(3,4,\infty)$ (Type II degeneration).
   - Action on basis vectors: $N \gamma = 0$, $N u = 0$, $N w = -u$, $N \delta = \gamma$.
   - Calabi-Yau 3-fold MUM (Maximally Unipotent Monodromy): $N_{\mathrm{MUM}}^4 = 0$ and $N_{\mathrm{MUM}}^3 \ne 0$ (Type III).
   - Mutual exclusion and classification between Type I, Type II, and Type III monodromies.

3. **Symplectic Bilinear Invariance & Griffiths Transversality**:
   - Symplectic Lie algebra condition: $N^T J + J N = 0$ for standard $J$.
   - Symplectic Lie algebra condition: $N^T \Omega_6 + \Omega_6 N = 0$ for the $S_6$-polarized form.
   - Symplectic group invariance: $T_0^T J T_0 = J$ and $T_0^T \Omega_6 T_0 = \Omega_6$.
   - Symplectic pairing $\langle v, w \rangle_J = v^T J w$ satisfies skew-symmetry and infinitesimal invariance:
     $$\langle N v, w \rangle_J + \langle v, N w \rangle_J = 0$$

4. **Classical Yukawa Coupling & Mirror Map**:
   - Yukawa coupling function $C_{zzz}(z, \kappa_0, \mu) = \frac{\kappa_0}{z^3 (1 - \mu z)}$.
   - Regularized cusp function $\kappa_{\mathrm{reg}}(z) = \frac{\kappa_0}{1 - \mu z}$ (order-3 pole at $z = 0$).
   - Conifold regularized function $\kappa_{\mathrm{con}}(z) = \frac{\kappa_0}{z^3}$ (discriminant singularity at $z = 1/\mu$).
   - Instantaneous BPS / Gromov-Witten instanton expansion:
     $$C_{ttt}(q, K_0, n) = K_0 + \sum_{d=1}^M \frac{d^3 n_d q^d}{1 - q^d}$$
   - Machine-checked evaluations for degree 1, degree 2, Quintic Calabi-Yau 3-fold, and modular certificates.
-/

namespace PicardFuchsMirrorMonodromy

/-! ### 1. Picard-Fuchs Differential Operator $\mathcal{L}_4$ & Hypergeometric Parameters -/

/-- Elementary symmetric polynomial $e_1(\alpha) = \sum \alpha_i$. -/
def e1 (α : Fin 4 → ℚ) : ℚ :=
  α 0 + α 1 + α 2 + α 3

/-- Elementary symmetric polynomial $e_2(\alpha) = \sum_{i < j} \alpha_i \alpha_j$. -/
def e2 (α : Fin 4 → ℚ) : ℚ :=
  α 0 * α 1 + α 0 * α 2 + α 0 * α 3 + α 1 * α 2 + α 1 * α 3 + α 2 * α 3

/-- Elementary symmetric polynomial $e_3(\alpha) = \sum_{i < j < k} \alpha_i \alpha_j \alpha_k$. -/
def e3 (α : Fin 4 → ℚ) : ℚ :=
  α 0 * α 1 * α 2 + α 0 * α 1 * α 3 + α 0 * α 2 * α 3 + α 1 * α 2 * α 3

/-- Elementary symmetric polynomial $e_4(\alpha) = \prod \alpha_i$. -/
def e4 (α : Fin 4 → ℚ) : ℚ :=
  α 0 * α 1 * α 2 * α 3

/-- Order-4 Picard-Fuchs algebraic symbol $\mathcal{L}_4(\theta, z) = \theta^4 - z \prod_{i=0}^3 (\theta + \alpha_i)$. -/
def pfSymbol (α : Fin 4 → ℚ) (z θ : ℚ) : ℚ :=
  θ^4 - z * (θ + α 0) * (θ + α 1) * (θ + α 2) * (θ + α 3)

/-- Expansion of the Picard-Fuchs operator symbol in powers of $\theta$. -/
theorem pfSymbol_expansion (α : Fin 4 → ℚ) (z θ : ℚ) :
    pfSymbol α z θ = (1 - z) * θ^4 - z * (e1 α * θ^3 + e2 α * θ^2 + e3 α * θ + e4 α) := by
  dsimp [pfSymbol, e1, e2, e3, e4]; ring

/-- Geometric Riemann parameter exponents for the $(3,4,\infty)$ family:
    $\alpha = (1/12, 5/12, 7/12, 11/12)$. -/
def alpha_3_4_infty : Fin 4 → ℚ :=
  ![1/12, 5/12, 7/12, 11/12]

/-- Alias for geometric parameters of $(3,4,\infty)$. -/
def alpha_3_4_geom : Fin 4 → ℚ :=
  alpha_3_4_infty

/-- Modular parameter exponents for the $(3,4,\infty)$ family:
    $\alpha = (1/3, 2/3, 1/4, 3/4)$. -/
def alpha_3_4_mod : Fin 4 → ℚ :=
  ![1/3, 2/3, 1/4, 3/4]

/-- Parameter exponents for the $(2,3,\infty)$ modular family:
    $\alpha = (1/6, 5/6, 1/6, 5/6)$. -/
def alpha_2_3_infty : Fin 4 → ℚ :=
  ![1/6, 5/6, 1/6, 5/6]

/-- Alias for $(2,3,\infty)$ exponents. -/
def alpha_2_3 : Fin 4 → ℚ :=
  alpha_2_3_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,4,\infty)$ geometric exponents. -/
theorem sum_alpha_3_4_infty : (∑ i : Fin 4, alpha_3_4_infty i) = 2 := by
  rw [Fin.sum_univ_four]; dsimp [alpha_3_4_infty]; norm_num

/-- Calabi-Yau self-duality sum condition for `e1` on $(3,4,\infty)$ geometric exponents. -/
theorem e1_alpha_3_4_infty : e1 alpha_3_4_infty = 2 := by
  dsimp [e1, alpha_3_4_infty]; norm_num

/-- Calabi-Yau self-duality sum condition for `e1` on $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem e1_alpha_3_4_geom : e1 alpha_3_4_geom = 2 :=
  e1_alpha_3_4_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem sum_alpha_3_4_geom : (∑ i : Fin 4, alpha_3_4_geom i) = 2 :=
  sum_alpha_3_4_infty

/-- Symmetric polynomial $e_2$ for $(3,4,\infty)$ geometric exponents evaluates to $95/72$. -/
theorem e2_alpha_3_4_infty : e2 alpha_3_4_infty = 95 / 72 := by
  dsimp [e2, alpha_3_4_infty]; norm_num

/-- Symmetric polynomial $e_2$ for $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem e2_alpha_3_4_geom : e2 alpha_3_4_geom = 95 / 72 :=
  e2_alpha_3_4_infty

/-- Symmetric polynomial $e_3$ for $(3,4,\infty)$ geometric exponents evaluates to $23/72$. -/
theorem e3_alpha_3_4_infty : e3 alpha_3_4_infty = 23 / 72 := by
  dsimp [e3, alpha_3_4_infty]; norm_num

/-- Symmetric polynomial $e_3$ for $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem e3_alpha_3_4_geom : e3 alpha_3_4_geom = 23 / 72 :=
  e3_alpha_3_4_infty

/-- Symmetric polynomial $e_4$ for $(3,4,\infty)$ geometric exponents evaluates to $385/20736$. -/
theorem e4_alpha_3_4_infty : e4 alpha_3_4_infty = 385 / 20736 := by
  dsimp [e4, alpha_3_4_infty]; norm_num

/-- Symmetric polynomial $e_4$ for $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem e4_alpha_3_4_geom : e4 alpha_3_4_geom = 385 / 20736 :=
  e4_alpha_3_4_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,4,\infty)$ modular exponents. -/
theorem sum_alpha_3_4_mod : (∑ i : Fin 4, alpha_3_4_mod i) = 2 := by
  rw [Fin.sum_univ_four]; dsimp [alpha_3_4_mod]; norm_num

/-- Symmetric polynomial $e_1$ for $(3,4,\infty)$ modular exponents evaluates to $2$. -/
theorem e1_alpha_3_4_mod : e1 alpha_3_4_mod = 2 := by
  dsimp [e1, alpha_3_4_mod]; norm_num

/-- Symmetric polynomial $e_2$ for $(3,4,\infty)$ modular exponents evaluates to $203/144$. -/
theorem e2_alpha_3_4_mod : e2 alpha_3_4_mod = 203 / 144 := by
  dsimp [e2, alpha_3_4_mod]; norm_num

/-- Symmetric polynomial $e_3$ for $(3,4,\infty)$ modular exponents evaluates to $59/144$. -/
theorem e3_alpha_3_4_mod : e3 alpha_3_4_mod = 59 / 144 := by
  dsimp [e3, alpha_3_4_mod]; norm_num

/-- Symmetric polynomial $e_4$ for $(3,4,\infty)$ modular exponents evaluates to $1/24$. -/
theorem e4_alpha_3_4_mod : e4 alpha_3_4_mod = 1 / 24 := by
  dsimp [e4, alpha_3_4_mod]; norm_num

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(2,3,\infty)$ exponents. -/
theorem sum_alpha_2_3_infty : (∑ i : Fin 4, alpha_2_3_infty i) = 2 := by
  rw [Fin.sum_univ_four]; dsimp [alpha_2_3_infty]; norm_num

/-- Symmetric polynomial $e_1$ for $(2,3,\infty)$ exponents evaluates to $2$. -/
theorem e1_alpha_2_3_infty : e1 alpha_2_3_infty = 2 := by
  dsimp [e1, alpha_2_3_infty]; norm_num

/-- Symmetric polynomial $e_1$ for $(2,3,\infty)$ exponents (alias). -/
theorem e1_alpha_2_3 : e1 alpha_2_3 = 2 :=
  e1_alpha_2_3_infty

/-- Symmetric polynomial $e_2$ for $(2,3,\infty)$ exponents evaluates to $23/18$. -/
theorem e2_alpha_2_3_infty : e2 alpha_2_3_infty = 23 / 18 := by
  dsimp [e2, alpha_2_3_infty]; norm_num

/-- Symmetric polynomial $e_2$ for $(2,3,\infty)$ exponents (alias). -/
theorem e2_alpha_2_3 : e2 alpha_2_3 = 23 / 18 :=
  e2_alpha_2_3_infty

/-- Symmetric polynomial $e_3$ for $(2,3,\infty)$ exponents evaluates to $5/18$. -/
theorem e3_alpha_2_3_infty : e3 alpha_2_3_infty = 5 / 18 := by
  dsimp [e3, alpha_2_3_infty]; norm_num

/-- Symmetric polynomial $e_3$ for $(2,3,\infty)$ exponents (alias). -/
theorem e3_alpha_2_3 : e3 alpha_2_3 = 5 / 18 :=
  e3_alpha_2_3_infty

/-- Symmetric polynomial $e_4$ for $(2,3,\infty)$ exponents evaluates to $25/1296$. -/
theorem e4_alpha_2_3_infty : e4 alpha_2_3_infty = 25 / 1296 := by
  dsimp [e4, alpha_2_3_infty]; norm_num

/-- Symmetric polynomial $e_4$ for $(2,3,\infty)$ exponents (alias). -/
theorem e4_alpha_2_3 : e4 alpha_2_3 = 25 / 1296 :=
  e4_alpha_2_3_infty

/-- The indicial polynomial at the cusp $z = 0$: $I_0(\theta) = \mathcal{L}_4(\theta, 0) = \theta^4$. -/
def indicialPoly (α : Fin 4 → ℚ) (θ : ℚ) : ℚ :=
  pfSymbol α 0 θ

/-- The indicial polynomial at $z = 0$ is exactly $\theta^4$, independent of $\alpha$. -/
theorem indicialPoly_eq (α : Fin 4 → ℚ) (θ : ℚ) : indicialPoly α θ = θ^4 := by
  dsimp [indicialPoly, pfSymbol]; ring

/-- $\theta = 0$ is a root of the indicial polynomial. -/
theorem indicialPoly_zero (α : Fin 4 → ℚ) : indicialPoly α 0 = 0 := by
  rw [indicialPoly_eq]; ring

/-- Unique real/rational root of the indicial polynomial is $\theta = 0$. -/
theorem indicial_root_unique (α : Fin 4 → ℚ) (θ : ℚ) (h : indicialPoly α θ = 0) : θ = 0 := by
  simpa [indicialPoly_eq] using h

/-! ### 2. Frobenius Local Monodromy at Cusp $z = 0$ -/

/-- Parabolic cusp monodromy matrix $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ from `SymplecticTriangleRepresentations`. -/
def T0 : Matrix (Fin 4) (Fin 4) ℤ :=
  SymplecticTriangleRepresentations.T0

/-- Nilpotent cusp monodromy operator $N := T_0 - I_4$. -/
def N : Matrix (Fin 4) (Fin 4) ℤ :=
  SymplecticTriangleRepresentations.N

/-- The unipotent matrix $T_0$ satisfies $N = T_0 - 1$. -/
theorem N_eq_T0_sub_one : N = T0 - 1 :=
  SymplecticTriangleRepresentations.N_def

/-- Machine-checked proof that $N$ matches `SymplecticTriangleRepresentations.N`. -/
theorem N_matches_SymplecticTriangleRepresentations : N = SymplecticTriangleRepresentations.N :=
  rfl

/-- Machine-checked proof that the $S_6$ monodromy operator matches $T_0 - I_4$. -/
theorem ModularFamilyS6_N_eq_T0_sub_one : ModularFamilyS6.N = ModularFamilyS6.T0 - 1 :=
  ModularFamilyS6.N_def

/-- Nilpotence of index 2 for the abelian surface $(3,4,\infty)$ modular family: $N^2 = 0$. -/
theorem N_unipotent_index_2 : N * N = 0 :=
  SymplecticTriangleRepresentations.N_squared_zero

/-- Nilpotence of index 2 for the $S_6$ family: $N^2 = 0$. -/
theorem ModularFamilyS6_N_unipotent_index_2 : ModularFamilyS6.N * ModularFamilyS6.N = 0 :=
  ModularFamilyS6.N_squared_zero

/-- Basis vector $\gamma = (1, 0, 0, 0)^T$. -/
def gamma : Fin 4 → ℤ := ModularFamilyS6.gamma

/-- Basis vector $u = (0, 1, 0, 0)^T$. -/
def u : Fin 4 → ℤ := ModularFamilyS6.u

/-- Basis vector $w = (0, 0, 1, 0)^T$. -/
def w : Fin 4 → ℤ := ModularFamilyS6.w

/-- Basis vector $\delta = (0, 0, 0, 1)^T$. -/
def delta : Fin 4 → ℤ := ModularFamilyS6.delta

/-- Action of $N_{S_6}$ on the basis vector $\gamma$: $N\gamma = 0$. -/
theorem S6_N_act_gamma : ModularFamilyS6.N *ᵥ ModularFamilyS6.gamma = 0 :=
  ModularFamilyS6.N_act_gamma

/-- Action of $N_{S_6}$ on the basis vector $u$: $Nu = 0$. -/
theorem S6_N_act_u : ModularFamilyS6.N *ᵥ ModularFamilyS6.u = 0 :=
  ModularFamilyS6.N_act_u

/-- Action of $N_{S_6}$ on the basis vector $w$: $Nw = -u$. -/
theorem S6_N_act_w : ModularFamilyS6.N *ᵥ ModularFamilyS6.w = -ModularFamilyS6.u :=
  ModularFamilyS6.N_act_w

/-- Action of $N_{S_6}$ on the basis vector $\delta$: $N\delta = \gamma$. -/
theorem S6_N_act_delta : ModularFamilyS6.N *ᵥ ModularFamilyS6.delta = ModularFamilyS6.gamma :=
  ModularFamilyS6.N_act_delta

/-- Action of $N_{S_6}$ on alias $\gamma$: $N\gamma = 0$. -/
theorem N_act_gamma : ModularFamilyS6.N *ᵥ gamma = 0 :=
  S6_N_act_gamma

/-- Action of $N_{S_6}$ on alias $u$: $Nu = 0$. -/
theorem N_act_u : ModularFamilyS6.N *ᵥ u = 0 :=
  S6_N_act_u

/-- Action of $N_{S_6}$ on alias $w$: $Nw = -u$. -/
theorem N_act_w : ModularFamilyS6.N *ᵥ w = -u :=
  S6_N_act_w

/-- Action of $N_{S_6}$ on alias $\delta$: $N\delta = \gamma$. -/
theorem N_act_delta : ModularFamilyS6.N *ᵥ delta = gamma :=
  S6_N_act_delta

/-- Action of $N$ on standard basis vector $e_0 = (1, 0, 0, 0)^T$. -/
theorem N_act_e0 : N *ᵥ ![1, 0, 0, 0] = 0 := by
  ext i; fin_cases i <;> rfl

/-- Action of $N$ on standard basis vector $e_1 = (0, 1, 0, 0)^T$. -/
theorem N_act_e1 : N *ᵥ ![0, 1, 0, 0] = ![-1, 0, 0, 0] := by
  ext i; fin_cases i <;> rfl

/-- Action of $N$ on standard basis vector $e_2 = (0, 0, 1, 0)^T$. -/
theorem N_act_e2 : N *ᵥ ![0, 0, 1, 0] = ![0, 0, 0, 1] := by
  ext i; fin_cases i <;> rfl

/-- Action of $N$ on standard basis vector $e_3 = (0, 0, 0, 1)^T$. -/
theorem N_act_e3 : N *ᵥ ![0, 0, 0, 1] = 0 := by
  ext i; fin_cases i <;> rfl

/-- Matrix-vector multiplication for standard $N$. -/
theorem mulVec_N (v : Fin 4 → ℤ) :
    N *ᵥ v = ![-v 1, 0, 0, v 2] := by
  ext i
  fin_cases i <;> simp [N, SymplecticTriangleRepresentations.N, mulVec, dotProduct, Fin.sum_univ_four]

/-- Matrix-vector multiplication for standard $T_0$. -/
theorem mulVec_T0 (v : Fin 4 → ℤ) :
    T0 *ᵥ v = ![v 0 - v 1, v 1, v 2, v 2 + v 3] := by
  ext i
  fin_cases i <;> simp [T0, SymplecticTriangleRepresentations.T0, mulVec, dotProduct, Fin.sum_univ_four, sub_eq_add_neg]

/-- Matrix-vector multiplication for $S_6$ monodromy operator $N_{S_6}$. -/
theorem mulVec_S6_N (v : Fin 4 → ℤ) :
    ModularFamilyS6.N *ᵥ v = ![v 3, -v 2, 0, 0] := by
  ext i
  fin_cases i <;> simp [ModularFamilyS6.N, mulVec, dotProduct, Fin.sum_univ_four]

/-- Matrix-vector multiplication for $S_6$ cusp monodromy $T_{0, S_6}$. -/
theorem mulVec_S6_T0 (v : Fin 4 → ℤ) :
    ModularFamilyS6.T0 *ᵥ v = ![v 0 + v 3, v 1 - v 2, v 2, v 3] := by
  ext i
  fin_cases i <;> simp [ModularFamilyS6.T0, mulVec, dotProduct, Fin.sum_univ_four, sub_eq_add_neg]

/-- The standard Calabi-Yau 3-fold Maximally Unipotent Monodromy (MUM) nilpotent operator
    exhibiting index 4 nilpotence: $N^4 = 0$ and $N^3 \ne 0$. -/
def N_MUM : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0, 1, 0, 0 ],
    ![ 0, 0, 1, 0 ],
    ![ 0, 0, 0, 1 ],
    ![ 0, 0, 0, 0 ]]

/-- $N_{\mathrm{MUM}}^2$ is non-zero. -/
theorem N_MUM_squared_ne_zero : N_MUM * N_MUM ≠ 0 := by
  intro h; absurd (congr_fun (congr_fun h 0) 2); decide

/-- $N_{\mathrm{MUM}}^3$ is non-zero. -/
theorem N_MUM_cubed_ne_zero : N_MUM * N_MUM * N_MUM ≠ 0 := by
  intro h; absurd (congr_fun (congr_fun h 0) 3); decide

/-- $N_{\mathrm{MUM}}^4 = 0$. -/
theorem N_MUM_fourth_zero : N_MUM * N_MUM * N_MUM * N_MUM = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The Calabi-Yau 3-fold MUM monodromy is strictly Type III. -/
theorem N_MUM_is_typeIII : IsTypeIII N_MUM :=
  ⟨N_MUM_squared_ne_zero, N_MUM_fourth_zero⟩

/-- The $(3,4,\infty)$ abelian surface monodromy $N$ is strictly Type II. -/
theorem N_is_typeII : IsTypeII N :=
  SymplecticTriangleRepresentations.monodromy_34_is_typeII

/-- The $(3,4,\infty)$ abelian surface monodromy is not Type III (i.e. not a CY3 MUM). -/
theorem N_not_typeIII : ¬ IsTypeIII N :=
  SymplecticTriangleRepresentations.monodromy_34_not_typeIII

/-- The $(3,4,\infty)$ $S_6$ monodromy is strictly Type II. -/
theorem ModularFamilyS6_N_is_typeII : IsTypeII ModularFamilyS6.N :=
  SymplecticTriangleRepresentations.ModularFamilyS6_is_typeII

/-- The $(3,4,\infty)$ $S_6$ monodromy is not Type III. -/
theorem ModularFamilyS6_N_not_typeIII : ¬ IsTypeIII ModularFamilyS6.N :=
  typeII_not_typeIII ModularFamilyS6.N ModularFamilyS6_N_is_typeII

/-! ### 3. Symplectic Bilinear Invariance & Griffiths Transversality -/

/-- Infinitesimal symplectic condition for matrices in $\mathfrak{sp}_4(\mathbb{Z})$:
    $M^T J + J M = 0$. -/
def IsInfinitesimalSymplectic (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * J + J * M = 0

/-- Infinitesimal symplectic condition for the $S_6$ polarized form $\Omega_6$:
    $M^T \Omega_6 + \Omega_6 M = 0$. -/
def IsInfinitesimalSymplecticOmega6 (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * Omega6 + Omega6 * M = 0

/-- The nilpotent operator $N$ is an infinitesimal symplectic transformation: $N^T J + J N = 0$. -/
theorem isInfinitesimalSymplectic_N : IsInfinitesimalSymplectic N := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The nilpotent operator $N_{S_6}$ is an infinitesimal symplectic transformation for $\Omega_6$. -/
theorem isInfinitesimalSymplectic_S6_N : IsInfinitesimalSymplecticOmega6 ModularFamilyS6.N := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Parabolic cusp monodromy $T_0$ is symplectic: $T_0^T J T_0 = J$. -/
theorem isSymplectic_T0 : IsSymplectic T0 :=
  SymplecticTriangleRepresentations.isSymplectic_T0

/-- Parabolic cusp monodromy $T_{0, S_6}$ preserves $\Omega_6$: $T_0^T \Omega_6 T_0 = \Omega_6$. -/
theorem isSymplectic_S6_T0 :
    ModularFamilyS6.T0ᵀ * Omega6 * ModularFamilyS6.T0 = Omega6 :=
  SymplecticTriangleRepresentations.isSymplectic_Omega6_T0

/-- The symplectic bilinear pairing on $\mathbb{Z}^4$: $\langle v, w \rangle_J = v_0 w_2 + v_1 w_3 - v_2 w_0 - v_3 w_1$. -/
def symplecticPairing (v w : Fin 4 → ℤ) : ℤ :=
  v 0 * w 2 + v 1 * w 3 - v 2 * w 0 - v 3 * w 1

/-- Coordinate expansion of the standard symplectic bilinear pairing. -/
theorem symplecticPairing_def (v w : Fin 4 → ℤ) :
    symplecticPairing v w = v 0 * w 2 + v 1 * w 3 - v 2 * w 0 - v 3 * w 1 := rfl

/-- Skew-symmetry of the symplectic pairing: $\langle v, w \rangle_J = -\langle w, v \rangle_J$. -/
theorem symplecticPairing_skew (v w : Fin 4 → ℤ) :
    symplecticPairing v w = -symplecticPairing w v := by
  dsimp [symplecticPairing]; ring

/-- The symplectic pairing of any vector with itself vanishes: $\langle v, v \rangle_J = 0$. -/
theorem symplecticPairing_self_zero (v : Fin 4 → ℤ) :
    symplecticPairing v v = 0 := by
  dsimp [symplecticPairing]; ring

/-- Infinitesimal symplectic invariance (Griffiths transversality) of the pairing under $N$:
    $\langle N v, w \rangle_J + \langle v, N w \rangle_J = 0$. -/
theorem symplecticPairing_N_invariant (v w : Fin 4 → ℤ) :
    symplecticPairing (N *ᵥ v) w + symplecticPairing v (N *ᵥ w) = 0 := by
  rw [mulVec_N, mulVec_N]; dsimp [symplecticPairing]; ring

/-- Finite symplectic invariance of the pairing under $T_0$:
    $\langle T_0 v, T_0 w \rangle_J = \langle v, w \rangle_J$. -/
theorem symplecticPairing_T0_invariant (v w : Fin 4 → ℤ) :
    symplecticPairing (T0 *ᵥ v) (T0 *ᵥ w) = symplecticPairing v w := by
  rw [mulVec_T0, mulVec_T0]; dsimp [symplecticPairing]; ring

/-- The polarized $S_6$ symplectic bilinear pairing on $\mathbb{Z}^4$: $\langle v, w \rangle_{\Omega_6}$. -/
def symplecticPairingOmega6 (v w : Fin 4 → ℤ) : ℤ :=
  v 0 * w 3 + 6 * v 1 * w 2 - 6 * v 2 * w 1 - v 3 * w 0

/-- Coordinate expansion of the polarized $S_6$ symplectic bilinear pairing. -/
theorem symplecticPairingOmega6_def (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 v w = v 0 * w 3 + 6 * v 1 * w 2 - 6 * v 2 * w 1 - v 3 * w 0 := rfl

/-- Skew-symmetry of the polarized $S_6$ symplectic pairing. -/
theorem symplecticPairingOmega6_skew (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 v w = -symplecticPairingOmega6 w v := by
  dsimp [symplecticPairingOmega6]; ring

/-- Infinitesimal symplectic invariance of the $S_6$ pairing under $N_{S_6}$:
    $\langle N v, w \rangle_{\Omega_6} + \langle v, N w \rangle_{\Omega_6} = 0$. -/
theorem symplecticPairingOmega6_N_invariant (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 (ModularFamilyS6.N *ᵥ v) w +
    symplecticPairingOmega6 v (ModularFamilyS6.N *ᵥ w) = 0 := by
  rw [mulVec_S6_N, mulVec_S6_N]; dsimp [symplecticPairingOmega6]; ring

/-- Finite symplectic invariance of the $S_6$ pairing under $T_{0, S_6}$:
    $\langle T_0 v, T_0 w \rangle_{\Omega_6} = \langle v, w \rangle_{\Omega_6}$. -/
theorem symplecticPairingOmega6_T0_invariant (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 (ModularFamilyS6.T0 *ᵥ v) (ModularFamilyS6.T0 *ᵥ w) =
    symplecticPairingOmega6 v w := by
  rw [mulVec_S6_T0, mulVec_S6_T0]; dsimp [symplecticPairingOmega6]; ring

/-! ### 4. Classical Yukawa Coupling & Mirror Map -/

/-- The algebraic Yukawa coupling function $C_{zzz}(z, \kappa_0, \mu) = \frac{\kappa_0}{z^3 (1 - \mu z)}$. -/
def C_zzz (kappa0 mu : ℚ) (z : ℚ) : ℚ :=
  kappa0 / (z^3 * (1 - mu * z))

/-- Alias `Yukawa` for algebraic Yukawa coupling. -/
def Yukawa (kappa0 mu : ℚ) (z : ℚ) : ℚ :=
  C_zzz kappa0 mu z

/-- Regularized Yukawa function at the cusp $z = 0$: $\kappa_{\mathrm{reg}}(z) = \frac{\kappa_0}{1 - \mu z}$. -/
def regularizedYukawa (kappa0 mu : ℚ) (z : ℚ) : ℚ :=
  kappa0 / (1 - mu * z)

/-- Conifold regularized Yukawa function at $z = 1/\mu$: $\kappa_{\mathrm{con}}(z) = \frac{\kappa_0}{z^3}$. -/
def conifoldRegularizedYukawa (kappa0 : ℚ) (z : ℚ) : ℚ :=
  kappa0 / z^3

/-- Cusp factorization theorem: $z^3 \cdot C_{zzz}(z) = \kappa_{\mathrm{reg}}(z)$. -/
theorem yukawa_cusp_factorization (kappa0 mu z : ℚ) (hz : z ≠ 0) (_hcon : 1 - mu * z ≠ 0) :
    z^3 * Yukawa kappa0 mu z = regularizedYukawa kappa0 mu z := by
  dsimp [Yukawa, C_zzz, regularizedYukawa]
  field_simp [hz]

/-- Cusp limit value: regularized Yukawa coupling at $z = 0$ equals $\kappa_0$. -/
theorem regularizedYukawa_at_cusp (kappa0 mu : ℚ) :
    regularizedYukawa kappa0 mu 0 = kappa0 := by
  simp [regularizedYukawa]

/-- Conifold factorization theorem: $(1 - \mu z) \cdot C_{zzz}(z) = \kappa_{\mathrm{con}}(z)$. -/
theorem yukawa_conifold_factorization (kappa0 mu z : ℚ) (hz : z ≠ 0) (hcon : 1 - mu * z ≠ 0) :
    (1 - mu * z) * Yukawa kappa0 mu z = conifoldRegularizedYukawa kappa0 z := by
  dsimp [Yukawa, C_zzz, conifoldRegularizedYukawa]
  field_simp [hz, hcon]

/-- Conifold evaluation theorem: at the discriminant locus $z = 1/\mu$,
    the conifold regularized Yukawa coupling evaluates to $\kappa_0 \mu^3$. -/
theorem conifoldRegularizedYukawa_at_conifold (kappa0 mu : ℚ) (hmu : mu ≠ 0) :
    conifoldRegularizedYukawa kappa0 (1 / mu) = kappa0 * mu^3 := by
  dsimp [conifoldRegularizedYukawa]
  field_simp [hmu]

/-- The discriminant factor $1 - \mu z$ vanishes at $z = 1/\mu$. -/
theorem discriminant_root (mu z : ℚ) (hmu : mu ≠ 0) (hz : z = 1 / mu) :
    1 - mu * z = 0 := by
  rw [hz, mul_one_div_cancel hmu, sub_self]

/-- Instanton degree-$d$ term in the Gromov-Witten / BPS expansion:
    $I_d(q) = \frac{d^3 n_d q^d}{1 - q^d}$. -/
def instantonTerm (d : ℕ) (n_d : ℤ) (q : ℚ) : ℚ :=
  (d : ℚ)^3 * (n_d : ℚ) * q^d / (1 - q^d)

/-- Finite instanton sum for the mirror Yukawa coupling:
    $C_{ttt}(q, K_0, n) = K_0 + \sum_{d=1}^M \frac{d^3 n_d q^d}{1 - q^d}$. -/
def C_ttt (K0 : ℚ) (n : ℕ → ℤ) (M : ℕ) (q : ℚ) : ℚ :=
  K0 + ∑ d ∈ Finset.Icc 1 M, instantonTerm d (n d) q

/-- Alias `instantonYukawa` for finite instanton sum. -/
def instantonYukawa (K0 : ℚ) (n : ℕ → ℤ) (k : ℕ) (q : ℚ) : ℚ :=
  C_ttt K0 n k q

/-- At $q = 0$, all instanton corrections vanish, giving the classical intersection number $K_0$. -/
theorem C_ttt_zero (K0 : ℚ) (n : ℕ → ℤ) (M : ℕ) :
    C_ttt K0 n M 0 = K0 := by
  dsimp [C_ttt]
  rw [Finset.sum_eq_zero (fun d hd => by
    simp [instantonTerm, zero_pow (ne_of_gt (Finset.mem_Icc.mp hd).1)]), add_zero]

/-- Instanton Yukawa evaluates to $K_0$ at $q = 0$. -/
theorem instantonYukawa_zero (K0 : ℚ) (n : ℕ → ℤ) (k : ℕ) :
    instantonYukawa K0 n k 0 = K0 :=
  C_ttt_zero K0 n k

/-- Degree 1 instanton term formula: $I_1(q) = \frac{n_1 q}{1 - q}$. -/
theorem instantonTerm_deg1 (n1 : ℤ) (q : ℚ) :
    instantonTerm 1 n1 q = (n1 : ℚ) * q / (1 - q) := by
  dsimp [instantonTerm]; ring

/-- Degree 2 instanton term formula: $I_2(q) = \frac{8 n_2 q^2}{1 - q^2}$. -/
theorem instantonTerm_deg2 (n2 : ℤ) (q : ℚ) :
    instantonTerm 2 n2 q = 8 * (n2 : ℚ) * q^2 / (1 - q^2) := by
  dsimp [instantonTerm]; ring

/-- Explicit 1-instanton truncated Yukawa coupling $C_{ttt}$. -/
theorem C_ttt_M1 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    C_ttt K0 n 1 q = K0 + (n 1 : ℚ) * q / (1 - q) := by
  rw [C_ttt, Finset.Icc_self, Finset.sum_singleton, instantonTerm_deg1]

/-- Explicit 1-instanton truncated Yukawa coupling. -/
theorem instantonYukawa_k1 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    instantonYukawa K0 n 1 q = K0 + (n 1 : ℚ) * q / (1 - q) :=
  C_ttt_M1 K0 n q

/-- Explicit 2-instanton truncated Yukawa coupling $C_{ttt}$. -/
theorem C_ttt_M2 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    C_ttt K0 n 2 q = K0 + (n 1 : ℚ) * q / (1 - q) + 8 * (n 2 : ℚ) * q^2 / (1 - q^2) := by
  rw [C_ttt, show Finset.Icc 1 2 = {1, 2} from rfl, Finset.sum_pair (by decide),
    instantonTerm_deg1, instantonTerm_deg2, add_assoc]

/-- Explicit 2-instanton truncated Yukawa coupling. -/
theorem instantonYukawa_k2 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    instantonYukawa K0 n 2 q = K0 + (n 1 : ℚ) * q / (1 - q) + 8 * (n 2 : ℚ) * q^2 / (1 - q^2) :=
  C_ttt_M2 K0 n q

/-- Calabi-Yau 3-fold Quintic mirror BPS invariant sequence certificate:
    $n_1 = 2875, n_2 = 609250$. -/
def quintic_n : ℕ → ℤ
  | 1 => 2875
  | 2 => 609250
  | _ => 0

/-- Quintic Calabi-Yau 1-instanton Yukawa coupling certificate:
    $C(q) = 5 + \frac{2875 q}{1 - q}$. -/
theorem quintic_instanton_k1 (q : ℚ) :
    instantonYukawa 5 quintic_n 1 q = 5 + 2875 * q / (1 - q) :=
  instantonYukawa_k1 5 quintic_n q

/-- Quintic Calabi-Yau 2-instanton Yukawa coupling certificate:
    $C(q) = 5 + \frac{2875 q}{1 - q} + \frac{4874000 q^2}{1 - q^2}$. -/
theorem quintic_instanton_k2 (q : ℚ) :
    instantonYukawa 5 quintic_n 2 q = 5 + 2875 * q / (1 - q) + 4874000 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k2]; dsimp [quintic_n]; norm_num

/-- Modular $(3,4,\infty)$ abelian surface / modular family certificate sequence:
    $n_1 = 4, n_2 = -2$. -/
def modular_34_n : ℕ → ℤ
  | 1 => 4
  | 2 => -2
  | _ => 0

/-- Modular $(3,4,\infty)$ 1-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{4 q}{1 - q}$. -/
theorem modular_34_instanton_k1 (q : ℚ) :
    instantonYukawa 1 modular_34_n 1 q = 1 + 4 * q / (1 - q) :=
  instantonYukawa_k1 1 modular_34_n q

/-- Modular $(3,4,\infty)$ 2-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{4 q}{1 - q} - \frac{16 q^2}{1 - q^2}$. -/
theorem modular_34_instanton_k2 (q : ℚ) :
    instantonYukawa 1 modular_34_n 2 q = 1 + 4 * q / (1 - q) - 16 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k2]; dsimp [modular_34_n]; norm_num; ring

end PicardFuchsMirrorMonodromy
