/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace.PosDef
import Formalization.AbelianSurfaceDegenerations.SiegelSpace.Basic
import Formalization.AbelianSurfaceDegenerations.SiegelSpace.FLT

/-!
# Genus-2 Siegel Upper Half-Space $\mathbb{H}_2$ & $\mathrm{Sp}_4(\mathbb{Z})$ Action

This module serves as the primary aggregator for the formalization of the genus $g=2$ Siegel upper
half-space $\mathbb{H}_2$, positive definiteness criteria for $2 \times 2$ real symmetric matrices,
canonical basepoints, block decomposition of integral symplectic transformations in $\mathrm{Sp}_4(\mathbb{Z})$,
and generalized fractional linear transformations.

## Mathematical Architecture

The theory is factored into three granular submodules:

1. **`Formalization.AbelianSurfaceDegenerations.SiegelSpace.PosDef`**:
   - Pure real $2 \times 2$ matrix algebra and positive definiteness criteria (`det2`, `trace2`, `quadForm`, `IsPosDef2`).
   - Sylvester's criterion consequences: diagonal entry positivity (`posDef_implies_M11_pos`), trace positivity (`posDef_implies_trace_pos`), and quadratic form positivity (`posDef_quadForm_pos`).

2. **`Formalization.AbelianSurfaceDegenerations.SiegelSpace.Basic`**:
   - The complex Siegel upper half-space $\mathbb{H}_2$ structure (`SiegelHalfSpace2`).
   - Real and imaginary part projections (`imMatrix`, `reMatrix`).
   - Diagonal period matrices $Z_{\mathrm{diag}}(y_1, y_2)$ and canonical basepoints (`canonicalSiegelPoint`).

3. **`Formalization.AbelianSurfaceDegenerations.SiegelSpace.FLT`**:
   - Symplectic $2 \times 2$ block projections of $4 \times 4$ matrices (`blockA`, `blockB`, `blockC`, `blockD`).
   - Verified symplectic block relations for $(3,4,\infty)$ generators $T_1, T_2, T_0$.
   - Complex matrix determinant, adjugate, and inverse (`det2C`, `adjugate2C`, `inv2C`).
   - Fractional linear action (`fltAction`) and translation invariance of $\mathbb{H}_2$ (`translation_in_Siegel`).
-/
