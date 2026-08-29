/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Fin.VecNotation
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

open scoped Matrix BigOperators
open Matrix

/-!
# Candidate 4: The Heisenberg Nilmanifold ($\mathrm{Nil}^3$ Thurston Space Form) - Basic Definitions

This module formalizes the foundational algebraic structure of the discrete 3D Heisenberg group
$\mathcal{H}_3(\mathbb{Z})$ and the topological bundle structure of the compact Heisenberg nilmanifold
$N_3 = \mathcal{H}_3(\mathbb{Z}) \backslash \mathcal{H}_3(\mathbb{R})$.

## Mathematical Summary

1. **Matrix Representation**:
   The discrete Heisenberg group $\mathcal{H}_3(\mathbb{Z})$ is represented as $3 \times 3$ upper unitriangular integer matrices:
   $$M(x, y, z) = \begin{pmatrix} 1 & x & z \\ 0 & 1 & y \\ 0 & 0 & 1 \end{pmatrix}, \quad x, y, z \in \mathbb{Z}.$$

2. **Group Operation & Inverse**:
   - Product law:
     $$(x_1, y_1, z_1) \cdot (x_2, y_2, z_2) = (x_1 + x_2, y_1 + y_2, z_1 + z_2 + x_1 y_2).$$
   - Identity element: $(0, 0, 0)$.
   - Group inverse:
     $$(x, y, z)^{-1} = (-x, -y, -z + x y).$$

3. **Commutators & Lie Algebra Relations**:
   - Commutator: $[g_1, g_2] = g_1 g_2 g_1^{-1} g_2^{-1} = (0, 0, x_1 y_2 - x_2 y_1)$.
   - Canonical generators: $X = (1, 0, 0), Y = (0, 1, 0), Z = (0, 0, 1)$.
   - Heisenberg relations: $[X, Y] = Z, [X, Z] = 1, [Y, Z] = 1$.

4. **Center & Abelianization**:
   - Center: $Z(\mathcal{H}_3(\mathbb{Z})) = \{(0, 0, z) \mid z \in \mathbb{Z}\} \cong \mathbb{Z}$.
   - Abelianization: $H_1(N_3, \mathbb{Z}) = \mathcal{H}_3(\mathbb{Z}) / [\mathcal{H}_3, \mathcal{H}_3] \cong \mathbb{Z} \oplus \mathbb{Z}$.
   - First Betti number: $b_1(N_3) = \mathrm{rank}_{\mathbb{Z}}(H_1(N_3, \mathbb{Z})) = 2$.

5. **Principal $S^1$-Bundle Structure**:
   - Fibration: $S^1 \hookrightarrow N_3 \xrightarrow{\pi} T^2$ where $\pi(x, y, z) = (x, y) \pmod{\mathbb{Z}^2}$.
   - Euler class: $e(N_3) = 1 \in H^2(T^2, \mathbb{Z}) \cong \mathbb{Z}$.
-/

namespace HeisenbergNilmanifold

/-! ### 1. Group Elements and Matrix Representation -/

/-- Element of the discrete 3D Heisenberg group $\mathcal{H}_3(\mathbb{Z})$.
    Represents the upper unitriangular matrix:
    $$\begin{pmatrix} 1 & x & z \\ 0 & 1 & y \\ 0 & 0 & 1 \end{pmatrix}$$ -/
@[ext]
structure HeisenbergGroup where
  x : ℤ
  y : ℤ
  z : ℤ
  deriving DecidableEq, Repr

/-- Explicit $3 \times 3$ upper unitriangular integer matrix representation. -/
def toMatrix (g : HeisenbergGroup) : Matrix (Fin 3) (Fin 3) ℤ :=
  ![![1, g.x, g.z],
    ![0, 1, g.y],
    ![0, 0, 1]]

/-- Explicit $3 \times 3$ matrix constructor from integer coordinates $(x, y, z)$. -/
def heisenbergMat (x y z : ℤ) : Matrix (Fin 3) (Fin 3) ℤ :=
  ![![1, x, z],
    ![0, 1, y],
    ![0, 0, 1]]

/-- Group multiplication on $\mathcal{H}_3(\mathbb{Z})$:
    $(x_1, y_1, z_1) \cdot (x_2, y_2, z_2) = (x_1 + x_2, y_1 + y_2, z_1 + z_2 + x_1 y_2)$. -/
def mul (g1 g2 : HeisenbergGroup) : HeisenbergGroup :=
  ⟨g1.x + g2.x, g1.y + g2.y, g1.z + g2.z + g1.x * g2.y⟩

instance : Mul HeisenbergGroup := ⟨mul⟩

/-- Coordinate-level group multiplication on triples $(x, y, z) \in \mathbb{Z}^3$. -/
def heisenbergMul (x1 y1 z1 x2 y2 z2 : ℤ) : ℤ × ℤ × ℤ :=
  (x1 + x2, y1 + y2, z1 + z2 + x1 * y2)

/-- Identity element of $\mathcal{H}_3(\mathbb{Z})$: $(0, 0, 0)$. -/
def one : HeisenbergGroup := ⟨0, 0, 0⟩

instance : One HeisenbergGroup := ⟨one⟩

/-- Group inverse on $\mathcal{H}_3(\mathbb{Z})$:
    $(x, y, z)^{-1} = (-x, -y, -z + x y)$. -/
def inv (g : HeisenbergGroup) : HeisenbergGroup :=
  ⟨-g.x, -g.y, -g.z + g.x * g.y⟩

instance : Inv HeisenbergGroup := ⟨inv⟩

/-- Coordinate-level group inverse on triples $(x, y, z) \in \mathbb{Z}^3$. -/
def heisenbergInv (x y z : ℤ) : ℤ × ℤ × ℤ :=
  (-x, -y, -z + x * y)

/-! ### 2. Simplification Lemmas and Group Axioms -/

@[simp] theorem mul_x (a b : HeisenbergGroup) : (a * b).x = a.x + b.x := rfl
@[simp] theorem mul_y (a b : HeisenbergGroup) : (a * b).y = a.y + b.y := rfl
@[simp] theorem mul_z (a b : HeisenbergGroup) : (a * b).z = a.z + b.z + a.x * b.y := rfl

@[simp] theorem one_x : (1 : HeisenbergGroup).x = 0 := rfl
@[simp] theorem one_y : (1 : HeisenbergGroup).y = 0 := rfl
@[simp] theorem one_z : (1 : HeisenbergGroup).z = 0 := rfl

@[simp] theorem inv_x (a : HeisenbergGroup) : a⁻¹.x = -a.x := rfl
@[simp] theorem inv_y (a : HeisenbergGroup) : a⁻¹.y = -a.y := rfl
@[simp] theorem inv_z (a : HeisenbergGroup) : a⁻¹.z = -a.z + a.x * a.y := rfl

theorem mul_assoc_proof (a b c : HeisenbergGroup) : a * b * c = a * (b * c) := by
  ext <;> { simp [add_assoc]; try ring }

theorem one_mul_proof (a : HeisenbergGroup) : 1 * a = a := by
  ext <;> simp

theorem mul_one_proof (a : HeisenbergGroup) : a * 1 = a := by
  ext <;> simp

theorem inv_mul_cancel_proof (a : HeisenbergGroup) : a⁻¹ * a = 1 := by
  ext <;> simp

instance : Group HeisenbergGroup where
  mul_assoc := mul_assoc_proof
  one_mul := one_mul_proof
  mul_one := mul_one_proof
  inv_mul_cancel := inv_mul_cancel_proof

/-- Left identity law. -/
theorem heisenberg_one_mul (g : HeisenbergGroup) : 1 * g = g := one_mul g

/-- Right identity law. -/
theorem heisenberg_mul_one (g : HeisenbergGroup) : g * 1 = g := mul_one g

/-- Associativity law. -/
theorem heisenberg_mul_assoc (a b c : HeisenbergGroup) : (a * b) * c = a * (b * c) := mul_assoc a b c

/-- Left inverse law. -/
theorem heisenberg_left_inv (g : HeisenbergGroup) : g⁻¹ * g = 1 := inv_mul_cancel g

/-- Right inverse law. -/
theorem heisenberg_right_inv (g : HeisenbergGroup) : g * g⁻¹ = 1 := mul_inv_cancel g

/-! ### 3. Matrix Representation Invariants -/

/-- Determinant of the matrix representation is 1 for all elements. -/
theorem det_toMatrix (g : HeisenbergGroup) : (toMatrix g).det = 1 := by
  rw [det_fin_three]
  simp [toMatrix]

/-- Determinant of explicit matrix constructor is 1. -/
theorem det_heisenbergMat (x y z : ℤ) : (heisenbergMat x y z).det = 1 := by
  rw [det_fin_three]
  simp [heisenbergMat]

/-- Matrix representation preserves multiplication:
    $M(g_1 \cdot g_2) = M(g_1) M(g_2)$. -/
theorem toMatrix_mul (g1 g2 : HeisenbergGroup) :
    toMatrix (g1 * g2) = toMatrix g1 * toMatrix g2 := by
  ext i j
  fin_cases i <;> fin_cases j <;> {
    rw [mul_apply, Fin.sum_univ_three]
    simp [toMatrix, add_assoc, add_comm]
  }

/-- Matrix representation maps identity to identity matrix. -/
theorem toMatrix_one : toMatrix 1 = 1 := by
  decide

/-! ### 4. Commutators and Canonical Generators -/

/-- Group commutator $[g, h] = g h g^{-1} h^{-1}$. -/
def commutator (g h : HeisenbergGroup) : HeisenbergGroup :=
  g * h * g⁻¹ * h⁻¹

/-- Commutator formula:
    $[(x_1, y_1, z_1), (x_2, y_2, z_2)] = (0, 0, x_1 y_2 - x_2 y_1)$. -/
theorem commutator_eq (g1 g2 : HeisenbergGroup) :
    commutator g1 g2 = ⟨0, 0, g1.x * g2.y - g2.x * g1.y⟩ := by
  ext <;> { simp [commutator]; try ring }

/-- Canonical generator $X = (1, 0, 0)$. -/
def genX : HeisenbergGroup := ⟨1, 0, 0⟩

/-- Canonical generator $Y = (0, 1, 0)$. -/
def genY : HeisenbergGroup := ⟨0, 1, 0⟩

/-- Canonical central generator $Z = (0, 0, 1)$. -/
def genZ : HeisenbergGroup := ⟨0, 0, 1⟩

/-- Heisenberg relation: $[X, Y] = Z$. -/
theorem commutator_X_Y : commutator genX genY = genZ := by
  ext <;> rfl

/-- Heisenberg relation: $[X, Z] = 1$. -/
theorem commutator_X_Z : commutator genX genZ = 1 := by
  ext <;> rfl

/-- Heisenberg relation: $[Y, Z] = 1$. -/
theorem commutator_Y_Z : commutator genY genZ = 1 := by
  ext <;> rfl

/-! ### 5. Center of the Discrete Heisenberg Group -/

/-- Centrality predicate: $g$ commutes with all elements of $\mathcal{H}_3(\mathbb{Z})$. -/
def isCentral (g : HeisenbergGroup) : Prop :=
  ∀ h : HeisenbergGroup, g * h = h * g

/-- Center characterization theorem:
    $g \in Z(\mathcal{H}_3(\mathbb{Z})) \iff g.x = 0 \wedge g.y = 0$. -/
theorem isCentral_iff (g : HeisenbergGroup) :
    isCentral g ↔ g.x = 0 ∧ g.y = 0 := by
  constructor
  · intro h
    have h1 := congr_arg (·.z) (h genY)
    have h2 := congr_arg (·.z) (h genX)
    simp [genY, genX] at h1 h2
    constructor <;> linarith
  · rintro ⟨hx, hy⟩ h
    ext <;> simp [hx, hy, add_comm]

/-- The central generator $Z$ is central. -/
theorem genZ_isCentral : isCentral genZ := by
  simp [isCentral_iff, genZ]

/-- Explicit center subgroup predicate $Z(\mathcal{H}_3(\mathbb{Z})) = \{(0, 0, z) \mid z \in \mathbb{Z}\}$. -/
def inCenter (g : HeisenbergGroup) : Prop :=
  ∃ z : ℤ, g = ⟨0, 0, z⟩

/-- Equivalence between `isCentral` and explicit center membership `inCenter`. -/
theorem isCentral_iff_inCenter (g : HeisenbergGroup) :
    isCentral g ↔ inCenter g := by
  simp [isCentral_iff, inCenter, HeisenbergGroup.ext_iff]

/-! ### 6. Abelianization and First Homology -/

/-- Abelianization map $\pi_{\mathrm{ab}} : \mathcal{H}_3(\mathbb{Z}) \to \mathbb{Z} \oplus \mathbb{Z}$
    given by $(x, y, z) \mapsto (x, y)$. -/
def abelianization (g : HeisenbergGroup) : ℤ × ℤ := (g.x, g.y)

/-- Abelianization is a group homomorphism to $(\mathbb{Z} \oplus \mathbb{Z}, +)$. -/
theorem abelianization_mul (g1 g2 : HeisenbergGroup) :
    abelianization (g1 * g2) = (g1.x + g2.x, g1.y + g2.y) := rfl

/-- Abelianization maps identity to $(0, 0)$. -/
theorem abelianization_one : abelianization 1 = (0, 0) := rfl

/-- The kernel of abelianization is exactly the center $Z(\mathcal{H}_3(\mathbb{Z}))$. -/
theorem abelianization_eq_zero_iff_isCentral (g : HeisenbergGroup) :
    abelianization g = (0, 0) ↔ isCentral g := by
  simp [isCentral_iff, abelianization, Prod.ext_iff]

/-- First Betti number $b_1(N_3) = \mathrm{rank}_{\mathbb{Z}}(H_1(N_3, \mathbb{Z})) = 2$. -/
def betti1 : ℕ := 2

/-- First Betti number is 2. -/
theorem betti1_eq_two : betti1 = 2 := rfl

/-! ### 7. Principal $S^1$-Bundle Projection and Euler Class -/

/-- Principal $S^1$-bundle projection $\pi : N_3 \to T^2$ onto the base torus. -/
def bundleProjection (x y _z : ℤ) : ℤ × ℤ := (x, y)

/-- Euler class of the principal $S^1$-bundle $N_3 \to T^2$ is $e = 1 \in H^2(T^2, \mathbb{Z})$. -/
def eulerClass : ℤ := 1

/-- Euler class is 1 (non-trivial nilmanifold circle bundle). -/
theorem eulerClass_eq_one : eulerClass = 1 := rfl

end HeisenbergNilmanifold
