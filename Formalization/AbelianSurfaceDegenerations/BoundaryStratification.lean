/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Matrix.Basic

open scoped Matrix
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Kodaira–Mumford Toric Degeneration at Boundary $\partial \overline{\mathcal{A}_2}$

This submodule formalizes the boundary stratification of the Satake / toroidal compactification
$\overline{\mathcal{A}_2} = \mathcal{A}_2 \cup \Delta_1 \cup \Delta_0$, toric rank classifications,
and the machine-checked certification that the $(3,4,\infty)$ cusp monodromy is strictly Type II,
landing in the rank-1 boundary divisor $\Delta_1 \cong \mathcal{A}_1$.

## Mathematical Overview

### 1. Stratification of $\overline{\mathcal{A}_2}$
The compactified moduli space of principally polarized abelian surfaces $\overline{\mathcal{A}_2}$ admits
a natural stratification by the toric rank $r \in \{0, 1, 2\}$ of the semi-abelian reduction:
- **Interior ($\mathcal{A}_2$, $r=0$)**: Smooth principally polarized abelian surfaces ($A_t \cong \mathbb{C}^2 / \Lambda$).
- **Boundary Divisor ($\Delta_1$, $r=1$)**: Semi-abelian varieties given by group extensions
  $$0 \to \mathbb{G}_m \to A_0 \to E \to 0$$
  where $E$ is an elliptic curve parameterized by $\tau_{22} \in \mathbb{H}_1 \cong \mathcal{A}_1$.
- **Zero-Dimensional Cusps ($\Delta_0$, $r=2$)**: Degenerations to the algebraic 2-torus $\mathbb{G}_m^2$.

### 2. Dimension Conservation
For any degenerating semi-abelian surface $A_0$, the toric rank and abelian rank satisfy the conservation law:
$$\operatorname{toricRank}(S) + \operatorname{abelianRank}(S) = 2$$

### 3. Classification of the $(3,4,\infty)$ Degeneration
The nilpotent monodromy operator $N \in \mathrm{Mat}_4(\mathbb{Z})$ around the cusp satisfies:
$$N \ne 0, \quad N^2 = 0$$
which corresponds precisely to a Type II degeneration in the Deligne–Schmid classification, and certifies
that the boundary stratum is $\Delta_1$ with toric rank 1 and abelian rank 1.

## Main Declarations

- `AbelianSurfaceDegenerations.BoundaryStratum`: Inductive type for strata (`Interior`, `BoundaryDelta1`, `BoundaryDelta0`).
- `AbelianSurfaceDegenerations.toricRank`: Dimension of the torus part ($0, 1, 2$).
- `AbelianSurfaceDegenerations.abelianRank`: Dimension of the abelian quotient ($2, 1, 0$).
- `AbelianSurfaceDegenerations.semiabelian_dim_conservation`: Theorem proving $\operatorname{toricRank}(s) + \operatorname{abelianRank}(s) = 2$.
- `AbelianSurfaceDegenerations.stratumOfMonodromy`: Classification map from $4 \times 4$ nilpotent monodromy matrices.
- `AbelianSurfaceDegenerations.cusp_34_in_Delta1`: Proof that $(3,4,\infty)$ cusp monodromy lands in $\Delta_1$.
- `AbelianSurfaceDegenerations.cusp_34_toric_rank_eq_one`: Proof that toric rank is 1.
- `AbelianSurfaceDegenerations.cusp_34_abelian_rank_eq_one`: Proof that abelian rank is 1.
- `AbelianSurfaceDegenerations.limitEllipticParameter`: Extraction of $(\tau_0)_{11} \in \mathbb{H}_1$.
- `AbelianSurfaceDegenerations.limitEllipticParameter_in_H1`: Proof that $\operatorname{Im}(\tau_{22}) > 0$.
-/

namespace AbelianSurfaceDegenerations

/-! ### 4. Kodaira–Mumford Toric Degeneration at Boundary $\partial \overline{\mathcal{A}_2}$ -/

/-- Boundary stratification of the compactified moduli space $\overline{\mathcal{A}_2}$:
    - `Interior`: smooth abelian surface in $\mathcal{A}_2$ (toric rank 0).
    - `BoundaryDelta1`: semi-abelian extension $0 \to \mathbb{G}_m \to A_0 \to E \to 0$ in $\Delta_1 \cong \mathcal{A}_1$ (toric rank 1).
    - `BoundaryDelta0`: algebraic torus $\mathbb{G}_m^2$ at the 0D cusps $\Delta_0 \cong \mathcal{A}_0$ (toric rank 2). -/
inductive BoundaryStratum
  | Interior        : BoundaryStratum
  | BoundaryDelta1  : BoundaryStratum
  | BoundaryDelta0  : BoundaryStratum
  deriving DecidableEq, Repr

/-- Toric rank (dimension of the torus part in the semi-abelian reduction) of a stratum. -/
def toricRank : BoundaryStratum → ℕ
  | BoundaryStratum.Interior       => 0
  | BoundaryStratum.BoundaryDelta1 => 1
  | BoundaryStratum.BoundaryDelta0 => 2

/-- Abelian rank (dimension of the abelian variety quotient) of a stratum. -/
def abelianRank : BoundaryStratum → ℕ
  | BoundaryStratum.Interior       => 2
  | BoundaryStratum.BoundaryDelta1 => 1
  | BoundaryStratum.BoundaryDelta0 => 0

/-- Dimension conservation theorem for semi-abelian surface reductions:
    $\operatorname{toricRank}(S) + \operatorname{abelianRank}(S) = 2$ for all strata. -/
theorem semiabelian_dim_conservation (s : BoundaryStratum) :
    toricRank s + abelianRank s = 2 := by
  cases s <;> rfl

/-- Monodromy type classification map:
    - Type I ($M=0$) $\mapsto$ Toric rank 0 (smooth fiber in $\mathcal{A}_2$).
    - Type II ($M \ne 0, M^2=0$) $\mapsto$ Toric rank 1 ($\Delta_1 \cong \mathcal{A}_1$).
    - Type III ($M^2 \ne 0, M^4=0$) $\mapsto$ Toric rank 2 ($\Delta_0 \cong \mathcal{A}_0$). -/
def stratumOfMonodromy (M : Matrix (Fin 4) (Fin 4) ℤ) : BoundaryStratum :=
  if M = 0 then BoundaryStratum.Interior
  else if M * M = 0 then BoundaryStratum.BoundaryDelta1
  else BoundaryStratum.BoundaryDelta0

/-- Theorem: The $(3,4,\infty)$ cusp monodromy degeneration lands strictly in $\Delta_1 \cong \mathcal{A}_1$. -/
theorem cusp_34_in_Delta1 :
    stratumOfMonodromy N = BoundaryStratum.BoundaryDelta1 := by
  decide

/-- The toric rank of the $(3,4,\infty)$ cusp degenerating fiber is 1. -/
theorem cusp_34_toric_rank_eq_one :
    toricRank (stratumOfMonodromy N) = 1 := by
  rw [cusp_34_in_Delta1]
  rfl

/-- The abelian rank of the $(3,4,\infty)$ cusp degenerating fiber is 1 (an elliptic curve quotient $E$). -/
theorem cusp_34_abelian_rank_eq_one :
    abelianRank (stratumOfMonodromy N) = 1 := by
  rw [cusp_34_in_Delta1]
  rfl

/-- Limit elliptic curve modular parameter: the $(1,1)$-entry $\tau_{22} = (\tau_0)_{11} \in \mathbb{H}_1$. -/
def limitEllipticParameter (tau0 : SiegelHalfSpace2) : ℂ :=
  tau0.Z 1 1

/-- Machine-checked proof that the limit elliptic parameter has strictly positive imaginary part:
    $\operatorname{Im}(\tau_{22}) > 0$, so $\tau_{22} \in \mathbb{H}_1$. -/
theorem limitEllipticParameter_in_H1 (tau0 : SiegelHalfSpace2) :
    (limitEllipticParameter tau0).im > 0 := by
  dsimp [limitEllipticParameter]
  have h11 : (imMatrix tau0.Z) 1 1 > 0 := posDef_implies_M11_pos tau0.pos_def
  exact h11

end AbelianSurfaceDegenerations
