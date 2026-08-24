/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.TriangleModularGroup
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases

open scoped Matrix

/-!
# Symplectic Triangle Representations in $\mathrm{Sp}_4(\mathbb{Z})$ & Nilpotent Cusp Monodromy

This file establishes the formal symplectic geometry and monodromy weight filtration
for hyperbolic triangle modular groups acting on $V \cong \mathbb{Z}^4$:

1. **Standard Symplectic Form $J$**:
   The canonical non-degenerate skew-symmetric matrix $J \in \mathrm{Mat}_4(\mathbb{Z})$:
   $$J = \begin{pmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ -1 & 0 & 0 & 0 \\ 0 & -1 & 0 & 0 \end{pmatrix} = \begin{pmatrix} 0 & I_2 \\ -I_2 & 0 \end{pmatrix}$$
   satisfies $J^T = -J$ and $J^2 = -I_4$.

2. **Symplectic Group Predicate $\mathrm{Sp}_4(\mathbb{Z})$**:
   `IsSymplectic M := Mᵀ * J * M = J`.

3. **Symplectic $(3,4,\infty)$ Representation**:
   Explicit integer matrices $T_1, T_2, T_0 \in \mathrm{GL}_4(\mathbb{Z})$ with:
   $T_1^3 = I_4$, $T_2^4 = I_4$, $(T_1 T_2) T_0 = I_4$, and $T_1, T_2, T_0 \in \mathrm{Sp}_4(\mathbb{Z})$.

4. **Symplectic $(2,3,\infty)$ Modular Family**:
   Explicit integer matrices $S_1, S_2, S_0 \in \mathrm{GL}_4(\mathbb{Z})$ with:
   $S_1^2 = I_4$, $S_2^3 = I_4$, $(S_1 S_2) S_0 = I_4$, and $S_1, S_2, S_0 \in \mathrm{Sp}_4(\mathbb{Z})$.

5. **Classification of Unipotent Cusp Monodromies**:
   - Type I (Smooth): $N = 0$.
   - Type II (Toric / 1D Degeneration): $N \ne 0, N^2 = 0$.
   - Type III (Maximally Unipotent): $N^2 \ne 0, N^4 = 0$.
   - Machine-checked proof that the cusp monodromy $N = T_0 - I_4$ is strictly Type II.

6. **Monodromy Weight Filtration**:
   Weight filtration $W_0 \subset W_1 \subset W_2 \subset \mathbb{Z}^4$ where
   $W_0 = \ker N \cap \operatorname{im} N^2 = \{0\}$,
   $W_1 = \ker N^2 \cap \operatorname{im} N = \operatorname{im} N \subset \ker N$,
   $W_2 = \ker N^3 \cap \operatorname{im} I = \mathbb{Z}^4$.

7. **Polarized $(3,4,\infty)$ Symplectic Form $\Omega_6$**:
   Invariance verification for the geometric Seifert $S_6$-family from `TriangleModularGroup`.
-/

namespace SymplecticTriangleRepresentations

open Matrix

/-! ### 1. The Standard Symplectic Form $J$ -/

/-- The standard non-degenerate skew-symmetric symplectic form $J \in \mathrm{Mat}_4(\mathbb{Z})$. -/
def J : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0,  0,  1,  0],
    ![ 0,  0,  0,  1],
    ![-1,  0,  0,  0],
    ![ 0, -1,  0,  0]]

/-- $J$ is skew-symmetric: $J^T = -J$. -/
theorem J_transpose : Jᵀ = -J := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $J$ squares to $-I_4$: $J^2 = -I_4$. -/
theorem J_squared : J * J = -1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $J$ has inverse $-J$: $J * (-J) = I_4$. -/
theorem J_mul_neg_J : J * (-J) = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Symplectic group predicate on $\mathrm{Mat}_4(\mathbb{Z})$: $M^T J M = J$. -/
def IsSymplectic (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * J * M = J

/-- The identity matrix is symplectic. -/
theorem isSymplectic_one : IsSymplectic 1 := by
  simp [IsSymplectic]

/-- Product of symplectic matrices is symplectic. -/
theorem isSymplectic_mul (A B : Matrix (Fin 4) (Fin 4) ℤ)
    (hA : IsSymplectic A) (hB : IsSymplectic B) :
    IsSymplectic (A * B) := by
  dsimp [IsSymplectic] at *
  calc (A * B)ᵀ * J * (A * B)
    _ = Bᵀ * (Aᵀ * J * A) * B := by simp only [transpose_mul, mul_assoc]
    _ = J := by rw [hA, hB]

/-! ### 2. The $(3,4,\infty)$ Symplectic Representation -/

/-- Order 3 generator $T_1$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
def T1 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ -1,  1,  0,  0],
    ![ -1,  0,  0,  0],
    ![  0,  0,  0,  1],
    ![  0,  0, -1, -1]]

/-- Order 4 generator $T_2$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
def T2 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0, -1,  0,  0],
    ![  1,  0,  0,  0],
    ![  0,  0,  0, -1],
    ![  0,  0,  1,  0]]

/-- Parabolic cusp monodromy $T_0 = (T_1 T_2)^{-1}$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
def T0 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  1, -1,  0,  0],
    ![  0,  1,  0,  0],
    ![  0,  0,  1,  0],
    ![  0,  0,  1,  1]]

/-- Nilpotent cusp monodromy operator $N := T_0 - I_4$. -/
def N : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0, -1,  0,  0],
    ![  0,  0,  0,  0],
    ![  0,  0,  0,  0],
    ![  0,  0,  1,  0]]

/-- $T_1$ has order 3: $T_1^3 = I_4$. -/
theorem T1_order_three : T1 * T1 * T1 = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_2$ has order 4: $T_2^4 = I_4$. -/
theorem T2_order_four : T2 * T2 * T2 * T2 = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_0$ is the exact inverse of $T_1 T_2$: $(T_1 T_2) T_0 = I_4$. -/
theorem T0_is_inverse : (T1 * T2) * T0 = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_1$ is symplectic: $T_1^T J T_1 = J$. -/
theorem isSymplectic_T1 : IsSymplectic T1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_2$ is symplectic: $T_2^T J T_2 = J$. -/
theorem isSymplectic_T2 : IsSymplectic T2 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_0$ is symplectic: $T_0^T J T_0 = J$. -/
theorem isSymplectic_T0 : IsSymplectic T0 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The composite group element $T_1 T_2$ is symplectic. -/
theorem isSymplectic_T1_mul_T2 : IsSymplectic (T1 * T2) :=
  isSymplectic_mul T1 T2 isSymplectic_T1 isSymplectic_T2

/-- Definition of $N = T_0 - 1$. -/
theorem N_def : N = T0 - 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Nilpotence: $N^2 = 0$. -/
theorem N_squared_zero : N * N = 0 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Non-triviality: $N \ne 0$. -/
theorem N_nonzero : N ≠ 0 :=
  fun h => by injection congr_fun (congr_fun h 0) 1

/-! ### 3. The $(2,3,\infty)$ Modular Family in $\mathrm{Sp}_4(\mathbb{Z})$ -/

/-- Order 2 generator $S_1$ for the $(2,3,\infty)$ family. -/
def S1 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  1,  0,  0,  0],
    ![  0, -1,  0,  0],
    ![  0,  0,  1,  0],
    ![  0,  0,  0, -1]]

/-- Order 3 generator $S_2$ for the $(2,3,\infty)$ family. -/
def S2 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ -1,  1,  0,  0],
    ![ -1,  0,  0,  0],
    ![  0,  0,  0,  1],
    ![  0,  0, -1, -1]]

/-- Parabolic cusp monodromy $S_0 = (S_1 S_2)^{-1}$ for $(2,3,\infty)$. -/
def S0 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![  0,  1,  0,  0],
    ![  1,  1,  0,  0],
    ![  0,  0, -1,  1],
    ![  0,  0,  1,  0]]

/-- $S_1$ has order 2: $S_1^2 = I_4$. -/
theorem S1_order_two : S1 * S1 = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $S_2$ has order 3: $S_2^3 = I_4$. -/
theorem S2_order_three : S2 * S2 * S2 = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $S_0$ is the exact inverse of $S_1 S_2$: $(S_1 S_2) S_0 = I_4$. -/
theorem S0_is_inverse : (S1 * S2) * S0 = 1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $S_1$ is symplectic: $S_1^T J S_1 = J$. -/
theorem isSymplectic_S1 : IsSymplectic S1 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $S_2$ is symplectic: $S_2^T J S_2 = J$. -/
theorem isSymplectic_S2 : IsSymplectic S2 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $S_0$ is symplectic: $S_0^T J S_0 = J$. -/
theorem isSymplectic_S0 : IsSymplectic S0 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-! ### 4. Classification of Unipotent Cusp Monodromy -/

/-- Type I monodromy (Smooth fiber / trivial cusp action): $M = 0$. -/
def IsTypeI (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M = 0

/-- Type II monodromy (Toric / 1D nodal degeneration): $M \ne 0$ and $M^2 = 0$. -/
def IsTypeII (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M ≠ 0 ∧ M * M = 0

/-- Type III monodromy (Maximally unipotent degeneration): $M^2 \ne 0$ and $M^4 = 0$. -/
def IsTypeIII (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M * M ≠ 0 ∧ M * M * M * M = 0

/-- Mutual exclusion: Type II monodromy is not Type I. -/
theorem typeII_not_typeI (M : Matrix (Fin 4) (Fin 4) ℤ) (h : IsTypeII M) : ¬ IsTypeI M :=
  h.1

/-- Mutual exclusion: Type II monodromy is not Type III. -/
theorem typeII_not_typeIII (M : Matrix (Fin 4) (Fin 4) ℤ) (h : IsTypeII M) : ¬ IsTypeIII M :=
  fun h3 => h3.1 h.2

/-- Mutual exclusion: Type I monodromy is not Type II. -/
theorem typeI_not_typeII (M : Matrix (Fin 4) (Fin 4) ℤ) (h : IsTypeI M) : ¬ IsTypeII M :=
  fun h2 => h2.1 h

/-- The $(3,4,\infty)$ cusp monodromy $N$ is strictly Type II. -/
theorem monodromy_34_is_typeII : IsTypeII N :=
  ⟨N_nonzero, N_squared_zero⟩

/-- The $(3,4,\infty)$ cusp monodromy $N$ is not Type I. -/
theorem monodromy_34_not_typeI : ¬ IsTypeI N :=
  typeII_not_typeI N monodromy_34_is_typeII

/-- The $(3,4,\infty)$ cusp monodromy $N$ is not Type III. -/
theorem monodromy_34_not_typeIII : ¬ IsTypeIII N :=
  typeII_not_typeIII N monodromy_34_is_typeII

/-! ### 5. Monodromy Weight Filtration -/

/-- Kernel of matrix-vector multiplication as a set in $\mathbb{Z}^4$. -/
def kerMat (M : Matrix (Fin 4) (Fin 4) ℤ) : Set (Fin 4 → ℤ) :=
  {v | M *ᵥ v = 0}

/-- Image of matrix-vector multiplication as a set in $\mathbb{Z}^4$. -/
def imMat (M : Matrix (Fin 4) (Fin 4) ℤ) : Set (Fin 4 → ℤ) :=
  {v | ∃ u, M *ᵥ u = v}

/-- Weight space $W_0 := \ker(N) \cap \operatorname{im}(N^2)$. -/
def W0 : Set (Fin 4 → ℤ) :=
  kerMat N ∩ imMat (N * N)

/-- Weight space $W_1 := \ker(N^2) \cap \operatorname{im}(N)$. -/
def W1 : Set (Fin 4 → ℤ) :=
  kerMat (N * N) ∩ imMat N

/-- Weight space $W_2 := \mathbb{Z}^4$. -/
def W2 : Set (Fin 4 → ℤ) :=
  Set.univ

/-- Because $N^2 = 0$, the image of $N^2$ is trivial $\{0\}$. -/
theorem im_N_squared_zero : imMat (N * N) = {0} := by
  simp [imMat, N_squared_zero]

/-- $W_0 = \{0\}$ is the trivial subspace. -/
theorem W0_eq_zero : W0 = {0} := by
  simp [W0, kerMat, im_N_squared_zero]

/-- Since $N^2 = 0$, every vector is in the kernel of $N^2$: $\ker(N^2) = \mathbb{Z}^4$. -/
theorem ker_N_squared_univ : kerMat (N * N) = Set.univ := by
  simp [kerMat, N_squared_zero]

/-- $W_1$ coincides with $\operatorname{im}(N)$. -/
theorem W1_eq_im_N : W1 = imMat N := by
  simp [W1, ker_N_squared_univ]

/-- The image of $N$ is contained in the kernel of $N$: $\operatorname{im}(N) \subseteq \ker(N)$. -/
theorem im_N_subset_ker_N : imMat N ⊆ kerMat N := by
  rintro _ ⟨u, rfl⟩
  simp [kerMat, mulVec_mulVec, N_squared_zero]

/-- $W_1$ is contained in the kernel of $N$. -/
theorem W1_subset_ker_N : W1 ⊆ kerMat N :=
  W1_eq_im_N.symm ▸ im_N_subset_ker_N

/-- Filtration step $W_0 \subseteq W_1$. -/
theorem W0_subset_W1 : W0 ⊆ W1 := by
  rw [W0_eq_zero, W1_eq_im_N]
  rintro _ rfl
  exact ⟨0, mulVec_zero N⟩

/-- Filtration step $W_1 \subseteq W_2$. -/
theorem W1_subset_W2 : W1 ⊆ W2 :=
  Set.subset_univ _

/-- Complete weight filtration chain $W_0 \subseteq W_1 \subseteq W_2$. -/
theorem weight_filtration_chain : W0 ⊆ W1 ∧ W1 ⊆ W2 :=
  ⟨W0_subset_W1, W1_subset_W2⟩

/-! ### 6. Polarized Symplectic Geometry for the $S_6$ Family -/

/-- The polarized skew-symmetric matrix $\Omega_6$ preserving the $S_6$ Seifert family. -/
def Omega6 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0,  0,  0,  1],
    ![ 0,  0,  6,  0],
    ![ 0, -6,  0,  0],
    ![-1,  0,  0,  0]]

/-- Skew-symmetry of $\Omega_6$: $\Omega_6^T = -\Omega_6$. -/
theorem Omega6_transpose : Omega6ᵀ = -Omega6 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Invariance of $\Omega_6$ under $T_1$ from `ModularFamilyS6`: $T_1^T \Omega_6 T_1 = \Omega_6$. -/
theorem isSymplectic_Omega6_T1 :
    ModularFamilyS6.T1ᵀ * Omega6 * ModularFamilyS6.T1 = Omega6 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Invariance of $\Omega_6$ under $T_2$ from `ModularFamilyS6`: $T_2^T \Omega_6 T_2 = \Omega_6$. -/
theorem isSymplectic_Omega6_T2 :
    ModularFamilyS6.T2ᵀ * Omega6 * ModularFamilyS6.T2 = Omega6 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Invariance of $\Omega_6$ under $T_0$ from `ModularFamilyS6`: $T_0^T \Omega_6 T_0 = \Omega_6$. -/
theorem isSymplectic_Omega6_T0 :
    ModularFamilyS6.T0ᵀ * Omega6 * ModularFamilyS6.T0 = Omega6 := by ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The $S_6$ modular family also exhibits strictly Type II cusp monodromy. -/
theorem ModularFamilyS6_is_typeII : IsTypeII ModularFamilyS6.N :=
  ⟨fun h => (by decide : ModularFamilyS6.N 0 3 ≠ 0) (congr_fun (congr_fun h 0) 3),
   ModularFamilyS6.N_squared_zero⟩

end SymplecticTriangleRepresentations

