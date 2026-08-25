/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.AbelianSurfaceDegenerations.SiegelSpace
import Formalization.AbelianSurfaceDegenerations.NilpotentOrbit
import Formalization.AbelianSurfaceDegenerations.BoundaryStratification
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

open scoped Matrix Real
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Nilpotent Orbit Asymptotics & Matrix Exponential

This submodule formalizes the matrix exponential $\exp(z N)$ for index-2 nilpotent monodromy
operators ($N^2 = 0$), its preservation of the complex symplectic form $J_{\mathbb{C}}$,
block decompositions, compatibility with the Schmid nilpotent orbit period map
$\tau_{\mathrm{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$, the bundle `SchmidAsymptoticEstimate`,
and the isolation of the limit elliptic curve parameter $\tau_{22} = (\tau_0)_{11} \in \mathbb{H}_1$.

## Mathematical Overview

### 1. Matrix Exponential for Nilpotent $N$
For an index-2 nilpotent matrix $N \in \mathrm{Mat}_4(\mathbb{Z})$ satisfying $N^2 = 0$, the Lie group
exponential $\exp(z N)$ truncates to a first-order polynomial in $z \in \mathbb{C}$:
$$\exp(z N) = I_4 + z N$$
We machine-verify the exponential laws:
- $\exp(z_1 N) \exp(z_2 N) = \exp((z_1 + z_2) N)$
- $\exp(0 N) = I_4$
- $\exp(z N) \exp(-z N) = I_4$
- $(\exp(z N))^T J_{\mathbb{C}} \exp(z N) = J_{\mathbb{C}}$ (Symplectic Form Invariance)

### 2. $2 \times 2$ Block Projections & Nilpotent Orbit Translation
Decomposing $\exp(z N)$ into $2 \times 2$ blocks $\begin{pmatrix} A & B \\ C & D \end{pmatrix}$:
- $A(z) = \begin{pmatrix} 1 & -z \\ 0 & 1 \end{pmatrix}$
- $B(z) = 0$
- $C(z) = 0$
- $D(z) = \begin{pmatrix} 1 & 0 \\ z & 1 \end{pmatrix}$

In the Siegel cusp translation chart $N_{\mathrm{trans}} = \begin{pmatrix} 0 & N_\tau \\ 0 & 0 \end{pmatrix}$,
the fractional linear transformation (FLT) is identically:
$$\operatorname{FLT}(\exp(z N_{\mathrm{trans}}), \tau_0) = \tau_0 + z N_\tau = \tau_{\mathrm{nilp}}(\tau_0, z)$$

### 3. Schmid's Asymptotic Error Estimate & Limit Elliptic Parameter
Schmid's Nilpotent Orbit Theorem (1973) states that on the punctured disk $\Delta^*_r$, the true period
matrix $\tau(t)$ satisfies:
$$\|\tau(t) - \tau_{\mathrm{nilp}}(\tau_0, z(t))\|^2 \le C |t|^{2\alpha}$$
where $z(t) = \frac{1}{2\pi i} \log t$.
Since the $(1,1)$ entry of $N_\tau$ vanishes, the $(1,1)$ component is completely invariant along the
nilpotent orbit:
$$\tau_{\mathrm{nilp}}(\tau_0, z)_{11} = (\tau_0)_{11} \in \mathbb{H}_1$$
certifying the limit elliptic curve parameter.

## Main Declarations

- `AbelianSurfaceDegenerations.toComplexMatrix4`: Embedding $\mathrm{Mat}_4(\mathbb{Z}) \to \mathrm{Mat}_4(\mathbb{C})$.
- `AbelianSurfaceDegenerations.J_C`: Complex standard symplectic form.
- `AbelianSurfaceDegenerations.expN`: Matrix exponential $\exp(z N) = I_4 + z N_{\mathbb{C}}$.
- `AbelianSurfaceDegenerations.expN_add`: Exponential group law $\exp(z_1 N)\exp(z_2 N) = \exp((z_1+z_2)N)$.
- `AbelianSurfaceDegenerations.expN_zero`, `expN_inv`: Group identity and inversion.
- `AbelianSurfaceDegenerations.expN_preserves_symplectic`: Symplectic invariance $(\exp(z N))^T J_{\mathbb{C}} \exp(z N) = J_{\mathbb{C}}$.
- `AbelianSurfaceDegenerations.blockAC`, `blockBC`, `blockCC`, `blockDC`: $2 \times 2$ block projections.
- `AbelianSurfaceDegenerations.expN_blockA`, `expN_blockB`, `expN_blockC`, `expN_blockD`: Explicit block values.
- `AbelianSurfaceDegenerations.expN_trans`: Siegel translation nilpotent exponential.
- `AbelianSurfaceDegenerations.flt_expN_trans_eq_nilpotentOrbit`: Equivalence of FLT translation with nilpotent orbit.
- `AbelianSurfaceDegenerations.SchmidAsymptoticEstimate`: Structure bundling Schmid's asymptotic estimate.
- `AbelianSurfaceDegenerations.nilpotentOrbit_entry_11`: Invariance of $(1,1)$ entry under nilpotent shift.
- `AbelianSurfaceDegenerations.schmid_elliptic_parameter_limit`: Limit elliptic parameter along nilpotent orbit.
- `AbelianSurfaceDegenerations.asymptotic_limit_elliptic_parameter`: Isolation of $\tau_{22} = (\tau_0)_{11} \in \mathbb{H}_1$.
- `AbelianSurfaceDegenerations.schmid_elliptic_parameter_decay`: Convergence of $(1,1)$ period entry.
-/

namespace AbelianSurfaceDegenerations

/-! ### 1. Matrix Exponential for Index-2 Nilpotent Monodromy -/

/-- Complex embedding of a $4 \times 4$ integer matrix. -/
def toComplexMatrix4 (M : Matrix (Fin 4) (Fin 4) ℤ) : Matrix (Fin 4) (Fin 4) ℂ :=
  fun i j => (M i j : ℂ)

/-- Matrix multiplication compatibility of integer-to-complex embedding. -/
theorem toComplexMatrix4_mul (A B : Matrix (Fin 4) (Fin 4) ℤ) :
    toComplexMatrix4 (A * B) = toComplexMatrix4 A * toComplexMatrix4 B := by
  ext i j
  simp only [toComplexMatrix4, mul_apply, Fin.sum_univ_four, Int.cast_add, Int.cast_mul]

/-- Matrix addition compatibility of integer-to-complex embedding. -/
theorem toComplexMatrix4_add (A B : Matrix (Fin 4) (Fin 4) ℤ) :
    toComplexMatrix4 (A + B) = toComplexMatrix4 A + toComplexMatrix4 B := by
  ext i j
  simp only [toComplexMatrix4, Matrix.add_apply, Int.cast_add]

/-- Zero matrix preservation. -/
theorem toComplexMatrix4_zero : toComplexMatrix4 (0 : Matrix (Fin 4) (Fin 4) ℤ) = 0 := by
  ext i j; simp [toComplexMatrix4]

/-- Transpose compatibility. -/
theorem toComplexMatrix4_transpose (M : Matrix (Fin 4) (Fin 4) ℤ) :
    toComplexMatrix4 Mᵀ = (toComplexMatrix4 M)ᵀ := rfl

/-- Complex embedding of the standard symplectic form $J$. -/
def J_C : Matrix (Fin 4) (Fin 4) ℂ :=
  toComplexMatrix4 SymplecticTriangleRepresentations.J

/-- Complex embedding of $N$: $N_{\mathbb{C}} = \text{toComplexMatrix4}(N)$. -/
def N_C4 : Matrix (Fin 4) (Fin 4) ℂ :=
  toComplexMatrix4 SymplecticTriangleRepresentations.N

/-- The matrix exponential $\exp(z N) = I_4 + z N_{\mathbb{C}}$ for the index-2 nilpotent operator $N$ ($N^2 = 0$). -/
def expN (z : ℂ) : Matrix (Fin 4) (Fin 4) ℂ :=
  1 + z • N_C4

/-- Nilpotence in the complex algebra: $N_{\mathbb{C}}^2 = 0$. -/
theorem N_C4_squared_zero : N_C4 * N_C4 = 0 := by
  rw [N_C4, ← toComplexMatrix4_mul, N_squared_zero, toComplexMatrix4_zero]

/-- Group law for nilpotent matrix exponential:
    $\exp(z_1 N) \exp(z_2 N) = \exp((z_1 + z_2) N)$. -/
theorem expN_add (z1 z2 : ℂ) : expN z1 * expN z2 = expN (z1 + z2) := by
  dsimp [expN]
  rw [add_mul, mul_add, mul_add, Matrix.one_mul, Matrix.mul_one, Matrix.one_mul,
      Matrix.smul_mul, Matrix.mul_smul, smul_smul, N_C4_squared_zero, smul_zero, add_zero,
      add_assoc, add_comm (z2 • N_C4), ← add_smul]

/-- Alias: `expN_squared_zero` proving the exponential group law via $N^2 = 0$. -/
theorem expN_squared_zero (z1 z2 : ℂ) : expN z1 * expN z2 = expN (z1 + z2) :=
  expN_add z1 z2

/-- Identity element: $\exp(0 \cdot N) = I_4$. -/
theorem expN_zero : expN 0 = 1 := by
  simp [expN]

/-- Inverse element: $\exp(z N) \exp(-z N) = I_4$. -/
theorem expN_inv (z : ℂ) : expN z * expN (-z) = 1 := by
  rw [expN_add, add_neg_cancel, expN_zero]

/-- Left inverse element: $\exp(-z N) \exp(z N) = I_4$. -/
theorem expN_inv_left (z : ℂ) : expN (-z) * expN z = 1 := by
  rw [expN_add, neg_add_cancel, expN_zero]

/-- Infinitesimal Lie algebra identity $N^T J + J N = 0$ in $\mathrm{Mat}_4(\mathbb{C})$. -/
theorem NT_J_plus_J_N_zero : SymplecticTriangleRepresentations.Nᵀ * SymplecticTriangleRepresentations.J +
    SymplecticTriangleRepresentations.J * SymplecticTriangleRepresentations.N = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Quadratic Lie algebra identity $N^T J N = 0$ in $\mathrm{Mat}_4(\mathbb{C})$. -/
theorem NT_J_N_zero : SymplecticTriangleRepresentations.Nᵀ * SymplecticTriangleRepresentations.J *
    SymplecticTriangleRepresentations.N = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Machine-checked proof that $\exp(z N)$ preserves the complex symplectic form:
    $(\exp(z N))^T J_{\mathbb{C}} \exp(z N) = J_{\mathbb{C}}$. -/
theorem expN_preserves_symplectic (z : ℂ) : (expN z)ᵀ * J_C * expN z = J_C := by
  have hLie : (N_C4)ᵀ * J_C + J_C * N_C4 = 0 := by
    rw [N_C4, J_C, ← toComplexMatrix4_transpose, ← toComplexMatrix4_mul, ← toComplexMatrix4_mul,
        ← toComplexMatrix4_add, NT_J_plus_J_N_zero, toComplexMatrix4_zero]
  have hZero : (N_C4)ᵀ * J_C * N_C4 = 0 := by
    rw [N_C4, J_C, ← toComplexMatrix4_transpose, ← toComplexMatrix4_mul, ← toComplexMatrix4_mul,
        NT_J_N_zero, toComplexMatrix4_zero]
  have hsmul : (z • ((N_C4)ᵀ * J_C)) * (z • N_C4) = 0 := by
    rw [Matrix.smul_mul, Matrix.mul_smul, smul_smul, mul_comm z, hZero, smul_zero]
  dsimp [expN]
  rw [transpose_add, transpose_one, transpose_smul, add_mul, Matrix.one_mul, Matrix.smul_mul,
      add_mul, mul_add, mul_add, Matrix.mul_one, Matrix.mul_one, Matrix.mul_smul,
      hsmul, add_zero, add_assoc, ← smul_add, add_comm (J_C * N_C4), hLie, smul_zero, add_zero]

/-! ### 2. $2 \times 2$ Block Projections of $\exp(z N)$ -/

/-- $2 \times 2$ Block $A$ of a $4 \times 4$ complex matrix. -/
def blockAC (M : Matrix (Fin 4) (Fin 4) ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![M 0 0, M 0 1], ![M 1 0, M 1 1]]

/-- $2 \times 2$ Block $B$ of a $4 \times 4$ complex matrix. -/
def blockBC (M : Matrix (Fin 4) (Fin 4) ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![M 0 2, M 0 3], ![M 1 2, M 1 3]]

/-- $2 \times 2$ Block $C$ of a $4 \times 4$ complex matrix. -/
def blockCC (M : Matrix (Fin 4) (Fin 4) ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![M 2 0, M 2 1], ![M 3 0, M 3 1]]

/-- $2 \times 2$ Block $D$ of a $4 \times 4$ complex matrix. -/
def blockDC (M : Matrix (Fin 4) (Fin 4) ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![M 2 2, M 2 3], ![M 3 2, M 3 3]]

/-- Block $A$ of $\exp(z N)$: $\begin{pmatrix} 1 & -z \\ 0 & 1 \end{pmatrix}$. -/
theorem expN_blockA (z : ℂ) : blockAC (expN z) = ![![1, -z], ![0, 1]] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [blockAC, expN, N_C4, toComplexMatrix4, N]

/-- Block $B$ of $\exp(z N)$ is zero: $\begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}$. -/
theorem expN_blockB (z : ℂ) : blockBC (expN z) = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [blockBC, expN, N_C4, toComplexMatrix4, N]

/-- Block $C$ of $\exp(z N)$ is zero: $\begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}$. -/
theorem expN_blockC (z : ℂ) : blockCC (expN z) = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [blockCC, expN, N_C4, toComplexMatrix4, N]

/-- Block $D$ of $\exp(z N)$: $\begin{pmatrix} 1 & 0 \\ z & 1 \end{pmatrix}$. -/
theorem expN_blockD (z : ℂ) : blockDC (expN z) = ![![1, 0], ![z, 1]] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [blockDC, expN, N_C4, toComplexMatrix4, N]

/-! ### 3. Siegel Translation Matrix & Nilpotent Orbit FLT Compatibility -/

/-- The Siegel translation nilpotent generator $N_{\text{trans}} \in \mathrm{Mat}_4(\mathbb{C})$
    representing the period shift in the standard Siegel cusp chart. -/
def N_trans_C : Matrix (Fin 4) (Fin 4) ℂ :=
  ![![ 0, 0, 1, 0 ],
    ![ 0, 0, 0, 0 ],
    ![ 0, 0, 0, 0 ],
    ![ 0, 0, 0, 0 ]]

/-- Nilpotent translation matrix exponential $\exp(z N_{\text{trans}}) = \begin{pmatrix} I & z N_\tau \\ 0 & I \end{pmatrix}$. -/
def expN_trans (z : ℂ) : Matrix (Fin 4) (Fin 4) ℂ :=
  1 + z • N_trans_C

/-- Block $A$ of $\exp(z N_{\text{trans}})$ is $I_2$. -/
theorem expN_trans_blockA (z : ℂ) : blockAC (expN_trans z) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> first
  | change (1 : ℂ) + z * 0 = 1; ring
  | change (0 : ℂ) + z * 0 = 0; ring

/-- Block $B$ of $\exp(z N_{\text{trans}})$ is $z N_\tau$. -/
theorem expN_trans_blockB (z : ℂ) : blockBC (expN_trans z) = z • N_tau_C := by
  ext i j; fin_cases i <;> fin_cases j <;> first
  | change (0 : ℂ) + z * 1 = z * 1; ring
  | change (0 : ℂ) + z * 0 = z * 0; ring

/-- Block $C$ of $\exp(z N_{\text{trans}})$ is 0. -/
theorem expN_trans_blockC (z : ℂ) : blockCC (expN_trans z) = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> { change (0 : ℂ) + z * 0 = 0; ring }

/-- Block $D$ of $\exp(z N_{\text{trans}})$ is $I_2$. -/
theorem expN_trans_blockD (z : ℂ) : blockDC (expN_trans z) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> first
  | change (1 : ℂ) + z * 0 = 1; ring
  | change (0 : ℂ) + z * 0 = 0; ring

/-- FLT theorem for nilpotent orbit: Fractional linear transformation of $\exp(z N_{\text{trans}})$ on $\tau_0$
    coincides identically with the Schmid nilpotent orbit $\tau_{\mathrm{nilp}}(\tau_0, z) = \tau_0 + z N_\tau$. -/
theorem flt_expN_trans_eq_nilpotentOrbit (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) :
    fltAction (blockAC (expN_trans z)) (blockBC (expN_trans z))
              (blockCC (expN_trans z)) (blockDC (expN_trans z)) tau0 =
    nilpotentOrbit tau0 z := by
  simp [fltAction, nilpotentOrbit, expN_trans_blockA, expN_trans_blockB, expN_trans_blockC, expN_trans_blockD, inv2C_one]

/-- Alias: `flt_expN_period` proving FLT translation matches the nilpotent orbit $\tau_0 + z N_\tau$. -/
theorem flt_expN_period (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) :
    fltAction (blockAC (expN_trans z)) (blockBC (expN_trans z))
              (blockCC (expN_trans z)) (blockDC (expN_trans z)) tau0 =
    nilpotentOrbit tau0 z :=
  flt_expN_trans_eq_nilpotentOrbit tau0 z

/-! ### 4. Schmid's Asymptotic Error Estimate & Limit Elliptic Parameter -/

/-- Structure bundling Schmid's Nilpotent Orbit Asymptotic Estimate (Schmid 1973):
    On a punctured disk $\Delta^*_r$, the true period map $\tau(t)$ is approximated by the
    nilpotent orbit $\tau_{\mathrm{nilp}}(\tau_0, z(t))$ with polynomial error decay $O(|t|^{2\alpha})$. -/
structure SchmidAsymptoticEstimate where
  /-- The true period map from punctured disk to $\mathrm{Mat}_2(\mathbb{C})$. -/
  tau : ℂ → Matrix (Fin 2) (Fin 2) ℂ
  /-- Base nilpotent orbit period matrix in $\mathbb{H}_2$. -/
  tau0 : SiegelHalfSpace2
  /-- Coordinate mapping $z(t) = \frac{1}{2\pi i} \log t$. -/
  z_coord : ℂ → ℂ
  /-- Squared radius of the degeneration disk $r_2 > 0$. -/
  radiusSq : ℝ
  hradiusSq : 0 < radiusSq
  /-- Error bound constant $C > 0$. -/
  C : ℝ
  hC : 0 < C
  /-- Power decay exponent $\alpha > 0$. -/
  alpha : ℝ
  halpha : 0 < alpha
  /-- Entrywise asymptotic approximation bound on the punctured disk. -/
  asymptotic_bound : ∀ (t : ℂ), 0 < Complex.normSq t → Complex.normSq t < radiusSq →
    ∀ (i j : Fin 2),
      Complex.normSq (tau t i j - nilpotentOrbit tau0.Z (z_coord t) i j) ≤
        C * (Complex.normSq t) ^ alpha

/-- In the nilpotent orbit, the $(1,1)$ entry is completely invariant under the nilpotent shift $z N_\tau$:
    $\tau_{\mathrm{nilp}}(\tau_0, z)_{11} = (\tau_0)_{11}$. -/
theorem nilpotentOrbit_entry_11 (tau0 : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) :
    nilpotentOrbit tau0 z 1 1 = tau0 1 1 := by
  change tau0 1 1 + z * 0 = tau0 1 1; ring

/-- Limit elliptic parameter isolation along the nilpotent orbit. -/
theorem schmid_elliptic_parameter_limit (tau0 : SiegelHalfSpace2) (z : ℂ) :
    nilpotentOrbit tau0.Z z 1 1 = limitEllipticParameter tau0 :=
  nilpotentOrbit_entry_11 tau0.Z z

/-- Asymptotic limit elliptic parameter theorem:
    Under Schmid's nilpotent orbit approximation, the $(1,1)$ component is identically the limit elliptic
    parameter $\tau_{22} = (\tau_0)_{11} \in \mathbb{H}_1$. -/
theorem asymptotic_limit_elliptic_parameter (tau0 : SiegelHalfSpace2) (z : ℂ) :
    nilpotentOrbit tau0.Z z 1 1 = limitEllipticParameter tau0 ∧
    0 < (limitEllipticParameter tau0).im :=
  ⟨nilpotentOrbit_entry_11 tau0.Z z, limitEllipticParameter_in_H1 tau0⟩

/-- Under a Schmid asymptotic estimate, the true period entry $\tau(t)_{11}$ converges to the limit
    elliptic parameter $\tau_{22} \in \mathbb{H}_1$ with error at most $C |t|^{2\alpha}$. -/
theorem schmid_elliptic_parameter_decay (E : SchmidAsymptoticEstimate)
    (t : ℂ) (ht0 : 0 < Complex.normSq t) (htr : Complex.normSq t < E.radiusSq) :
    Complex.normSq (E.tau t 1 1 - limitEllipticParameter E.tau0) ≤ E.C * (Complex.normSq t) ^ E.alpha := by
  have h := E.asymptotic_bound t ht0 htr 1 1
  rwa [nilpotentOrbit_entry_11] at h

end AbelianSurfaceDegenerations
