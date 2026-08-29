/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.BrieskornSU2CharacterVariety.RepresentationCounts
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.IntervalCases

/-!
# Exact Chern-Simons Actions & Lawrence-Zagier / Hikami False Theta Invariants

This submodule formalizes the exact Chern-Simons invariants on the irreducible $SU(2)$ character
varieties of Brieskorn homology 3-spheres $\Sigma(p, q, r)$, their stationary phase / discrete
partition function sums, and the connection to Lawrence-Zagier false theta characters and exponents.

## Mathematical Formulation

### 1. Chern-Simons Action on Seifert Fibered Homology Spheres
For the Seifert homology sphere $\Sigma(p, q, r)$ with pairwise coprime exponents $p, q, r \ge 2$,
an irreducible $SU(2)$ representation $\rho_{(a,b,c)}$ corresponding to rotation parameters
$(a, b, c) \in \prod_{i=1}^3 [1, p_i - 1]$ with $a, b, c$ odd has Chern-Simons invariant:
$$CS(p, q, r; a, b, c) = -\frac{(a q r + b p r + c p q - p q r)^2}{4 p q r} \pmod 1$$
as established by Fintushel-Stern (1990) and Kirk-Klassen (1990).

### 2. Evaluations on Canonical Brieskorn Spheres
- **Poincaré Homology Sphere $\Sigma(2, 3, 5)$**:
  $4 p q r = 120$.
  - Representation $(1, 1, 1)$: $CS = -1/120$.
  - Representation $(1, 1, 3)$: $CS = -169/120 = -1 - 49/120 \equiv -49/120 \pmod 1$.
- **Brieskorn Sphere $\Sigma(2, 3, 7)$**:
  $4 p q r = 168$.
  - Representation $(1, 1, 3)$: $CS = -121/168$.
  - Representation $(1, 1, 5)$: $CS = -529/168 = -3 - 25/168 \equiv -25/168 \pmod 1$.
- **Brieskorn Sphere $\Sigma(2, 3, 11)$**:
  $4 p q r = 264$.
  - Representations $(1, 1, 3), (1, 1, 5), (1, 1, 7), (1, 1, 9)$:
    $CS = -49/264, -361/264, -961/264, -1849/264$.
- **Brieskorn Sphere $\Sigma(2, 5, 7)$**:
  $4 p q r = 280$.
  - Representations $(1, 1, 3), (1, 3, 1), (1, 3, 3), (1, 3, 5)$:
    $CS = -81/280, -289/280, -1369/280, -3249/280$.

### 3. Lawrence-Zagier False Theta Invariant $\widetilde{\psi}(q)$
For $\Sigma(2, 3, 5)$, Lawrence & Zagier (1999) and Hikami (2003) showed the quantum invariant
is captured by the false theta function:
$$\widetilde{\psi}(q) = \sum_{n=1}^\infty \chi_{120}(n) q^{\frac{n^2 - 1}{120}}$$
where $\chi_{120}$ is periodic modulo 60 (and 120) with values $+1$ at $\{1, 11, 19, 29\}$,
$-1$ at $\{31, 41, 49, 59\}$, and $0$ otherwise.
The rational exponents $\Delta(n) = \frac{n^2 - 1}{120}$ satisfy:
$$-\Delta(n) - \frac{1}{120} = -\frac{n^2}{120} = CS(2, 3, 5; a, b, c)$$
for $n = a q r + b p r + c p q - p q r$.
-/

namespace BrieskornSU2

open BigOperators

/-! ### 1. Chern-Simons Invariant Definition -/

/-- Integer numerator for the Chern-Simons invariant:
    $N(p, q, r; a, b, c) = a q r + b p r + c p q - p q r$. -/
def chernSimonsNum (p q r a b c : ℕ) : ℤ :=
  (a * q * r + b * p * r + c * p * q : ℤ) - (p * q * r : ℤ)

/-- Exact rational Chern-Simons invariant of the flat $SU(2)$ connection corresponding
    to rotation parameters $(a, b, c)$ on the Brieskorn homology sphere $\Sigma(p, q, r)$:
    $$CS(p, q, r; a, b, c) = -\frac{(a q r + b p r + c p q - p q r)^2}{4 p q r} \in \mathbb{Q}$$ -/
def chernSimonsRat (p q r a b c : ℕ) : ℚ :=
  (- ((chernSimonsNum p q r a b c ^ 2 : ℤ) : ℚ)) / ((4 * p * q * r : ℕ) : ℚ)

/-- Reduced integer numerator modulo $4pqr$ in $[0, 4pqr - 1]$ for the Chern-Simons invariant. -/
def chernSimonsModInt (p q r a b c : ℕ) : ℤ :=
  let N := chernSimonsNum p q r a b c
  let M := (4 * p * q * r : ℤ)
  (- (N ^ 2)) % M

/-- Rational Chern-Simons invariant modulo 1, expressed with denominator $4pqr$. -/
def chernSimonsModOne (p q r a b c : ℕ) : ℚ :=
  ((chernSimonsModInt p q r a b c : ℚ)) / ((4 * p * q * r : ℕ) : ℚ)

/-! ### 2. Evaluation on Brieskorn Homology Spheres -/

/-! #### Explicit Characterizations of Representation Sets -/

/-- Explicit characterization of $\mathcal{R}^*(\Sigma(2, 3, 5))$. -/
theorem irredRepSet_2_3_5_eq : IrredSU2RepSet 2 3 5 = {(1, 1, 1), (1, 1, 3)} := rfl

/-- Explicit characterization of $\mathcal{R}^*(\Sigma(2, 3, 7))$. -/
theorem irredRepSet_2_3_7_eq : IrredSU2RepSet 2 3 7 = {(1, 1, 3), (1, 1, 5)} := rfl

/-- Explicit characterization of $\mathcal{R}^*(\Sigma(2, 3, 11))$. -/
theorem irredRepSet_2_3_11_eq : IrredSU2RepSet 2 3 11 = {(1, 1, 3), (1, 1, 5), (1, 1, 7), (1, 1, 9)} := rfl

/-- Explicit characterization of $\mathcal{R}^*(\Sigma(2, 5, 7))$. -/
theorem irredRepSet_2_5_7_eq : IrredSU2RepSet 2 5 7 = {(1, 1, 3), (1, 3, 1), (1, 3, 3), (1, 3, 5)} := rfl

/-! #### Poincaré Homology Sphere $\Sigma(2, 3, 5)$ -/

/-- For $\Sigma(2, 3, 5)$, the first representation $(1, 1, 1)$ has $CS = -1/120$. -/
theorem chernSimons_2_3_5_rep1 : chernSimonsRat 2 3 5 1 1 1 = -1 / 120 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 3, 5)$, the second representation $(1, 1, 3)$ has $CS = -169/120$. -/
theorem chernSimons_2_3_5_rep2 : chernSimonsRat 2 3 5 1 1 3 = -169 / 120 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- Decomposition of $CS(\Sigma(2,3,5); 1, 1, 3)$ as integer plus fractional part:
    $-169/120 = -1 - 49/120 \equiv -49/120 \pmod 1$. -/
theorem chernSimons_2_3_5_rep2_decomp :
    chernSimonsRat 2 3 5 1 1 3 = -1 + (-49 / 120) := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- Reduced integer numerator mod 120 for $(1, 1, 1)$ on $\Sigma(2, 3, 5)$ is 119. -/
theorem chernSimonsModInt_2_3_5_rep1 : chernSimonsModInt 2 3 5 1 1 1 = 119 := rfl

/-- Reduced integer numerator mod 120 for $(1, 1, 3)$ on $\Sigma(2, 3, 5)$ is 71 (equiv $-49 \pmod{120}$). -/
theorem chernSimonsModInt_2_3_5_rep2 : chernSimonsModInt 2 3 5 1 1 3 = 71 := rfl

/-- Modulo 1 rational Chern-Simons invariant for rep 1 on $\Sigma(2, 3, 5)$. -/
theorem chernSimonsModOne_2_3_5_rep1 : chernSimonsModOne 2 3 5 1 1 1 = 119 / 120 := rfl

/-- Modulo 1 rational Chern-Simons invariant for rep 2 on $\Sigma(2, 3, 5)$. -/
theorem chernSimonsModOne_2_3_5_rep2 : chernSimonsModOne 2 3 5 1 1 3 = 71 / 120 := rfl

/-! #### Brieskorn Sphere $\Sigma(2, 3, 7)$ -/

/-- For $\Sigma(2, 3, 7)$, the first representation $(1, 1, 3)$ has $CS = -121/168$. -/
theorem chernSimons_2_3_7_rep1 : chernSimonsRat 2 3 7 1 1 3 = -121 / 168 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 3, 7)$, the second representation $(1, 1, 5)$ has $CS = -529/168$. -/
theorem chernSimons_2_3_7_rep2 : chernSimonsRat 2 3 7 1 1 5 = -529 / 168 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- Decomposition of $CS(\Sigma(2,3,7); 1, 1, 5)$:
    $-529/168 = -3 - 25/168 \equiv -25/168 \pmod 1$. -/
theorem chernSimons_2_3_7_rep2_decomp :
    chernSimonsRat 2 3 7 1 1 5 = -3 + (-25 / 168) := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-! #### Brieskorn Sphere $\Sigma(2, 3, 11)$ -/

/-- For $\Sigma(2, 3, 11)$, representation $(1, 1, 3)$ has $CS = -49/264$. -/
theorem chernSimons_2_3_11_rep1 : chernSimonsRat 2 3 11 1 1 3 = -49 / 264 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 3, 11)$, representation $(1, 1, 5)$ has $CS = -361/264$. -/
theorem chernSimons_2_3_11_rep2 : chernSimonsRat 2 3 11 1 1 5 = -361 / 264 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 3, 11)$, representation $(1, 1, 7)$ has $CS = -961/264$. -/
theorem chernSimons_2_3_11_rep3 : chernSimonsRat 2 3 11 1 1 7 = -961 / 264 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 3, 11)$, representation $(1, 1, 9)$ has $CS = -1849/264$. -/
theorem chernSimons_2_3_11_rep4 : chernSimonsRat 2 3 11 1 1 9 = -1849 / 264 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-! #### Brieskorn Sphere $\Sigma(2, 5, 7)$ -/

/-- For $\Sigma(2, 5, 7)$, representation $(1, 1, 3)$ has $CS = -81/280$. -/
theorem chernSimons_2_5_7_rep1 : chernSimonsRat 2 5 7 1 1 3 = -81 / 280 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 5, 7)$, representation $(1, 3, 1)$ has $CS = -289/280$. -/
theorem chernSimons_2_5_7_rep2 : chernSimonsRat 2 5 7 1 3 1 = -289 / 280 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 5, 7)$, representation $(1, 3, 3)$ has $CS = -1369/280$. -/
theorem chernSimons_2_5_7_rep3 : chernSimonsRat 2 5 7 1 3 3 = -1369 / 280 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-- For $\Sigma(2, 5, 7)$, representation $(1, 3, 5)$ has $CS = -3249/280$. -/
theorem chernSimons_2_5_7_rep4 : chernSimonsRat 2 5 7 1 3 5 = -3249 / 280 := by
  norm_num [chernSimonsRat, chernSimonsNum]

/-! ### 3. Chern-Simons Sum / Stationary Phase Partition Function -/

/-- Discrete sum of rational Chern-Simons invariants over the irreducible $SU(2)$ character variety. -/
def chernSimonsSumRat (p q r : ℕ) : ℚ :=
  ∑ pt ∈ IrredSU2RepSet p q r, chernSimonsRat p q r pt.1 pt.2.1 pt.2.2

/-- Alias for discrete phase / stationary phase rational sum. -/
abbrev chernSimonsExpSumRat (p q r : ℕ) : ℚ :=
  chernSimonsSumRat p q r

/-- Total rational Chern-Simons sum for $\Sigma(2, 3, 5)$ is $-17/12$. -/
theorem chernSimonsSumRat_2_3_5 : chernSimonsSumRat 2 3 5 = -17 / 12 := by
  rw [chernSimonsSumRat, irredRepSet_2_3_5_eq, Finset.sum_pair (by decide)]
  norm_num [chernSimonsRat, chernSimonsNum]

/-- Total rational Chern-Simons sum for $\Sigma(2, 3, 7)$ is $-325/84$. -/
theorem chernSimonsSumRat_2_3_7 : chernSimonsSumRat 2 3 7 = -325 / 84 := by
  rw [chernSimonsSumRat, irredRepSet_2_3_7_eq, Finset.sum_pair (by decide)]
  norm_num [chernSimonsRat, chernSimonsNum]

/-- Total rational Chern-Simons sum for $\Sigma(2, 3, 11)$ is $-805/66$. -/
theorem chernSimonsSumRat_2_3_11 : chernSimonsSumRat 2 3 11 = -805 / 66 := by
  rw [chernSimonsSumRat, irredRepSet_2_3_11_eq,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_pair (by decide)]
  norm_num [chernSimonsRat, chernSimonsNum]

/-- Total rational Chern-Simons sum for $\Sigma(2, 5, 7)$ is $-1247/70$. -/
theorem chernSimonsSumRat_2_5_7 : chernSimonsSumRat 2 5 7 = -1247 / 70 := by
  rw [chernSimonsSumRat, irredRepSet_2_5_7_eq,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_pair (by decide)]
  norm_num [chernSimonsRat, chernSimonsNum]

/-! ### 4. Lawrence-Zagier False Theta Character $\chi_{120}$ and Exponents -/

/-- Lawrence-Zagier Dirichlet-type character $\chi_{120} : \mathbb{N} \to \mathbb{Z}$ of period 60/120:
    - $+1$ for $n \equiv 1, 11, 19, 29 \pmod{60}$
    - $-1$ for $n \equiv 31, 41, 49, 59 \pmod{60}$
    - $0$ otherwise. -/
def chi120 (n : ℕ) : ℤ :=
  let m := n % 60
  if m = 1 || m = 11 || m = 19 || m = 29 then 1
  else if m = 31 || m = 41 || m = 49 || m = 59 then -1
  else 0

/-- Periodicity of $\chi_{120}$ under shifts of 60. -/
theorem chi120_periodic_60 (n : ℕ) : chi120 (n + 60) = chi120 n := by
  dsimp [chi120]; rw [Nat.add_mod_right]

/-- Periodicity of $\chi_{120}$ under shifts of 120. -/
theorem chi120_periodic_120 (n : ℕ) : chi120 (n + 120) = chi120 n := by
  dsimp [chi120]; rw [show (n + 120) % 60 = n % 60 by omega]

/-- Reflection antisymmetry: $\chi_{120}(60 - n) = -\chi_{120}(n)$ for $1 \le n < 60$. -/
theorem chi120_neg (n : ℕ) (h1 : 1 ≤ n) (h2 : n < 60) : chi120 (60 - n) = - chi120 n := by
  interval_cases n <;> rfl

/-- Specific values of $\chi_{120}$ on positive residue classes. -/
theorem chi120_1 : chi120 1 = 1 := rfl
theorem chi120_11 : chi120 11 = 1 := rfl
theorem chi120_19 : chi120 19 = 1 := rfl
theorem chi120_29 : chi120 29 = 1 := rfl

/-- Specific values of $\chi_{120}$ on negative residue classes. -/
theorem chi120_31 : chi120 31 = -1 := rfl
theorem chi120_41 : chi120 41 = -1 := rfl
theorem chi120_49 : chi120 49 = -1 := rfl
theorem chi120_59 : chi120 59 = -1 := rfl

/-- Value at $n = 0$ is 0. -/
theorem chi120_0 : chi120 0 = 0 := rfl

/-! #### False Theta Rational Exponents -/

/-- Rational exponent $\Delta(n) = \frac{n^2 - 1}{120}$ in the Lawrence-Zagier false theta series
    $\widetilde{\psi}(q) = \sum_{n=1}^\infty \chi_{120}(n) q^{\frac{n^2-1}{120}}$. -/
def falseThetaExpRat (n : ℕ) : ℚ :=
  ((n ^ 2 : ℤ) - 1 : ℚ) / 120

/-- Exponent for $n = 1$: $(1^2 - 1)/120 = 0$. -/
theorem falseThetaExp_1 : falseThetaExpRat 1 = 0 := by
  norm_num [falseThetaExpRat]

/-- Exponent for $n = 11$: $(11^2 - 1)/120 = 120/120 = 1$. -/
theorem falseThetaExp_11 : falseThetaExpRat 11 = 1 := by
  norm_num [falseThetaExpRat]

/-- Exponent for $n = 13$: $(13^2 - 1)/120 = 168/120 = 7/5$. -/
theorem falseThetaExp_13 : falseThetaExpRat 13 = 7 / 5 := by
  norm_num [falseThetaExpRat]

/-- Exponent for $n = 19$: $(19^2 - 1)/120 = 360/120 = 3$. -/
theorem falseThetaExp_19 : falseThetaExpRat 19 = 3 := by
  norm_num [falseThetaExpRat]

/-- Exponent for $n = 29$: $(29^2 - 1)/120 = 840/120 = 7$. -/
theorem falseThetaExp_29 : falseThetaExpRat 29 = 7 := by
  norm_num [falseThetaExpRat]

/-- General algebraic relation between the false theta exponent $\Delta(n)$ and
    the quadratic form $-n^2/120$:
    $$-\Delta(n) - \frac{1}{120} = -\frac{n^2}{120}$$ -/
theorem cs_eq_falseThetaExp_rel (n : ℕ) :
    - falseThetaExpRat n - 1 / 120 = - ((n ^ 2 : ℤ) : ℚ) / 120 := by
  dsimp [falseThetaExpRat]; ring

/-- Exact match between Chern-Simons invariant of rep 1 on $\Sigma(2,3,5)$ and
    the false theta exponent at $n = 1$:
    $$CS(\Sigma(2,3,5); 1, 1, 1) = -\Delta(1) - \frac{1}{120} = -\frac{1}{120}$$ -/
theorem cs_2_3_5_rep1_falseTheta_match :
    chernSimonsRat 2 3 5 1 1 1 = - falseThetaExpRat 1 - 1 / 120 := by
  norm_num [chernSimonsRat, chernSimonsNum, falseThetaExpRat]

/-- Exact match between Chern-Simons invariant of rep 2 on $\Sigma(2,3,5)$ and
    the false theta exponent at $n = 13$:
    $$CS(\Sigma(2,3,5); 1, 1, 3) = -\Delta(13) - \frac{1}{120} = -\frac{7}{5} - \frac{1}{120} = -\frac{169}{120}$$ -/
theorem cs_2_3_5_rep2_falseTheta_match :
    chernSimonsRat 2 3 5 1 1 3 = - falseThetaExpRat 13 - 1 / 120 := by
  norm_num [chernSimonsRat, chernSimonsNum, falseThetaExpRat]

end BrieskornSU2
