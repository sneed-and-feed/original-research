/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SymplecticTriangleRepresentations.MonodromyClassification
import Formalization.TriangleModularGroup

open scoped Matrix

/-!
# Monodromy Weight Filtration & Polarized Symplectic Geometry

This submodule formalizes the Deligne–Schmid monodromy weight filtration
$W_0 \subseteq W_1 \subseteq W_2 = \mathbb{Z}^4$ associated with the nilpotent operator $N$
and establishes the polarized skew-symmetric form $\Omega_6$ preserving the geometric
$S_6$ Seifert family from `TriangleModularGroup`.

## Mathematical Overview

### 1. The Monodromy Weight Filtration
For a nilpotent operator $N$ of nilpotency index 2 ($N^2 = 0$) on $V \cong \mathbb{Z}^4$, the
canonical monodromy weight filtration $W_\bullet(N)$ centered at 0 is given by:
- $W_0 = \ker(N) \cap \operatorname{im}(N^2) = \{0\}$.
- $W_1 = \ker(N^2) \cap \operatorname{im}(N) = \operatorname{im}(N) \subseteq \ker(N)$.
- $W_2 = \ker(N^3) \cap \operatorname{im}(I) = \mathbb{Z}^4$.

We verify formally that $W_0 \subseteq W_1 \subseteq W_2$.

### 2. Polarized Symplectic Form $\Omega_6$
The geometric Seifert $S_6$-family from `ModularFamilyS6` preserves the polarized skew-symmetric
intersection matrix:
$$\Omega_6 = \begin{pmatrix} 0 & 0 & 0 & 1 \\ 0 & 0 & 6 & 0 \\ 0 & -6 & 0 & 0 \\ -1 & 0 & 0 & 0 \end{pmatrix}$$
satisfying $\Omega_6^T = -\Omega_6$ and the invariance identities:
$$T_1^T \Omega_6 T_1 = \Omega_6, \quad T_2^T \Omega_6 T_2 = \Omega_6, \quad T_0^T \Omega_6 T_0 = \Omega_6$$

Furthermore, the $S_6$ modular cusp monodromy operator `ModularFamilyS6.N` is certified to be strictly Type II.

## Main Declarations

- `SymplecticTriangleRepresentations.kerMat`: Kernel of matrix multiplication on $\mathbb{Z}^4$.
- `SymplecticTriangleRepresentations.imMat`: Image of matrix multiplication on $\mathbb{Z}^4$.
- `SymplecticTriangleRepresentations.W0`, `W1`, `W2`: Weight filtration subspaces.
- `SymplecticTriangleRepresentations.W0_eq_zero`: $W_0 = \{0\}$.
- `SymplecticTriangleRepresentations.W1_eq_im_N`: $W_1 = \operatorname{im}(N)$.
- `SymplecticTriangleRepresentations.W1_subset_ker_N`: $W_1 \subseteq \ker(N)$.
- `SymplecticTriangleRepresentations.W0_subset_W1`: $W_0 \subseteq W_1$.
- `SymplecticTriangleRepresentations.W1_subset_W2`: $W_1 \subseteq W_2$.
- `SymplecticTriangleRepresentations.weight_filtration_chain`: $W_0 \subseteq W_1 \wedge W_1 \subseteq W_2$.
- `SymplecticTriangleRepresentations.Omega6`: Polarized skew-symmetric matrix in $\mathrm{Mat}_4(\mathbb{Z})$.
- `SymplecticTriangleRepresentations.Omega6_transpose`, `Omega6_skew`: Skew-symmetry $\Omega_6^T = -\Omega_6$.
- `SymplecticTriangleRepresentations.isSymplectic_Omega6_T1`: Invariance under `ModularFamilyS6.T1`.
- `SymplecticTriangleRepresentations.isSymplectic_Omega6_T2`: Invariance under `ModularFamilyS6.T2`.
- `SymplecticTriangleRepresentations.isSymplectic_Omega6_T0`: Invariance under `ModularFamilyS6.T0`.
- `SymplecticTriangleRepresentations.ModularFamilyS6_is_typeII`: Proof that `ModularFamilyS6.N` is strictly Type II.
-/

namespace SymplecticTriangleRepresentations

open Matrix

/-! ### 1. Monodromy Weight Filtration Subspaces -/

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

/-! ### 2. Polarized Symplectic Geometry for the $S_6$ Family -/

/-- The polarized skew-symmetric matrix $\Omega_6$ preserving the $S_6$ Seifert family. -/
def Omega6 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0,  0,  0,  1],
    ![ 0,  0,  6,  0],
    ![ 0, -6,  0,  0],
    ![-1,  0,  0,  0]]

/-- Skew-symmetry of $\Omega_6$: $\Omega_6^T = -\Omega_6$. -/
theorem Omega6_transpose : Omega6ᵀ = -Omega6 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Skew-symmetry alias: $\Omega_6^T = -\Omega_6$. -/
theorem Omega6_skew : Omega6ᵀ = -Omega6 :=
  Omega6_transpose

/-- Invariance of $\Omega_6$ under $T_1$ from `ModularFamilyS6`: $T_1^T \Omega_6 T_1 = \Omega_6$. -/
theorem isSymplectic_Omega6_T1 :
    ModularFamilyS6.T1ᵀ * Omega6 * ModularFamilyS6.T1 = Omega6 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Invariance of $\Omega_6$ under $T_2$ from `ModularFamilyS6`: $T_2^T \Omega_6 T_2 = \Omega_6$. -/
theorem isSymplectic_Omega6_T2 :
    ModularFamilyS6.T2ᵀ * Omega6 * ModularFamilyS6.T2 = Omega6 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Invariance of $\Omega_6$ under $T_0$ from `ModularFamilyS6`: $T_0^T \Omega_6 T_0 = \Omega_6$. -/
theorem isSymplectic_Omega6_T0 :
    ModularFamilyS6.T0ᵀ * Omega6 * ModularFamilyS6.T0 = Omega6 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- The $S_6$ modular family also exhibits strictly Type II cusp monodromy. -/
theorem ModularFamilyS6_is_typeII : IsTypeII ModularFamilyS6.N :=
  ⟨fun h => (by decide : ModularFamilyS6.N 0 3 ≠ 0) (congr_fun (congr_fun h 0) 3),
   ModularFamilyS6.N_squared_zero⟩

end SymplecticTriangleRepresentations
