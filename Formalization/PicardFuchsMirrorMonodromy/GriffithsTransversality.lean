/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.PicardFuchsMirrorMonodromy.CuspMonodromy
import Formalization.PicardFuchsMirrorMonodromy.SymplecticInvariance
import Formalization.SymplecticTriangleRepresentations
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith

open scoped Matrix BigOperators
open Matrix SymplecticTriangleRepresentations

set_option linter.unusedSectionVars false

/-!
# Component 4: Higher-Dimensional Griffiths Transversality & PVHS Generalization

This module establishes the generalized theory of Polarized Variations of Hodge Structure (PVHS),
higher-dimensional integral symplectic forms $J_{2g}$ for $g \in \{1, 2, 3\}$, generalized
symplectic bilinear pairings on $\mathbb{Z}^n$, Griffiths transversality flags in dimension 4
($F^3 \subset F^2 \subset F^1 \subset F^0$), and machine-checked operator certificates
across dimensions 2, 4, and 6.

## Mathematical Overview

### 1. Dimension-Independent Symplectic Forms $J_{2g}$
For genus $g \in \{1, 2, 3\}$, the standard non-degenerate skew-symmetric block matrix
$$J_{2g} = \begin{pmatrix} 0 & I_g \\ -I_g & 0 \end{pmatrix} \in \mathrm{Mat}_{2g}(\mathbb{Z})$$
satisfies the canonical algebraic axioms:
- Skew-symmetry: $J_{2g}^T = -J_{2g}$.
- Complex structure / involution: $J_{2g}^2 = -I_{2g}$.

### 2. Generalized Symplectic Predicates & Invariant Bilinear Pairings
For arbitrary dimension $n$ and skew form $J \in \mathrm{Mat}_n(\mathbb{Z})$:
- **Infinitesimal Symplectic Lie Algebra**: $\mathfrak{sp}_J(\mathbb{Z}) := \{M \mid M^T J + J M = 0\}$.
- **Symplectic Group**: $\mathrm{Sp}_J(\mathbb{Z}) := \{T \mid T^T J T = J\}$.
- **Symplectic Bilinear Pairing**: $\langle v, w \rangle_J := v \cdot (J w)$.
- **Skew-symmetry & Diagonal Vanishing**: $J^T = -J \implies \langle v, w \rangle_J = -\langle w, v \rangle_J$ and $\langle v, v \rangle_J = 0$.
- **Infinitesimal Invariance**: $M \in \mathfrak{sp}_J \implies \langle M v, w \rangle_J + \langle v, M w \rangle_J = 0$.
- **Finite Invariance**: $T \in \mathrm{Sp}_J \implies \langle T v, T w \rangle_J = \langle v, w \rangle_J$.

### 3. Hodge Filtration Flags & Griffiths Transversality in Dimension 4
On $V \cong \mathbb{Z}^4$, the standard Hodge filtration flag is:
$$F^3 \subset F^2 \subset F^1 \subset F^0 = \mathbb{Z}^4$$
defined by coordinate vanishing:
- $v \in F^3 \iff v_1 = 0 \wedge v_2 = 0 \wedge v_3 = 0$.
- $v \in F^2 \iff v_2 = 0 \wedge v_3 = 0$.
- $v \in F^1 \iff v_3 = 0$.
- $v \in F^0 \iff \mathrm{True}$.

An operator $M$ satisfies **Griffiths Transversality** if $M(F^p) \subseteq F^{p-1}$ for all $p$:
$$(\forall v \in F^3, M v \in F^2) \wedge (\forall v \in F^2, M v \in F^1) \wedge (\forall v \in F^1, M v \in F^0)$$

Under the Hodge-Riemann bilinear relations:
- $F^3 \perp F^1$ under the polarized pairing $\Omega_6$: $\langle F^3, F^1 \rangle_{\Omega_6} = 0$.
- $F^2 \perp F^2$ (Lagrangian property) under both $J_4$ and $\Omega_6$: $\langle F^2, F^2 \rangle = 0$.

### 4. Machine-Checked Operator Certificates
- Griffiths transversality is formally certified for:
  1. $N_{\mathrm{MUM}}$ (Calabi-Yau 3-fold Maximally Unipotent Monodromy operator).
  2. $N$ (Abelian surface modular family $(3,4,\infty)$ nilpotent generator).
  3. $N_{S_6}$ (Polarized $S_6$ Seifert modular family nilpotent generator).
- Infinitesimal and finite symplectic invariance are verified for $(J_4, N, T_0)$ and $(\Omega_6, N_{S_6}, T_{0, S_6})$.
- Genus 1 ($2 \times 2$) parabolic unipotent generator $N_2 \in \mathfrak{sp}_2(\mathbb{Z})$ and $T_{0,2} \in \mathrm{Sp}_2(\mathbb{Z})$.
- Genus 3 ($6 \times 6$) parabolic unipotent generator $N_6 \in \mathfrak{sp}_6(\mathbb{Z})$ and $T_{0,6} \in \mathrm{Sp}_6(\mathbb{Z})$.

## Main Declarations

- `PicardFuchsMirrorMonodromy.J2`, `J4`, `J6`: Dimension-independent symplectic forms.
- `PicardFuchsMirrorMonodromy.IsInfinitesimalSymplecticGen`, `IsSymplecticGen`: Generalized symplectic predicates.
- `PicardFuchsMirrorMonodromy.symplecticPairingGen`: Generalized bilinear pairing $v \cdot (J w)$.
- `PicardFuchsMirrorMonodromy.symplecticPairingGen_skew`: Skew-symmetry.
- `PicardFuchsMirrorMonodromy.symplecticPairingGen_M_invariant`: Infinitesimal invariance.
- `PicardFuchsMirrorMonodromy.symplecticPairingGen_T_invariant`: Finite group invariance.
- `PicardFuchsMirrorMonodromy.InF3`, `InF2`, `InF1`, `InF0`: Hodge filtration subspaces.
- `PicardFuchsMirrorMonodromy.hodge_filtration_chain`: Inclusion chain $F^3 \subseteq F^2 \subseteq F^1 \subseteq F^0$.
- `PicardFuchsMirrorMonodromy.SatisfiesGriffithsTransversality`: Griffiths transversality predicate.
- `PicardFuchsMirrorMonodromy.hodge_riemann_orthogonality_F3_F1_Omega6`: $F^3 \perp F^1$.
- `PicardFuchsMirrorMonodromy.hodge_riemann_lagrangian_F2_Omega6`, `hodge_lagrangian_F2`: $F^2 \perp F^2$.
- `PicardFuchsMirrorMonodromy.N_MUM_satisfies_GriffithsTransversality`: Verification for $N_{\mathrm{MUM}}$.
- `PicardFuchsMirrorMonodromy.N_satisfies_GriffithsTransversality`: Verification for $N$.
- `PicardFuchsMirrorMonodromy.ModularFamilyS6_N_satisfies_GriffithsTransversality`: Verification for $N_{S_6}$.
- `PicardFuchsMirrorMonodromy.N2`, `T0_2`, `N6`, `T0_6`: Parabolic generators for $g=1$ and $g=3$.
-/

namespace PicardFuchsMirrorMonodromy

/-! ### 1. Dimension-Independent Symplectic Forms -/

/-- Standard symplectic form in dimension 2 ($g=1$): $J_2 \in \mathrm{Mat}_2(\mathbb{Z})$. -/
def J2 : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![ 0,  1],
    ![-1,  0]]

/-- $J_2$ is skew-symmetric: $J_2^T = -J_2$. -/
theorem J2_transpose : J2ᵀ = -J2 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $J_2^2 = -I_2$. -/
theorem J2_squared : J2 * J2 = -1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Standard symplectic form in dimension 4 ($g=2$): $J_4 \in \mathrm{Mat}_4(\mathbb{Z})$. -/
def J4 : Matrix (Fin 4) (Fin 4) ℤ :=
  ![![ 0,  0,  1,  0],
    ![ 0,  0,  0,  1],
    ![-1,  0,  0,  0],
    ![ 0, -1,  0,  0]]

/-- $J_4$ matches the canonical $J$ in $\mathrm{Sp}_4(\mathbb{Z})$. -/
theorem J4_eq_J : J4 = J := rfl

/-- $J_4$ is skew-symmetric: $J_4^T = -J_4$. -/
theorem J4_transpose : J4ᵀ = -J4 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $J_4^2 = -I_4$. -/
theorem J4_squared : J4 * J4 = -1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Standard symplectic form in dimension 6 ($g=3$): $J_6 \in \mathrm{Mat}_6(\mathbb{Z})$. -/
def J6 : Matrix (Fin 6) (Fin 6) ℤ :=
  ![![ 0,  0,  0,  1,  0,  0],
    ![ 0,  0,  0,  0,  1,  0],
    ![ 0,  0,  0,  0,  0,  1],
    ![-1,  0,  0,  0,  0,  0],
    ![ 0, -1,  0,  0,  0,  0],
    ![ 0,  0, -1,  0,  0,  0]]

/-- $J_6$ is skew-symmetric: $J_6^T = -J_6$. -/
theorem J6_transpose : J6ᵀ = -J6 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $J_6^2 = -I_6$. -/
theorem J6_squared : J6 * J6 = -1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-! ### 2. Generalized Symplectic Predicates & Bilinear Pairings -/

/-- Infinitesimal symplectic Lie algebra condition $\mathfrak{sp}_{2g}(\mathbb{Z})$
    with respect to a symplectic form $J$: $M^T J + J M = 0$. -/
def IsInfinitesimalSymplecticGen {n : ℕ} (J M : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  Mᵀ * J + J * M = 0

/-- Symplectic group condition $\mathrm{Sp}_{2g}(\mathbb{Z})$ with respect to $J$:
    $T^T J T = J$. -/
def IsSymplecticGen {n : ℕ} (J T : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  Tᵀ * J * T = J

/-- Generalized symplectic bilinear pairing $\langle v, w \rangle_J = v \cdot (J w)$. -/
def symplecticPairingGen {n : ℕ} (J : Matrix (Fin n) (Fin n) ℤ) (v w : Fin n → ℤ) : ℤ :=
  dotProduct v (J *ᵥ w)

/-- Coordinate expansion of `symplecticPairingGen`. -/
theorem symplecticPairingGen_def {n : ℕ} (J : Matrix (Fin n) (Fin n) ℤ) (v w : Fin n → ℤ) :
    symplecticPairingGen J v w = dotProduct v (J *ᵥ w) :=
  rfl

/-- Adjoint identity for matrix-vector multiplication under the standard dot product. -/
theorem dotProduct_mulVec_transpose {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ) (v w : Fin n → ℤ) :
    dotProduct (M *ᵥ v) w = dotProduct v (Mᵀ *ᵥ w) := by
  dsimp [dotProduct, mulVec, transpose]
  simp_rw [Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  congr 1; ext i; congr 1; ext j; ring

/-- Commutativity of the dot product on $\mathbb{Z}^n$. -/
theorem dotProduct_comm {n : ℕ} (v w : Fin n → ℤ) :
    dotProduct v w = dotProduct w v :=
  _root_.dotProduct_comm v w

/-- Skew-symmetry of the generalized symplectic bilinear pairing. -/
theorem symplecticPairingGen_skew {n : ℕ} (J : Matrix (Fin n) (Fin n) ℤ)
    (hJ : Jᵀ = -J) (v w : Fin n → ℤ) :
    symplecticPairingGen J v w = -symplecticPairingGen J w v := by
  simp only [symplecticPairingGen, dotProduct_comm v, dotProduct_mulVec_transpose,
    hJ, neg_mulVec, dotProduct_neg]

/-- Vanishing of the generalized symplectic pairing on the diagonal. -/
theorem symplecticPairingGen_self_zero {n : ℕ} (J : Matrix (Fin n) (Fin n) ℤ)
    (hJ : Jᵀ = -J) (v : Fin n → ℤ) :
    symplecticPairingGen J v v = 0 := by
  have h := symplecticPairingGen_skew J hJ v v
  linarith

/-- Infinitesimal symplectic invariance of the generalized pairing:
    $\langle M v, w \rangle_J + \langle v, M w \rangle_J = 0$. -/
theorem symplecticPairingGen_M_invariant {n : ℕ} (J M : Matrix (Fin n) (Fin n) ℤ)
    (hM : IsInfinitesimalSymplecticGen J M) (v w : Fin n → ℤ) :
    symplecticPairingGen J (M *ᵥ v) w + symplecticPairingGen J v (M *ᵥ w) = 0 := by
  dsimp [symplecticPairingGen]
  rw [dotProduct_mulVec_transpose, mulVec_mulVec, mulVec_mulVec,
    ← dotProduct_add, ← add_mulVec, hM, zero_mulVec, dotProduct_zero]

/-- Finite symplectic group invariance of the generalized pairing:
    $\langle T v, T w \rangle_J = \langle v, w \rangle_J$. -/
theorem symplecticPairingGen_T_invariant {n : ℕ} (J T : Matrix (Fin n) (Fin n) ℤ)
    (hT : IsSymplecticGen J T) (v w : Fin n → ℤ) :
    symplecticPairingGen J (T *ᵥ v) (T *ᵥ w) = symplecticPairingGen J v w := by
  dsimp [symplecticPairingGen]
  rw [dotProduct_mulVec_transpose, mulVec_mulVec, mulVec_mulVec, hT]

/-- Identification between specialized `IsInfinitesimalSymplectic` and `IsInfinitesimalSymplecticGen J4`. -/
theorem isInfinitesimalSymplectic_iff_gen (M : Matrix (Fin 4) (Fin 4) ℤ) :
    IsInfinitesimalSymplectic M ↔ IsInfinitesimalSymplecticGen J4 M :=
  Iff.rfl

/-- Identification between specialized `IsSymplectic` and `IsSymplecticGen J4`. -/
theorem isSymplectic_iff_gen (T : Matrix (Fin 4) (Fin 4) ℤ) :
    IsSymplectic T ↔ IsSymplecticGen J4 T :=
  Iff.rfl

/-- Identification between specialized `IsInfinitesimalSymplecticOmega6` and generalized predicate. -/
theorem isInfinitesimalSymplecticOmega6_iff_gen (M : Matrix (Fin 4) (Fin 4) ℤ) :
    IsInfinitesimalSymplecticOmega6 M ↔ IsInfinitesimalSymplecticGen Omega6 M :=
  Iff.rfl

/-- Matrix-vector multiplication formula for $J_4$. -/
theorem mulVec_J4 (w : Fin 4 → ℤ) :
    J4 *ᵥ w = ![w 2, w 3, -w 0, -w 1] := by
  ext i
  fin_cases i <;> simp [J4, mulVec, dotProduct, Fin.sum_univ_four]

/-- Matrix-vector multiplication formula for $\Omega_6$. -/
theorem mulVec_Omega6 (w : Fin 4 → ℤ) :
    Omega6 *ᵥ w = ![w 3, 6 * w 2, -6 * w 1, -w 0] := by
  ext i
  fin_cases i <;> simp [Omega6, mulVec, dotProduct, Fin.sum_univ_four]

/-- Equivalence of coordinate formula `symplecticPairing` and generalized form `symplecticPairingGen J4`. -/
theorem symplecticPairing_eq_gen (v w : Fin 4 → ℤ) :
    symplecticPairing v w = symplecticPairingGen J4 v w := by
  dsimp [symplecticPairingGen, symplecticPairing]
  rw [mulVec_J4]
  dsimp [dotProduct]
  simp [Fin.sum_univ_four]
  ring

/-- Equivalence of coordinate formula `symplecticPairingOmega6` and generalized form with `Omega6`. -/
theorem symplecticPairingOmega6_eq_gen (v w : Fin 4 → ℤ) :
    symplecticPairingOmega6 v w = symplecticPairingGen Omega6 v w := by
  dsimp [symplecticPairingGen, symplecticPairingOmega6]
  rw [mulVec_Omega6]
  dsimp [dotProduct]
  simp [Fin.sum_univ_four]
  ring

/-! ### 3. Hodge Filtration Flags & Griffiths Transversality in Dimension 4 -/

/-- Membership in the Hodge filtration subspace $F^3 \subset \mathbb{Z}^4$. -/
def InF3 (v : Fin 4 → ℤ) : Prop :=
  v 1 = 0 ∧ v 2 = 0 ∧ v 3 = 0

/-- Membership in the Hodge filtration subspace $F^2 \subset \mathbb{Z}^4$. -/
def InF2 (v : Fin 4 → ℤ) : Prop :=
  v 2 = 0 ∧ v 3 = 0

/-- Membership in the Hodge filtration subspace $F^1 \subset \mathbb{Z}^4$. -/
def InF1 (v : Fin 4 → ℤ) : Prop :=
  v 3 = 0

/-- Membership in the Hodge filtration subspace $F^0 = \mathbb{Z}^4$. -/
def InF0 (_v : Fin 4 → ℤ) : Prop :=
  True

/-- Inclusion $F^3 \subseteq F^2$. -/
theorem InF3_subset_InF2 (v : Fin 4 → ℤ) (h : InF3 v) : InF2 v :=
  h.2

/-- Inclusion $F^2 \subseteq F^1$. -/
theorem InF2_subset_InF1 (v : Fin 4 → ℤ) (h : InF2 v) : InF1 v :=
  h.2

/-- Inclusion $F^1 \subseteq F^0$. -/
theorem InF1_subset_InF0 (v : Fin 4 → ℤ) (_h : InF1 v) : InF0 v :=
  trivial

/-- Complete Hodge filtration inclusion hierarchy: $F^3 \subseteq F^2 \subseteq F^1 \subseteq F^0$. -/
theorem hodge_filtration_chain (v : Fin 4 → ℤ) :
    (InF3 v → InF2 v) ∧ (InF2 v → InF1 v) ∧ (InF1 v → InF0 v) :=
  ⟨InF3_subset_InF2 v, InF2_subset_InF1 v, InF1_subset_InF0 v⟩

/-- Griffiths transversality condition for an infinitesimal/nilpotent operator $M \in \mathrm{Mat}_4(\mathbb{Z})$:
    $M(F^p) \subseteq F^{p-1}$ for all $p \in \{1, 2, 3\}$. -/
def SatisfiesGriffithsTransversality (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  (∀ v, InF3 v → InF2 (M *ᵥ v)) ∧
  (∀ v, InF2 v → InF1 (M *ᵥ v)) ∧
  (∀ v, InF1 v → InF0 (M *ᵥ v))

/-- Hodge-Riemann bilinear relation (orthogonality $F^3 \perp F^1$) for the polarized form $\Omega_6$. -/
theorem hodge_riemann_orthogonality_F3_F1_Omega6 (v w : Fin 4 → ℤ)
    (hv : InF3 v) (hw : InF1 w) :
    symplecticPairingOmega6 v w = 0 := by
  obtain ⟨hv1, hv2, hv3⟩ := hv
  dsimp [symplecticPairingOmega6, InF1] at hw ⊢
  rw [hv1, hv2, hv3, hw]
  ring

/-- Hodge-Riemann bilinear relation (orthogonality $F^3 \perp F^1$) alias. -/
theorem hodge_riemann_orthogonality_F3_F1 (v w : Fin 4 → ℤ)
    (hv : InF3 v) (hw : InF1 w) :
    symplecticPairingOmega6 v w = 0 :=
  hodge_riemann_orthogonality_F3_F1_Omega6 v w hv hw

/-- Hodge-Riemann bilinear relation (Lagrangian property $F^2 \perp F^2$) for the polarized form $\Omega_6$. -/
theorem hodge_riemann_lagrangian_F2_Omega6 (v w : Fin 4 → ℤ)
    (hv : InF2 v) (hw : InF2 w) :
    symplecticPairingOmega6 v w = 0 := by
  obtain ⟨hv2, hv3⟩ := hv
  obtain ⟨hw2, hw3⟩ := hw
  dsimp [symplecticPairingOmega6]
  rw [hv2, hv3, hw2, hw3]
  ring

/-- Hodge-Riemann Lagrangian property for the standard symplectic pairing: $F^2 \perp F^2$. -/
theorem hodge_lagrangian_F2 (v w : Fin 4 → ℤ)
    (hv : InF2 v) (hw : InF2 w) :
    symplecticPairing v w = 0 := by
  obtain ⟨hv2, hv3⟩ := hv
  obtain ⟨hw2, hw3⟩ := hw
  dsimp [symplecticPairing]
  rw [hv2, hv3, hw2, hw3]
  ring

/-- Hodge-Riemann Lagrangian property alias for standard pairing. -/
theorem hodge_riemann_lagrangian_F2 (v w : Fin 4 → ℤ)
    (hv : InF2 v) (hw : InF2 w) :
    symplecticPairing v w = 0 :=
  hodge_lagrangian_F2 v w hv hw

/-! ### 4. Machine-Checked Operator Verification -/

/-- Matrix-vector multiplication for $N_{\mathrm{MUM}}$. -/
theorem mulVec_N_MUM (v : Fin 4 → ℤ) :
    N_MUM *ᵥ v = ![v 1, v 2, v 3, 0] := by
  ext i
  fin_cases i <;> simp [N_MUM, mulVec, dotProduct, Fin.sum_univ_four]

/-- Griffiths transversality holds for the Calabi-Yau 3-fold MUM nilpotent operator $N_{\mathrm{MUM}}$. -/
theorem N_MUM_satisfies_GriffithsTransversality :
    SatisfiesGriffithsTransversality N_MUM := by
  refine ⟨fun v hv => ?_, fun v _ => ?_, fun _ _ => trivial⟩
  · rw [mulVec_N_MUM]; exact ⟨hv.2.2, rfl⟩
  · rw [mulVec_N_MUM]; rfl

/-- Griffiths transversality holds for the abelian surface $(3,4,\infty)$ nilpotent operator $N$. -/
theorem N_satisfies_GriffithsTransversality :
    SatisfiesGriffithsTransversality N := by
  refine ⟨fun v hv => ?_, fun v hv => ?_, fun _ _ => trivial⟩
  · rw [mulVec_N]; exact ⟨rfl, hv.2.1⟩
  · rw [mulVec_N]; exact hv.1

/-- Griffiths transversality holds for the $S_6$ modular family nilpotent operator. -/
theorem ModularFamilyS6_N_satisfies_GriffithsTransversality :
    SatisfiesGriffithsTransversality ModularFamilyS6.N := by
  refine ⟨fun v _ => ?_, fun v _ => ?_, fun _ _ => trivial⟩
  · rw [mulVec_S6_N]; exact ⟨rfl, rfl⟩
  · rw [mulVec_S6_N]; rfl

/-- The standard abelian surface nilpotent operator $N \in \mathfrak{sp}_4(\mathbb{Z})$ is infinitesimal symplectic for $J_4$. -/
theorem isInfinitesimalSymplecticGen_J4_N :
    IsInfinitesimalSymplecticGen J4 N := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The standard abelian surface cusp monodromy $T_0 \in \mathrm{Sp}_4(\mathbb{Z})$ is symplectic for $J_4$. -/
theorem isSymplecticGen_J4_T0 :
    IsSymplecticGen J4 T0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The $S_6$ nilpotent operator is infinitesimal symplectic for $\Omega_6$. -/
theorem isInfinitesimalSymplecticGen_Omega6_S6_N :
    IsInfinitesimalSymplecticGen Omega6 ModularFamilyS6.N := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- The $S_6$ cusp monodromy is symplectic for $\Omega_6$. -/
theorem isSymplecticGen_Omega6_S6_T0 :
    IsSymplecticGen Omega6 ModularFamilyS6.T0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-! ### 5. Dimension 2 ($g=1$) and Dimension 6 ($g=3$) Certificates -/

/-- Parabolic unipotent generator in $\mathrm{SL}_2(\mathbb{Z}) = \mathrm{Sp}_2(\mathbb{Z})$ ($g=1$). -/
def T0_2 : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![ 1,  1],
    ![ 0,  1]]

/-- Nilpotent log-monodromy operator in $\mathfrak{sp}_2(\mathbb{Z})$ ($g=1$): $N_2 = T_{0,2} - I_2$. -/
def N2 : Matrix (Fin 2) (Fin 2) ℤ :=
  ![![ 0,  1],
    ![ 0,  0]]

/-- $N_2$ satisfies $N_2 = T_{0,2} - I_2$. -/
theorem N2_def : N2 = T0_2 - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_2$ is unipotent of index 2: $N_2^2 = 0$. -/
theorem N2_squared_zero : N2 * N2 = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_2$ is non-zero. -/
theorem N2_nonzero : N2 ≠ 0 :=
  fun h => absurd (congr_fun (congr_fun h 0) 1) (by decide)

/-- $N_2 \in \mathfrak{sp}_2(\mathbb{Z})$: $N_2^T J_2 + J_2 N_2 = 0$. -/
theorem isInfinitesimalSymplecticGen_J2_N2 :
    IsInfinitesimalSymplecticGen J2 N2 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_{0,2} \in \mathrm{Sp}_2(\mathbb{Z})$: $T_{0,2}^T J_2 T_{0,2} = J_2$. -/
theorem isSymplecticGen_J2_T0_2 :
    IsSymplecticGen J2 T0_2 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- Parabolic unipotent generator in $\mathrm{Sp}_6(\mathbb{Z})$ ($g=3$). -/
def T0_6 : Matrix (Fin 6) (Fin 6) ℤ :=
  ![![ 1,  0,  0,  1,  0,  0],
    ![ 0,  1,  0,  0,  1,  0],
    ![ 0,  0,  1,  0,  0,  1],
    ![ 0,  0,  0,  1,  0,  0],
    ![ 0,  0,  0,  0,  1,  0],
    ![ 0,  0,  0,  0,  0,  1]]

/-- Nilpotent log-monodromy operator in $\mathfrak{sp}_6(\mathbb{Z})$ ($g=3$): $N_6 = T_{0,6} - I_6$. -/
def N6 : Matrix (Fin 6) (Fin 6) ℤ :=
  ![![ 0,  0,  0,  1,  0,  0],
    ![ 0,  0,  0,  0,  1,  0],
    ![ 0,  0,  0,  0,  0,  1],
    ![ 0,  0,  0,  0,  0,  0],
    ![ 0,  0,  0,  0,  0,  0],
    ![ 0,  0,  0,  0,  0,  0]]

/-- $N_6$ satisfies $N_6 = T_{0,6} - I_6$. -/
theorem N6_def : N6 = T0_6 - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_6$ is unipotent of index 2: $N_6^2 = 0$. -/
theorem N6_squared_zero : N6 * N6 = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $N_6$ is non-zero. -/
theorem N6_nonzero : N6 ≠ 0 :=
  fun h => absurd (congr_fun (congr_fun h 0) 3) (by decide)

/-- $N_6 \in \mathfrak{sp}_6(\mathbb{Z})$: $N_6^T J_6 + J_6 N_6 = 0$. -/
theorem isInfinitesimalSymplecticGen_J6_N6 :
    IsInfinitesimalSymplecticGen J6 N6 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

/-- $T_{0,6} \in \mathrm{Sp}_6(\mathbb{Z})$: $T_{0,6}^T J_6 T_{0,6} = J_6$. -/
theorem isSymplecticGen_J6_T0_6 :
    IsSymplecticGen J6 T0_6 := by
  ext i j; fin_cases i <;> fin_cases j <;> rfl

end PicardFuchsMirrorMonodromy
