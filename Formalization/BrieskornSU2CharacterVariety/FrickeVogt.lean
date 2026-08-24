/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Fricke-Vogt Trace Variety & SU(2) Central Relations

This submodule formalizes the classical Fricke-Vogt trace polynomial $\Phi(t_x, t_y, t_z)$,
its permutation symmetries, discriminant identity, rational boundary zero property,
and order-2 generator specialization for representations $\rho: \pi_1(\Sigma(p, q, r)) \to SU(2)$
satisfying the central fiber relation $\rho(xyz) = -I$.

## Mathematical Background

For matrices $X, Y, Z \in SU(2)$ satisfying $XYZ = -I$, the trace variables
$(t_x, t_y, t_z) = (\operatorname{tr}(X), \operatorname{tr}(Y), \operatorname{tr}(Z))$ lie on the
Fricke-Vogt hypersurface:
$$\Phi(t_x, t_y, t_z) = t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4 = 0$$
The discriminant of $\Phi$ with respect to $t_z$ gives the identity:
$$(2 t_z + t_x t_y)^2 - (4 - t_x^2)(4 - t_y^2) = 4 \Phi(t_x, t_y, t_z)$$
For order-2 generators ($p = 2 \implies t_x = 0$), this simplifies to the boundary circle:
$$\Phi(0, t_y, t_z) = t_y^2 + t_z^2 - 4$$
-/

namespace BrieskornSU2

/-- The Fricke-Vogt trace polynomial for representations satisfying $XYZ = -I$:
    $\Phi(t_x, t_y, t_z) = t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4$. -/
def frickeVogtPoly {R : Type*} [CommRing R] (tx ty tz : R) : R :=
  tx ^ 2 + ty ^ 2 + tz ^ 2 + tx * ty * tz - 4

/-- Permutation symmetry of the Fricke-Vogt polynomial under $t_x \leftrightarrow t_y$. -/
theorem frickeVogtPoly_perm_xy {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly ty tx tz := by
  dsimp [frickeVogtPoly]; ring

/-- Permutation symmetry of the Fricke-Vogt polynomial under $t_y \leftrightarrow t_z$. -/
theorem frickeVogtPoly_perm_yz {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly tx tz ty := by
  dsimp [frickeVogtPoly]; ring

/-- Permutation symmetry of the Fricke-Vogt polynomial under $t_x \leftrightarrow t_z$. -/
theorem frickeVogtPoly_perm_xz {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly tz ty tx := by
  dsimp [frickeVogtPoly]; ring

/-- Cyclic permutation symmetry of the Fricke-Vogt polynomial. -/
theorem frickeVogtPoly_cyclic {R : Type*} [CommRing R] (tx ty tz : R) :
    frickeVogtPoly tx ty tz = frickeVogtPoly ty tz tx := by
  dsimp [frickeVogtPoly]; ring

/-- The discriminant identity for the Fricke-Vogt trace variety:
    $(2 t_z + t_x t_y)^2 - (4 - t_x^2)(4 - t_y^2) = 4 \Phi(t_x, t_y, t_z)$. -/
theorem frickeVogt_discriminant_identity {R : Type*} [CommRing R] (tx ty tz : R) :
    (2 * tz + tx * ty) ^ 2 - (4 - tx ^ 2) * (4 - ty ^ 2) = 4 * frickeVogtPoly tx ty tz := by
  dsimp [frickeVogtPoly]; ring

/-- Rational boundary vanishing: if $(2 t_z + t_x t_y)^2 = (4 - t_x^2)(4 - t_y^2)$ over $\mathbb{Q}$,
    then the Fricke-Vogt polynomial vanishes: $t_x^2 + t_y^2 + t_z^2 + t_x t_y t_z - 4 = 0$. -/
theorem frickeVogt_boundary_zero_rat (tx ty tz : ℚ)
    (h : (2 * tz + tx * ty) ^ 2 = (4 - tx ^ 2) * (4 - ty ^ 2)) :
    frickeVogtPoly tx ty tz = 0 := by
  linarith [frickeVogt_discriminant_identity (R := ℚ) tx ty tz, h]

/-- Specialization to order-2 generator $x$ ($p = 2 \implies t_x = 0$):
    $\Phi(0, t_y, t_z) = t_y^2 + t_z^2 - 4$. -/
theorem frickeVogt_order2_specialization {R : Type*} [CommRing R] (ty tz : R) :
    frickeVogtPoly 0 ty tz = ty ^ 2 + tz ^ 2 - 4 := by
  dsimp [frickeVogtPoly]; ring

/-- Order-2 boundary circle relation: when $t_y^2 + t_z^2 = 4$, the Fricke-Vogt relation vanishes. -/
theorem frickeVogt_order2_boundary_circle {R : Type*} [CommRing R] (ty tz : R)
    (h : ty ^ 2 + tz ^ 2 = 4) :
    frickeVogtPoly 0 ty tz = 0 := by
  rw [frickeVogt_order2_specialization, h, sub_self]

end BrieskornSU2
