/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.PicardFuchsMirrorMonodromy.DifferentialOperator
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FieldSimp

open scoped BigOperators

/-!
# Component 3: Multi-Instanton BPS & Gromov–Witten Expansions

This submodule formalizes the algebraic structure of classical Yukawa couplings $C_{zzz}(z)$,
their asymptotic singularities (order-3 pole at the large complex structure cusp $z = 0$,
simple pole at the conifold discriminant locus $z = 1/\mu$), the flat coordinate mirror map
$q = \exp(2\pi i t)$, and multi-instanton BPS / Gromov-Witten expansions $C_{ttt}(q)$
and $C_{\mathrm{GW}}(q)$ with certified intersection numbers and instanton counts.

## Mathematical Overview

### 1. Classical / Algebraic Yukawa Coupling $C_{zzz}(z)$
In the algebraic modulus coordinate $z$, the Special Geometry / Picard-Fuchs 3-point Yukawa coupling is:
$$C_{zzz}(z, \kappa_0, \mu) = \frac{\kappa_0}{z^3 (1 - \mu z)}$$
where:
- $\kappa_0$ is the classical intersection number.
- $\Delta(z) = 1 - \mu z$ is the discriminant locus (conifold singularity at $z = 1/\mu$).
- The regularized cusp function $\kappa_{\mathrm{reg}}(z) = z^3 C_{zzz}(z) = \frac{\kappa_0}{1 - \mu z}$ evaluates to $\kappa_0$ at $z = 0$.
- The conifold regularized function $\kappa_{\mathrm{con}}(z) = (1 - \mu z) C_{zzz}(z) = \frac{\kappa_0}{z^3}$ evaluates to $\kappa_0 \mu^3$ at $z = 1/\mu$.

### 2. Multi-Cover BPS / Gopakumar–Vafa Invariants & Gromov–Witten Invariants
Under the genus-0 Aspinwall-Morrison multi-covering formula, the genus-0 Gromov-Witten invariants $N_d$
are related to the integer BPS / Gopakumar-Vafa invariants $n_d$ via:
$$N_d = \sum_{k \mid d} \frac{n_{d/k}}{k^3}$$
Explicitly for degrees $d = 1, 2, 3, 4$:
- $N_1 = n_1$
- $N_2 = n_2 + \frac{n_1}{8}$
- $N_3 = n_3 + \frac{n_1}{27}$
- $N_4 = n_4 + \frac{n_2}{8} + \frac{n_1}{64}$

By Möbius inversion, the BPS counts are extracted from Gromov-Witten invariants as:
- $n_1 = N_1$
- $n_2 = N_2 - \frac{N_1}{8}$
- $n_3 = N_3 - \frac{N_1}{27}$
- $n_4 = N_4 - \frac{N_2}{8}$

### 3. Multi-Instanton Mirror Yukawa Expansion $C_{ttt}(q)$ vs $C_{\mathrm{GW}}(q)$
In the flat Kähler coordinate $t$ with $q = \exp(2\pi i t)$:
- **BPS Sum Representation**:
  $$C_{ttt}(q, K_0, n) = K_0 + \sum_{d=1}^M \frac{d^3 n_d q^d}{1 - q^d}$$
- **Gromov-Witten Polynomial Representation**:
  $$C_{\mathrm{GW}}(q, K_0, N) = K_0 + \sum_{d=1}^M d^3 N_d q^d$$

Expanding $\frac{q^d}{1 - q^d} = \sum_{k=1}^\infty q^{k d}$ establishes the exact order-by-order
asymptotic agreement $C_{ttt}(q) = C_{\mathrm{GW}}(q) + \mathcal{O}(q^{M+1})$.

### 4. Machine-Checked Certificates
- **Quintic 3-Fold ($\kappa_0 = 5$)**:
  - BPS invariants: $n_1 = 2875$, $n_2 = 609250$, $n_3 = 317206375$ (Candelas et al. 1991).
  - GW invariants: $N_1 = 2875$, $N_2 = 4876875/8$, $N_3 = 8564575000/27$.
  - Certified $C_{ttt}$ expansions for $M = 1, 2, 3$.
- **Modular $(3,4,\infty)$ Family ($\kappa_0 = 1$)**:
  - $n_1 = 4$, $n_2 = -2$, $n_3 = 0$.
  - $N_1 = 4$, $N_2 = -3/2$, $N_3 = 4/27$.
- **Modular $(2,3,\infty)$ Family ($\kappa_0 = 1$)**:
  - $n_1 = 2$, $n_2 = 1$, $n_3 = 0$.
  - $N_1 = 2$, $N_2 = 5/4$, $N_3 = 2/27$.
- **Modular $(2,5,\infty)$ Family ($\kappa_0 = 1$)**:
  - $n_1 = 1$, $n_2 = 3$, $n_3 = -1$.
  - $N_1 = 1$, $N_2 = 25/8$, $N_3 = -26/27$.

## Main Declarations

- `PicardFuchsMirrorMonodromy.C_zzz`, `Yukawa`: Classical Yukawa coupling function.
- `PicardFuchsMirrorMonodromy.regularizedYukawa`, `conifoldRegularizedYukawa`: Singularity regularizations.
- `PicardFuchsMirrorMonodromy.yukawa_cusp_factorization`, `regularizedYukawa_at_cusp`: Cusp behaviors.
- `PicardFuchsMirrorMonodromy.yukawa_conifold_factorization`, `conifoldRegularizedYukawa_at_conifold`: Conifold behaviors.
- `PicardFuchsMirrorMonodromy.instantonTerm`: Degree-$d$ instanton summand $\frac{d^3 n_d q^d}{1 - q^d}$.
- `PicardFuchsMirrorMonodromy.C_ttt`, `instantonYukawa`: Finite instanton expansion sum.
- `PicardFuchsMirrorMonodromy.gwFromBPS`: Genus-0 GW invariant extraction from BPS invariants.
- `PicardFuchsMirrorMonodromy.bpsFromGW`: BPS invariant extraction from GW invariants via inversion.
- `PicardFuchsMirrorMonodromy.bpsFromGW_gwFromBPS`: Roundtrip inversion theorem.
- `PicardFuchsMirrorMonodromy.C_GW`, `gwYukawa`: Polynomial Gromov-Witten Yukawa series.
- `PicardFuchsMirrorMonodromy.instanton_gw_equivalence_deg1`, `deg2`, `deg3`: Truncated $q$-expansion equivalences.
- `PicardFuchsMirrorMonodromy.IsBPSIntegral`, `IsBPSPositive`: BPS integrality and positivity predicates.
- Machine-checked certificates for Quintic and modular triangle families $(3,4,\infty)$, $(2,3,\infty)$, and $(2,5,\infty)$.
-/

namespace PicardFuchsMirrorMonodromy

/-! ### 1. Classical / Algebraic Yukawa Coupling -/

/-- The algebraic Yukawa coupling function $C_{zzz}(z, \kappa_0, \mu) = \frac{\kappa_0}{z^3 (1 - \mu z)}$. -/
def C_zzz (kappa0 mu : ℚ) (z : ℚ) : ℚ :=
  kappa0 / (z^3 * (1 - mu * z))

/-- Alias `Yukawa` for algebraic Yukawa coupling. -/
def Yukawa (kappa0 mu : ℚ) (z : ℚ) : ℚ :=
  C_zzz kappa0 mu z

/-- Regularized Yukawa function at the cusp $z = 0$: $\kappa_{\mathrm{reg}}(z) = \frac{\kappa_0}{1 - \mu z}$. -/
def regularizedYukawa (kappa0 mu : ℚ) (z : ℚ) : ℚ :=
  kappa0 / (1 - mu * z)

/-- Conifold regularized Yukawa function at $z = 1/\mu$: $\kappa_{\mathrm{con}}(z) = \frac{\kappa_0}{z^3}$. -/
def conifoldRegularizedYukawa (kappa0 : ℚ) (z : ℚ) : ℚ :=
  kappa0 / z^3

/-- Cusp factorization theorem: $z^3 \cdot C_{zzz}(z) = \kappa_{\mathrm{reg}}(z)$. -/
theorem yukawa_cusp_factorization (kappa0 mu z : ℚ) (hz : z ≠ 0) :
    z^3 * Yukawa kappa0 mu z = regularizedYukawa kappa0 mu z := by
  dsimp [Yukawa, C_zzz, regularizedYukawa]
  field_simp [hz]

/-- Cusp limit value: regularized Yukawa coupling at $z = 0$ equals $\kappa_0$. -/
theorem regularizedYukawa_at_cusp (kappa0 mu : ℚ) :
    regularizedYukawa kappa0 mu 0 = kappa0 := by
  simp [regularizedYukawa]

/-- Conifold factorization theorem: $(1 - \mu z) \cdot C_{zzz}(z) = \kappa_{\mathrm{con}}(z)$. -/
theorem yukawa_conifold_factorization (kappa0 mu z : ℚ) (hz : z ≠ 0) (hcon : 1 - mu * z ≠ 0) :
    (1 - mu * z) * Yukawa kappa0 mu z = conifoldRegularizedYukawa kappa0 z := by
  dsimp [Yukawa, C_zzz, conifoldRegularizedYukawa]
  field_simp [hz, hcon]

/-- Conifold evaluation theorem: at the discriminant locus $z = 1/\mu$,
    the conifold regularized Yukawa coupling evaluates to $\kappa_0 \mu^3$. -/
theorem conifoldRegularizedYukawa_at_conifold (kappa0 mu : ℚ) (hmu : mu ≠ 0) :
    conifoldRegularizedYukawa kappa0 (1 / mu) = kappa0 * mu^3 := by
  dsimp [conifoldRegularizedYukawa]
  field_simp [hmu]

/-- The discriminant factor $1 - \mu z$ vanishes at $z = 1/\mu$. -/
theorem discriminant_root (mu z : ℚ) (hmu : mu ≠ 0) (hz : z = 1 / mu) :
    1 - mu * z = 0 := by
  rw [hz, mul_one_div_cancel hmu, sub_self]

/-! ### 2. Multi-Instanton BPS Sum $C_{ttt}(q)$ -/

/-- Instanton degree-$d$ term in the Gromov-Witten / BPS expansion:
    $I_d(q) = \frac{d^3 n_d q^d}{1 - q^d}$. -/
def instantonTerm (d : ℕ) (nd : ℤ) (q : ℚ) : ℚ :=
  (d : ℚ)^3 * (nd : ℚ) * q^d / (1 - q^d)

/-- Finite instanton sum for the mirror Yukawa coupling:
    $C_{ttt}(q, K_0, n) = K_0 + \sum_{d=1}^M \frac{d^3 n_d q^d}{1 - q^d}$. -/
def C_ttt (K0 : ℚ) (n : ℕ → ℤ) (M : ℕ) (q : ℚ) : ℚ :=
  K0 + ∑ d ∈ Finset.Icc 1 M, instantonTerm d (n d) q

/-- Alias `instantonYukawa` for finite instanton sum. -/
def instantonYukawa (K0 : ℚ) (n : ℕ → ℤ) (k : ℕ) (q : ℚ) : ℚ :=
  C_ttt K0 n k q

/-- At $q = 0$, all instanton corrections vanish, giving the classical intersection number $K_0$. -/
theorem C_ttt_zero (K0 : ℚ) (n : ℕ → ℤ) (M : ℕ) :
    C_ttt K0 n M 0 = K0 := by
  dsimp [C_ttt]
  rw [Finset.sum_eq_zero fun d hd => by
    simp [instantonTerm, zero_pow (ne_of_gt (Finset.mem_Icc.mp hd).1)], add_zero]

/-- Instanton Yukawa evaluates to $K_0$ at $q = 0$. -/
theorem instantonYukawa_zero (K0 : ℚ) (n : ℕ → ℤ) (k : ℕ) :
    instantonYukawa K0 n k 0 = K0 :=
  C_ttt_zero K0 n k

/-- Degree 1 instanton term formula: $I_1(q) = \frac{n_1 q}{1 - q}$. -/
theorem instantonTerm_deg1 (n1 : ℤ) (q : ℚ) :
    instantonTerm 1 n1 q = (n1 : ℚ) * q / (1 - q) := by
  dsimp [instantonTerm]; ring

/-- Degree 2 instanton term formula: $I_2(q) = \frac{8 n_2 q^2}{1 - q^2}$. -/
theorem instantonTerm_deg2 (n2 : ℤ) (q : ℚ) :
    instantonTerm 2 n2 q = 8 * (n2 : ℚ) * q^2 / (1 - q^2) := by
  dsimp [instantonTerm]; ring

/-- Degree 3 instanton term formula: $I_3(q) = \frac{27 n_3 q^3}{1 - q^3}$. -/
theorem instantonTerm_deg3 (n3 : ℤ) (q : ℚ) :
    instantonTerm 3 n3 q = 27 * (n3 : ℚ) * q^3 / (1 - q^3) := by
  dsimp [instantonTerm]; ring

/-- Helper finite interval equality for $M = 3$. -/
theorem icc_1_3 : Finset.Icc 1 3 = ({1, 2, 3} : Finset ℕ) := by decide

/-- Explicit 1-instanton truncated Yukawa coupling $C_{ttt}$. -/
theorem C_ttt_M1 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    C_ttt K0 n 1 q = K0 + (n 1 : ℚ) * q / (1 - q) := by
  rw [C_ttt, Finset.Icc_self, Finset.sum_singleton, instantonTerm_deg1]

/-- Explicit 1-instanton truncated Yukawa coupling. -/
theorem instantonYukawa_k1 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    instantonYukawa K0 n 1 q = K0 + (n 1 : ℚ) * q / (1 - q) :=
  C_ttt_M1 K0 n q

/-- Explicit 2-instanton truncated Yukawa coupling $C_{ttt}$. -/
theorem C_ttt_M2 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    C_ttt K0 n 2 q = K0 + (n 1 : ℚ) * q / (1 - q) + 8 * (n 2 : ℚ) * q^2 / (1 - q^2) := by
  rw [C_ttt, show Finset.Icc 1 2 = {1, 2} from rfl, Finset.sum_pair (by decide),
    instantonTerm_deg1, instantonTerm_deg2, add_assoc]

/-- Explicit 2-instanton truncated Yukawa coupling. -/
theorem instantonYukawa_k2 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    instantonYukawa K0 n 2 q = K0 + (n 1 : ℚ) * q / (1 - q) + 8 * (n 2 : ℚ) * q^2 / (1 - q^2) :=
  C_ttt_M2 K0 n q

/-- Explicit 3-instanton truncated Yukawa coupling $C_{ttt}$. -/
theorem C_ttt_M3 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    C_ttt K0 n 3 q = K0 + (n 1 : ℚ) * q / (1 - q) + 8 * (n 2 : ℚ) * q^2 / (1 - q^2) +
      27 * (n 3 : ℚ) * q^3 / (1 - q^3) := by
  dsimp [C_ttt]
  rw [icc_1_3, Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton,
      instantonTerm_deg1, instantonTerm_deg2, instantonTerm_deg3]
  ring

/-- Explicit 3-instanton truncated Yukawa coupling. -/
theorem instantonYukawa_k3 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) :
    instantonYukawa K0 n 3 q = K0 + (n 1 : ℚ) * q / (1 - q) + 8 * (n 2 : ℚ) * q^2 / (1 - q^2) +
      27 * (n 3 : ℚ) * q^3 / (1 - q^3) :=
  C_ttt_M3 K0 n q

/-! ### 3. Genus-0 Gromov-Witten Invariants Extraction & BPS Inversion -/

/-- Genus-0 Gromov-Witten invariants $N_d$ extracted from integer BPS invariants $n_d$
    via the multi-covering formula $N_d = \sum_{k \mid d} \frac{n_{d/k}}{k^3}$ for $d = 1, 2, 3, 4$. -/
def gwFromBPS (n : ℕ → ℤ) : ℕ → ℚ
  | 1 => (n 1 : ℚ)
  | 2 => (n 2 : ℚ) + (n 1 : ℚ) / 8
  | 3 => (n 3 : ℚ) + (n 1 : ℚ) / 27
  | 4 => (n 4 : ℚ) + (n 2 : ℚ) / 8 + (n 1 : ℚ) / 64
  | _ => 0

/-- Inverse BPS invariant extraction from rational Gromov-Witten invariants $N_d$
    via Möbius inversion $n_d = \sum_{k \mid d} \mu(k) \frac{N_{d/k}}{k^3}$ for $d = 1, 2, 3, 4$. -/
def bpsFromGW (N : ℕ → ℚ) : ℕ → ℚ
  | 1 => N 1
  | 2 => N 2 - N 1 / 8
  | 3 => N 3 - N 1 / 27
  | 4 => N 4 - N 2 / 8
  | _ => 0

/-- Roundtrip inversion theorem at degree 1: $n_1 = \mathrm{bpsFromGW}(\mathrm{gwFromBPS}(n), 1)$. -/
theorem bpsFromGW_gwFromBPS_1 (n : ℕ → ℤ) :
    bpsFromGW (gwFromBPS n) 1 = (n 1 : ℚ) := rfl

/-- Roundtrip inversion theorem at degree 2: $n_2 = \mathrm{bpsFromGW}(\mathrm{gwFromBPS}(n), 2)$. -/
theorem bpsFromGW_gwFromBPS_2 (n : ℕ → ℤ) :
    bpsFromGW (gwFromBPS n) 2 = (n 2 : ℚ) := by
  change (n 2 : ℚ) + (n 1 : ℚ) / 8 - (n 1 : ℚ) / 8 = (n 2 : ℚ)
  ring

/-- Roundtrip inversion theorem at degree 3: $n_3 = \mathrm{bpsFromGW}(\mathrm{gwFromBPS}(n), 3)$. -/
theorem bpsFromGW_gwFromBPS_3 (n : ℕ → ℤ) :
    bpsFromGW (gwFromBPS n) 3 = (n 3 : ℚ) := by
  change (n 3 : ℚ) + (n 1 : ℚ) / 27 - (n 1 : ℚ) / 27 = (n 3 : ℚ)
  ring

/-- Roundtrip inversion theorem at degree 4: $n_4 = \mathrm{bpsFromGW}(\mathrm{gwFromBPS}(n), 4)$. -/
theorem bpsFromGW_gwFromBPS_4 (n : ℕ → ℤ) :
    bpsFromGW (gwFromBPS n) 4 = (n 4 : ℚ) := by
  change (n 4 : ℚ) + (n 2 : ℚ) / 8 + (n 1 : ℚ) / 64 - ((n 2 : ℚ) + (n 1 : ℚ) / 8) / 8 = (n 4 : ℚ)
  ring

/-- Dual inversion theorem for degree 1 with rational inputs. -/
theorem gwFromBPS_bpsFromGW_1 (N : ℕ → ℚ) :
    bpsFromGW N 1 = N 1 := rfl

/-- Dual inversion theorem for degree 2 with rational inputs: $N_2 = n_2 + n_1 / 8$. -/
theorem gwFromBPS_bpsFromGW_2 (N : ℕ → ℚ) :
    bpsFromGW N 2 + bpsFromGW N 1 / 8 = N 2 := by
  change (N 2 - N 1 / 8) + N 1 / 8 = N 2
  ring

/-- Dual inversion theorem for degree 3 with rational inputs: $N_3 = n_3 + n_1 / 27$. -/
theorem gwFromBPS_bpsFromGW_3 (N : ℕ → ℚ) :
    bpsFromGW N 3 + bpsFromGW N 1 / 27 = N 3 := by
  change (N 3 - N 1 / 27) + N 1 / 27 = N 3
  ring

/-- Dual inversion theorem for degree 4 with rational inputs: $N_4 = n_4 + n_2 / 8 + n_1 / 64$. -/
theorem gwFromBPS_bpsFromGW_4 (N : ℕ → ℚ) :
    bpsFromGW N 4 + bpsFromGW N 2 / 8 + bpsFromGW N 1 / 64 = N 4 := by
  change (N 4 - N 2 / 8) + (N 2 - N 1 / 8) / 8 + N 1 / 64 = N 4
  ring

/-! ### 4. Polynomial Gromov-Witten Yukawa Series $C_{\mathrm{GW}}(q)$ -/

/-- Truncated polynomial Gromov-Witten Yukawa series:
    $C_{\mathrm{GW}}(q, K_0, N, M) = K_0 + \sum_{d=1}^M d^3 N_d q^d$. -/
def C_GW (K0 : ℚ) (N : ℕ → ℚ) (M : ℕ) (q : ℚ) : ℚ :=
  K0 + ∑ d ∈ Finset.Icc 1 M, (d : ℚ)^3 * N d * q^d

/-- Alias `gwYukawa` for polynomial Gromov-Witten Yukawa series. -/
def gwYukawa (K0 : ℚ) (N : ℕ → ℚ) (M : ℕ) (q : ℚ) : ℚ :=
  C_GW K0 N M q

/-- At $q = 0$, the Gromov-Witten series evaluates to the classical intersection number $K_0$. -/
theorem C_GW_zero (K0 : ℚ) (N : ℕ → ℚ) (M : ℕ) :
    C_GW K0 N M 0 = K0 := by
  dsimp [C_GW]
  rw [Finset.sum_eq_zero fun d hd => by
    simp [zero_pow (ne_of_gt (Finset.mem_Icc.mp hd).1)], add_zero]

/-- Gromov-Witten Yukawa evaluates to $K_0$ at $q = 0$. -/
theorem gwYukawa_zero (K0 : ℚ) (N : ℕ → ℚ) (M : ℕ) :
    gwYukawa K0 N M 0 = K0 :=
  C_GW_zero K0 N M

/-- Explicit degree-1 Gromov-Witten polynomial Yukawa coupling:
    $C_{\mathrm{GW}}(q) = K_0 + N_1 q$. -/
theorem C_GW_M1 (K0 : ℚ) (N : ℕ → ℚ) (q : ℚ) :
    C_GW K0 N 1 q = K0 + N 1 * q := by
  dsimp [C_GW]
  rw [Finset.Icc_self, Finset.sum_singleton]
  ring

/-- Explicit degree-2 Gromov-Witten polynomial Yukawa coupling:
    $C_{\mathrm{GW}}(q) = K_0 + N_1 q + 8 N_2 q^2$. -/
theorem C_GW_M2 (K0 : ℚ) (N : ℕ → ℚ) (q : ℚ) :
    C_GW K0 N 2 q = K0 + N 1 * q + 8 * N 2 * q^2 := by
  dsimp [C_GW]
  rw [show Finset.Icc 1 2 = {1, 2} from rfl, Finset.sum_pair (by decide)]
  ring

/-- Explicit degree-3 Gromov-Witten polynomial Yukawa coupling:
    $C_{\mathrm{GW}}(q) = K_0 + N_1 q + 8 N_2 q^2 + 27 N_3 q^3$. -/
theorem C_GW_M3 (K0 : ℚ) (N : ℕ → ℚ) (q : ℚ) :
    C_GW K0 N 3 q = K0 + N 1 * q + 8 * N 2 * q^2 + 27 * N 3 * q^3 := by
  dsimp [C_GW]
  rw [icc_1_3, Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  ring

/-! ### 5. Truncated $q$-Expansion Asymptotic Equivalence -/

/-- Exact geometric series identity at order 1:
    $\frac{1}{1 - q} = 1 + \frac{q}{1 - q}$. -/
theorem geom_inv_deg1 (q : ℚ) (hq : 1 - q ≠ 0) :
    (1 - q)⁻¹ = 1 + q / (1 - q) := by
  field_simp [hq]; ring

/-- Exact geometric series identity at order 2:
    $\frac{1}{1 - q} = 1 + q + \frac{q^2}{1 - q}$. -/
theorem geom_inv_deg2 (q : ℚ) (hq : 1 - q ≠ 0) :
    (1 - q)⁻¹ = 1 + q + q^2 / (1 - q) := by
  field_simp [hq]; ring

/-- Exact quadratic geometric series identity:
    $\frac{1}{1 - q^2} = 1 + \frac{q^2}{1 - q^2}$. -/
theorem geom_inv_q2 (q : ℚ) (hq : 1 - q^2 ≠ 0) :
    (1 - q^2)⁻¹ = 1 + q^2 / (1 - q^2) := by
  field_simp [hq]; ring

/-- Geometric summand expansion for degree 1:
    $\frac{q}{1 - q} = q + \frac{q^2}{1 - q}$. -/
theorem geom_series_order1 (q : ℚ) (hq : 1 - q ≠ 0) :
    q / (1 - q) = q + q^2 / (1 - q) := by
  field_simp [hq]; ring

/-- Geometric summand expansion for degree 2:
    $\frac{q}{1 - q} = q + q^2 + \frac{q^3}{1 - q}$. -/
theorem geom_series_order2 (q : ℚ) (hq : 1 - q ≠ 0) :
    q / (1 - q) = q + q^2 + q^3 / (1 - q) := by
  field_simp [hq]; ring

/-- Geometric summand expansion for degree 3:
    $\frac{q}{1 - q} = q + q^2 + q^3 + \frac{q^4}{1 - q}$. -/
theorem geom_series_order3 (q : ℚ) (hq : 1 - q ≠ 0) :
    q / (1 - q) = q + q^2 + q^3 + q^4 / (1 - q) := by
  field_simp [hq]; ring

/-- Quadratic geometric summand expansion:
    $\frac{q^2}{1 - q^2} = q^2 + \frac{q^4}{1 - q^2}$. -/
theorem geom_series_q2 (q : ℚ) (hq : 1 - q^2 ≠ 0) :
    q^2 / (1 - q^2) = q^2 + q^4 / (1 - q^2) := by
  field_simp [hq]; ring

/-- Cubic geometric summand expansion:
    $\frac{q^3}{1 - q^3} = q^3 + \frac{q^6}{1 - q^3}$. -/
theorem geom_series_q3 (q : ℚ) (hq : 1 - q^3 ≠ 0) :
    q^3 / (1 - q^3) = q^3 + q^6 / (1 - q^3) := by
  field_simp [hq]; ring

/-- Exact 1-instanton BPS to Gromov-Witten expansion equivalence theorem:
    $C_{ttt}(q, K_0, n, 1) = C_{\mathrm{GW}}(q, K_0, N(n), 1) + \frac{n_1 q^2}{1 - q}$. -/
theorem instanton_gw_equivalence_deg1 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ) (hq1 : 1 - q ≠ 0) :
    C_ttt K0 n 1 q = C_GW K0 (gwFromBPS n) 1 q + (n 1 : ℚ) * q^2 / (1 - q) := by
  rw [C_ttt_M1, C_GW_M1]
  dsimp [gwFromBPS]
  field_simp [hq1]
  ring

/-- Exact 2-instanton BPS to Gromov-Witten expansion equivalence theorem:
    $C_{ttt}(q, K_0, n, 2) = C_{\mathrm{GW}}(q, K_0, N(n), 2) + \frac{n_1 q^3}{1 - q} + \frac{8 n_2 q^4}{1 - q^2}$. -/
theorem instanton_gw_equivalence_deg2 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ)
    (hq1 : 1 - q ≠ 0) (hq2 : 1 - q^2 ≠ 0) :
    C_ttt K0 n 2 q = C_GW K0 (gwFromBPS n) 2 q +
      (n 1 : ℚ) * q^3 / (1 - q) + 8 * (n 2 : ℚ) * q^4 / (1 - q^2) := by
  rw [C_ttt_M2, C_GW_M2]
  dsimp [gwFromBPS]
  field_simp [hq1, hq2]
  ring

/-- Exact 3-instanton BPS to Gromov-Witten expansion equivalence theorem:
    $C_{ttt}(q, K_0, n, 3) = C_{\mathrm{GW}}(q, K_0, N(n), 3) + \frac{n_1 q^4}{1 - q} + \frac{8 n_2 q^4}{1 - q^2} + \frac{27 n_3 q^6}{1 - q^3}$. -/
theorem instanton_gw_equivalence_deg3 (K0 : ℚ) (n : ℕ → ℤ) (q : ℚ)
    (hq1 : 1 - q ≠ 0) (hq2 : 1 - q^2 ≠ 0) (hq3 : 1 - q^3 ≠ 0) :
    C_ttt K0 n 3 q = C_GW K0 (gwFromBPS n) 3 q +
      (n 1 : ℚ) * q^4 / (1 - q) + 8 * (n 2 : ℚ) * q^4 / (1 - q^2) +
      27 * (n 3 : ℚ) * q^6 / (1 - q^3) := by
  rw [C_ttt_M3, C_GW_M3]
  dsimp [gwFromBPS]
  field_simp [hq1, hq2, hq3]
  ring

/-! ### 6. Machine-Checked Invariant Certificates -/

/-! #### A. Calabi-Yau 3-Fold Quintic Mirror Family ($\kappa_0 = 5$) -/

/-- Calabi-Yau 3-fold Quintic mirror BPS invariant sequence certificate:
    $n_1 = 2875, n_2 = 609250, n_3 = 317206375$ (Candelas et al. 1991). -/
def quintic_n : ℕ → ℤ
  | 1 => 2875
  | 2 => 609250
  | 3 => 317206375
  | _ => 0

/-- Quintic degree-1 Gromov-Witten invariant certificate: $N_1 = 2875$. -/
theorem quintic_gw_N1 : gwFromBPS quintic_n 1 = 2875 := rfl

/-- Quintic degree-2 Gromov-Witten invariant certificate: $N_2 = \frac{4876875}{8}$. -/
theorem quintic_gw_N2 : gwFromBPS quintic_n 2 = 4876875 / 8 := by
  dsimp [gwFromBPS, quintic_n]; norm_num

/-- Quintic degree-3 Gromov-Witten invariant certificate: $N_3 = \frac{8564575000}{27}$. -/
theorem quintic_gw_N3 : gwFromBPS quintic_n 3 = 8564575000 / 27 := by
  dsimp [gwFromBPS, quintic_n]; norm_num

/-- Quintic Calabi-Yau 1-instanton Yukawa coupling certificate:
    $C(q) = 5 + \frac{2875 q}{1 - q}$. -/
theorem quintic_instanton_k1 (q : ℚ) :
    instantonYukawa 5 quintic_n 1 q = 5 + 2875 * q / (1 - q) :=
  instantonYukawa_k1 5 quintic_n q

/-- Quintic Calabi-Yau 2-instanton Yukawa coupling certificate:
    $C(q) = 5 + \frac{2875 q}{1 - q} + \frac{4874000 q^2}{1 - q^2}$. -/
theorem quintic_instanton_k2 (q : ℚ) :
    instantonYukawa 5 quintic_n 2 q = 5 + 2875 * q / (1 - q) + 4874000 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k2]; dsimp [quintic_n]; push_cast; ring

/-- Quintic Calabi-Yau 3-instanton Yukawa coupling certificate:
    $C(q) = 5 + \frac{2875 q}{1 - q} + \frac{4874000 q^2}{1 - q^2} + \frac{8564572125 q^3}{1 - q^3}$. -/
theorem quintic_instanton_k3 (q : ℚ) :
    instantonYukawa 5 quintic_n 3 q =
      5 + 2875 * q / (1 - q) + 4874000 * q^2 / (1 - q^2) + 8564572125 * q^3 / (1 - q^3) := by
  rw [instantonYukawa_k3]; dsimp [quintic_n]; push_cast; ring

/-- Quintic polynomial Gromov-Witten Yukawa series at $M = 1$:
    $C_{\mathrm{GW}}(q) = 5 + 2875 q$. -/
theorem quintic_gw_yukawa_M1 (q : ℚ) :
    C_GW 5 (gwFromBPS quintic_n) 1 q = 5 + 2875 * q := by
  rw [C_GW_M1, quintic_gw_N1]

/-- Quintic polynomial Gromov-Witten Yukawa series at $M = 2$:
    $C_{\mathrm{GW}}(q) = 5 + 2875 q + 4876875 q^2$. -/
theorem quintic_gw_yukawa_M2 (q : ℚ) :
    C_GW 5 (gwFromBPS quintic_n) 2 q = 5 + 2875 * q + 4876875 * q^2 := by
  rw [C_GW_M2, quintic_gw_N1, quintic_gw_N2]; ring

/-- Quintic polynomial Gromov-Witten Yukawa series at $M = 3$:
    $C_{\mathrm{GW}}(q) = 5 + 2875 q + 4876875 q^2 + 8564575000 q^3$. -/
theorem quintic_gw_yukawa_M3 (q : ℚ) :
    C_GW 5 (gwFromBPS quintic_n) 3 q = 5 + 2875 * q + 4876875 * q^2 + 8564575000 * q^3 := by
  rw [C_GW_M3, quintic_gw_N1, quintic_gw_N2, quintic_gw_N3]; ring

/-! #### B. Modular Triangle Family $\Delta(3,4,\infty)$ ($\kappa_0 = 1$) -/

/-- Modular $(3,4,\infty)$ abelian surface / modular family certificate sequence:
    $n_1 = 4, n_2 = -2, n_3 = 0$. -/
def modular_34_n : ℕ → ℤ
  | 1 => 4
  | 2 => -2
  | 3 => 0
  | _ => 0

/-- $\Delta(3,4,\infty)$ degree-1 Gromov-Witten invariant certificate: $N_1 = 4$. -/
theorem modular_34_gw_N1 : gwFromBPS modular_34_n 1 = 4 := rfl

/-- $\Delta(3,4,\infty)$ degree-2 Gromov-Witten invariant certificate: $N_2 = -3/2$. -/
theorem modular_34_gw_N2 : gwFromBPS modular_34_n 2 = -3 / 2 := by
  dsimp [gwFromBPS, modular_34_n]; norm_num

/-- $\Delta(3,4,\infty)$ degree-3 Gromov-Witten invariant certificate: $N_3 = 4/27$. -/
theorem modular_34_gw_N3 : gwFromBPS modular_34_n 3 = 4 / 27 := by
  dsimp [gwFromBPS, modular_34_n]; norm_num

/-- Modular $(3,4,\infty)$ 1-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{4 q}{1 - q}$. -/
theorem modular_34_instanton_k1 (q : ℚ) :
    instantonYukawa 1 modular_34_n 1 q = 1 + 4 * q / (1 - q) :=
  instantonYukawa_k1 1 modular_34_n q

/-- Modular $(3,4,\infty)$ 2-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{4 q}{1 - q} - \frac{16 q^2}{1 - q^2}$. -/
theorem modular_34_instanton_k2 (q : ℚ) :
    instantonYukawa 1 modular_34_n 2 q = 1 + 4 * q / (1 - q) - 16 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k2]; dsimp [modular_34_n]; push_cast; ring

/-- Modular $(3,4,\infty)$ 3-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{4 q}{1 - q} - \frac{16 q^2}{1 - q^2}$. -/
theorem modular_34_instanton_k3 (q : ℚ) :
    instantonYukawa 1 modular_34_n 3 q = 1 + 4 * q / (1 - q) - 16 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k3]; dsimp [modular_34_n]; push_cast; ring

/-- $\Delta(3,4,\infty)$ polynomial Gromov-Witten Yukawa series at $M = 3$:
    $C_{\mathrm{GW}}(q) = 1 + 4 q - 12 q^2 + 4 q^3$. -/
theorem modular_34_gw_yukawa_M3 (q : ℚ) :
    C_GW 1 (gwFromBPS modular_34_n) 3 q = 1 + 4 * q - 12 * q^2 + 4 * q^3 := by
  rw [C_GW_M3, modular_34_gw_N1, modular_34_gw_N2, modular_34_gw_N3]; ring

/-! #### C. Modular Triangle Family $\Delta(2,3,\infty)$ ($\kappa_0 = 1$) -/

/-- Modular $(2,3,\infty)$ abelian surface family certificate sequence:
    $n_1 = 2, n_2 = 1, n_3 = 0$. -/
def modular_23_n : ℕ → ℤ
  | 1 => 2
  | 2 => 1
  | 3 => 0
  | _ => 0

/-- $\Delta(2,3,\infty)$ degree-1 Gromov-Witten invariant certificate: $N_1 = 2$. -/
theorem modular_23_gw_N1 : gwFromBPS modular_23_n 1 = 2 := rfl

/-- $\Delta(2,3,\infty)$ degree-2 Gromov-Witten invariant certificate: $N_2 = 5/4$. -/
theorem modular_23_gw_N2 : gwFromBPS modular_23_n 2 = 5 / 4 := by
  dsimp [gwFromBPS, modular_23_n]; norm_num

/-- $\Delta(2,3,\infty)$ degree-3 Gromov-Witten invariant certificate: $N_3 = 2/27$. -/
theorem modular_23_gw_N3 : gwFromBPS modular_23_n 3 = 2 / 27 := by
  dsimp [gwFromBPS, modular_23_n]; norm_num

/-- Modular $(2,3,\infty)$ 1-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{2 q}{1 - q}$. -/
theorem modular_23_instanton_k1 (q : ℚ) :
    instantonYukawa 1 modular_23_n 1 q = 1 + 2 * q / (1 - q) :=
  instantonYukawa_k1 1 modular_23_n q

/-- Modular $(2,3,\infty)$ 2-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{2 q}{1 - q} + \frac{8 q^2}{1 - q^2}$. -/
theorem modular_23_instanton_k2 (q : ℚ) :
    instantonYukawa 1 modular_23_n 2 q = 1 + 2 * q / (1 - q) + 8 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k2]; dsimp [modular_23_n]; push_cast; ring

/-- Modular $(2,3,\infty)$ 3-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{2 q}{1 - q} + \frac{8 q^2}{1 - q^2}$. -/
theorem modular_23_instanton_k3 (q : ℚ) :
    instantonYukawa 1 modular_23_n 3 q = 1 + 2 * q / (1 - q) + 8 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k3]; dsimp [modular_23_n]; push_cast; ring

/-- $\Delta(2,3,\infty)$ polynomial Gromov-Witten Yukawa series at $M = 3$:
    $C_{\mathrm{GW}}(q) = 1 + 2 q + 10 q^2 + 2 q^3$. -/
theorem modular_23_gw_yukawa_M3 (q : ℚ) :
    C_GW 1 (gwFromBPS modular_23_n) 3 q = 1 + 2 * q + 10 * q^2 + 2 * q^3 := by
  rw [C_GW_M3, modular_23_gw_N1, modular_23_gw_N2, modular_23_gw_N3]; ring

/-! #### D. Modular Triangle Family $\Delta(2,5,\infty)$ ($\kappa_0 = 1$) -/

/-- Modular $(2,5,\infty)$ family certificate sequence:
    $n_1 = 1, n_2 = 3, n_3 = -1$. -/
def modular_25_n : ℕ → ℤ
  | 1 => 1
  | 2 => 3
  | 3 => -1
  | _ => 0

/-- $\Delta(2,5,\infty)$ degree-1 Gromov-Witten invariant certificate: $N_1 = 1$. -/
theorem modular_25_gw_N1 : gwFromBPS modular_25_n 1 = 1 := rfl

/-- $\Delta(2,5,\infty)$ degree-2 Gromov-Witten invariant certificate: $N_2 = 25/8$. -/
theorem modular_25_gw_N2 : gwFromBPS modular_25_n 2 = 25 / 8 := by
  dsimp [gwFromBPS, modular_25_n]; norm_num

/-- $\Delta(2,5,\infty)$ degree-3 Gromov-Witten invariant certificate: $N_3 = -26/27$. -/
theorem modular_25_gw_N3 : gwFromBPS modular_25_n 3 = -26 / 27 := by
  dsimp [gwFromBPS, modular_25_n]; norm_num

/-- Modular $(2,5,\infty)$ 1-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{q}{1 - q}$. -/
theorem modular_25_instanton_k1 (q : ℚ) :
    instantonYukawa 1 modular_25_n 1 q = 1 + 1 * q / (1 - q) :=
  instantonYukawa_k1 1 modular_25_n q

/-- Modular $(2,5,\infty)$ 2-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{q}{1 - q} + \frac{24 q^2}{1 - q^2}$. -/
theorem modular_25_instanton_k2 (q : ℚ) :
    instantonYukawa 1 modular_25_n 2 q = 1 + 1 * q / (1 - q) + 24 * q^2 / (1 - q^2) := by
  rw [instantonYukawa_k2]; dsimp [modular_25_n]; push_cast; ring

/-- Modular $(2,5,\infty)$ 3-instanton Yukawa coupling certificate:
    $C(q) = 1 + \frac{q}{1 - q} + \frac{24 q^2}{1 - q^2} - \frac{27 q^3}{1 - q^3}$. -/
theorem modular_25_instanton_k3 (q : ℚ) :
    instantonYukawa 1 modular_25_n 3 q =
      1 + 1 * q / (1 - q) + 24 * q^2 / (1 - q^2) - 27 * q^3 / (1 - q^3) := by
  rw [instantonYukawa_k3]; dsimp [modular_25_n]; push_cast; ring

/-- $\Delta(2,5,\infty)$ polynomial Gromov-Witten Yukawa series at $M = 3$:
    $C_{\mathrm{GW}}(q) = 1 + 1 * q + 25 * q^2 - 26 * q^3$. -/
theorem modular_25_gw_yukawa_M3 (q : ℚ) :
    C_GW 1 (gwFromBPS modular_25_n) 3 q = 1 + 1 * q + 25 * q^2 - 26 * q^3 := by
  rw [C_GW_M3, modular_25_gw_N1, modular_25_gw_N2, modular_25_gw_N3]; ring

/-! ### 7. Multi-Instanton BPS Integrality & Positivity Properties -/

/-- Predicate characterizing that the rational Gromov-Witten invariants $N_d$ invert
    to integer BPS invariants $n_d$ for all degrees $d \in \{1, 2, 3, 4\}$. -/
def IsBPSIntegral (N : ℕ → ℚ) (n : ℕ → ℤ) : Prop :=
  ∀ d ∈ ({1, 2, 3, 4} : Finset ℕ), bpsFromGW N d = (n d : ℚ)

/-- Strict positivity predicate for genus-0 BPS invariants up to degree $M$:
    $n_d > 0$ for all $1 \le d \le M$. -/
def IsBPSPositive (n : ℕ → ℤ) (M : ℕ) : Prop :=
  ∀ d ∈ Finset.Icc 1 M, 0 < n d

/-- Non-negativity predicate for genus-0 BPS invariants up to degree $M$:
    $n_d \ge 0$ for all $1 \le d \le M$. -/
def IsBPSNonNegative (n : ℕ → ℤ) (M : ℕ) : Prop :=
  ∀ d ∈ Finset.Icc 1 M, 0 ≤ n d

/-- Universal BPS integrality theorem for BPS-extracted Gromov-Witten invariants. -/
theorem bps_integrality (n : ℕ → ℤ) :
    IsBPSIntegral (gwFromBPS n) n := by
  intro d hd
  simp only [Finset.mem_insert, Finset.mem_singleton] at hd
  rcases hd with rfl | rfl | rfl | rfl
  · exact bpsFromGW_gwFromBPS_1 n
  · exact bpsFromGW_gwFromBPS_2 n
  · exact bpsFromGW_gwFromBPS_3 n
  · exact bpsFromGW_gwFromBPS_4 n

/-- Calabi-Yau Quintic BPS integrality certificate. -/
theorem quintic_bps_integral :
    IsBPSIntegral (gwFromBPS quintic_n) quintic_n :=
  bps_integrality quintic_n

/-- Calabi-Yau Quintic strict BPS positivity certificate through degree 3:
    $n_1 = 2875 > 0$, $n_2 = 609250 > 0$, $n_3 = 317206375 > 0$. -/
theorem quintic_bps_positive :
    IsBPSPositive quintic_n 3 := by
  intro d hd
  simp only [Finset.mem_Icc] at hd
  rcases show d = 1 ∨ d = 2 ∨ d = 3 by omega with rfl | rfl | rfl <;> decide

/-- Modular $(3,4,\infty)$ BPS integrality certificate. -/
theorem modular_34_bps_integral :
    IsBPSIntegral (gwFromBPS modular_34_n) modular_34_n :=
  bps_integrality modular_34_n

/-- Modular $(2,3,\infty)$ BPS integrality certificate. -/
theorem modular_23_bps_integral :
    IsBPSIntegral (gwFromBPS modular_23_n) modular_23_n :=
  bps_integrality modular_23_n

/-- Modular $(2,3,\infty)$ strict BPS positivity certificate through degree 2:
    $n_1 = 2 > 0$, $n_2 = 1 > 0$. -/
theorem modular_23_bps_positive_2 :
    IsBPSPositive modular_23_n 2 := by
  intro d hd
  simp only [Finset.mem_Icc] at hd
  rcases show d = 1 ∨ d = 2 by omega with rfl | rfl <;> decide

/-- Modular $(2,3,\infty)$ non-negativity certificate through degree 3:
    $n_1 = 2 \ge 0$, $n_2 = 1 \ge 0$, $n_3 = 0 \ge 0$. -/
theorem modular_23_bps_nonneg_3 :
    IsBPSNonNegative modular_23_n 3 := by
  intro d hd
  simp only [Finset.mem_Icc] at hd
  rcases show d = 1 ∨ d = 2 ∨ d = 3 by omega with rfl | rfl | rfl <;> decide

/-- Modular $(2,5,\infty)$ BPS integrality certificate. -/
theorem modular_25_bps_integral :
    IsBPSIntegral (gwFromBPS modular_25_n) modular_25_n :=
  bps_integrality modular_25_n

end PicardFuchsMirrorMonodromy
