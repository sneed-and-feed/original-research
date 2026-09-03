/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SymplecticTriangleRepresentations.Representations

open scoped Matrix

/-!
# Classification of Nilpotent Cusp Monodromies

This submodule establishes the formal algebraic classification of unipotent cusp monodromy
operators $N = T_0 - I_4$ acting on $V \cong \mathbb{Z}^4$, corresponding to the Kulikov and
Deligne–Schmid classification of degenerating complex abelian surfaces and K3 surfaces.

## Mathematical Overview

For an integral unipotent monodromy operator $M \in \mathrm{Mat}_4(\mathbb{Z})$ (such as $N = T_0 - I$):
1. **Type I Monodromy (Smooth Fiber)**:
   $M = 0$.
   The family does not degenerate; the central fiber is a smooth compact complex abelian surface.
2. **Type II Monodromy (Toric / 1D Nodal Degeneration)**:
   $M \ne 0$ and $M^2 = 0$.
   The monodromy logarithm has nilpotency index 2. The central fiber is a 1-dimensional cycle of
   elliptic surfaces / Kodaira type $I_b$ or elliptic ruled surfaces.
3. **Type III Monodromy (Maximally Unipotent Degeneration)**:
   $M^2 \ne 0$ and $M^4 = 0$.
   The monodromy logarithm has higher nilpotency index. The central fiber is a union of rational surfaces
   meeting along double curves and triple points.

## Main Declarations

- `SymplecticTriangleRepresentations.IsTypeI`: Predicate $M = 0$.
- `SymplecticTriangleRepresentations.IsTypeII`: Predicate $M \ne 0 \wedge M^2 = 0$.
- `SymplecticTriangleRepresentations.IsTypeIII`: Predicate $M^2 \ne 0 \wedge M^4 = 0$.
- `SymplecticTriangleRepresentations.typeII_not_typeI`: Type II monodromy is not Type I.
- `SymplecticTriangleRepresentations.typeII_not_typeIII`: Type II monodromy is not Type III.
- `SymplecticTriangleRepresentations.typeI_not_typeII`: Type I monodromy is not Type II.
- `SymplecticTriangleRepresentations.monodromy_34_is_typeII`: Machine-checked proof that the $(3,4,\infty)$ cusp monodromy $N$ is strictly Type II.
- `SymplecticTriangleRepresentations.monodromy_34_not_typeI`: $N$ is not Type I.
- `SymplecticTriangleRepresentations.monodromy_34_not_typeIII`: $N$ is not Type III.
- `SymplecticTriangleRepresentations.monodromy_23_is_typeII`: Machine-checked proof that the $(2,3,\infty)$ nilpotent operator $N_{23}$ is strictly Type II.
- `SymplecticTriangleRepresentations.monodromy_23_not_typeI`: $N_{23}$ is not Type I.
- `SymplecticTriangleRepresentations.monodromy_23_not_typeIII`: $N_{23}$ is not Type III.
- `SymplecticTriangleRepresentations.monodromy_24_is_typeII`: Machine-checked proof that the $(2,4,\infty)$ nilpotent operator $N_{24}$ is strictly Type II.
- `SymplecticTriangleRepresentations.monodromy_24_not_typeI`: $N_{24}$ is not Type I.
- `SymplecticTriangleRepresentations.monodromy_24_not_typeIII`: $N_{24}$ is not Type III.
- `SymplecticTriangleRepresentations.monodromy_25_is_typeII`: Machine-checked proof that the $(2,5,\infty)$ nilpotent operator $N_{25}$ is strictly Type II.
- `SymplecticTriangleRepresentations.monodromy_25_not_typeI`: $N_{25}$ is not Type I.
- `SymplecticTriangleRepresentations.monodromy_25_not_typeIII`: $N_{25}$ is not Type III.
- `SymplecticTriangleRepresentations.monodromy_35_is_typeII`: Machine-checked proof that the $(3,5,\infty)$ nilpotent operator $N_{35}$ is strictly Type II.
- `SymplecticTriangleRepresentations.monodromy_35_not_typeI`: $N_{35}$ is not Type I.
- `SymplecticTriangleRepresentations.monodromy_35_not_typeIII`: $N_{35}$ is not Type III.
- `SymplecticTriangleRepresentations.monodromy_44_is_typeII`: Machine-checked proof that the $(4,4,\infty)$ nilpotent operator $N_{44}$ is strictly Type II.
- `SymplecticTriangleRepresentations.monodromy_44_not_typeI`: $N_{44}$ is not Type I.
- `SymplecticTriangleRepresentations.monodromy_44_not_typeIII`: $N_{44}$ is not Type III.
-/

namespace SymplecticTriangleRepresentations

open Matrix

/-! ### 1. Monodromy Classification Predicates -/

/-- Type I monodromy (Smooth fiber / trivial cusp action): $M = 0$. -/
def IsTypeI (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M = 0

/-- Type II monodromy (Toric / 1D nodal degeneration): $M \ne 0$ and $M^2 = 0$. -/
def IsTypeII (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M ≠ 0 ∧ M * M = 0

/-- Type III monodromy (Maximally unipotent degeneration): $M^2 \ne 0$ and $M^4 = 0$. -/
def IsTypeIII (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M * M ≠ 0 ∧ M * M * M * M = 0

/-! ### 2. Mutual Exclusion Theorems -/

/-- Mutual exclusion: Type II monodromy is not Type I. -/
theorem typeII_not_typeI (M : Matrix (Fin 4) (Fin 4) ℤ) (h : IsTypeII M) : ¬ IsTypeI M :=
  h.1

/-- Mutual exclusion: Type II monodromy is not Type III. -/
theorem typeII_not_typeIII (M : Matrix (Fin 4) (Fin 4) ℤ) (h : IsTypeII M) : ¬ IsTypeIII M :=
  fun h3 => h3.1 h.2

/-- Mutual exclusion: Type I monodromy is not Type II. -/
theorem typeI_not_typeII (M : Matrix (Fin 4) (Fin 4) ℤ) (h : IsTypeI M) : ¬ IsTypeII M :=
  fun h2 => h2.1 h

/-! ### 3. Classification of the $(3,4,\infty)$ Family -/

/-- The $(3,4,\infty)$ cusp monodromy $N$ is strictly Type II. -/
theorem monodromy_34_is_typeII : IsTypeII N :=
  ⟨N_nonzero, N_squared_zero⟩

/-- The $(3,4,\infty)$ cusp monodromy $N$ is not Type I. -/
theorem monodromy_34_not_typeI : ¬ IsTypeI N :=
  typeII_not_typeI N monodromy_34_is_typeII

/-- The $(3,4,\infty)$ cusp monodromy $N$ is not Type III. -/
theorem monodromy_34_not_typeIII : ¬ IsTypeIII N :=
  typeII_not_typeIII N monodromy_34_is_typeII

/-! ### 4. Classification of the $(2,3,\infty)$ Family -/

/-- The $(2,3,\infty)$ nilpotent monodromy operator $N_{23}$ is strictly Type II. -/
theorem monodromy_23_is_typeII : IsTypeII N23 :=
  ⟨N23_nonzero, N23_squared_zero⟩

/-- The $(2,3,\infty)$ monodromy $N_{23}$ is not Type I. -/
theorem monodromy_23_not_typeI : ¬ IsTypeI N23 :=
  typeII_not_typeI N23 monodromy_23_is_typeII

/-- The $(2,3,\infty)$ monodromy $N_{23}$ is not Type III. -/
theorem monodromy_23_not_typeIII : ¬ IsTypeIII N23 :=
  typeII_not_typeIII N23 monodromy_23_is_typeII

/-! ### 5. Classification of the $(2,4,\infty)$ Family -/

/-- The $(2,4,\infty)$ nilpotent monodromy operator $N_{24}$ is strictly Type II. -/
theorem monodromy_24_is_typeII : IsTypeII N24 :=
  ⟨N24_nonzero, N24_squared_zero⟩

/-- The $(2,4,\infty)$ monodromy $N_{24}$ is not Type I. -/
theorem monodromy_24_not_typeI : ¬ IsTypeI N24 :=
  typeII_not_typeI N24 monodromy_24_is_typeII

/-- The $(2,4,\infty)$ monodromy $N_{24}$ is not Type III. -/
theorem monodromy_24_not_typeIII : ¬ IsTypeIII N24 :=
  typeII_not_typeIII N24 monodromy_24_is_typeII

/-! ### 6. Classification of the $(2,5,\infty)$ Family -/

/-- The $(2,5,\infty)$ nilpotent monodromy operator $N_{25}$ is strictly Type II. -/
theorem monodromy_25_is_typeII : IsTypeII N25 :=
  ⟨N25_nonzero, N25_squared_zero⟩

/-- The $(2,5,\infty)$ monodromy $N_{25}$ is not Type I. -/
theorem monodromy_25_not_typeI : ¬ IsTypeI N25 :=
  typeII_not_typeI N25 monodromy_25_is_typeII

/-- The $(2,5,\infty)$ monodromy $N_{25}$ is not Type III. -/
theorem monodromy_25_not_typeIII : ¬ IsTypeIII N25 :=
  typeII_not_typeIII N25 monodromy_25_is_typeII

/-! ### 7. Classification of the $(3,5,\infty)$ Family -/

/-- The $(3,5,\infty)$ nilpotent monodromy operator $N_{35}$ is strictly Type II. -/
theorem monodromy_35_is_typeII : IsTypeII N35 :=
  ⟨N35_nonzero, N35_squared_zero⟩

/-- The $(3,5,\infty)$ monodromy $N_{35}$ is not Type I. -/
theorem monodromy_35_not_typeI : ¬ IsTypeI N35 :=
  typeII_not_typeI N35 monodromy_35_is_typeII

/-- The $(3,5,\infty)$ monodromy $N_{35}$ is not Type III. -/
theorem monodromy_35_not_typeIII : ¬ IsTypeIII N35 :=
  typeII_not_typeIII N35 monodromy_35_is_typeII

/-! ### 8. Classification of the $(4,4,\infty)$ Family -/

/-- The $(4,4,\infty)$ nilpotent monodromy operator $N_{44}$ is strictly Type II. -/
theorem monodromy_44_is_typeII : IsTypeII N44 :=
  ⟨N44_nonzero, N44_squared_zero⟩

/-- The $(4,4,\infty)$ monodromy $N_{44}$ is not Type I. -/
theorem monodromy_44_not_typeI : ¬ IsTypeI N44 :=
  typeII_not_typeI N44 monodromy_44_is_typeII

/-- The $(4,4,\infty)$ monodromy $N_{44}$ is not Type III. -/
theorem monodromy_44_not_typeIII : ¬ IsTypeIII N44 :=
  typeII_not_typeIII N44 monodromy_44_is_typeII

end SymplecticTriangleRepresentations
