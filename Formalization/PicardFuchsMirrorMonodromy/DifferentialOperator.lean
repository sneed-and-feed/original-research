/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

open scoped BigOperators

/-!
# Order-4 Picard-Fuchs Differential Operator $\mathcal{L}_4$ & Hypergeometric Exponents

This submodule formalizes the algebraic symbol of the order-4 Picard-Fuchs differential operator
$\mathcal{L}_4$, the elementary symmetric polynomials of its local exponents, and the Calabi-Yau
self-duality sum condition $\sum_{i=1}^4 \alpha_i = 2$ for the modular families $\Delta(3,4,\infty)$
and $\Delta(2,3,\infty)$.

## Mathematical Overview

### 1. The Order-4 Picard-Fuchs Operator
In the logarithmic derivative coordinate $\theta = z \frac{d}{dz}$, the standard order-4
hypergeometric Picard-Fuchs differential operator is:
$$\mathcal{L}_4 = \theta^4 - z(\theta + \alpha_1)(\theta + \alpha_2)(\theta + \alpha_3)(\theta + \alpha_4)$$
where $\alpha = (\alpha_1, \alpha_2, \alpha_3, \alpha_4) \in \mathbb{Q}^4$ are the local Riemann exponents.

Its algebraic symbol expands in powers of $\theta$ via the elementary symmetric polynomials $e_k(\alpha)$:
$$\mathcal{L}_4(\theta, z) = (1 - z)\theta^4 - z(e_1(\alpha)\theta^3 + e_2(\alpha)\theta^2 + e_3(\alpha)\theta + e_4(\alpha))$$

### 2. Local Riemann Exponents & Calabi-Yau Self-Duality
- Geometric/mirror family $(3,4,\infty)$: $\alpha = (1/12, 5/12, 7/12, 11/12)$.
- Modular family $(3,4,\infty)$: $\alpha = (1/3, 2/3, 1/4, 3/4)$.
- Modular family $(2,3,\infty)$: $\alpha = (1/6, 5/6, 1/6, 5/6)$.

Each family satisfies the Calabi-Yau self-duality sum condition:
$$\sum_{i=1}^4 \alpha_i = e_1(\alpha) = 2$$
guaranteeing the existence of a flat symplectic structure on the solution space.

### 3. Indicial Polynomial at Cusp $z = 0$
At $z = 0$, the algebraic symbol specializes to the indicial polynomial:
$$I_0(\theta) = \mathcal{L}_4(\theta, 0) = \theta^4$$
which has a unique quadruple root at $\theta = 0$, yielding maximally unipotent logarithmic Frobenius solutions.

## Main Declarations

- `PicardFuchsMirrorMonodromy.e1`, `e2`, `e3`, `e4`: Elementary symmetric polynomials on $\mathbb{Q}^4$.
- `PicardFuchsMirrorMonodromy.pfSymbol`: Algebraic symbol $\mathcal{L}_4(\theta, z)$.
- `PicardFuchsMirrorMonodromy.pfSymbol_expansion`: Full polynomial expansion in powers of $\theta$.
- `PicardFuchsMirrorMonodromy.alpha_3_4_infty`, `alpha_3_4_mod`, `alpha_2_3_infty`: Parameter tuples.
- `PicardFuchsMirrorMonodromy.sum_alpha_3_4_infty`, `sum_alpha_3_4_mod`, `sum_alpha_2_3_infty`: Self-duality sum certificates $\sum \alpha_i = 2$.
- `PicardFuchsMirrorMonodromy.indicialPoly`, `indicialPoly_eq`: Indicial polynomial $I_0(\theta) = \theta^4$.
-/

namespace PicardFuchsMirrorMonodromy

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

end PicardFuchsMirrorMonodromy
