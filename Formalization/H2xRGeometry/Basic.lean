/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Pillar 8: $\mathbb{H}^2 \times \mathbb{R}$ Geometry - Basic Topology and Product Structure

This module formalizes the topological and foundational geometric invariants of the compact
3-manifold $M = \Sigma_g \times S^1$, the direct product of a closed Riemann surface $\Sigma_g$ of
genus $g \ge 2$ (endowed with a hyperbolic metric of constant negative curvature $K = -1$) and a
circle $S^1$ of length $L > 0$.

## Mathematical Summary

1. **Surface Geometry ($\Sigma_g, g \ge 2$)**:
   - Genus $g \ge 2$.
   - Euler characteristic: $\chi(\Sigma_g) = 2 - 2g \le -2 < 0$.
   - Hyperbolic area by the Gauss-Bonnet theorem: $\mathrm{Area}(\Sigma_g) = -2\pi \chi(\Sigma_g) = 4\pi (g - 1) > 0$.
   - Betti numbers: $b_0(\Sigma_g) = 1$, $b_1(\Sigma_g) = 2g$, $b_2(\Sigma_g) = 1$, $b_k(\Sigma_g) = 0$ for $k \ge 3$.

2. **Circle Factor ($S^1, L > 0$)**:
   - Length $L > 0$.
   - Betti numbers: $b_0(S^1) = 1$, $b_1(S^1) = 1$, $b_k(S^1) = 0$ for $k \ge 2$.
   - Euler characteristic: $\chi(S^1) = 1 - 1 = 0$.

3. **Product 3-Manifold ($M = \Sigma_g \times S^1$)**:
   - Real dimension: $\dim(M) = 2 + 1 = 3$.
   - Fundamental group: $\pi_1(M) \cong \pi_1(\Sigma_g) \times \mathbb{Z}$.
   - Number of canonical generators: $2g + 1$ ($2g$ surface generators $a_1, b_1, \dots, a_g, b_g$ and 1 circle generator $t$).
   - Center rank: $\mathrm{rank}(Z(\pi_1(M))) = 1$ (spanned by the central circle factor).
   - First homology group: $H_1(M, \mathbb{Z}) \cong \mathbb{Z}^{2g+1}$, with first homology rank $b_1(M) = 2g + 1 \ge 5$.

4. **Künneth Formula & Betti Numbers of $M$**:
   - $b_0(M) = b_0(\Sigma_g) b_0(S^1) = 1 \cdot 1 = 1$.
   - $b_1(M) = b_0(\Sigma_g) b_1(S^1) + b_1(\Sigma_g) b_0(S^1) = 1 \cdot 1 + 2g \cdot 1 = 2g + 1$.
   - $b_2(M) = b_1(\Sigma_g) b_1(S^1) + b_2(\Sigma_g) b_0(S^1) = 2g \cdot 1 + 1 \cdot 1 = 2g + 1$.
   - $b_3(M) = b_2(\Sigma_g) b_1(S^1) = 1 \cdot 1 = 1$.
   - $b_k(M) = 0$ for $k \ge 4$.
   - Poincaré Duality: $b_0(M) = b_3(M) = 1$ and $b_1(M) = b_2(M) = 2g + 1$.

5. **Euler Characteristic**:
   - Alternating sum of Betti numbers: $\chi(M) = b_0 - b_1 + b_2 - b_3 = 1 - (2g+1) + (2g+1) - 1 = 0$.
   - Product multiplicativity: $\chi(\Sigma_g \times S^1) = \chi(\Sigma_g) \cdot \chi(S^1) = (2 - 2g) \cdot 0 = 0$.

6. **Total Riemannian Volume**:
   - $\mathrm{Vol}(\Sigma_g \times S^1) = \mathrm{Area}(\Sigma_g) \cdot L = 4\pi (g - 1) L > 0$.
-/

namespace H2xRGeometry

/-! ### 1. Genus and Manifold Parameters -/

/-- Parameter structure for the compact product 3-manifold $\Sigma_g \times S^1$. -/
structure ManifoldParams where
  g : ℕ
  hg : g ≥ 2
  L : ℝ
  hL : L > 0

/-- Dimension of the hyperbolic surface $\Sigma_g$: $\dim(\Sigma_g) = 2$. -/
def surfaceDim : ℕ := 2

/-- Dimension of the circle $S^1$: $\dim(S^1) = 1$. -/
def circleDim : ℕ := 1

/-- Real dimension of the product 3-manifold $\Sigma_g \times S^1$: $\dim(\Sigma_g \times S^1) = 2 + 1 = 3$. -/
def manifoldDim : ℕ := surfaceDim + circleDim

/-- Manifold dimension is exactly 3. -/
theorem manifoldDim_eq_three : manifoldDim = 3 := rfl

/-- Euler characteristic of a closed orientable surface $\Sigma_g$ of genus $g$:
    $\chi(\Sigma_g) = 2 - 2g$. -/
def surfaceEulerChar (g : ℕ) : ℤ :=
  2 - 2 * (g : ℤ)

/-- Euler characteristic of $\Sigma_g$ is at most $-2$ for $g \ge 2$. -/
theorem surfaceEulerChar_le_neg_two (g : ℕ) (hg : g ≥ 2) :
    surfaceEulerChar g ≤ -2 := by
  dsimp [surfaceEulerChar]; omega

/-- Euler characteristic of $\Sigma_g$ is strictly negative for $g \ge 2$. -/
theorem surfaceEulerChar_neg (g : ℕ) (hg : g ≥ 2) :
    surfaceEulerChar g < 0 := by
  dsimp [surfaceEulerChar]; omega

/-- Hyperbolic area of a closed surface $\Sigma_g$ with constant curvature $K = -1$
    by the Gauss-Bonnet theorem:
    $\mathrm{Area}(\Sigma_g) = -2\pi \chi(\Sigma_g) = 4\pi(g - 1)$. -/
noncomputable def surfaceArea (g : ℕ) : ℝ :=
  4 * Real.pi * ((g : ℝ) - 1)

/-- Surface area is strictly positive for $g \ge 2$. -/
theorem surfaceArea_pos (g : ℕ) (hg : g ≥ 2) :
    surfaceArea g > 0 := by
  have : (1 : ℝ) < g := Nat.one_lt_cast.2 (by omega)
  dsimp [surfaceArea]; positivity

/-! ### 2. Betti Numbers of Surface $\Sigma_g$ and Circle $S^1$ -/

/-- Betti numbers of closed Riemann surface $\Sigma_g$. -/
def surfaceBetti (g : ℕ) (k : ℕ) : ℕ :=
  match k with
  | 0 => 1
  | 1 => 2 * g
  | 2 => 1
  | _ => 0

@[simp] theorem surfaceBetti_zero (g : ℕ) : surfaceBetti g 0 = 1 := rfl
@[simp] theorem surfaceBetti_one (g : ℕ) : surfaceBetti g 1 = 2 * g := rfl
@[simp] theorem surfaceBetti_two (g : ℕ) : surfaceBetti g 2 = 1 := rfl
@[simp] theorem surfaceBetti_three (g : ℕ) : surfaceBetti g 3 = 0 := rfl

/-- Alternating sum of Betti numbers gives the Euler characteristic of $\Sigma_g$. -/
theorem surface_euler_char_eq_betti_sum (g : ℕ) :
    (surfaceBetti g 0 : ℤ) - (surfaceBetti g 1 : ℤ) + (surfaceBetti g 2 : ℤ) = surfaceEulerChar g := by
  dsimp [surfaceBetti, surfaceEulerChar]; ring

/-- Betti numbers of the circle $S^1$. -/
def circleBetti (k : ℕ) : ℕ :=
  match k with
  | 0 => 1
  | 1 => 1
  | _ => 0

@[simp] theorem circleBetti_zero : circleBetti 0 = 1 := rfl
@[simp] theorem circleBetti_one : circleBetti 1 = 1 := rfl
@[simp] theorem circleBetti_two : circleBetti 2 = 0 := rfl
@[simp] theorem circleBetti_three : circleBetti 3 = 0 := rfl

/-- Euler characteristic of the circle $S^1$ is 0. -/
def circleEulerChar : ℤ :=
  (circleBetti 0 : ℤ) - (circleBetti 1 : ℤ)

/-- Circle Euler characteristic vanishes. -/
theorem circleEulerChar_eq_zero : circleEulerChar = 0 := rfl

/-! ### 3. Fundamental Group & Homology of the Product $\Sigma_g \times S^1$ -/

/-- Number of canonical generators for the surface fundamental group $\pi_1(\Sigma_g)$: $2g$. -/
def surfaceGenCount (g : ℕ) : ℕ := 2 * g

/-- Total number of canonical generators for $\pi_1(\Sigma_g \times S^1)$: $2g + 1$. -/
def fundamentalGroupGenCount (g : ℕ) : ℕ := surfaceGenCount g + 1

/-- Fundamental group generator count formula. -/
theorem fundamentalGroupGenCount_eq (g : ℕ) :
    fundamentalGroupGenCount g = 2 * g + 1 := rfl

/-- Center rank of $\pi_1(\Sigma_g \times S^1)$ is 1 (isomorphic to $\mathbb{Z}$ via the $S^1$ fiber). -/
def centerRank : ℕ := 1

/-- Center rank is 1. -/
theorem centerRank_eq_one : centerRank = 1 := rfl

/-- Rank of the first integral homology group $H_1(\Sigma_g \times S^1, \mathbb{Z}) \cong \mathbb{Z}^{2g+1}$. -/
def firstHomologyRank (g : ℕ) : ℕ := 2 * g + 1

/-- First homology rank is at least 5 for genus $g \ge 2$. -/
theorem firstHomologyRank_ge_five (g : ℕ) (hg : g ≥ 2) :
    firstHomologyRank g ≥ 5 := by
  dsimp [firstHomologyRank]; omega

/-! ### 4. Product Manifold $\Sigma_g \times S^1$ Betti Numbers (Künneth Formula) -/

/-- Betti numbers of $\Sigma_g \times S^1$ via the Künneth formula:
    $b_k(\Sigma_g \times S^1) = \sum_{i+j=k} b_i(\Sigma_g) b_j(S^1)$. -/
def betti (g : ℕ) (k : ℕ) : ℕ :=
  match k with
  | 0 => 1
  | 1 => 2 * g + 1
  | 2 => 2 * g + 1
  | 3 => 1
  | _ => 0

@[simp] theorem betti_zero (g : ℕ) : betti g 0 = 1 := rfl
@[simp] theorem betti_one (g : ℕ) : betti g 1 = 2 * g + 1 := rfl
@[simp] theorem betti_two (g : ℕ) : betti g 2 = 2 * g + 1 := rfl
@[simp] theorem betti_three (g : ℕ) : betti g 3 = 1 := rfl
@[simp] theorem betti_ge_four (g : ℕ) (k : ℕ) (hk : k ≥ 4) : betti g k = 0 := by
  rcases k with _|(_|(_|(_|k))) <;> try omega
  rfl

/-- Künneth verification for $b_0(M) = b_0(\Sigma) b_0(S^1) = 1 \cdot 1 = 1$. -/
theorem betti_zero_kunneth (g : ℕ) :
    betti g 0 = surfaceBetti g 0 * circleBetti 0 := rfl

/-- Künneth verification for $b_1(M) = b_0(\Sigma) b_1(S^1) + b_1(\Sigma) b_0(S^1) = 1 + 2g$. -/
theorem betti_one_kunneth (g : ℕ) :
    betti g 1 = surfaceBetti g 0 * circleBetti 1 + surfaceBetti g 1 * circleBetti 0 := by
  dsimp [betti, surfaceBetti, circleBetti]; omega

/-- Künneth verification for $b_2(M) = b_1(\Sigma) b_1(S^1) + b_2(\Sigma) b_0(S^1) = 2g + 1$. -/
theorem betti_two_kunneth (g : ℕ) :
    betti g 2 = surfaceBetti g 1 * circleBetti 1 + surfaceBetti g 2 * circleBetti 0 := by
  dsimp [betti, surfaceBetti, circleBetti]; omega

/-- Künneth verification for $b_3(M) = b_2(\Sigma) b_1(S^1) = 1 \cdot 1 = 1$. -/
theorem betti_three_kunneth (g : ℕ) :
    betti g 3 = surfaceBetti g 2 * circleBetti 1 := rfl

/-- First homology rank equals first Betti number $b_1$. -/
theorem firstHomologyRank_eq_betti_one (g : ℕ) :
    firstHomologyRank g = betti g 1 := rfl

/-- Poincaré Duality for $\Sigma_g \times S^1$: $b_0 = b_3$. -/
theorem poincare_duality_zero_three (g : ℕ) :
    betti g 0 = betti g 3 := rfl

/-- Poincaré Duality for $\Sigma_g \times S^1$: $b_1 = b_2$. -/
theorem poincare_duality_one_two (g : ℕ) :
    betti g 1 = betti g 2 := rfl

/-! ### 5. Euler Characteristic of $\Sigma_g \times S^1$ -/

/-- Euler characteristic of the product 3-manifold $\Sigma_g \times S^1$
    as alternating sum of Betti numbers:
    $\chi(\Sigma_g \times S^1) = b_0 - b_1 + b_2 - b_3$. -/
def productEulerChar (g : ℕ) : ℤ :=
  (betti g 0 : ℤ) - (betti g 1 : ℤ) + (betti g 2 : ℤ) - (betti g 3 : ℤ)

/-- Euler characteristic of $\Sigma_g \times S^1$ vanishes: $\chi(\Sigma_g \times S^1) = 0$. -/
theorem productEulerChar_eq_zero (g : ℕ) :
    productEulerChar g = 0 := by
  dsimp [productEulerChar, betti]; ring

/-- Multiplicativity of Euler characteristic on products:
    $\chi(\Sigma_g \times S^1) = \chi(\Sigma_g) \cdot \chi(S^1) = (2-2g) \cdot 0 = 0$. -/
theorem product_euler_char_multiplicative (g : ℕ) :
    productEulerChar g = surfaceEulerChar g * circleEulerChar := by
  dsimp [productEulerChar, surfaceEulerChar, circleEulerChar, betti, circleBetti]; ring

/-! ### 6. Total Riemannian Volume -/

/-- Total Riemannian volume of the product manifold $\Sigma_g \times S^1$:
    $\mathrm{Vol}(\Sigma_g \times S^1) = \mathrm{Area}(\Sigma_g) \cdot L = 4\pi (g - 1) L$. -/
noncomputable def totalVolume (g : ℕ) (L : ℝ) : ℝ :=
  surfaceArea g * L

/-- Total volume formula: $\mathrm{Vol}(\Sigma_g \times S^1) = 4\pi (g - 1) L$. -/
theorem totalVolume_eq (g : ℕ) (L : ℝ) :
    totalVolume g L = 4 * Real.pi * ((g : ℝ) - 1) * L := rfl

/-- Positivity of total volume for $g \ge 2$ and $L > 0$. -/
theorem totalVolume_pos (p : ManifoldParams) :
    totalVolume p.g p.L > 0 := by
  have : (1 : ℝ) < p.g := Nat.one_lt_cast.2 (by have := p.hg; omega)
  have := p.hL
  dsimp [totalVolume, surfaceArea]; positivity

end H2xRGeometry
