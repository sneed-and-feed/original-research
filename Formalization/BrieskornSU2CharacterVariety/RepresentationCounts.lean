/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornSU2CharacterVariety.SphericalAngles
import Mathlib.Data.Finset.Card

/-!
# Certified Irreducible SU(2) Representation Counts

This submodule formalizes exact, certified irreducible $SU(2)$ representation counts
$\#\mathcal{R}^*(\Sigma(p, q, r))$ for canonical Brieskorn homology 3-spheres:
- Poincaré homology sphere $\Sigma(2, 3, 5)$: count is 2.
- Brieskorn sphere $\Sigma(2, 3, 7)$: count is 2.
- Brieskorn sphere $\Sigma(2, 3, 11)$: count is 4.
- Brieskorn sphere $\Sigma(2, 5, 7)$: count is 4.

Each certificate is verified by `rfl` via native decision procedures on finite sets.
-/

namespace BrieskornSU2

/-- Poincaré homology sphere $\Sigma(2, 3, 5)$ has exactly 2 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_3_5 : (IrredSU2RepSet 2 3 5).card = 2 := rfl

/-- Alias for Poincaré homology sphere representation count. -/
theorem card_irredRepSet_2_3_5 : (IrredSU2RepSet 2 3 5).card = 2 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 7)$ has exactly 2 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_3_7 : (IrredSU2RepSet 2 3 7).card = 2 := rfl

/-- Alias for $\Sigma(2, 3, 7)$ representation count. -/
theorem card_irredRepSet_2_3_7 : (IrredSU2RepSet 2 3 7).card = 2 := rfl

/-- Brieskorn sphere $\Sigma(2, 3, 11)$ has exactly 4 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_3_11 : (IrredSU2RepSet 2 3 11).card = 4 := rfl

/-- Alias for $\Sigma(2, 3, 11)$ representation count. -/
theorem card_irredRepSet_2_3_11 : (IrredSU2RepSet 2 3 11).card = 4 := rfl

/-- Brieskorn sphere $\Sigma(2, 5, 7)$ has exactly 4 irreducible $SU(2)$ representations. -/
theorem card_irred_su2_2_5_7 : (IrredSU2RepSet 2 5 7).card = 4 := rfl

/-- Alias for $\Sigma(2, 5, 7)$ representation count. -/
theorem card_irredRepSet_2_5_7 : (IrredSU2RepSet 2 5 7).card = 4 := rfl

end BrieskornSU2
