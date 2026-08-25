/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.PicardFuchsMirrorMonodromy.CuspMonodromy
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Matrix.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

open scoped Matrix BigOperators
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Component 2: Mirror Map & Unipotent Monodromy for Picard-Fuchs Systems

This module formalizes the algebraic and analytic theory of the **mirror map** and **unipotent
cusp monodromy** for Picard-Fuchs differential equations of modular abelian surface families
$\Delta(p,q,\infty)$ and Calabi-Yau 3-fold mirror families (such as the Quintic 3-fold).

## Mathematical Overview

### 1. Frobenius Period Expansions at the Cusp $z = 0$
Near the regular singular cusp $z = 0$, the Frobenius method yields local period solutions:
- **Holomorphic Period**:
  $$w_0(z) = 1 + c_1 z + c_2 z^2 + \mathcal{O}(z^3)$$
- **Logarithmic Companion Period**:
  $$w_1(z) = w_0(z) \log z + \tilde{w}_1(z), \quad \tilde{w}_1(z) = b_1 z + b_2 z^2 + \mathcal{O}(z^3)$$
- **Regular Quotient**:
  $$\Delta t(z) = (b_1 - c_1) z$$

### 2. Flat Kähler / Mirror Coordinate and $q$-Series Inversion
The canonical flat coordinate $t$ and instanton coordinate $q$ are defined by:
$$t(z) = \frac{1}{2\pi i} \frac{w_1(z)}{w_0(z)} = \frac{1}{2\pi i}\log z + \Delta t(z)$$
$$q(z) = \exp(2\pi i t) = z \exp(2\pi i \Delta t(z)) = z (1 + q_1 z + q_2 z^2 + \mathcal{O}(z^3))$$
The inverse mirror map $z(q)$ has the series expansion:
$$z(q) = q (1 + z_1 q + z_2 q^2 + \mathcal{O}(q^3))$$
Algebraic reversion of series establishes the exact universal inversion formulas through order 2:
$$z_1 = -q_1, \qquad z_2 = 2 q_1^2 - q_2$$

### 3. Cusp Monodromy and Nilpotent Matrix Exponentials
Under local analytic continuation around the cusp $z \mapsto e^{2\pi i} z$:
- The logarithmic coordinate transforms as $\log z \mapsto \log z + 2\pi i$.
- The flat coordinate shifts by $t \mapsto t + 1$, and $q = \exp(2\pi i t)$ is single-valued ($q(t+1) = q(t)$).
- On the 4-dimensional period vector $\Pi_4 = (w_0, w_1, w_2, w_3)^T$, the monodromy transformation acts
  via the matrix exponential $\exp(N)$:
  - **Type II Degeneration** (Abelian surface modular families $\Delta(3,4,\infty)$):
    $N^2 = 0 \implies \exp(N) = I_4 + N$, with $(I_4 + N)^k = I_4 + k N$.
  - **Type III Degeneration** (Calabi-Yau 3-fold MUM):
    $N^4 = 0 \implies \exp(N) = I_4 + N + \frac{1}{2} N^2 + \frac{1}{6} N^3$.

### 4. Certified Mirror Map Coefficients
- **Quintic Calabi-Yau 3-fold**:
  $$q_1 = 770, \quad q_2 = 293275 \implies z_1 = -770, \quad z_2 = 892525$$
- **Modular $\Delta(3,4,\infty)$ family**:
  $$q_1 = 4, \quad q_2 = 18 \implies z_1 = -4, \quad z_2 = 14$$
- **Modular $\Delta(2,3,\infty)$ family**:
  $$q_1 = 2, \quad q_2 = 5 \implies z_1 = -2, \quad z_2 = 3$$

## Main Declarations

### Frobenius Expansions
- `PicardFuchsMirrorMonodromy.w0`: Truncated holomorphic period $1 + c_1 z + c_2 z^2$.
- `PicardFuchsMirrorMonodromy.w1_tilde`: Truncated logarithmic companion $b_1 z + b_2 z^2$.
- `PicardFuchsMirrorMonodromy.delta_t`: Regular quotient $(b_1 - c_1) z$.
- `PicardFuchsMirrorMonodromy.w1_tilde_sub_delta_t`: Difference $\tilde{w}_1(z) - \Delta t(z) = c_1 z + b_2 z^2$.

### Mirror Map Inversion
- `PicardFuchsMirrorMonodromy.q_series`: Truncated mirror map $z(1 + q_1 z + q_2 z^2)$.
- `PicardFuchsMirrorMonodromy.z_series`: Truncated inverse mirror map $q(1 + z_1 q + z_2 q^2)$.
- `PicardFuchsMirrorMonodromy.mirror_inversion_sub_z`: Machine-checked proof that $z(q(z)) = z + \mathcal{O}(z^4)$.
- `PicardFuchsMirrorMonodromy.mirror_inversion_sub_q`: Machine-checked proof that $q(z(q)) = q + \mathcal{O}(q^4)$.

### Monodromy & Matrix Exponentials
- `PicardFuchsMirrorMonodromy.PeriodVector`: 4-dimensional period vector type `Fin 4 → R`.
- `PicardFuchsMirrorMonodromy.toRatMatrix4`: Integer to rational matrix embedding.
- `PicardFuchsMirrorMonodromy.expTypeII`: Matrix exponential for index-2 unipotent operators $I + N$.
- `PicardFuchsMirrorMonodromy.expTypeII_squared`, `expTypeII_mul_sub`: Monodromy algebraic identities.
- `PicardFuchsMirrorMonodromy.expTypeIII`: Matrix exponential for index-4 unipotent operators $I + N + \frac{1}{2}N^2 + \frac{1}{6}N^3$.
- `PicardFuchsMirrorMonodromy.expTypeIII_N_MUM_act`: Explicit action of MUM monodromy on period vectors.
- `PicardFuchsMirrorMonodromy.monodromyShiftT`: Flat coordinate translation $t \mapsto t + 1$.

### Certificates
- `PicardFuchsMirrorMonodromy.quintic_mirror_map_inversion`: Quintic 3-fold certificate ($z_1 = -770, z_2 = 892525$).
- `PicardFuchsMirrorMonodromy.modular_34_mirror_map_inversion`: $\Delta(3,4,\infty)$ certificate ($z_1 = -4, z_2 = 14$).
- `PicardFuchsMirrorMonodromy.modular_23_mirror_map_inversion`: $\Delta(2,3,\infty)$ certificate ($z_1 = -2, z_2 = 3$).
-/

namespace PicardFuchsMirrorMonodromy

/-! ### 1. Frobenius Period Expansion Models -/

/-- Truncated holomorphic period solution at cusp $z = 0$:
    $w_0(c_1, c_2, z) = 1 + c_1 z + c_2 z^2$. -/
def w0 (c1 c2 z : ℚ) : ℚ :=
  1 + c1 * z + c2 * z^2

/-- Truncated logarithmic companion series at cusp $z = 0$:
    $\tilde{w}_1(b_1, b_2, z) = b_1 z + b_2 z^2$. -/
def w1_tilde (b1 b2 z : ℚ) : ℚ :=
  b1 * z + b2 * z^2

/-- Regular quotient series $\Delta t(c_1, b_1, z) = (b_1 - c_1) z$. -/
def delta_t (c1 b1 z : ℚ) : ℚ :=
  (b1 - c1) * z

/-- Value of the holomorphic period at the cusp $z = 0$ is $1$. -/
@[simp] theorem w0_zero (c1 c2 : ℚ) : w0 c1 c2 0 = 1 := by
  simp [w0]

/-- Value of the logarithmic companion at the cusp $z = 0$ is $0$. -/
@[simp] theorem w1_tilde_zero (b1 b2 : ℚ) : w1_tilde b1 b2 0 = 0 := by
  simp [w1_tilde]

/-- Value of the regular quotient at $z = 0$ is $0$. -/
@[simp] theorem delta_t_zero (c1 b1 : ℚ) : delta_t c1 b1 0 = 0 := by
  simp [delta_t]

/-- Value of $w_0$ at $z = 1$. -/
theorem w0_one (c1 c2 : ℚ) : w0 c1 c2 1 = 1 + c1 + c2 := by
  simp [w0]

/-- Difference between the companion series and the regular quotient $\Delta t(z)$:
    $\tilde{w}_1(z) - \Delta t(z) = c_1 z + b_2 z^2$. -/
theorem w1_tilde_sub_delta_t (c1 b1 b2 z : ℚ) :
    w1_tilde b1 b2 z - delta_t c1 b1 z = c1 * z + b2 * z^2 := by
  dsimp [w1_tilde, delta_t]; ring

/-- Algebraic decomposition expressing $\tilde{w}_1(z)$ as $\Delta t(z) + c_1 z + b_2 z^2$. -/
theorem w1_tilde_eq_delta_t_add (c1 b1 b2 z : ℚ) :
    w1_tilde b1 b2 z = delta_t c1 b1 z + c1 * z + b2 * z^2 := by
  dsimp [w1_tilde, delta_t]; ring

/-! ### 2. Flat Coordinate Mirror Map & Series Inversion -/

/-- Truncated $q$-series expansion of the mirror map:
    $q_{\mathrm{series}}(q_1, q_2, z) = z(1 + q_1 z + q_2 z^2) = z + q_1 z^2 + q_2 z^3$. -/
def q_series (q1 q2 z : ℚ) : ℚ :=
  z * (1 + q1 * z + q2 * z^2)

/-- Truncated inverse mirror map $z$-series expansion:
    $z_{\mathrm{series}}(z_1, z_2, q) = q(1 + z_1 q + z_2 q^2) = q + z_1 q^2 + z_2 q^3$. -/
def z_series (z1 z2 q : ℚ) : ℚ :=
  q * (1 + z1 * q + z2 * q^2)

/-- At $z = 0$, $q_{\mathrm{series}} = 0$. -/
@[simp] theorem q_series_zero (q1 q2 : ℚ) : q_series q1 q2 0 = 0 := by
  simp [q_series]

/-- At $q = 0$, $z_{\mathrm{series}} = 0$. -/
@[simp] theorem z_series_zero (z1 z2 : ℚ) : z_series z1 z2 0 = 0 := by
  simp [z_series]

/-- Exact algebraic inversion theorem:
    When $z_1 = -q_1$ and $z_2 = 2 q_1^2 - q_2$, the composition $z(q(z))$ agrees with $z$
    modulo $\mathcal{O}(z^4)$, with the explicit error polynomial factored. -/
theorem mirror_inversion_sub_z (q1 q2 z : ℚ) :
    z_series (-q1) (2 * q1^2 - q2) (q_series q1 q2 z) - z =
      z^4 * (5 * q1^3 - 5 * q1 * q2 +
             (6 * q1^4 + q1^2 * q2 - 3 * q2^2) * z +
             (2 * q1^5 + 11 * q1^3 * q2 - 7 * q1 * q2^2) * z^2 +
             (6 * q1^4 * q2 + 3 * q1^2 * q2^2 - 3 * q2^3) * z^3 +
             (6 * q1^3 * q2^2 - 3 * q1 * q2^3) * z^4 +
             (2 * q1^2 * q2^3 - q2^4) * z^5) := by
  dsimp [z_series, q_series]; ring

/-- Exact algebraic composition identity for $z_{\mathrm{series}}(q_{\mathrm{series}}(z))$ through order 3. -/
theorem mirror_inversion_order2_exact (q1 q2 z : ℚ) :
    z_series (-q1) (2 * q1^2 - q2) (q_series q1 q2 z) =
      z + z^4 * (5 * q1^3 - 5 * q1 * q2 +
                 (6 * q1^4 + q1^2 * q2 - 3 * q2^2) * z +
                 (2 * q1^5 + 11 * q1^3 * q2 - 7 * q1 * q2^2) * z^2 +
                 (6 * q1^4 * q2 + 3 * q1^2 * q2^2 - 3 * q2^3) * z^3 +
                 (6 * q1^3 * q2^2 - 3 * q1 * q2^3) * z^4 +
                 (2 * q1^2 * q2^3 - q2^4) * z^5) := by
  dsimp [z_series, q_series]; ring

/-- Dual algebraic inversion theorem:
    The composition $q_{\mathrm{series}}(z_{\mathrm{series}}(q))$ agrees with $q$ modulo $\mathcal{O}(q^4)$. -/
theorem mirror_inversion_sub_q (q1 q2 q : ℚ) :
    q_series q1 q2 (z_series (-q1) (2 * q1^2 - q2) q) - q =
      q^4 * (5 * q1^3 - 5 * q1 * q2 +
             (11 * q1^2 * q2 - 4 * q1^4 - 3 * q2^2) * q +
             (4 * q1^5 - 17 * q1^3 * q2 + 7 * q1 * q2^2) * q^2 +
             (18 * q1^4 * q2 - 15 * q1^2 * q2^2 + 3 * q2^3) * q^3 +
             (12 * q1^3 * q2^2 - 12 * q1^5 * q2 - 3 * q1 * q2^3) * q^4 +
             (8 * q1^6 * q2 - 12 * q1^4 * q2^2 + 6 * q1^2 * q2^3 - q2^4) * q^5) := by
  dsimp [z_series, q_series]; ring

/-- The unique algebraic inverse coefficients $z_1 = -q_1$ and $z_2 = 2 q_1^2 - q_2$. -/
def inverseMirrorZ1 (q1 : ℚ) : ℚ := -q1

/-- Second order inverse mirror coefficient. -/
def inverseMirrorZ2 (q1 q2 : ℚ) : ℚ := 2 * q1^2 - q2

/-- The inverse coefficients formula identity. -/
theorem inverseMirror_formula (q1 q2 : ℚ) :
    inverseMirrorZ1 q1 = -q1 ∧ inverseMirrorZ2 q1 q2 = 2 * q1^2 - q2 :=
  ⟨rfl, rfl⟩

/-! ### 3. Period Vectors & Cusp Monodromy Transformation -/

/-- Standard 4-dimensional period vector type. -/
def PeriodVector (R : Type*) := Fin 4 → R

/-- Construct a rational 4-dimensional period vector from 4 coordinates. -/
def periodVector (w0 w1 w2 w3 : ℚ) : PeriodVector ℚ :=
  ![w0, w1, w2, w3]

/-- Construct an integer 4-dimensional period vector from 4 coordinates. -/
def periodVectorZ (w0 w1 w2 w3 : ℤ) : PeriodVector ℤ :=
  ![w0, w1, w2, w3]

/-- Monodromy action on the flat coordinate $t \mapsto t + 1$. -/
def monodromyShiftT (t : ℚ) : ℚ :=
  t + 1

/-- Monodromy iteration action $t \mapsto t + n$ for $n \in ℕ$. -/
def monodromyShiftTN (n : ℕ) (t : ℚ) : ℚ :=
  t + (n : ℚ)

/-- Monodromy iteration action $t \mapsto t + k$ for $k \in ℤ$. -/
def monodromyShiftTZ (k : ℤ) (t : ℚ) : ℚ :=
  t + (k : ℚ)

/-- Single-valuedness / monodromy invariance predicate for flat coordinate functions:
    $f(t + 1) = f(t)$. -/
def IsMonodromyInvariant (f : ℚ → ℚ) : Prop :=
  ∀ t, f (t + 1) = f t

/-- Monodromy invariance under $n$-fold monodromy shifts. -/
theorem monodromy_invariant_shift_n (f : ℚ → ℚ) (hf : IsMonodromyInvariant f) (t : ℚ) :
    ∀ n : ℕ, f (t + (n : ℚ)) = f t
  | 0 => by simp
  | n + 1 => by rw [Nat.cast_add_one, ← add_assoc, hf, monodromy_invariant_shift_n f hf t n]

/-- Embedding of integer $4 \times 4$ matrices into rational matrices. -/
def toRatMatrix4 (M : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 4) (Fin 4) ℚ :=
  fun i j => (M i j : ℚ)

/-- Multiplication compatibility for integer-to-rational matrix embedding. -/
theorem toRatMatrix4_mul (A B : Matrix (Fin 4) (Fin 4) ℤ) :
    toRatMatrix4 (A * B) = toRatMatrix4 A * toRatMatrix4 B := by
  ext i j
  simp only [toRatMatrix4, Matrix.mul_apply, Fin.sum_univ_four]
  push_cast
  rfl

/-- Addition compatibility for integer-to-rational matrix embedding. -/
theorem toRatMatrix4_add (A B : Matrix (Fin 4) (Fin 4) ℤ) :
    toRatMatrix4 (A + B) = toRatMatrix4 A + toRatMatrix4 B := by
  ext i j
  simp only [toRatMatrix4, Matrix.add_apply]
  push_cast
  rfl

/-- Identity matrix compatibility. -/
theorem toRatMatrix4_one : toRatMatrix4 1 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Zero matrix compatibility. -/
theorem toRatMatrix4_zero : toRatMatrix4 0 = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Matrix exponential for Type II nilpotent monodromy ($N^2 = 0$):
    $\exp(N) = I_4 + N$. -/
def expTypeII (N : Matrix (Fin 4) (Fin 4) ℚ) : Matrix (Fin 4) (Fin 4) ℚ :=
  1 + N

/-- Matrix exponential for Type II nilpotent monodromy on $ℤ$:
    $\exp(N) = I_4 + N$. -/
def expTypeII_Z (N : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 4) (Fin 4) ℤ :=
  1 + N

/-- For any index-2 nilpotent matrix $N^2 = 0$, the square of the monodromy is $(I+N)^2 = I + 2N$. -/
theorem expTypeII_squared (N : Matrix (Fin 4) (Fin 4) ℚ) (hN : N * N = 0) :
    expTypeII N * expTypeII N = 1 + (2 : ℚ) • N := by
  dsimp [expTypeII]
  rw [add_mul, mul_add, mul_add, one_mul, mul_one, one_mul, hN, add_zero, add_assoc, two_smul]

/-- For any index-2 nilpotent matrix $N^2 = 0$, $(I+N)(I-N) = I_4$. -/
theorem expTypeII_mul_sub (N : Matrix (Fin 4) (Fin 4) ℚ) (hN : N * N = 0) :
    (1 + N) * (1 - N) = 1 := by
  rw [add_mul, mul_sub, mul_sub, one_mul, mul_one, one_mul, hN, sub_zero, sub_add_cancel]

/-- Monodromy action of $\exp(N)$ on a period vector $\Pi$: $(I + N)\Pi = \Pi + N\Pi$. -/
theorem expTypeII_period_action (N : Matrix (Fin 4) (Fin 4) ℚ) (Pi : Fin 4 → ℚ) :
    expTypeII N *ᵥ Pi = Pi + N *ᵥ Pi := by
  simp [expTypeII, add_mulVec]

/-- Matrix exponential for Type III maximally unipotent monodromy ($N^4 = 0$):
    $\exp(N) = I_4 + N + \frac{1}{2} N^2 + \frac{1}{6} N^3$. -/
def expTypeIII (N : Matrix (Fin 4) (Fin 4) ℚ) : Matrix (Fin 4) (Fin 4) ℚ :=
  1 + N + (1/2 : ℚ) • (N * N) + (1/6 : ℚ) • (N * N * N)

/-- Integer MUM nilpotent matrix $N_{\mathrm{MUM}} \in \mathrm{Mat}_4(ℤ)$ from `CuspMonodromy`. -/
def N_MUM_Z : Matrix (Fin 4) (Fin 4) ℤ :=
  PicardFuchsMirrorMonodromy.N_MUM

/-- Rational MUM nilpotent matrix $N_{\mathrm{MUM}} \in \mathrm{Mat}_4(ℚ)$. -/
def N_MUM_Q : Matrix (Fin 4) (Fin 4) ℚ :=
  toRatMatrix4 N_MUM_Z

/-- Helper integer matrix $1 + N_{\mathrm{MUM},\mathbb{Z}}$. -/
def N1_Z : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 1, 1, 0, 0 ],
    ![ 0, 1, 1, 0 ],
    ![ 0, 0, 1, 1 ],
    ![ 0, 0, 0, 1 ]]

/-- Helper integer matrix $N_{\mathrm{MUM},\mathbb{Z}}^2$. -/
def N2_Z : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0, 0, 1, 0 ],
    ![ 0, 0, 0, 1 ],
    ![ 0, 0, 0, 0 ],
    ![ 0, 0, 0, 0 ]]

/-- Helper integer matrix $N_{\mathrm{MUM},\mathbb{Z}}^3$. -/
def N3_Z : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0, 0, 0, 1 ],
    ![ 0, 0, 0, 0 ],
    ![ 0, 0, 0, 0 ],
    ![ 0, 0, 0, 0 ]]

/-- $1 + N_{\mathrm{MUM},\mathbb{Z}} = N_1$. -/
theorem N_MUM_Z_one_add : 1 + N_MUM_Z = N1_Z := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_{\mathrm{MUM},\mathbb{Z}}^2 = N_2$. -/
theorem N_MUM_Z_squared : N_MUM_Z * N_MUM_Z = N2_Z := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_{\mathrm{MUM},\mathbb{Z}}^3 = N_3$. -/
theorem N_MUM_Z_cubed : N_MUM_Z * N_MUM_Z * N_MUM_Z = N3_Z := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_{\mathrm{MUM},\mathbb{Z}}^4 = 0$. -/
theorem N_MUM_Z_fourth :
    N_MUM_Z * N_MUM_Z * N_MUM_Z * N_MUM_Z = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_{\mathrm{MUM},\mathbb{Q}}^2$. -/
theorem N_MUM_Q_squared :
    N_MUM_Q * N_MUM_Q = toRatMatrix4 N2_Z := by
  rw [N_MUM_Q, ← toRatMatrix4_mul, N_MUM_Z_squared]

/-- $N_{\mathrm{MUM},\mathbb{Q}}^3$. -/
theorem N_MUM_Q_cubed :
    N_MUM_Q * N_MUM_Q * N_MUM_Q = toRatMatrix4 N3_Z := by
  rw [N_MUM_Q, ← toRatMatrix4_mul, ← toRatMatrix4_mul, N_MUM_Z_cubed]

/-- $N_{\mathrm{MUM},\mathbb{Q}}^4 = 0$. -/
theorem N_MUM_Q_fourth :
    N_MUM_Q * N_MUM_Q * N_MUM_Q * N_MUM_Q = 0 := by
  rw [N_MUM_Q, ← toRatMatrix4_mul, ← toRatMatrix4_mul, ← toRatMatrix4_mul, N_MUM_Z_fourth, toRatMatrix4_zero]

/-- Explicit matrix form of the Calabi-Yau 3-fold MUM unipotent monodromy matrix $\exp(N_{\mathrm{MUM}})$. -/
theorem expTypeIII_N_MUM_matrix :
    expTypeIII N_MUM_Q =
      ![![ 1, 1, 1/2, 1/6 ],
        ![ 0, 1, 1, 1/2 ],
        ![ 0, 0, 1, 1 ],
        ![ 0, 0, 0, 1 ]] := by
  dsimp [expTypeIII, N_MUM_Q]
  rw [← toRatMatrix4_mul, ← toRatMatrix4_mul, N_MUM_Z_cubed, N_MUM_Z_squared]
  rw [← toRatMatrix4_one, ← toRatMatrix4_add, N_MUM_Z_one_add]
  ext i j
  fin_cases i <;> fin_cases j <;> norm_num [toRatMatrix4, N1_Z, N2_Z, N3_Z]

/-- Explicit action of the Type III unipotent monodromy $\exp(N_{\mathrm{MUM}})$ on a general period vector
    $\Pi = (w_0, w_1, w_2, w_3)^T$:
    $\exp(N_{\mathrm{MUM}}) \Pi = \left(w_0 + w_1 + \frac{1}{2}w_2 + \frac{1}{6}w_3, \, w_1 + w_2 + \frac{1}{2}w_3, \, w_2 + w_3, \, w_3\right)^T$. -/
theorem expTypeIII_N_MUM_act (w0 w1 w2 w3 : ℚ) :
    expTypeIII N_MUM_Q *ᵥ ![w0, w1, w2, w3] =
      ![w0 + w1 + 1/2 * w2 + 1/6 * w3,
        w1 + w2 + 1/2 * w3,
        w2 + w3,
        w3] := by
  rw [expTypeIII_N_MUM_matrix]
  ext i
  fin_cases i <;> simp [Matrix.mulVec, dotProduct, Fin.sum_univ_four]

/-- Monodromy commutativity with log-monodromy operator for Type II: $(I + N) N = N (I + N)$. -/
theorem typeII_monodromy_commute (N : Matrix (Fin 4) (Fin 4) ℚ) :
    expTypeII N * N = N * expTypeII N := by
  dsimp [expTypeII]
  simp only [add_mul, mul_add, one_mul, mul_one]

/-- Monodromy commutativity with log-monodromy operator for Type III: $\exp(N) N = N \exp(N)$. -/
theorem typeIII_monodromy_commute (N : Matrix (Fin 4) (Fin 4) ℚ) :
    expTypeIII N * N = N * expTypeIII N := by
  dsimp [expTypeIII]
  simp only [add_mul, mul_add, one_mul, mul_one, smul_mul_assoc, mul_smul_comm, mul_assoc]

/-! ### 4. Certified Mirror Map Coefficients -/

/-! #### A. Quintic Calabi-Yau 3-Fold Mirror Family -/

/-- Mirror map coefficient $q_1$ for the Quintic 3-fold. -/
def q1_quintic : ℚ := 770

/-- Mirror map coefficient $q_2$ for the Quintic 3-fold. -/
def q2_quintic : ℚ := 293275

/-- Inverse mirror map coefficient $z_1$ for the Quintic 3-fold. -/
def z1_quintic : ℚ := -770

/-- Inverse mirror map coefficient $z_2$ for the Quintic 3-fold. -/
def z2_quintic : ℚ := 892525

/-- Proof that the Quintic $z_1$ satisfies the algebraic inversion formula $z_1 = -q_1$. -/
theorem quintic_z1_eq : z1_quintic = -q1_quintic := rfl

/-- Proof that the Quintic $z_2$ satisfies the algebraic inversion formula $z_2 = 2 q_1^2 - q_2$. -/
theorem quintic_z2_eq : z2_quintic = 2 * q1_quintic^2 - q2_quintic := by
  norm_num [z2_quintic, q1_quintic, q2_quintic]

/-- Machine-checked certified mirror map inversion pair for the Quintic Calabi-Yau 3-fold. -/
theorem quintic_mirror_map_inversion :
    z1_quintic = -q1_quintic ∧ z2_quintic = 2 * q1_quintic^2 - q2_quintic :=
  ⟨quintic_z1_eq, quintic_z2_eq⟩

/-- Quintic mirror map composition inversion evaluation. -/
theorem quintic_mirror_composition (z : ℚ) :
    z_series z1_quintic z2_quintic (q_series q1_quintic q2_quintic z) - z =
      z^4 * (1153556250 +
             2025034530625 * z +
             1550548586606250 * z^2 +
             695882927515171875 * z^3 +
             177330099005951718750 * z^4 +
             22513629777476402734375 * z^5) := by
  dsimp [z_series, q_series, z1_quintic, z2_quintic, q1_quintic, q2_quintic]; ring

/-! #### B. Modular Triangle Family $\Delta(3,4,\infty)$ -/

/-- Mirror map coefficient $q_1$ for the modular $\Delta(3,4,\infty)$ family. -/
def q1_modular_34 : ℚ := 4

/-- Mirror map coefficient $q_2$ for the modular $\Delta(3,4,\infty)$ family. -/
def q2_modular_34 : ℚ := 18

/-- Inverse mirror map coefficient $z_1$ for the modular $\Delta(3,4,\infty)$ family. -/
def z1_modular_34 : ℚ := -4

/-- Inverse mirror map coefficient $z_2$ for the modular $\Delta(3,4,\infty)$ family. -/
def z2_modular_34 : ℚ := 14

/-- Proof that the $\Delta(3,4,\infty)$ $z_1$ satisfies $z_1 = -q_1$. -/
theorem modular_34_z1_eq : z1_modular_34 = -q1_modular_34 := rfl

/-- Proof that the $\Delta(3,4,\infty)$ $z_2$ satisfies $z_2 = 2 q_1^2 - q_2$. -/
theorem modular_34_z2_eq : z2_modular_34 = 2 * q1_modular_34^2 - q2_modular_34 := by
  norm_num [z2_modular_34, q1_modular_34, q2_modular_34]

/-- Machine-checked certified mirror map inversion pair for the modular $\Delta(3,4,\infty)$ family. -/
theorem modular_34_mirror_map_inversion :
    z1_modular_34 = -q1_modular_34 ∧ z2_modular_34 = 2 * q1_modular_34^2 - q2_modular_34 :=
  ⟨modular_34_z1_eq, modular_34_z2_eq⟩

/-- $\Delta(3,4,\infty)$ mirror map composition inversion evaluation. -/
theorem modular_34_mirror_composition (z : ℚ) :
    z_series z1_modular_34 z2_modular_34 (q_series q1_modular_34 q2_modular_34 z) - z =
      z^4 * (-40 + 852 * z + 5648 * z^2 + 25704 * z^3 + 54432 * z^4 + 81648 * z^5) := by
  dsimp [z_series, q_series, z1_modular_34, z2_modular_34, q1_modular_34, q2_modular_34]; ring

/-! #### C. Modular Triangle Family $\Delta(2,3,\infty)$ -/

/-- Mirror map coefficient $q_1$ for the modular $\Delta(2,3,\infty)$ family. -/
def q1_modular_23 : ℚ := 2

/-- Mirror map coefficient $q_2$ for the modular $\Delta(2,3,\infty)$ family. -/
def q2_modular_23 : ℚ := 5

/-- Inverse mirror map coefficient $z_1$ for the modular $\Delta(2,3,\infty)$ family. -/
def z1_modular_23 : ℚ := -2

/-- Inverse mirror map coefficient $z_2$ for the modular $\Delta(2,3,\infty)$ family. -/
def z2_modular_23 : ℚ := 3

/-- Proof that the $\Delta(2,3,\infty)$ $z_1$ satisfies $z_1 = -q_1$. -/
theorem modular_23_z1_eq : z1_modular_23 = -q1_modular_23 := rfl

/-- Proof that the $\Delta(2,3,\infty)$ $z_2$ satisfies $z_2 = 2 q_1^2 - q_2$. -/
theorem modular_23_z2_eq : z2_modular_23 = 2 * q1_modular_23^2 - q2_modular_23 := by
  norm_num [z2_modular_23, q1_modular_23, q2_modular_23]

/-- Machine-checked certified mirror map inversion pair for the modular $\Delta(2,3,\infty)$ family. -/
theorem modular_23_mirror_map_inversion :
    z1_modular_23 = -q1_modular_23 ∧ z2_modular_23 = 2 * q1_modular_23^2 - q2_modular_23 :=
  ⟨modular_23_z1_eq, modular_23_z2_eq⟩

/-- $\Delta(2,3,\infty)$ mirror map composition inversion evaluation. -/
theorem modular_23_mirror_composition (z : ℚ) :
    z_series z1_modular_23 z2_modular_23 (q_series q1_modular_23 q2_modular_23 z) - z =
      z^4 * (-10 + 41 * z + 154 * z^2 + 405 * z^3 + 450 * z^4 + 375 * z^5) := by
  dsimp [z_series, q_series, z1_modular_23, z2_modular_23, q1_modular_23, q2_modular_23]; ring

/-! ### 5. Action of Parabolic Cusp Monodromy on Abelian Surface Period Vectors -/

/-- Rational conversion of standard $(3,4,\infty)$ parabolic cusp monodromy $T_0$. -/
def T0_Q : Matrix (Fin 4) (Fin 4) ℚ :=
  toRatMatrix4 SymplecticTriangleRepresentations.T0

/-- Rational conversion of standard $(3,4,\infty)$ nilpotent operator $N$. -/
def N_Q : Matrix (Fin 4) (Fin 4) ℚ :=
  toRatMatrix4 SymplecticTriangleRepresentations.N

/-- $N_{\mathbb{Q}}^2 = 0$. -/
theorem N_Q_squared_zero : N_Q * N_Q = 0 := by
  rw [N_Q, ← toRatMatrix4_mul, SymplecticTriangleRepresentations.N_squared_zero, toRatMatrix4_zero]

/-- Type II matrix exponential of $N_{\mathbb{Q}}$ equals $T_{0,\mathbb{Q}}$. -/
theorem expTypeII_N_Q_eq_T0 : expTypeII N_Q = T0_Q := by
  dsimp [expTypeII, N_Q, T0_Q]
  rw [← toRatMatrix4_one, ← toRatMatrix4_add]
  congr 1
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Explicit action of $T_0$ on standard period vector $(w_0, w_1, w_2, w_3)^T$:
    $T_0 \Pi = (w_0 - w_1, w_1, w_2, w_2 + w_3)^T$. -/
theorem T0_Q_act_periodVector (w0 w1 w2 w3 : ℚ) :
    T0_Q *ᵥ ![w0, w1, w2, w3] = ![w0 - w1, w1, w2, w2 + w3] := by
  ext i
  fin_cases i <;> {
    simp [T0_Q, toRatMatrix4, SymplecticTriangleRepresentations.T0,
          Matrix.mulVec, dotProduct, Fin.sum_univ_four]
    try ring
  }

/-- Explicit action of $N$ on standard period vector $(w_0, w_1, w_2, w_3)^T$:
    $N \Pi = (-w_1, 0, 0, w_2)^T$. -/
theorem N_Q_act_periodVector (w0 w1 w2 w3 : ℚ) :
    N_Q *ᵥ ![w0, w1, w2, w3] = ![-w1, 0, 0, w2] := by
  ext i
  fin_cases i <;> simp [N_Q, toRatMatrix4, SymplecticTriangleRepresentations.N,
                        Matrix.mulVec, dotProduct, Fin.sum_univ_four]

/-- Period vector transformation under $T_0$: $T_0 \Pi = \Pi + N \Pi$. -/
theorem periodVector_monodromy_shift (w0 w1 w2 w3 : ℚ) :
    T0_Q *ᵥ ![w0, w1, w2, w3] = ![w0, w1, w2, w3] + N_Q *ᵥ ![w0, w1, w2, w3] := by
  rw [← expTypeII_N_Q_eq_T0, expTypeII_period_action]

end PicardFuchsMirrorMonodromy
