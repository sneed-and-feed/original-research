/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

open scoped BigOperators

/-!
# Order-4 Picard-Fuchs Differential Operator $\mathcal{L}_4$, Modular Families & Calabi-Yau Self-Duality

This module formalizes the algebraic symbol of the order-4 Picard-Fuchs differential operator
$\mathcal{L}_4$, the elementary symmetric polynomials $e_1, e_2, e_3, e_4$ of its local Riemann exponents,
the universal Calabi-Yau self-duality theorem, and full parameter evaluations for all 6 triangle modular
families $\Delta(p,q,\infty)$ and canonical Calabi-Yau 3-fold mirror families (Quintic and Bicubic).

## Mathematical Overview

### 1. The Order-4 Picard-Fuchs Operator
In the logarithmic derivative coordinate $\theta = z \frac{d}{dz}$, the standard order-4
hypergeometric Picard-Fuchs differential operator is:
$$\mathcal{L}_4 = \theta^4 - z(\theta + \alpha_1)(\theta + \alpha_2)(\theta + \alpha_3)(\theta + \alpha_4)$$
where $\alpha = (\alpha_1, \alpha_2, \alpha_3, \alpha_4) \in \mathbb{Q}^4$ are the local Riemann exponents.

Its algebraic symbol expands in powers of $\theta$ via the elementary symmetric polynomials $e_k(\alpha)$:
$$\mathcal{L}_4(\theta, z) = (1 - z)\theta^4 - z(e_1(\alpha)\theta^3 + e_2(\alpha)\theta^2 + e_3(\alpha)\theta + e_4(\alpha))$$

### 2. Universal Calabi-Yau Self-Duality
A parameter tuple $\alpha \in \mathbb{Q}^4$ satisfies the **Calabi-Yau self-duality** condition if:
$$(\alpha_0 + \alpha_3 = 1) \wedge (\alpha_1 + \alpha_2 = 1)$$
For any such self-dual tuple:
1. **First Symmetric Polynomial**: $e_1(\alpha) = 2$.
2. **Total Exponent Sum**: $\sum_{i=0}^3 \alpha_i = 2$.
3. **Third Symmetric Polynomial Duality**: $e_3(\alpha) = e_2(\alpha) - 1$ (or $e_2(\alpha) - e_3(\alpha) = 1$).
4. **Picard-Fuchs Operator Reduction**:
   $$\mathcal{L}_4(\theta, z) = (1 - z)\theta^4 - z(2\theta^3 + e_2(\alpha)\theta^2 + (e_2(\alpha)-1)\theta + e_4(\alpha))$$
5. **Conifold Locus Specialization ($z = 1$)**:
   $$\mathcal{L}_4(\theta, 1) = -(2\theta^3 + e_2(\alpha)\theta^2 + (e_2(\alpha)-1)\theta + e_4(\alpha))$$

### 3. The 6 Modular Triangle Families $\Delta(p,q,\infty)$
- **$\Delta(2,3,\infty)$**: $\alpha = (1/6, 5/6, 1/6, 5/6)$, $e = (2, 23/18, 5/18, 25/1296)$.
- **$\Delta(2,4,\infty)$**: $\alpha = (1/8, 3/8, 5/8, 7/8)$, $e = (2, 43/32, 11/32, 105/4096)$.
- **$\Delta(2,5,\infty)$**: $\alpha = (1/10, 3/10, 7/10, 9/10)$, $e = (2, 13/10, 3/10, 189/10000)$.
- **$\Delta(3,4,\infty)$ (Geometric)**: $\alpha = (1/12, 5/12, 7/12, 11/12)$, $e = (2, 95/72, 23/72, 385/20736)$.
- **$\Delta(3,4,\infty)$ (Modular)**: $\alpha = (1/3, 2/3, 1/4, 3/4)$, $e = (2, 203/144, 59/144, 1/24)$.
- **$\Delta(3,5,\infty)$**: $\alpha = (1/15, 4/15, 11/15, 14/15)$, $e = (2, 283/225, 58/225, 616/50625)$.
- **$\Delta(4,4,\infty)$**: $\alpha = (1/8, 3/8, 5/8, 7/8)$, $e = (2, 43/32, 11/32, 105/4096)$.

### 4. Calabi-Yau 3-Fold Families
- **Quintic 3-fold mirror**: $\alpha = (1/5, 2/5, 3/5, 4/5)$, $e = (2, 7/5, 2/5, 24/625)$.
- **Bicubic 3-fold mirror**: $\alpha = (1/3, 2/3, 1/3, 2/3)$, $e = (2, 13/9, 4/9, 4/81)$.

### 5. Indicial Polynomial at Cusp $z = 0$
At $z = 0$, the algebraic symbol specializes to the indicial polynomial:
$$I_0(\theta) = \mathcal{L}_4(\theta, 0) = \theta^4$$
which has a unique quadruple root at $\theta = 0$, yielding maximally unipotent logarithmic Frobenius solutions.

## Main Declarations

- `PicardFuchsMirrorMonodromy.e1`, `e2`, `e3`, `e4`: Elementary symmetric polynomials on $\mathbb{Q}^4$.
- `PicardFuchsMirrorMonodromy.pfSymbol`: Algebraic symbol $\mathcal{L}_4(\theta, z)$.
- `PicardFuchsMirrorMonodromy.pfSymbol_expansion`: Full polynomial expansion in powers of $\theta$.
- `PicardFuchsMirrorMonodromy.IsCalabiYauSelfDual`: Calabi-Yau self-duality predicate $(\alpha_0+\alpha_3=1)\wedge(\alpha_1+\alpha_2=1)$.
- `PicardFuchsMirrorMonodromy.self_dual_e1`, `self_dual_sum`: Master self-duality sum theorems ($e_1=2$, $\sum \alpha_i=2$).
- `PicardFuchsMirrorMonodromy.self_dual_e3_eq_e2_sub_one`, `self_dual_e2_sub_e3`: Master $e_3 = e_2 - 1$ theorem.
- `PicardFuchsMirrorMonodromy.pfSymbol_self_dual`, `pfSymbol_self_dual_at_one`: Self-dual Picard-Fuchs operator symbol formulas.
- Parameter tuples & evaluations for:
  - $(3,4,\infty)$ geometric: `alpha_3_4_infty`, `isCalabiYauSelfDual_3_4_infty`, `e1`–`e4` theorems.
  - $(3,4,\infty)$ modular: `alpha_3_4_mod`, `sum_alpha_3_4_mod`, `e1`–`e4` theorems.
  - $(2,3,\infty)$ modular: `alpha_2_3_infty`, `isCalabiYauSelfDual_2_3_infty`, `e1`–`e4` theorems.
  - $(2,4,\infty)$ modular: `alpha_2_4_infty`, `isCalabiYauSelfDual_2_4_infty`, `e1`–`e4` theorems.
  - $(2,5,\infty)$ modular: `alpha_2_5_infty`, `isCalabiYauSelfDual_2_5_infty`, `e1`–`e4` theorems.
  - $(3,5,\infty)$ modular: `alpha_3_5_infty`, `isCalabiYauSelfDual_3_5_infty`, `e1`–`e4` theorems.
  - $(4,4,\infty)$ modular: `alpha_4_4_infty`, `isCalabiYauSelfDual_4_4_infty`, `e1`–`e4` theorems.
  - Quintic 3-fold: `alpha_quintic`, `isCalabiYauSelfDual_quintic`, `e1`–`e4` theorems.
  - Bicubic 3-fold: `alpha_bicubic`, `isCalabiYauSelfDual_bicubic`, `e1`–`e4` theorems.
- `PicardFuchsMirrorMonodromy.indicialPoly`, `indicialPoly_eq`: Indicial polynomial $I_0(\theta) = \theta^4$.
-/

namespace PicardFuchsMirrorMonodromy

/-- Elementary symmetric polynomial $e_1(\alpha) = \sum_{i=0}^3 \alpha_i$. -/
def e1 (α : Fin 4 → ℚ) : ℚ :=
  α 0 + α 1 + α 2 + α 3

/-- Elementary symmetric polynomial $e_2(\alpha) = \sum_{0 \le i < j \le 3} \alpha_i \alpha_j$. -/
def e2 (α : Fin 4 → ℚ) : ℚ :=
  α 0 * α 1 + α 0 * α 2 + α 0 * α 3 + α 1 * α 2 + α 1 * α 3 + α 2 * α 3

/-- Elementary symmetric polynomial $e_3(\alpha) = \sum_{0 \le i < j < k \le 3} \alpha_i \alpha_j \alpha_k$. -/
def e3 (α : Fin 4 → ℚ) : ℚ :=
  α 0 * α 1 * α 2 + α 0 * α 1 * α 3 + α 0 * α 2 * α 3 + α 1 * α 2 * α 3

/-- Elementary symmetric polynomial $e_4(\alpha) = \prod_{i=0}^3 \alpha_i$. -/
def e4 (α : Fin 4 → ℚ) : ℚ :=
  α 0 * α 1 * α 2 * α 3

/-- Order-4 Picard-Fuchs algebraic symbol $\mathcal{L}_4(\theta, z) = \theta^4 - z \prod_{i=0}^3 (\theta + \alpha_i)$. -/
def pfSymbol (α : Fin 4 → ℚ) (z θ : ℚ) : ℚ :=
  θ^4 - z * (θ + α 0) * (θ + α 1) * (θ + α 2) * (θ + α 3)

/-- Expansion of the Picard-Fuchs operator symbol in powers of $\theta$. -/
theorem pfSymbol_expansion (α : Fin 4 → ℚ) (z θ : ℚ) :
    pfSymbol α z θ = (1 - z) * θ^4 - z * (e1 α * θ^3 + e2 α * θ^2 + e3 α * θ + e4 α) := by
  dsimp [pfSymbol, e1, e2, e3, e4]; ring

/-- Calabi-Yau self-duality condition: $(\alpha_0 + \alpha_3 = 1) \wedge (\alpha_1 + \alpha_2 = 1)$. -/
def IsCalabiYauSelfDual (α : Fin 4 → ℚ) : Prop :=
  (α 0 + α 3 = 1) ∧ (α 1 + α 2 = 1)

/-- Universal Calabi-Yau self-duality master theorem for $e_1(\alpha) = 2$. -/
theorem self_dual_e1 (α : Fin 4 → ℚ) (h : IsCalabiYauSelfDual α) : e1 α = 2 := by
  dsimp [e1]; linarith [h.1, h.2]

/-- Universal Calabi-Yau self-duality sum condition $\sum_{i=0}^3 \alpha_i = 2$. -/
theorem self_dual_sum (α : Fin 4 → ℚ) (h : IsCalabiYauSelfDual α) : (∑ i : Fin 4, α i) = 2 :=
  (Fin.sum_univ_four α).trans (self_dual_e1 α h)

/-- For any Calabi-Yau self-dual parameter set, $e_3(\alpha) = e_2(\alpha) - 1$. -/
theorem self_dual_e3_eq_e2_sub_one (α : Fin 4 → ℚ) (h : IsCalabiYauSelfDual α) : e3 α = e2 α - 1 := by
  have h3 : α 3 = 1 - α 0 := by linarith [h.1]
  have h4 : α 2 = 1 - α 1 := by linarith [h.2]
  dsimp [e2, e3]; rw [h3, h4]; ring

/-- For any Calabi-Yau self-dual parameter set, $e_2(\alpha) - e_3(\alpha) = 1$. -/
theorem self_dual_e2_sub_e3 (α : Fin 4 → ℚ) (h : IsCalabiYauSelfDual α) : e2 α - e3 α = 1 := by
  linarith [self_dual_e3_eq_e2_sub_one α h]

/-- Algebraic symbol $\mathcal{L}_4(\theta, z)$ under Calabi-Yau self-duality. -/
theorem pfSymbol_self_dual (α : Fin 4 → ℚ) (h : IsCalabiYauSelfDual α) (z θ : ℚ) :
    pfSymbol α z θ = (1 - z) * θ^4 - z * (2 * θ^3 + e2 α * θ^2 + (e2 α - 1) * θ + e4 α) := by
  rw [pfSymbol_expansion, self_dual_e1 α h, self_dual_e3_eq_e2_sub_one α h]

/-- Conifold locus specialization ($z = 1$) under Calabi-Yau self-duality. -/
theorem pfSymbol_self_dual_at_one (α : Fin 4 → ℚ) (h : IsCalabiYauSelfDual α) (θ : ℚ) :
    pfSymbol α 1 θ = -(2 * θ^3 + e2 α * θ^2 + (e2 α - 1) * θ + e4 α) := by
  rw [pfSymbol_self_dual α h 1 θ]; ring

/-! ### 1. Triangle Family $(3,4,\infty)$ (Geometric / Mirror) -/

/-- Geometric Riemann parameter exponents for the $(3,4,\infty)$ family:
    $\alpha = (1/12, 5/12, 7/12, 11/12)$. -/
def alpha_3_4_infty : Fin 4 → ℚ :=
  ![1/12, 5/12, 7/12, 11/12]

/-- Alias for geometric parameters of $(3,4,\infty)$. -/
def alpha_3_4_geom : Fin 4 → ℚ :=
  alpha_3_4_infty

/-- Proof that $(3,4,\infty)$ geometric parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_3_4_infty : IsCalabiYauSelfDual alpha_3_4_infty := by
  dsimp [IsCalabiYauSelfDual, alpha_3_4_infty]; norm_num

/-- Proof that $(3,4,\infty)$ geometric parameters satisfy Calabi-Yau self-duality (geom alias). -/
theorem isCalabiYauSelfDual_3_4_geom : IsCalabiYauSelfDual alpha_3_4_geom :=
  isCalabiYauSelfDual_3_4_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,4,\infty)$ geometric exponents. -/
theorem sum_alpha_3_4_infty : (∑ i : Fin 4, alpha_3_4_infty i) = 2 :=
  self_dual_sum alpha_3_4_infty isCalabiYauSelfDual_3_4_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem sum_alpha_3_4_geom : (∑ i : Fin 4, alpha_3_4_geom i) = 2 :=
  sum_alpha_3_4_infty

/-- Calabi-Yau self-duality sum condition for `e1` on $(3,4,\infty)$ geometric exponents. -/
theorem e1_alpha_3_4_infty : e1 alpha_3_4_infty = 2 :=
  self_dual_e1 alpha_3_4_infty isCalabiYauSelfDual_3_4_infty

/-- Calabi-Yau self-duality sum condition for `e1` on $(3,4,\infty)$ geometric exponents (geom alias). -/
theorem e1_alpha_3_4_geom : e1 alpha_3_4_geom = 2 :=
  e1_alpha_3_4_infty

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

/-! ### 2. Triangle Family $(3,4)$ Modular Parameters -/

/-- Modular parameter exponents for the $(3,4,\infty)$ family:
    $\alpha = (1/3, 2/3, 1/4, 3/4)$. -/
def alpha_3_4_mod : Fin 4 → ℚ :=
  ![1/3, 2/3, 1/4, 3/4]

/-- Symmetric polynomial $e_1$ for $(3,4,\infty)$ modular exponents evaluates to $2$. -/
theorem e1_alpha_3_4_mod : e1 alpha_3_4_mod = 2 := by
  dsimp [e1, alpha_3_4_mod]; norm_num

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,4,\infty)$ modular exponents. -/
theorem sum_alpha_3_4_mod : (∑ i : Fin 4, alpha_3_4_mod i) = 2 :=
  (Fin.sum_univ_four alpha_3_4_mod).trans e1_alpha_3_4_mod

/-- Symmetric polynomial $e_2$ for $(3,4,\infty)$ modular exponents evaluates to $203/144$. -/
theorem e2_alpha_3_4_mod : e2 alpha_3_4_mod = 203 / 144 := by
  dsimp [e2, alpha_3_4_mod]; norm_num

/-- Symmetric polynomial $e_3$ for $(3,4,\infty)$ modular exponents evaluates to $59/144$. -/
theorem e3_alpha_3_4_mod : e3 alpha_3_4_mod = 59 / 144 := by
  dsimp [e3, alpha_3_4_mod]; norm_num

/-- Symmetric polynomial $e_4$ for $(3,4,\infty)$ modular exponents evaluates to $1/24$. -/
theorem e4_alpha_3_4_mod : e4 alpha_3_4_mod = 1 / 24 := by
  dsimp [e4, alpha_3_4_mod]; norm_num

/-! ### 3. Triangle Family $(2,3,\infty)$ -/

/-- Parameter exponents for the $(2,3,\infty)$ modular family:
    $\alpha = (1/6, 5/6, 1/6, 5/6)$. -/
def alpha_2_3_infty : Fin 4 → ℚ :=
  ![1/6, 5/6, 1/6, 5/6]

/-- Alias for $(2,3,\infty)$ exponents. -/
def alpha_2_3 : Fin 4 → ℚ :=
  alpha_2_3_infty

/-- Proof that $(2,3,\infty)$ parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_2_3_infty : IsCalabiYauSelfDual alpha_2_3_infty := by
  dsimp [IsCalabiYauSelfDual, alpha_2_3_infty]; norm_num

/-- Proof that $(2,3,\infty)$ parameters satisfy Calabi-Yau self-duality (alias). -/
theorem isCalabiYauSelfDual_2_3 : IsCalabiYauSelfDual alpha_2_3 :=
  isCalabiYauSelfDual_2_3_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(2,3,\infty)$ exponents. -/
theorem sum_alpha_2_3_infty : (∑ i : Fin 4, alpha_2_3_infty i) = 2 :=
  self_dual_sum alpha_2_3_infty isCalabiYauSelfDual_2_3_infty

/-- Calabi-Yau self-duality sum condition for $(2,3,\infty)$ (alias). -/
theorem sum_alpha_2_3 : (∑ i : Fin 4, alpha_2_3 i) = 2 :=
  sum_alpha_2_3_infty

/-- Symmetric polynomial $e_1$ for $(2,3,\infty)$ exponents evaluates to $2$. -/
theorem e1_alpha_2_3_infty : e1 alpha_2_3_infty = 2 :=
  self_dual_e1 alpha_2_3_infty isCalabiYauSelfDual_2_3_infty

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

/-! ### 4. Triangle Family $(2,4,\infty)$ -/

/-- Parameter exponents for the $(2,4,\infty)$ modular family:
    $\alpha = (1/8, 3/8, 5/8, 7/8)$. -/
def alpha_2_4_infty : Fin 4 → ℚ :=
  ![1/8, 3/8, 5/8, 7/8]

/-- Alias for $(2,4,\infty)$ exponents. -/
def alpha_2_4 : Fin 4 → ℚ :=
  alpha_2_4_infty

/-- Proof that $(2,4,\infty)$ parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_2_4_infty : IsCalabiYauSelfDual alpha_2_4_infty := by
  dsimp [IsCalabiYauSelfDual, alpha_2_4_infty]; norm_num

/-- Proof that $(2,4,\infty)$ parameters satisfy Calabi-Yau self-duality (alias). -/
theorem isCalabiYauSelfDual_2_4 : IsCalabiYauSelfDual alpha_2_4 :=
  isCalabiYauSelfDual_2_4_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(2,4,\infty)$ exponents. -/
theorem sum_alpha_2_4_infty : (∑ i : Fin 4, alpha_2_4_infty i) = 2 :=
  self_dual_sum alpha_2_4_infty isCalabiYauSelfDual_2_4_infty

/-- Calabi-Yau self-duality sum condition for $(2,4,\infty)$ (alias). -/
theorem sum_alpha_2_4 : (∑ i : Fin 4, alpha_2_4 i) = 2 :=
  sum_alpha_2_4_infty

/-- Symmetric polynomial $e_1$ for $(2,4,\infty)$ exponents evaluates to $2$. -/
theorem e1_alpha_2_4_infty : e1 alpha_2_4_infty = 2 :=
  self_dual_e1 alpha_2_4_infty isCalabiYauSelfDual_2_4_infty

/-- Symmetric polynomial $e_1$ for $(2,4,\infty)$ exponents (alias). -/
theorem e1_alpha_2_4 : e1 alpha_2_4 = 2 :=
  e1_alpha_2_4_infty

/-- Symmetric polynomial $e_2$ for $(2,4,\infty)$ exponents evaluates to $43/32$. -/
theorem e2_alpha_2_4_infty : e2 alpha_2_4_infty = 43 / 32 := by
  dsimp [e2, alpha_2_4_infty]; norm_num

/-- Symmetric polynomial $e_2$ for $(2,4,\infty)$ exponents (alias). -/
theorem e2_alpha_2_4 : e2 alpha_2_4 = 43 / 32 :=
  e2_alpha_2_4_infty

/-- Symmetric polynomial $e_3$ for $(2,4,\infty)$ exponents evaluates to $11/32$. -/
theorem e3_alpha_2_4_infty : e3 alpha_2_4_infty = 11 / 32 := by
  dsimp [e3, alpha_2_4_infty]; norm_num

/-- Symmetric polynomial $e_3$ for $(2,4,\infty)$ exponents (alias). -/
theorem e3_alpha_2_4 : e3 alpha_2_4 = 11 / 32 :=
  e3_alpha_2_4_infty

/-- Symmetric polynomial $e_4$ for $(2,4,\infty)$ exponents evaluates to $105/4096$. -/
theorem e4_alpha_2_4_infty : e4 alpha_2_4_infty = 105 / 4096 := by
  dsimp [e4, alpha_2_4_infty]; norm_num

/-- Symmetric polynomial $e_4$ for $(2,4,\infty)$ exponents (alias). -/
theorem e4_alpha_2_4 : e4 alpha_2_4 = 105 / 4096 :=
  e4_alpha_2_4_infty

/-! ### 5. Triangle Family $(2,5,\infty)$ -/

/-- Parameter exponents for the $(2,5,\infty)$ modular family:
    $\alpha = (1/10, 3/10, 7/10, 9/10)$. -/
def alpha_2_5_infty : Fin 4 → ℚ :=
  ![1/10, 3/10, 7/10, 9/10]

/-- Alias for $(2,5,\infty)$ exponents. -/
def alpha_2_5 : Fin 4 → ℚ :=
  alpha_2_5_infty

/-- Proof that $(2,5,\infty)$ parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_2_5_infty : IsCalabiYauSelfDual alpha_2_5_infty := by
  dsimp [IsCalabiYauSelfDual, alpha_2_5_infty]; norm_num

/-- Proof that $(2,5,\infty)$ parameters satisfy Calabi-Yau self-duality (alias). -/
theorem isCalabiYauSelfDual_2_5 : IsCalabiYauSelfDual alpha_2_5 :=
  isCalabiYauSelfDual_2_5_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(2,5,\infty)$ exponents. -/
theorem sum_alpha_2_5_infty : (∑ i : Fin 4, alpha_2_5_infty i) = 2 :=
  self_dual_sum alpha_2_5_infty isCalabiYauSelfDual_2_5_infty

/-- Calabi-Yau self-duality sum condition for $(2,5,\infty)$ (alias). -/
theorem sum_alpha_2_5 : (∑ i : Fin 4, alpha_2_5 i) = 2 :=
  sum_alpha_2_5_infty

/-- Symmetric polynomial $e_1$ for $(2,5,\infty)$ exponents evaluates to $2$. -/
theorem e1_alpha_2_5_infty : e1 alpha_2_5_infty = 2 :=
  self_dual_e1 alpha_2_5_infty isCalabiYauSelfDual_2_5_infty

/-- Symmetric polynomial $e_1$ for $(2,5,\infty)$ exponents (alias). -/
theorem e1_alpha_2_5 : e1 alpha_2_5 = 2 :=
  e1_alpha_2_5_infty

/-- Symmetric polynomial $e_2$ for $(2,5,\infty)$ exponents evaluates to $13/10$. -/
theorem e2_alpha_2_5_infty : e2 alpha_2_5_infty = 13 / 10 := by
  dsimp [e2, alpha_2_5_infty]; norm_num

/-- Symmetric polynomial $e_2$ for $(2,5,\infty)$ exponents (alias). -/
theorem e2_alpha_2_5 : e2 alpha_2_5 = 13 / 10 :=
  e2_alpha_2_5_infty

/-- Symmetric polynomial $e_3$ for $(2,5,\infty)$ exponents evaluates to $3/10$. -/
theorem e3_alpha_2_5_infty : e3 alpha_2_5_infty = 3 / 10 := by
  dsimp [e3, alpha_2_5_infty]; norm_num

/-- Symmetric polynomial $e_3$ for $(2,5,\infty)$ exponents (alias). -/
theorem e3_alpha_2_5 : e3 alpha_2_5 = 3 / 10 :=
  e3_alpha_2_5_infty

/-- Symmetric polynomial $e_4$ for $(2,5,\infty)$ exponents evaluates to $189/10000$. -/
theorem e4_alpha_2_5_infty : e4 alpha_2_5_infty = 189 / 10000 := by
  dsimp [e4, alpha_2_5_infty]; norm_num

/-- Symmetric polynomial $e_4$ for $(2,5,\infty)$ exponents (alias). -/
theorem e4_alpha_2_5 : e4 alpha_2_5 = 189 / 10000 :=
  e4_alpha_2_5_infty

/-! ### 6. Triangle Family $(3,5,\infty)$ -/

/-- Parameter exponents for the $(3,5,\infty)$ modular family:
    $\alpha = (1/15, 4/15, 11/15, 14/15)$. -/
def alpha_3_5_infty : Fin 4 → ℚ :=
  ![1/15, 4/15, 11/15, 14/15]

/-- Alias for $(3,5,\infty)$ exponents. -/
def alpha_3_5 : Fin 4 → ℚ :=
  alpha_3_5_infty

/-- Proof that $(3,5,\infty)$ parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_3_5_infty : IsCalabiYauSelfDual alpha_3_5_infty := by
  dsimp [IsCalabiYauSelfDual, alpha_3_5_infty]; norm_num

/-- Proof that $(3,5,\infty)$ parameters satisfy Calabi-Yau self-duality (alias). -/
theorem isCalabiYauSelfDual_3_5 : IsCalabiYauSelfDual alpha_3_5 :=
  isCalabiYauSelfDual_3_5_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(3,5,\infty)$ exponents. -/
theorem sum_alpha_3_5_infty : (∑ i : Fin 4, alpha_3_5_infty i) = 2 :=
  self_dual_sum alpha_3_5_infty isCalabiYauSelfDual_3_5_infty

/-- Calabi-Yau self-duality sum condition for $(3,5,\infty)$ (alias). -/
theorem sum_alpha_3_5 : (∑ i : Fin 4, alpha_3_5 i) = 2 :=
  sum_alpha_3_5_infty

/-- Symmetric polynomial $e_1$ for $(3,5,\infty)$ exponents evaluates to $2$. -/
theorem e1_alpha_3_5_infty : e1 alpha_3_5_infty = 2 :=
  self_dual_e1 alpha_3_5_infty isCalabiYauSelfDual_3_5_infty

/-- Symmetric polynomial $e_1$ for $(3,5,\infty)$ exponents (alias). -/
theorem e1_alpha_3_5 : e1 alpha_3_5 = 2 :=
  e1_alpha_3_5_infty

/-- Symmetric polynomial $e_2$ for $(3,5,\infty)$ exponents evaluates to $283/225$. -/
theorem e2_alpha_3_5_infty : e2 alpha_3_5_infty = 283 / 225 := by
  dsimp [e2, alpha_3_5_infty]; norm_num

/-- Symmetric polynomial $e_2$ for $(3,5,\infty)$ exponents (alias). -/
theorem e2_alpha_3_5 : e2 alpha_3_5 = 283 / 225 :=
  e2_alpha_3_5_infty

/-- Symmetric polynomial $e_3$ for $(3,5,\infty)$ exponents evaluates to $58/225$. -/
theorem e3_alpha_3_5_infty : e3 alpha_3_5_infty = 58 / 225 := by
  dsimp [e3, alpha_3_5_infty]; norm_num

/-- Symmetric polynomial $e_3$ for $(3,5,\infty)$ exponents (alias). -/
theorem e3_alpha_3_5 : e3 alpha_3_5 = 58 / 225 :=
  e3_alpha_3_5_infty

/-- Symmetric polynomial $e_4$ for $(3,5,\infty)$ exponents evaluates to $616/50625$. -/
theorem e4_alpha_3_5_infty : e4 alpha_3_5_infty = 616 / 50625 := by
  dsimp [e4, alpha_3_5_infty]; norm_num

/-- Symmetric polynomial $e_4$ for $(3,5,\infty)$ exponents (alias). -/
theorem e4_alpha_3_5 : e4 alpha_3_5 = 616 / 50625 :=
  e4_alpha_3_5_infty

/-! ### 7. Triangle Family $(4,4,\infty)$ -/

/-- Parameter exponents for the $(4,4,\infty)$ modular family:
    $\alpha = (1/8, 3/8, 5/8, 7/8)$. -/
def alpha_4_4_infty : Fin 4 → ℚ :=
  ![1/8, 3/8, 5/8, 7/8]

/-- Alias for $(4,4,\infty)$ exponents. -/
def alpha_4_4 : Fin 4 → ℚ :=
  alpha_4_4_infty

/-- Proof that $(4,4,\infty)$ parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_4_4_infty : IsCalabiYauSelfDual alpha_4_4_infty := by
  dsimp [IsCalabiYauSelfDual, alpha_4_4_infty]; norm_num

/-- Proof that $(4,4,\infty)$ parameters satisfy Calabi-Yau self-duality (alias). -/
theorem isCalabiYauSelfDual_4_4 : IsCalabiYauSelfDual alpha_4_4 :=
  isCalabiYauSelfDual_4_4_infty

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for $(4,4,\infty)$ exponents. -/
theorem sum_alpha_4_4_infty : (∑ i : Fin 4, alpha_4_4_infty i) = 2 :=
  self_dual_sum alpha_4_4_infty isCalabiYauSelfDual_4_4_infty

/-- Calabi-Yau self-duality sum condition for $(4,4,\infty)$ (alias). -/
theorem sum_alpha_4_4 : (∑ i : Fin 4, alpha_4_4 i) = 2 :=
  sum_alpha_4_4_infty

/-- Symmetric polynomial $e_1$ for $(4,4,\infty)$ exponents evaluates to $2$. -/
theorem e1_alpha_4_4_infty : e1 alpha_4_4_infty = 2 :=
  self_dual_e1 alpha_4_4_infty isCalabiYauSelfDual_4_4_infty

/-- Symmetric polynomial $e_1$ for $(4,4,\infty)$ exponents (alias). -/
theorem e1_alpha_4_4 : e1 alpha_4_4 = 2 :=
  e1_alpha_4_4_infty

/-- Symmetric polynomial $e_2$ for $(4,4,\infty)$ exponents evaluates to $43/32$. -/
theorem e2_alpha_4_4_infty : e2 alpha_4_4_infty = 43 / 32 := by
  dsimp [e2, alpha_4_4_infty]; norm_num

/-- Symmetric polynomial $e_2$ for $(4,4,\infty)$ exponents (alias). -/
theorem e2_alpha_4_4 : e2 alpha_4_4 = 43 / 32 :=
  e2_alpha_4_4_infty

/-- Symmetric polynomial $e_3$ for $(4,4,\infty)$ exponents evaluates to $11/32$. -/
theorem e3_alpha_4_4_infty : e3 alpha_4_4_infty = 11 / 32 := by
  dsimp [e3, alpha_4_4_infty]; norm_num

/-- Symmetric polynomial $e_3$ for $(4,4,\infty)$ exponents (alias). -/
theorem e3_alpha_4_4 : e3 alpha_4_4 = 11 / 32 :=
  e3_alpha_4_4_infty

/-- Symmetric polynomial $e_4$ for $(4,4,\infty)$ exponents evaluates to $105/4096$. -/
theorem e4_alpha_4_4_infty : e4 alpha_4_4_infty = 105 / 4096 := by
  dsimp [e4, alpha_4_4_infty]; norm_num

/-- Symmetric polynomial $e_4$ for $(4,4,\infty)$ exponents (alias). -/
theorem e4_alpha_4_4 : e4 alpha_4_4 = 105 / 4096 :=
  e4_alpha_4_4_infty

/-! ### 8. Quintic Calabi-Yau 3-Fold Family -/

/-- Parameter exponents for the quintic 3-fold mirror family:
    $\alpha = (1/5, 2/5, 3/5, 4/5)$. -/
def alpha_quintic : Fin 4 → ℚ :=
  ![1/5, 2/5, 3/5, 4/5]

/-- Proof that quintic 3-fold parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_quintic : IsCalabiYauSelfDual alpha_quintic := by
  dsimp [IsCalabiYauSelfDual, alpha_quintic]; norm_num

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for quintic exponents. -/
theorem sum_alpha_quintic : (∑ i : Fin 4, alpha_quintic i) = 2 :=
  self_dual_sum alpha_quintic isCalabiYauSelfDual_quintic

/-- Symmetric polynomial $e_1$ for quintic exponents evaluates to $2$. -/
theorem e1_alpha_quintic : e1 alpha_quintic = 2 :=
  self_dual_e1 alpha_quintic isCalabiYauSelfDual_quintic

/-- Symmetric polynomial $e_2$ for quintic exponents evaluates to $7/5$. -/
theorem e2_alpha_quintic : e2 alpha_quintic = 7 / 5 := by
  dsimp [e2, alpha_quintic]; norm_num

/-- Symmetric polynomial $e_3$ for quintic exponents evaluates to $2/5$. -/
theorem e3_alpha_quintic : e3 alpha_quintic = 2 / 5 := by
  dsimp [e3, alpha_quintic]; norm_num

/-- Symmetric polynomial $e_4$ for quintic exponents evaluates to $24/625$. -/
theorem e4_alpha_quintic : e4 alpha_quintic = 24 / 625 := by
  dsimp [e4, alpha_quintic]; norm_num

/-! ### 9. Bicubic Calabi-Yau 3-Fold Family -/

/-- Parameter exponents for the bicubic 3-fold mirror family:
    $\alpha = (1/3, 2/3, 1/3, 2/3)$. -/
def alpha_bicubic : Fin 4 → ℚ :=
  ![1/3, 2/3, 1/3, 2/3]

/-- Proof that bicubic 3-fold parameters satisfy Calabi-Yau self-duality. -/
theorem isCalabiYauSelfDual_bicubic : IsCalabiYauSelfDual alpha_bicubic := by
  dsimp [IsCalabiYauSelfDual, alpha_bicubic]; norm_num

/-- Calabi-Yau self-duality sum condition: $\sum_{i=0}^3 \alpha_i = 2$ for bicubic exponents. -/
theorem sum_alpha_bicubic : (∑ i : Fin 4, alpha_bicubic i) = 2 :=
  self_dual_sum alpha_bicubic isCalabiYauSelfDual_bicubic

/-- Symmetric polynomial $e_1$ for bicubic exponents evaluates to $2$. -/
theorem e1_alpha_bicubic : e1 alpha_bicubic = 2 :=
  self_dual_e1 alpha_bicubic isCalabiYauSelfDual_bicubic

/-- Symmetric polynomial $e_2$ for bicubic exponents evaluates to $13/9$. -/
theorem e2_alpha_bicubic : e2 alpha_bicubic = 13 / 9 := by
  dsimp [e2, alpha_bicubic]; norm_num

/-- Symmetric polynomial $e_3$ for bicubic exponents evaluates to $4/9$. -/
theorem e3_alpha_bicubic : e3 alpha_bicubic = 4 / 9 := by
  dsimp [e3, alpha_bicubic]; norm_num

/-- Symmetric polynomial $e_4$ for bicubic exponents evaluates to $4/81$. -/
theorem e4_alpha_bicubic : e4 alpha_bicubic = 4 / 81 := by
  dsimp [e4, alpha_bicubic]; norm_num

/-! ### 10. Indicial Polynomial at Cusp $z = 0$ -/

/-- The indicial polynomial at the cusp $z = 0$: $I_0(\theta) = \mathcal{L}_4(\theta, 0) = \theta^4$. -/
def indicialPoly (α : Fin 4 → ℚ) (θ : ℚ) : ℚ :=
  pfSymbol α 0 θ

/-- The indicial polynomial at $z = 0$ is exactly $\theta^4$, independent of $\alpha$. -/
theorem indicialPoly_eq (α : Fin 4 → ℚ) (θ : ℚ) : indicialPoly α θ = θ^4 := by
  dsimp [indicialPoly, pfSymbol]; ring

/-- $\theta = 0$ is a root of the indicial polynomial. -/
theorem indicialPoly_zero (α : Fin 4 → ℚ) : indicialPoly α 0 = 0 := by
  simp [indicialPoly_eq]

/-- Unique rational root of the indicial polynomial is $\theta = 0$. -/
theorem indicial_root_unique (α : Fin 4 → ℚ) (θ : ℚ) (h : indicialPoly α θ = 0) : θ = 0 := by
  simpa [indicialPoly_eq] using h

end PicardFuchsMirrorMonodromy
