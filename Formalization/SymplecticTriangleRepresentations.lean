/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.SymplecticTriangleRepresentations.Basic
import Formalization.SymplecticTriangleRepresentations.Representations
import Formalization.SymplecticTriangleRepresentations.MonodromyClassification
import Formalization.SymplecticTriangleRepresentations.WeightFiltration

open scoped Matrix

/-!
# Symplectic Triangle Group Representations in $\mathrm{Sp}_4(\mathbb{Z})$ & Monodromy Weight Filtration

This root aggregator module formalizes the integral symplectic geometry, arithmetic triangle representations,
unipotent cusp monodromy classification, and Deligne–Schmid weight filtration for hyperbolic triangle
modular groups acting on the 4-dimensional homology lattice $V \cong \mathbb{Z}^4$ of degenerating
complex abelian surfaces.

## Mathematical Overview

### 1. The Standard Symplectic Form $J \in \mathrm{Mat}_4(\mathbb{Z})$

The canonical skew-symmetric, non-degenerate bilinear form on $V \cong \mathbb{Z}^4$ is given by
$$J = \begin{pmatrix} 0 & I_2 \\ -I_2 & 0 \end{pmatrix} = \begin{pmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ -1 & 0 & 0 & 0 \\ 0 & -1 & 0 & 0 \end{pmatrix}$$
satisfying the core algebraic identities:
- $J^T = -J$ (skew-symmetry)
- $J^2 = -I_4$ (almost complex structure)
- $J (-J) = I_4$ (invertibility with $J^{-1} = -J$)

An integral matrix $M \in \mathrm{Mat}_4(\mathbb{Z})$ belongs to $\mathrm{Sp}_4(\mathbb{Z})$ if and only if $M^T J M = J$.

### 2. Integral Symplectic Triangle Group Representations

For hyperbolic triangle groups $\Delta(p,q,\infty) = \langle \tau_1, \tau_2, \tau_0 \mid \tau_1^p = \tau_2^q = \tau_1 \tau_2 \tau_0 = 1 \rangle$:
1. **$(3,4,\infty)$ Representation**:
   - $T_1 \in \mathrm{Sp}_4(\mathbb{Z})$ of order 3 ($T_1^3 = I_4$).
   - $T_2 \in \mathrm{Sp}_4(\mathbb{Z})$ of order 4 ($T_2^4 = I_4$).
   - $T_0 = (T_1 T_2)^{-1} \in \mathrm{Sp}_4(\mathbb{Z})$ parabolic cusp monodromy.
   - Nilpotent operator $N := T_0 - I_4$ with $N^2 = 0$ and $N \ne 0$.
2. **$(2,3,\infty)$ Representation**:
   - $S_1 \in \mathrm{Sp}_4(\mathbb{Z})$ involution ($S_1^2 = I_4$).
   - $S_2 \in \mathrm{Sp}_4(\mathbb{Z})$ of order 3 ($S_2^3 = I_4$).
   - $S_0 = (S_1 S_2)^{-1} \in \mathrm{Sp}_4(\mathbb{Z})$.
   - Nilpotent operator $N_{23}$ with $N_{23}^2 = 0$ and $N_{23} \ne 0$.

### 3. Classification of Unipotent Cusp Monodromy

Monodromy operators $M$ are classified into:
- **Type I (Smooth Fiber)**: $M = 0$.
- **Type II (Toric / 1D Nodal Degeneration)**: $M \ne 0$ and $M^2 = 0$.
- **Type III (Maximally Unipotent Degeneration)**: $M^2 \ne 0$ and $M^4 = 0$.

We verify machine-checked proofs that the $(3,4,\infty)$ cusp monodromy $N$ and the geometric
$S_6$ Seifert monodromy `ModularFamilyS6.N` are strictly Type II (and provably neither Type I nor Type III).

### 4. Deligne–Schmid Monodromy Weight Filtration

The nilpotent operator $N$ induces a canonical 3-step weight filtration on $V \cong \mathbb{Z}^4$:
$$W_0 \subseteq W_1 \subseteq W_2 = \mathbb{Z}^4$$
defined by:
- $W_0 := \ker N \cap \operatorname{im} N^2 = \{0\}$.
- $W_1 := \ker N^2 \cap \operatorname{im} N = \operatorname{im} N \subseteq \ker N$.
- $W_2 := \mathbb{Z}^4$.

### 5. Polarized $(3,4,\infty)$ Symplectic Form $\Omega_6$

The geometric Seifert $S_6$-family from `TriangleModularGroup` preserves the polarized skew-symmetric matrix
$$\Omega_6 = \begin{pmatrix} 0 & 0 & 0 & 1 \\ 0 & 0 & 6 & 0 \\ 0 & -6 & 0 & 0 \\ -1 & 0 & 0 & 0 \end{pmatrix}, \quad \Omega_6^T = -\Omega_6$$
satisfying $T_i^T \Omega_6 T_i = \Omega_6$ for all generators $T_1, T_2, T_0$.

## Module Architecture & Index

This module is partitioned into 4 focused submodules:

1. **`Formalization.SymplecticTriangleRepresentations.Basic`**:
   - `J`: Canonical standard symplectic matrix in $\mathrm{Mat}_4(\mathbb{Z})$.
   - `J_transpose`: Proof that $J^T = -J$.
   - `J_squared`: Proof that $J^2 = -I_4$.
   - `J_mul_neg_J`: Proof that $J(-J) = I_4$.
   - `IsSymplectic`: Predicate $M^T J M = J$ defining $\mathrm{Sp}_4(\mathbb{Z})$.
   - `isSymplectic_one`: Symplectic property for identity matrix $I_4$.
   - `isSymplectic_mul`: Multiplicative closure of $\mathrm{Sp}_4(\mathbb{Z})$.

2. **`Formalization.SymplecticTriangleRepresentations.Representations`**:
   - `T1`, `T2`, `T0`, `N`: $(3,4,\infty)$ integral matrix generators and nilpotent operator.
   - `T1_order_three`: $T_1^3 = I_4$.
   - `T2_order_four`: $T_2^4 = I_4$.
   - `T0_is_inverse`: $(T_1 T_2) T_0 = I_4$.
   - `isSymplectic_T1`, `isSymplectic_T2`, `isSymplectic_T0`, `isSymplectic_T1_mul_T2`: Symplectic preservation.
   - `N_def`: Identity $N = T_0 - 1$.
   - `N_squared_zero`: Unipotence identity $N^2 = 0$.
   - `N_nonzero`: Non-triviality $N \ne 0$.
   - `S1`, `S2`, `S0`, `N23`: $(2,3,\infty)$ integral matrix family.
   - `S1_order_two`: $S_1^2 = I_4$.
   - `S2_order_three`: $S_2^3 = I_4$.
   - `S0_is_inverse`: $(S_1 S_2) S_0 = I_4$.
   - `isSymplectic_S1`, `isSymplectic_S2`, `isSymplectic_S0`: Symplectic preservation.
   - `N23_squared_zero`: $N_{23}^2 = 0$.
   - `N23_nonzero`: $N_{23} \ne 0$.

3. **`Formalization.SymplecticTriangleRepresentations.MonodromyClassification`**:
   - `IsTypeI`, `IsTypeII`, `IsTypeIII`: Degeneration type classification predicates.
   - `typeII_not_typeI`, `typeII_not_typeIII`, `typeI_not_typeII`: Mutual exclusion proofs.
   - `monodromy_34_is_typeII`: Formal proof that $(3,4,\infty)$ cusp monodromy $N$ is Type II.
   - `monodromy_34_not_typeI`, `monodromy_34_not_typeIII`: Non-Type I and non-Type III certifications.
   - `monodromy_23_is_typeII`: Formal proof that $(2,3,\infty)$ operator $N_{23}$ is Type II.
   - `monodromy_23_not_typeI`, `monodromy_23_not_typeIII`: Non-Type I and non-Type III certifications.

4. **`Formalization.SymplecticTriangleRepresentations.WeightFiltration`**:
   - `kerMat`, `imMat`: Matrix kernel and image sets in $\mathbb{Z}^4$.
   - `W0`, `W1`, `W2`: Monodromy weight filtration subspaces.
   - `W0_eq_zero`: Triviality $W_0 = \{0\}$.
   - `W1_eq_im_N`: Identification $W_1 = \operatorname{im}(N)$.
   - `W1_subset_ker_N`: Subspace inclusion $W_1 \subseteq \ker(N)$.
   - `weight_filtration_chain`: Complete filtration chain $W_0 \subseteq W_1 \subseteq W_2$.
   - `Omega6`: Polarized symplectic matrix for $S_6$ family.
   - `Omega6_transpose`, `Omega6_skew`: Skew-symmetry $\Omega_6^T = -\Omega_6$.
   - `isSymplectic_Omega6_T1`, `isSymplectic_Omega6_T2`, `isSymplectic_Omega6_T0`: Invariance under $S_6$ generators.
   - `ModularFamilyS6_is_typeII`: Type II classification for `ModularFamilyS6.N`.

## References

- Deligne, P. (1971). *Théorie de Hodge: II*. Publications Mathématiques de l'IHÉS, 40, 5–57.
- Kulikov, V. S. (1977). *Degenerations of K3 surfaces and Enriques surfaces*. Mathematics of the USSR-Izvestiya, 11(5), 957–996.
- Milnor, J. (1975). *On the 3-dimensional Brieskorn manifolds $M(p,q,r)$*. Annals of Mathematics Studies, 84, 175–225.
- Schmid, W. (1973). *Variation of Hodge structure: the singularities of the period mapping*. Inventiones Mathematicae, 22(3), 211–319.
- Seifert, H. (1933). *Topologie dreidimensionaler gefaserter Räume*. Acta Mathematica, 60(1), 147–238.
-/
