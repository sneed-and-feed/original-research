import Formalization.PoincareDodecahedron.BinaryIcosahedral
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Inverse
import Mathlib.Topology.Algebra.InfiniteSum.Real
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic

noncomputable section

namespace PoincareDodecahedron

open scoped Quaternion Classical Real BigOperators
open Real

local notation "φ" => phi

/-- Chebyshev polynomials of the second kind $U_n(x)$ defined algebraically by recurrence:
$U_0(x) = 1$, $U_1(x) = 2x$, $U_{n+2}(x) = 2x U_{n+1}(x) - U_n(x)$. -/
def chebyshevU : ℕ → ℝ → ℝ
  | 0, _ => 1
  | 1, x => 2 * x
  | n + 2, x => 2 * x * chebyshevU (n + 1) x - chebyshevU n x

/-- Character $\chi_\ell$ evaluated on real parts $a = \operatorname{re}(u) \in [-1, 1]$
via the Chebyshev polynomial of the second kind: $\chi_\ell(a) = U_\ell(a)$. -/
def chi_re (l : ℕ) (a : ℝ) : ℝ :=
  chebyshevU l a

/-- Character $\chi_\ell : ℍ[ℝ]^\times \to ℝ$ of the irreducible $\mathrm{SU}(2)$
representation of degree $\ell \in \mathbb{N}$ (dimension $\ell + 1$). -/
def chi (l : ℕ) (u : ℍ[ℝ]ˣ) : ℝ :=
  chi_re l (u : ℍ[ℝ]).re

lemma chebyshevU_add_two (n : ℕ) (x : ℝ) :
    chebyshevU (n + 2) x = 2 * x * chebyshevU (n + 1) x - chebyshevU n x := rfl

lemma chi_re_add_two (n : ℕ) (x : ℝ) :
    chi_re (n + 2) x = 2 * x * chi_re (n + 1) x - chi_re n x := rfl

lemma chebyshevU_neg (l : ℕ) (x : ℝ) : chebyshevU l (-x) = (-1 : ℝ) ^ l * chebyshevU l x := by
  induction' l using Nat.strong_induction_on with n ih
  rcases n with _ | _ | n
  · simp [chebyshevU]
  · simp [chebyshevU]
  · rw [chebyshevU_add_two, chebyshevU_add_two, ih (n + 1) (by omega), ih n (by omega)]
    have h1 : (-1 : ℝ) ^ (n + 1) = -(-1 : ℝ) ^ n := by rw [pow_succ]; ring
    have h2 : (-1 : ℝ) ^ (n + 2) = (-1 : ℝ) ^ n := by rw [pow_succ, pow_succ]; ring
    rw [h1, h2]; ring

lemma chi_re_neg (l : ℕ) (x : ℝ) : chi_re l (-x) = (-1 : ℝ) ^ l * chi_re l x :=
  chebyshevU_neg l x

lemma chebyshevU_one_val (l : ℕ) : chebyshevU l 1 = (l + 1 : ℝ) := by
  induction' l using Nat.strong_induction_on with n ih
  rcases n with _ | _ | n
  · simp [chebyshevU]
  · norm_num [chebyshevU]
  · rw [chebyshevU_add_two, ih (n + 1) (by omega), ih n (by omega)]
    push_cast; ring

lemma chebyshevU_neg_one_val (l : ℕ) : chebyshevU l (-1) = (-1 : ℝ) ^ l * (l + 1 : ℝ) := by
  rw [chebyshevU_neg, chebyshevU_one_val]

lemma chi_one (l : ℕ) : chi l 1 = (l + 1 : ℝ) := by
  simp only [chi, chi_re]
  have : ((1 : ℍ[ℝ]ˣ) : ℍ[ℝ]).re = 1 := rfl
  rw [this, chebyshevU_one_val]

lemma chi_centralInv (l : ℕ) : chi l centralInv = (-1 : ℝ) ^ l * (l + 1 : ℝ) := by
  simp only [chi, chi_re]
  have : (centralInv : ℍ[ℝ]).re = -1 := rfl
  rw [this, chebyshevU_neg_one_val]

/-- The decomposition of the character sum over the binary icosahedral group into its 9 conjugacy classes. -/
def sum_chi_binaryIcosahedral (l : ℕ) : ℝ :=
  chi l 1 +
  chi l centralInv +
  30 * chi_re l 0 +
  20 * chi_re l (1 / 2) +
  20 * chi_re l (-1 / 2) +
  12 * chi_re l (phi / 2) +
  12 * chi_re l (-phi / 2) +
  12 * chi_re l (phi⁻¹ / 2) +
  12 * chi_re l (-phi⁻¹ / 2)

/-- Molien's character projection formula for the dimension of the $I^*$-invariant subspace
in the irreducible representation of degree $\ell$:
$$m_\ell = \frac{1}{120} \sum_{g \in I^*} \chi_\ell(g)$$ -/
def m (l : ℕ) : ℝ :=
  (1 / 120 : ℝ) * sum_chi_binaryIcosahedral l

/-- Golden ratio fundamental identity: $\phi - \phi^{-1} = 1$. -/
lemma phi_sub_phi_inv : phi - phi⁻¹ = 1 := by
  have h_inv : phi⁻¹ = phi - 1 := phi_inv
  linarith

/-! ### Character Evaluations at Conjugacy Classes for Degrees 0 to 12 -/

-- Degree 0
theorem chi_re_zero_0 : chi_re 0 0 = 1 := rfl
theorem chi_re_zero_half : chi_re 0 (1 / 2) = 1 := rfl
theorem chi_re_zero_neg_half : chi_re 0 (-1 / 2) = 1 := rfl
theorem chi_re_zero_phi_half : chi_re 0 (φ / 2) = 1 := rfl
theorem chi_re_zero_neg_phi_half : chi_re 0 (-φ / 2) = 1 := rfl
theorem chi_re_zero_phi_inv_half : chi_re 0 (φ⁻¹ / 2) = 1 := rfl
theorem chi_re_zero_neg_phi_inv_half : chi_re 0 (-φ⁻¹ / 2) = 1 := rfl

-- Degree 1
theorem chi_re_one_0 : chi_re 1 0 = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_one_half : chi_re 1 (1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_one_neg_half : chi_re 1 (-1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_one_phi_half : chi_re 1 (φ / 2) = φ := by simp [chi_re, chebyshevU]; ring
theorem chi_re_one_neg_phi_half : chi_re 1 (-φ / 2) = -φ := by rw [neg_div, chi_re_neg, chi_re_one_phi_half]; ring
theorem chi_re_one_phi_inv_half : chi_re 1 (φ⁻¹ / 2) = φ⁻¹ := by simp [chi_re, chebyshevU]; ring
theorem chi_re_one_neg_phi_inv_half : chi_re 1 (-φ⁻¹ / 2) = -φ⁻¹ := by rw [neg_div, chi_re_neg, chi_re_one_phi_inv_half]; ring

-- Degree 2
theorem chi_re_two_0 : chi_re 2 0 = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_two_half : chi_re 2 (1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_two_neg_half : chi_re 2 (-1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_two_phi_half : chi_re 2 (φ / 2) = φ := by
  rw [chi_re_add_two 0, chi_re_one_phi_half, chi_re_zero_phi_half]; linear_combination phi_sq
theorem chi_re_two_neg_phi_half : chi_re 2 (-φ / 2) = φ := by
  rw [neg_div, chi_re_neg, chi_re_two_phi_half]; ring
theorem chi_re_two_phi_inv_half : chi_re 2 (φ⁻¹ / 2) = -φ⁻¹ := by
  rw [chi_re_add_two 0, chi_re_one_phi_inv_half, chi_re_zero_phi_inv_half, phi_inv]; linear_combination phi_sq
theorem chi_re_two_neg_phi_inv_half : chi_re 2 (-φ⁻¹ / 2) = -φ⁻¹ := by
  rw [neg_div, chi_re_neg, chi_re_two_phi_inv_half]; ring

-- Degree 3
theorem chi_re_three_0 : chi_re 3 0 = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_three_half : chi_re 3 (1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_three_neg_half : chi_re 3 (-1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_three_phi_half : chi_re 3 (φ / 2) = 1 := by
  rw [chi_re_add_two 1, chi_re_two_phi_half, chi_re_one_phi_half]; linear_combination phi_sq
theorem chi_re_three_neg_phi_half : chi_re 3 (-φ / 2) = -1 := by
  rw [neg_div, chi_re_neg, chi_re_three_phi_half]; ring
theorem chi_re_three_phi_inv_half : chi_re 3 (φ⁻¹ / 2) = -1 := by
  rw [chi_re_add_two 1, chi_re_two_phi_inv_half, chi_re_one_phi_inv_half, phi_inv]; linear_combination -phi_sq
theorem chi_re_three_neg_phi_inv_half : chi_re 3 (-φ⁻¹ / 2) = 1 := by
  rw [neg_div, chi_re_neg, chi_re_three_phi_inv_half]; ring

-- Degree 4
theorem chi_re_four_0 : chi_re 4 0 = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_four_half : chi_re 4 (1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_four_neg_half : chi_re 4 (-1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_four_phi_half : chi_re 4 (φ / 2) = 0 := by
  rw [chi_re_add_two 2, chi_re_three_phi_half, chi_re_two_phi_half]; ring
theorem chi_re_four_neg_phi_half : chi_re 4 (-φ / 2) = 0 := by
  rw [neg_div, chi_re_neg, chi_re_four_phi_half]; ring
theorem chi_re_four_phi_inv_half : chi_re 4 (φ⁻¹ / 2) = 0 := by
  rw [chi_re_add_two 2, chi_re_three_phi_inv_half, chi_re_two_phi_inv_half]; ring
theorem chi_re_four_neg_phi_inv_half : chi_re 4 (-φ⁻¹ / 2) = 0 := by
  rw [neg_div, chi_re_neg, chi_re_four_phi_inv_half]; ring

-- Degree 5
theorem chi_re_five_0 : chi_re 5 0 = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_five_half : chi_re 5 (1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_five_neg_half : chi_re 5 (-1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_five_phi_half : chi_re 5 (φ / 2) = -1 := by
  rw [chi_re_add_two 3, chi_re_four_phi_half, chi_re_three_phi_half]; ring
theorem chi_re_five_neg_phi_half : chi_re 5 (-φ / 2) = 1 := by
  rw [neg_div, chi_re_neg, chi_re_five_phi_half]; ring
theorem chi_re_five_phi_inv_half : chi_re 5 (φ⁻¹ / 2) = 1 := by
  rw [chi_re_add_two 3, chi_re_four_phi_inv_half, chi_re_three_phi_inv_half]; ring
theorem chi_re_five_neg_phi_inv_half : chi_re 5 (-φ⁻¹ / 2) = -1 := by
  rw [neg_div, chi_re_neg, chi_re_five_phi_inv_half]; ring

-- Degree 6
theorem chi_re_six_0 : chi_re 6 0 = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_six_half : chi_re 6 (1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_six_neg_half : chi_re 6 (-1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_six_phi_half : chi_re 6 (φ / 2) = -φ := by
  rw [chi_re_add_two 4, chi_re_five_phi_half, chi_re_four_phi_half]; ring
theorem chi_re_six_neg_phi_half : chi_re 6 (-φ / 2) = -φ := by
  rw [neg_div, chi_re_neg, chi_re_six_phi_half]; ring
theorem chi_re_six_phi_inv_half : chi_re 6 (φ⁻¹ / 2) = φ⁻¹ := by
  rw [chi_re_add_two 4, chi_re_five_phi_inv_half, chi_re_four_phi_inv_half]; ring
theorem chi_re_six_neg_phi_inv_half : chi_re 6 (-φ⁻¹ / 2) = φ⁻¹ := by
  rw [neg_div, chi_re_neg, chi_re_six_phi_inv_half]; ring

-- Degree 7
theorem chi_re_seven_0 : chi_re 7 0 = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_seven_half : chi_re 7 (1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_seven_neg_half : chi_re 7 (-1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_seven_phi_half : chi_re 7 (φ / 2) = -φ := by
  rw [chi_re_add_two 5, chi_re_six_phi_half, chi_re_five_phi_half]; linear_combination -phi_sq
theorem chi_re_seven_neg_phi_half : chi_re 7 (-φ / 2) = φ := by
  rw [neg_div, chi_re_neg, chi_re_seven_phi_half]; ring
theorem chi_re_seven_phi_inv_half : chi_re 7 (φ⁻¹ / 2) = -φ⁻¹ := by
  rw [chi_re_add_two 5, chi_re_six_phi_inv_half, chi_re_five_phi_inv_half, phi_inv]; linear_combination phi_sq
theorem chi_re_seven_neg_phi_inv_half : chi_re 7 (-φ⁻¹ / 2) = φ⁻¹ := by
  rw [neg_div, chi_re_neg, chi_re_seven_phi_inv_half]; ring

-- Degree 8
theorem chi_re_eight_0 : chi_re 8 0 = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_eight_half : chi_re 8 (1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_eight_neg_half : chi_re 8 (-1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_eight_phi_half : chi_re 8 (φ / 2) = -1 := by
  rw [chi_re_add_two 6, chi_re_seven_phi_half, chi_re_six_phi_half]; linear_combination -phi_sq
theorem chi_re_eight_neg_phi_half : chi_re 8 (-φ / 2) = -1 := by
  rw [neg_div, chi_re_neg, chi_re_eight_phi_half]; ring
theorem chi_re_eight_phi_inv_half : chi_re 8 (φ⁻¹ / 2) = -1 := by
  rw [chi_re_add_two 6, chi_re_seven_phi_inv_half, chi_re_six_phi_inv_half, phi_inv]; linear_combination -phi_sq
theorem chi_re_eight_neg_phi_inv_half : chi_re 8 (-φ⁻¹ / 2) = -1 := by
  rw [neg_div, chi_re_neg, chi_re_eight_phi_inv_half]; ring

-- Degree 9
theorem chi_re_nine_0 : chi_re 9 0 = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_nine_half : chi_re 9 (1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_nine_neg_half : chi_re 9 (-1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_nine_phi_half : chi_re 9 (φ / 2) = 0 := by
  rw [chi_re_add_two 7, chi_re_eight_phi_half, chi_re_seven_phi_half]; ring
theorem chi_re_nine_neg_phi_half : chi_re 9 (-φ / 2) = 0 := by
  rw [neg_div, chi_re_neg, chi_re_nine_phi_half]; ring
theorem chi_re_nine_phi_inv_half : chi_re 9 (φ⁻¹ / 2) = 0 := by
  rw [chi_re_add_two 7, chi_re_eight_phi_inv_half, chi_re_seven_phi_inv_half]; ring
theorem chi_re_nine_neg_phi_inv_half : chi_re 9 (-φ⁻¹ / 2) = 0 := by
  rw [neg_div, chi_re_neg, chi_re_nine_phi_inv_half]; ring

-- Degree 10
theorem chi_re_ten_0 : chi_re 10 0 = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_ten_half : chi_re 10 (1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_ten_neg_half : chi_re 10 (-1 / 2) = -1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_ten_phi_half : chi_re 10 (φ / 2) = 1 := by
  rw [chi_re_add_two 8, chi_re_nine_phi_half, chi_re_eight_phi_half]; ring
theorem chi_re_ten_neg_phi_half : chi_re 10 (-φ / 2) = 1 := by
  rw [neg_div, chi_re_neg, chi_re_ten_phi_half]; ring
theorem chi_re_ten_phi_inv_half : chi_re 10 (φ⁻¹ / 2) = 1 := by
  rw [chi_re_add_two 8, chi_re_nine_phi_inv_half, chi_re_eight_phi_inv_half]; ring
theorem chi_re_ten_neg_phi_inv_half : chi_re 10 (-φ⁻¹ / 2) = 1 := by
  rw [neg_div, chi_re_neg, chi_re_ten_phi_inv_half]; ring

-- Degree 11
theorem chi_re_eleven_0 : chi_re 11 0 = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_eleven_half : chi_re 11 (1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_eleven_neg_half : chi_re 11 (-1 / 2) = 0 := by norm_num [chi_re, chebyshevU]
theorem chi_re_eleven_phi_half : chi_re 11 (φ / 2) = φ := by
  rw [chi_re_add_two 9, chi_re_ten_phi_half, chi_re_nine_phi_half]; ring
theorem chi_re_eleven_neg_phi_half : chi_re 11 (-φ / 2) = -φ := by
  rw [neg_div, chi_re_neg, chi_re_eleven_phi_half]; ring
theorem chi_re_eleven_phi_inv_half : chi_re 11 (φ⁻¹ / 2) = φ⁻¹ := by
  rw [chi_re_add_two 9, chi_re_ten_phi_inv_half, chi_re_nine_phi_inv_half]; ring
theorem chi_re_eleven_neg_phi_inv_half : chi_re 11 (-φ⁻¹ / 2) = -φ⁻¹ := by
  rw [neg_div, chi_re_neg, chi_re_eleven_phi_inv_half]; ring

-- Degree 12
theorem chi_re_twelve_0 : chi_re 12 0 = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_twelve_half : chi_re 12 (1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_twelve_neg_half : chi_re 12 (-1 / 2) = 1 := by norm_num [chi_re, chebyshevU]
theorem chi_re_twelve_phi_half : chi_re 12 (φ / 2) = φ := by
  rw [chi_re_add_two 10, chi_re_eleven_phi_half, chi_re_ten_phi_half]; linear_combination phi_sq
theorem chi_re_twelve_neg_phi_half : chi_re 12 (-φ / 2) = φ := by
  rw [neg_div, chi_re_neg, chi_re_twelve_phi_half]; ring
theorem chi_re_twelve_phi_inv_half : chi_re 12 (φ⁻¹ / 2) = -φ⁻¹ := by
  rw [chi_re_add_two 10, chi_re_eleven_phi_inv_half, chi_re_ten_phi_inv_half, phi_inv]; linear_combination phi_sq
theorem chi_re_twelve_neg_phi_inv_half : chi_re 12 (-φ⁻¹ / 2) = -φ⁻¹ := by
  rw [neg_div, chi_re_neg, chi_re_twelve_phi_inv_half]; ring

/-! ### Proofs of Multiplicities $m_\ell$ for $\ell \in [0, 12]$ -/

/-- $m_0 = 1$: The trivial representation is invariant under $I^*$. -/
theorem m_zero : m 0 = 1 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_zero_0, chi_re_zero_half, chi_re_zero_neg_half,
    chi_re_zero_phi_half, chi_re_zero_neg_phi_half, chi_re_zero_phi_inv_half, chi_re_zero_neg_phi_inv_half]
  ring

/-- $m_1 = 0$: No spin-1/2 invariants in $I^*$. -/
theorem m_one : m 1 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_one_0, chi_re_one_half, chi_re_one_neg_half,
    chi_re_one_phi_half, chi_re_one_neg_phi_half, chi_re_one_phi_inv_half, chi_re_one_neg_phi_inv_half]
  ring

/-- $m_2 = 0$: No spin-1 (vector) invariants in $I^*$. -/
theorem m_two : m 2 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_two_0, chi_re_two_half, chi_re_two_neg_half,
    chi_re_two_phi_half, chi_re_two_neg_phi_half, chi_re_two_phi_inv_half, chi_re_two_neg_phi_inv_half]
  linear_combination (24 / 120 : ℝ) * phi_sub_phi_inv

/-- $m_3 = 0$: No spin-3/2 invariants in $I^*$. -/
theorem m_three : m 3 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_three_0, chi_re_three_half, chi_re_three_neg_half,
    chi_re_three_phi_half, chi_re_three_neg_phi_half, chi_re_three_phi_inv_half, chi_re_three_neg_phi_inv_half]
  ring

/-- $m_4 = 0$: No spin-2 invariants in $I^*$. -/
theorem m_four : m 4 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_four_0, chi_re_four_half, chi_re_four_neg_half,
    chi_re_four_phi_half, chi_re_four_neg_phi_half, chi_re_four_phi_inv_half, chi_re_four_neg_phi_inv_half]
  ring

/-- $m_5 = 0$: No spin-5/2 invariants in $I^*$. -/
theorem m_five : m 5 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_five_0, chi_re_five_half, chi_re_five_neg_half,
    chi_re_five_phi_half, chi_re_five_neg_phi_half, chi_re_five_phi_inv_half, chi_re_five_neg_phi_inv_half]
  ring

/-- $m_6 = 0$: In the $\mathrm{SU}(2)$ representation of degree 6 (dimension 7), there are no $I^*$-invariants. -/
theorem m_six : m 6 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_six_0, chi_re_six_half, chi_re_six_neg_half,
    chi_re_six_phi_half, chi_re_six_neg_phi_half, chi_re_six_phi_inv_half, chi_re_six_neg_phi_inv_half]
  linear_combination (-24 / 120 : ℝ) * phi_sub_phi_inv

/-- $m_7 = 0$: No spin-7/2 invariants in $I^*$. -/
theorem m_seven : m 7 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_seven_0, chi_re_seven_half, chi_re_seven_neg_half,
    chi_re_seven_phi_half, chi_re_seven_neg_phi_half, chi_re_seven_phi_inv_half, chi_re_seven_neg_phi_inv_half]
  ring

/-- $m_8 = 0$: No spin-4 invariants in $I^*$. -/
theorem m_eight : m 8 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_eight_0, chi_re_eight_half, chi_re_eight_neg_half,
    chi_re_eight_phi_half, chi_re_eight_neg_phi_half, chi_re_eight_phi_inv_half, chi_re_eight_neg_phi_inv_half]
  ring

/-- $m_9 = 0$: No spin-9/2 invariants in $I^*$. -/
theorem m_nine : m 9 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_nine_0, chi_re_nine_half, chi_re_nine_neg_half,
    chi_re_nine_phi_half, chi_re_nine_neg_phi_half, chi_re_nine_phi_inv_half, chi_re_nine_neg_phi_inv_half]
  ring

/-- $m_{10} = 0$: No spin-5 invariants in $I^*$. -/
theorem m_ten : m 10 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_ten_0, chi_re_ten_half, chi_re_ten_neg_half,
    chi_re_ten_phi_half, chi_re_ten_neg_phi_half, chi_re_ten_phi_inv_half, chi_re_ten_neg_phi_inv_half]
  ring

/-- $m_{11} = 0$: No spin-11/2 invariants in $I^*$. -/
theorem m_eleven : m 11 = 0 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_eleven_0, chi_re_eleven_half, chi_re_eleven_neg_half,
    chi_re_eleven_phi_half, chi_re_eleven_neg_phi_half, chi_re_eleven_phi_inv_half, chi_re_eleven_neg_phi_inv_half]
  ring

/-- $m_{12} = 1$: The first non-trivial icosahedral invariant in $\mathrm{SU}(2)$ occurs at degree 12
(dimension 13), corresponding to Klein's degree 6 icosahedral harmonic invariant on $S^2$. -/
theorem m_twelve : m 12 = 1 := by
  unfold m sum_chi_binaryIcosahedral
  rw [chi_one, chi_centralInv, chi_re_twelve_0, chi_re_twelve_half, chi_re_twelve_neg_half,
    chi_re_twelve_phi_half, chi_re_twelve_neg_phi_half, chi_re_twelve_phi_inv_half, chi_re_twelve_neg_phi_inv_half]
  linear_combination (24 / 120 : ℝ) * phi_sub_phi_inv

/-! ### $\mathrm{SO}(3)$ Invariant Multiplicities $m^{\mathrm{SO}(3)}_L$ -/

/-- Invariant subspace multiplicity for the $\mathrm{SO}(3)$ irreducible representation of degree $L$
(dimension $2L + 1$), corresponding to $\mathrm{SU}(2)$ degree $2L$. -/
def m_SO3 (L : ℕ) : ℝ := m (2 * L)

theorem m_SO3_zero : m_SO3 0 = 1 := m_zero

theorem m_SO3_one : m_SO3 1 = 0 := m_two

theorem m_SO3_two : m_SO3 2 = 0 := m_four

theorem m_SO3_three : m_SO3 3 = 0 := m_six

theorem m_SO3_four : m_SO3 4 = 0 := m_eight

theorem m_SO3_five : m_SO3 5 = 0 := m_ten

/-- Klein's icosahedral invariant: $m^{\mathrm{SO}(3)}_6 = 1$. The first non-trivial icosahedral
spherical harmonic on $S^2 \cong \mathrm{SO}(3)/\mathrm{SO}(2)$ occurs at multipole $L = 6$. -/
theorem m_SO3_six : m_SO3 6 = 1 := m_twelve

/-! ### Laplacian Eigenvalues and Heat Kernel Trace on $S^3 / I^*$ -/

/-- Eigenvalue $\lambda_\ell = \ell(\ell + 2)$ of the Laplace-Beltrami operator on $S^3$. -/
def laplacianEigenvalue (l : ℕ) : ℝ :=
  (l : ℝ) * ((l : ℝ) + 2)

lemma laplacianEigenvalue_zero : laplacianEigenvalue 0 = 0 := by
  simp [laplacianEigenvalue]

lemma laplacianEigenvalue_twelve : laplacianEigenvalue 12 = 168 := by
  simp [laplacianEigenvalue]
  norm_num

/-- Heat trace summand for degree $\ell$: $m_\ell (\ell + 1) e^{-t \ell(\ell + 2)}$. -/
def heatTraceTerm (t : ℝ) (l : ℕ) : ℝ :=
  m l * ((l : ℝ) + 1) * Real.exp (-t * laplacianEigenvalue l)

/-- Heat kernel trace on Poincaré Dodecahedral Space $S^3 / I^*$:
$$Z(t) = \sum_{\ell = 0}^\infty m_\ell (\ell + 1) e^{-t \ell (\ell + 2)}$$ -/
def heatTrace (t : ℝ) : ℝ :=
  ∑' l : ℕ, heatTraceTerm t l

lemma heatTraceTerm_zero (t : ℝ) : heatTraceTerm t 0 = 1 := by
  simp [heatTraceTerm, m_zero, laplacianEigenvalue]

lemma heatTraceTerm_one (t : ℝ) : heatTraceTerm t 1 = 0 := by simp [heatTraceTerm, m_one]
lemma heatTraceTerm_two (t : ℝ) : heatTraceTerm t 2 = 0 := by simp [heatTraceTerm, m_two]
lemma heatTraceTerm_three (t : ℝ) : heatTraceTerm t 3 = 0 := by simp [heatTraceTerm, m_three]
lemma heatTraceTerm_four (t : ℝ) : heatTraceTerm t 4 = 0 := by simp [heatTraceTerm, m_four]
lemma heatTraceTerm_five (t : ℝ) : heatTraceTerm t 5 = 0 := by simp [heatTraceTerm, m_five]
lemma heatTraceTerm_six (t : ℝ) : heatTraceTerm t 6 = 0 := by simp [heatTraceTerm, m_six]
lemma heatTraceTerm_seven (t : ℝ) : heatTraceTerm t 7 = 0 := by simp [heatTraceTerm, m_seven]
lemma heatTraceTerm_eight (t : ℝ) : heatTraceTerm t 8 = 0 := by simp [heatTraceTerm, m_eight]
lemma heatTraceTerm_nine (t : ℝ) : heatTraceTerm t 9 = 0 := by simp [heatTraceTerm, m_nine]
lemma heatTraceTerm_ten (t : ℝ) : heatTraceTerm t 10 = 0 := by simp [heatTraceTerm, m_ten]
lemma heatTraceTerm_eleven (t : ℝ) : heatTraceTerm t 11 = 0 := by simp [heatTraceTerm, m_eleven]

lemma heatTraceTerm_twelve (t : ℝ) :
    heatTraceTerm t 12 = 13 * Real.exp (-168 * t) := by
  simp only [heatTraceTerm, m_twelve, laplacianEigenvalue_twelve]
  ring_nf

/-! ### 5. Weyl-Molien High-Degree Asymptotics & Spectral Multiplicity Density -/

/-- The leading linear growth density for representation-theoretic $I^*$-invariant multiplicities on $\mathrm{SU}(2)$:
$$\overline{m}_\ell^{\mathrm{SU}(2)} = \frac{\ell}{120}$$ -/
def weyl_molien_invariant_density (l : ℕ) : ℝ :=
  (l : ℝ) / 120

/-- The leading quadratic growth density for the total spatial Laplacian eigenfunction multiplicity on $S^3 / I^*$:
$$\overline{d}_\ell = \overline{m}_\ell (\ell + 1) \sim \frac{\ell^2}{120}$$ -/
def laplacian_spectral_density_leading (l : ℕ) : ℝ :=
  (l : ℝ) ^ 2 / 120

/-- Non-negativity of the linear invariant multiplicity density. -/
lemma weyl_molien_invariant_density_nonneg (l : ℕ) : weyl_molien_invariant_density l ≥ 0 := by
  unfold weyl_molien_invariant_density
  positivity

/-- Non-negativity of the quadratic Laplacian spectral density. -/
lemma laplacian_spectral_density_leading_nonneg (l : ℕ) : laplacian_spectral_density_leading l ≥ 0 := by
  unfold laplacian_spectral_density_leading
  positivity

/-- Explicit values of the linear invariant density at landmark degrees $\ell = 12, 60, 120$. -/
theorem weyl_molien_landmark_values :
    weyl_molien_invariant_density 12 = 1 / 10 ∧
    weyl_molien_invariant_density 60 = 1 / 2 ∧
    weyl_molien_invariant_density 120 = 1 := by
  unfold weyl_molien_invariant_density
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- Explicit values of the quadratic Laplacian spectral density at landmark degrees $\ell = 12, 60, 120$. -/
theorem laplacian_spectral_density_landmark_values :
    laplacian_spectral_density_leading 12 = 6 / 5 ∧
    laplacian_spectral_density_leading 60 = 30 ∧
    laplacian_spectral_density_leading 120 = 120 := by
  unfold laplacian_spectral_density_leading
  refine ⟨by norm_num, by norm_num, by norm_num⟩

end PoincareDodecahedron
