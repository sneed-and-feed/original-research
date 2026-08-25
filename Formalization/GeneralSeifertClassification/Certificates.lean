/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.GeneralSeifertClassification.Solvability
import Formalization.GeneralSeifertClassification.Obstructions

/-!
# Explicit Certificates and Concrete Family Classifications

This module constructs explicit solution certificates and obstruction certificates for
3-point, 4-point, and 5-point Seifert fibration families, using both `Fin k → ℤ` vector representations
and `List ℤ` representations.

## Main Definitions & Constructors
- `GeneralSeifert.vec3`, `GeneralSeifert.twist3`: Explicit 3-vector and 3-twist constructors.
- `GeneralSeifert.vec4`, `GeneralSeifert.twist4`: Explicit 4-vector and 4-twist constructors.
- `GeneralSeifert.vec5`, `GeneralSeifert.twist5`: Explicit 5-vector and 5-twist constructors.
- `GeneralSeifert.cofactorList`, `GeneralSeifert.seifertOrderList`, `GeneralSeifert.IsHomotopySphereList`: List-based definitions.

## Main Certificates
- `GeneralSeifert.sphere_3point_2_3_5`: Poincaré Homology Sphere $\Sigma(2, 3, 5)$.
- `GeneralSeifert.sphere_3point_2_3_7`: Brieskorn Homology Sphere $\Sigma(2, 3, 7)$.
- `GeneralSeifert.sphere_3point_2_3_11`: Brieskorn Homology Sphere $\Sigma(2, 3, 11)$.
- `GeneralSeifert.obstruction_3point_2_4_6`: Obstruction certificate for non-coprime $\Sigma(2, 4, 6)$.
- `GeneralSeifert.sphere_4point_2_3_5_7`: 4-point Homology Sphere $\Sigma(2, 3, 5, 7)$.
- `GeneralSeifert.sphere_4point_2_3_5_11`: 4-point Homology Sphere $\Sigma(2, 3, 5, 11)$.
- `GeneralSeifert.sphere_4point_2_3_7_11`: 4-point Homology Sphere $\Sigma(2, 3, 7, 11)$.
- `GeneralSeifert.sphere_4point_2_3_7_13`: 4-point Homology Sphere $\Sigma(2, 3, 7, 13)$.
- `GeneralSeifert.sphere_4point_3_4_5_7`: 4-point Homology Sphere $\Sigma(3, 4, 5, 7)$.
- `GeneralSeifert.obstruction_4point_2_3_4_5`: Obstruction certificate for non-coprime $\Sigma(2, 3, 4, 5)$.
- `GeneralSeifert.obstruction_4point_2_4_6_8`: Obstruction certificate for non-coprime $\Sigma(2, 4, 6, 8)$.
- `GeneralSeifert.obstruction_4point_2_3_6_7`: Obstruction certificate for non-coprime $\Sigma(2, 3, 6, 7)$.
- `GeneralSeifert.sphere_5point_2_3_5_7_11`: 5-point Homology Sphere $\Sigma(2, 3, 5, 7, 11)$.
- `GeneralSeifert.obstruction_5point_2_3_5_6_7`: Obstruction certificate for non-coprime $\Sigma(2, 3, 5, 6, 7)$.
- `GeneralSeifert.sphere_list_2_3_5`, `sphere_list_2_3_7`, `sphere_list_2_3_5_7`, `sphere_list_2_3_5_11`,
  `sphere_list_2_3_7_11`, `sphere_list_3_4_5_7`, `sphere_list_2_3_5_7_11`: List-based certificates.
-/

namespace GeneralSeifert

/-! ### Explicit Constructors & Vector Definitions -/

/-- Explicit vector constructor for 3-point systems $(a_1, a_2, a_3)$. -/
def vec3 (a1 a2 a3 : ℤ) : Fin 3 → ℤ :=
  fun | ⟨0, _⟩ => a1
      | ⟨1, _⟩ => a2
      | ⟨2, _⟩ => a3

/-- Explicit twist constructor for 3-point systems $(\ell_1, \ell_2, \ell_3)$. -/
def twist3 (l1 l2 l3 : ℤ) : Fin 3 → ℤ := vec3 l1 l2 l3

/-- Explicit vector constructor for 4-point systems $(a_1, a_2, a_3, a_4)$. -/
def vec4 (a1 a2 a3 a4 : ℤ) : Fin 4 → ℤ :=
  fun | ⟨0, _⟩ => a1
      | ⟨1, _⟩ => a2
      | ⟨2, _⟩ => a3
      | ⟨3, _⟩ => a4

/-- Explicit twist constructor for 4-point systems $(\ell_1, \ell_2, \ell_3, \ell_4)$. -/
def twist4 (l1 l2 l3 l4 : ℤ) : Fin 4 → ℤ := vec4 l1 l2 l3 l4

/-- Explicit vector constructor for 5-point systems $(a_1, a_2, a_3, a_4, a_5)$. -/
def vec5 (a1 a2 a3 a4 a5 : ℤ) : Fin 5 → ℤ :=
  fun | ⟨0, _⟩ => a1
      | ⟨1, _⟩ => a2
      | ⟨2, _⟩ => a3
      | ⟨3, _⟩ => a4
      | ⟨4, _⟩ => a5

/-- Explicit twist constructor for 5-point systems $(\ell_1, \ell_2, \ell_3, \ell_4, \ell_5)$. -/
def twist5 (l1 l2 l3 l4 l5 : ℤ) : Fin 5 → ℤ := vec5 l1 l2 l3 l4 l5

/-! ### 3-Point Classification Theorems -/

/-- Poincaré Homology Sphere $\Sigma(2, 3, 5)$ under generalized $k$-point invariant:
$|30(1) - 15(1) - 10(1) - 6(1)| = |-1| = 1$. -/
theorem sphere_3point_2_3_5 : IsHomotopySphere (vec3 2 3 5) 1 (twist3 1 1 1) := rfl

/-- Brieskorn Homology Sphere $\Sigma(2, 3, 7)$ under generalized $k$-point invariant:
$|42(1) - 21(1) - 14(1) - 6(1)| = |1| = 1$. -/
theorem sphere_3point_2_3_7 : IsHomotopySphere (vec3 2 3 7) 1 (twist3 1 1 1) := rfl

/-- Brieskorn Homology Sphere $\Sigma(2, 3, 11)$ under generalized $k$-point invariant:
$|66(0) - 33(1) - 22(-1) - 6(-2)| = |1| = 1$. -/
theorem sphere_3point_2_3_11 : IsHomotopySphere (vec3 2 3 11) 0 (twist3 1 (-1) (-2)) := rfl

/-- Non-coprime obstruction certificate for $(2, 4, 6)$: $d = 2 > 1$ divides $a_0 = 2$ and $a_1 = 4$,
precluding any homology sphere. -/
theorem obstruction_3point_2_4_6 (l0 l1 l2 l3 : ℤ) :
    2 ∣ seifertOrder (vec3 2 4 6) l0 (twist3 l1 l2 l3) ∧
    ¬ IsHomotopySphere (vec3 2 4 6) l0 (twist3 l1 l2 l3) :=
  common_divisor_obstruction (i := 0) (j := 1) (by decide) (by decide) ⟨1, rfl⟩ ⟨2, rfl⟩ _ _

/-! ### 4-Point Classification Theorems -/

/-- 4-Point Seifert Homology Sphere $\Sigma(2, 3, 5, 7)$:
Twists $(0, 1, -1, -3, 3)$ yield:
$|210(0) - 105(1) - 70(-1) - 42(-3) - 30(3)| = |-105 + 70 + 126 - 90| = |1| = 1$. -/
theorem sphere_4point_2_3_5_7 : IsHomotopySphere (vec4 2 3 5 7) 0 (twist4 1 (-1) (-3) 3) := rfl

/-- 4-Point Seifert Homology Sphere $\Sigma(2, 3, 5, 11)$:
Twists $(0, -1, 1, 9, -18)$ yield:
$|330(0) - 165(-1) - 110(1) - 66(9) - 30(-18)| = |165 - 110 - 594 + 540| = |1| = 1$. -/
theorem sphere_4point_2_3_5_11 : IsHomotopySphere (vec4 2 3 5 11) 0 (twist4 (-1) 1 9 (-18)) := rfl

/-- 4-Point Seifert Homology Sphere $\Sigma(2, 3, 7, 11)$:
Twists $(0, 1, -1, 2, -5)$ yield:
$|462(0) - (231(1) + 154(-1) + 66(2) + 42(-5))| = |-(231 - 154 + 132 - 210)| = |1| = 1$. -/
theorem sphere_4point_2_3_7_11 : IsHomotopySphere (vec4 2 3 7 11) 0 (twist4 1 (-1) 2 (-5)) := rfl

/-- 4-Point Seifert Homology Sphere $\Sigma(2, 3, 7, 13)$:
Twists $(0, 1, -1, 1, -4)$ yield:
$|546(0) - (273(1) + 182(-1) + 78(1) + 42(-4))| = |-(273 - 182 + 78 - 168)| = |-1| = 1$. -/
theorem sphere_4point_2_3_7_13 : IsHomotopySphere (vec4 2 3 7 13) 0 (twist4 1 (-1) 1 (-4)) := rfl

/-- 4-Point Seifert Homology Sphere $\Sigma(3, 4, 5, 7)$:
Twists $(0, 1, -1, 1, -2)$ yield:
$|420(0) - (140(1) + 105(-1) + 84(1) + 60(-2))| = |-(140 - 105 + 84 - 120)| = |1| = 1$. -/
theorem sphere_4point_3_4_5_7 : IsHomotopySphere (vec4 3 4 5 7) 0 (twist4 1 (-1) 1 (-2)) := rfl

/-- Non-coprime obstruction certificate for $(2, 3, 4, 5)$:
$d = 2 > 1$ divides $a_0 = 2$ and $a_2 = 4$ (indices $0 \ne 2$), precluding any homology sphere. -/
theorem obstruction_4point_2_3_4_5 (l0 l1 l2 l3 l4 : ℤ) :
    2 ∣ seifertOrder (vec4 2 3 4 5) l0 (twist4 l1 l2 l3 l4) ∧
    ¬ IsHomotopySphere (vec4 2 3 4 5) l0 (twist4 l1 l2 l3 l4) :=
  common_divisor_obstruction (i := 0) (j := 2) (by decide) (by decide) ⟨1, rfl⟩ ⟨2, rfl⟩ _ _

/-- Non-coprime obstruction certificate for $(2, 4, 6, 8)$:
$d = 2 > 1$ divides $a_0 = 2$ and $a_1 = 4$ (indices $0 \ne 1$), precluding any homology sphere. -/
theorem obstruction_4point_2_4_6_8 (l0 l1 l2 l3 l4 : ℤ) :
    2 ∣ seifertOrder (vec4 2 4 6 8) l0 (twist4 l1 l2 l3 l4) ∧
    ¬ IsHomotopySphere (vec4 2 4 6 8) l0 (twist4 l1 l2 l3 l4) :=
  common_divisor_obstruction (i := 0) (j := 1) (by decide) (by decide) ⟨1, rfl⟩ ⟨2, rfl⟩ _ _

/-- Non-coprime obstruction certificate for $(2, 3, 6, 7)$:
$d = 2 > 1$ divides $a_0 = 2$ and $a_2 = 6$ (indices $0 \ne 2$), precluding any homology sphere. -/
theorem obstruction_4point_2_3_6_7 (l0 l1 l2 l3 l4 : ℤ) :
    2 ∣ seifertOrder (vec4 2 3 6 7) l0 (twist4 l1 l2 l3 l4) ∧
    ¬ IsHomotopySphere (vec4 2 3 6 7) l0 (twist4 l1 l2 l3 l4) :=
  common_divisor_obstruction (i := 0) (j := 2) (by decide) (by decide) ⟨1, rfl⟩ ⟨3, rfl⟩ _ _

/-! ### 5-Point Classification Theorems -/

/-- 5-Point Seifert Homology Sphere $\Sigma(2, 3, 5, 7, 11)$:
Twists $(0, 1, -1, 3, 1, -10)$ yield:
$|2310(0) - (1155(1) + 770(-1) + 462(3) + 330(1) + 210(-10))| = |-(1155 - 770 + 1386 + 330 - 2100)| = |-1| = 1$. -/
theorem sphere_5point_2_3_5_7_11 : IsHomotopySphere (vec5 2 3 5 7 11) 0 (twist5 1 (-1) 3 1 (-10)) := rfl

/-- Non-coprime obstruction certificate for $(2, 3, 5, 6, 7)$:
$d = 2 > 1$ divides $a_0 = 2$ and $a_3 = 6$ (indices $0 \ne 3$), precluding any homology sphere. -/
theorem obstruction_5point_2_3_5_6_7 (l0 l1 l2 l3 l4 l5 : ℤ) :
    2 ∣ seifertOrder (vec5 2 3 5 6 7) l0 (twist5 l1 l2 l3 l4 l5) ∧
    ¬ IsHomotopySphere (vec5 2 3 5 6 7) l0 (twist5 l1 l2 l3 l4 l5) :=
  common_divisor_obstruction (i := 0) (j := 3) (by decide) (by decide) ⟨1, rfl⟩ ⟨3, rfl⟩ _ _

/-! ### List-Based Formulation & Equivalences -/

/-- List-based cofactor product: product of elements in `a` omitting index `idx`. -/
def cofactorList (a : List ℤ) (idx : ℕ) : ℤ :=
  (a.eraseIdx idx).prod

/-- List-based generalized $k$-point Seifert invariant order formula:
$$O_k(a; \ell_0, \ell) = a.\mathrm{prod} \cdot \ell_0 - \sum_{j=0}^{k-1} (\mathrm{cofactorList}\; a\; j) \cdot \ell_j$$ -/
def seifertOrderList (a : List ℤ) (l0 : ℤ) (l : List ℤ) : ℤ :=
  a.prod * l0 - (List.zipWith (fun c lj => c * lj) (List.range a.length |>.map (cofactorList a)) l).sum

/-- Homotopy sphere condition for list-based Seifert invariant. -/
def IsHomotopySphereList (a : List ℤ) (l0 : ℤ) (l : List ℤ) : Prop :=
  |seifertOrderList a l0 l| = 1

/-- List-based Poincaré Homology Sphere $\Sigma(2, 3, 5)$:
$|30(1) - 15(1) - 10(1) - 6(1)| = |-1| = 1$. -/
theorem sphere_list_2_3_5 : IsHomotopySphereList [2, 3, 5] 1 [1, 1, 1] := rfl

/-- List-based Brieskorn Homology Sphere $\Sigma(2, 3, 7)$:
$|42(1) - 21(1) - 14(1) - 6(1)| = |1| = 1$. -/
theorem sphere_list_2_3_7 : IsHomotopySphereList [2, 3, 7] 1 [1, 1, 1] := rfl

/-- List-based 4-point Homology Sphere $\Sigma(2, 3, 5, 7)$:
$|210(0) - 105(1) - 70(-1) - 42(-3) - 30(3)| = |1| = 1$. -/
theorem sphere_list_2_3_5_7 : IsHomotopySphereList [2, 3, 5, 7] 0 [1, -1, -3, 3] := rfl

/-- List-based 4-point Homology Sphere $\Sigma(2, 3, 5, 11)$:
$|330(0) - 165(-1) - 110(1) - 66(9) - 30(-18)| = |1| = 1$. -/
theorem sphere_list_2_3_5_11 : IsHomotopySphereList [2, 3, 5, 11] 0 [-1, 1, 9, -18] := rfl

/-- List-based 4-point Homology Sphere $\Sigma(2, 3, 7, 11)$:
$|462(0) - (231(1) + 154(-1) + 66(2) + 42(-5))| = |1| = 1$. -/
theorem sphere_list_2_3_7_11 : IsHomotopySphereList [2, 3, 7, 11] 0 [1, -1, 2, -5] := rfl

/-- List-based 4-point Homology Sphere $\Sigma(3, 4, 5, 7)$:
$|420(0) - (140(1) + 105(-1) + 84(1) + 60(-2))| = |1| = 1$. -/
theorem sphere_list_3_4_5_7 : IsHomotopySphereList [3, 4, 5, 7] 0 [1, -1, 1, -2] := rfl

/-- List-based 5-point Homology Sphere $\Sigma(2, 3, 5, 7, 11)$:
$|2310(0) - (1155(1) + 770(-1) + 462(3) + 330(1) + 210(-10))| = |-1| = 1$. -/
theorem sphere_list_2_3_5_7_11 : IsHomotopySphereList [2, 3, 5, 7, 11] 0 [1, -1, 3, 1, -10] := rfl

end GeneralSeifert
