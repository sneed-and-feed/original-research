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
  · rw [chebyshevU_add_two, chebyshevU_add_two, ih (n + 1) (by omega), ih n (by omega),
      pow_succ (-1 : ℝ) (n + 1), pow_succ (-1 : ℝ) n]
    ring

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

lemma chi_one (l : ℕ) : chi l 1 = (l + 1 : ℝ) :=
  chebyshevU_one_val l

lemma chi_centralInv (l : ℕ) : chi l centralInv = (-1 : ℝ) ^ l * (l + 1 : ℝ) :=
  chebyshevU_neg_one_val l

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
  have : phi⁻¹ = phi - 1 := phi_inv
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
  norm_num [laplacianEigenvalue]

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
  unfold heatTraceTerm
  rw [m_twelve, laplacianEigenvalue_twelve]
  have : -t * 168 = -168 * t := by ring
  rw [this]
  norm_num

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
    weyl_molien_invariant_density 120 = 1 :=
  ⟨by norm_num [weyl_molien_invariant_density],
   by norm_num [weyl_molien_invariant_density],
   by norm_num [weyl_molien_invariant_density]⟩

/-- Explicit values of the quadratic Laplacian spectral density at landmark degrees $\ell = 12, 60, 120$. -/
theorem laplacian_spectral_density_landmark_values :
    laplacian_spectral_density_leading 12 = 6 / 5 ∧
    laplacian_spectral_density_leading 60 = 30 ∧
    laplacian_spectral_density_leading 120 = 120 :=
  ⟨by norm_num [laplacian_spectral_density_leading],
   by norm_num [laplacian_spectral_density_leading],
   by norm_num [laplacian_spectral_density_leading]⟩

/-! ### 6. Off-Diagonal Mode Couplings and Parity Selection Rules on $S^3 / I^*$ -/

/-- The decomposition of the character product sum $\sum_{g \in I^*} \chi_{l_1}(g) \chi_{l_2}(g)$
over the 9 conjugacy classes of the binary icosahedral group $I^*$. -/
def sum_chi_product_binaryIcosahedral (l₁ l₂ : ℕ) : ℝ :=
  chi l₁ 1 * chi l₂ 1 +
  chi l₁ centralInv * chi l₂ centralInv +
  30 * (chi_re l₁ 0 * chi_re l₂ 0) +
  20 * (chi_re l₁ (1 / 2) * chi_re l₂ (1 / 2)) +
  20 * (chi_re l₁ (-1 / 2) * chi_re l₂ (-1 / 2)) +
  12 * (chi_re l₁ (phi / 2) * chi_re l₂ (phi / 2)) +
  12 * (chi_re l₁ (-phi / 2) * chi_re l₂ (-phi / 2)) +
  12 * (chi_re l₁ (phi⁻¹ / 2) * chi_re l₂ (phi⁻¹ / 2)) +
  12 * (chi_re l₁ (-phi⁻¹ / 2) * chi_re l₂ (-phi⁻¹ / 2))

/-- Mode coupling / projection overlap between $\mathrm{SU}(2)$ representations of degrees $\ell_1$ and $\ell_2$
under the icosahedral projection on $S^3 / I^*$:
$$C(\ell_1, \ell_2) = \frac{1}{120} \sum_{g \in I^*} \chi_{\ell_1}(g) \chi_{\ell_2}(g)$$ -/
def mode_coupling (l₁ l₂ : ℕ) : ℝ :=
  (1 / 120 : ℝ) * sum_chi_product_binaryIcosahedral l₁ l₂

/-- Off-diagonal mode coupling between representations of degrees $\ell_1$ and $\ell_2$ on $S^3 / I^*$. -/
def off_diagonal_coupling (l₁ l₂ : ℕ) : ℝ :=
  mode_coupling l₁ l₂

/-- Off-diagonal mode coupling for $\mathrm{SO}(3)$ multipoles $L_1$ and $L_2$ on $S^3 / I^*$,
corresponding to $\mathrm{SU}(2)$ representations of degrees $2 L_1$ and $2 L_2$. -/
def off_diagonal_coupling_SO3 (L₁ L₂ : ℕ) : ℝ :=
  off_diagonal_coupling (2 * L₁) (2 * L₂)

/-- Commutativity / symmetry of the mode coupling matrix: $C(\ell_1, \ell_2) = C(\ell_2, \ell_1)$. -/
theorem mode_coupling_comm (l₁ l₂ : ℕ) : mode_coupling l₁ l₂ = mode_coupling l₂ l₁ := by
  unfold mode_coupling sum_chi_product_binaryIcosahedral
  ring

/-- Commutativity of off-diagonal couplings. -/
theorem off_diagonal_coupling_comm (l₁ l₂ : ℕ) :
    off_diagonal_coupling l₁ l₂ = off_diagonal_coupling l₂ l₁ :=
  mode_coupling_comm l₁ l₂

/-- Sign of $(-1)^n$ for odd $n$. -/
lemma neg_one_pow_odd {n : ℕ} (h : n % 2 = 1) : (-1 : ℝ) ^ n = -1 :=
  (Nat.odd_iff.2 h).neg_one_pow

/-- Sign of $(-1)^n$ for even $n$. -/
lemma neg_one_pow_even {n : ℕ} (h : n % 2 = 0) : (-1 : ℝ) ^ n = 1 :=
  (Nat.even_iff.2 h).neg_one_pow

/-- Sign of $(-1)^{L + L'}$ when $L$ and $L'$ have opposite parities ($L \not\equiv L' \pmod 2$). -/
lemma neg_one_pow_of_ne_mod {L L' : ℕ} (h : L % 2 ≠ L' % 2) : (-1 : ℝ) ^ (L + L') = -1 :=
  neg_one_pow_odd (by omega)

/-- The character evaluated at real part $0$ vanishes for all odd degrees $\ell$. -/
lemma chi_re_zero_of_odd (l : ℕ) (h : l % 2 = 1) : chi_re l 0 = 0 := by
  have := chi_re_neg l 0
  rw [neg_zero, neg_one_pow_odd h] at this
  linarith

/-- The product of characters at real part $0$ vanishes whenever degrees have opposite parity. -/
lemma chi_re_zero_mul_of_ne_mod {L L' : ℕ} (h : L % 2 ≠ L' % 2) :
    chi_re L 0 * chi_re L' 0 = 0 := by
  rcases show L % 2 = 1 ∨ L' % 2 = 1 by omega with hL | hL <;> simp [chi_re_zero_of_odd _ hL]

/-- Pairwise cancellation of conjugate character evaluations on $x$ and $-x$ under opposite parity. -/
lemma chi_re_neg_pair_cancel (L L' : ℕ) (x : ℝ) (h : L % 2 ≠ L' % 2) :
    chi_re L x * chi_re L' x + chi_re L (-x) * chi_re L' (-x) = 0 := by
  rw [chi_re_neg, chi_re_neg]
  have : ((-1 : ℝ) ^ L * chi_re L x) * ((-1 : ℝ) ^ L' * chi_re L' x) =
      (-1 : ℝ) ^ (L + L') * (chi_re L x * chi_re L' x) := by
    rw [pow_add]; ring
  rw [this, neg_one_pow_of_ne_mod h]
  ring

/-- Cancellation of identity and central inversion character product contributions under opposite parity. -/
lemma chi_centralInv_pair_cancel (L L' : ℕ) (h : L % 2 ≠ L' % 2) :
    chi L 1 * chi L' 1 + chi L centralInv * chi L' centralInv = 0 := by
  rw [chi_one, chi_one, chi_centralInv, chi_centralInv]
  have : (((-1 : ℝ) ^ L * (L + 1 : ℝ)) * ((-1 : ℝ) ^ L' * (L' + 1 : ℝ))) =
      (-1 : ℝ) ^ (L + L') * ((L + 1 : ℝ) * (L' + 1 : ℝ)) := by
    rw [pow_add]; ring
  rw [this, neg_one_pow_of_ne_mod h]
  ring

/-- **Character Product Vanishing Theorem**:
The character product sum over the binary icosahedral group $I^*$ vanishes identically
whenever $L \not\equiv L' \pmod 2$. -/
theorem sum_chi_product_binaryIcosahedral_odd_sum (L L' : ℕ) (h : L % 2 ≠ L' % 2) :
    sum_chi_product_binaryIcosahedral L L' = 0 := by
  unfold sum_chi_product_binaryIcosahedral
  have h1 := chi_centralInv_pair_cancel L L' h
  have h0 := chi_re_zero_mul_of_ne_mod h
  have h_half := chi_re_neg_pair_cancel L L' (1 / 2) h
  have h_phi := chi_re_neg_pair_cancel L L' (phi / 2) h
  have h_phi_inv := chi_re_neg_pair_cancel L L' (phi⁻¹ / 2) h
  have h_neg_half : - (1 / 2 : ℝ) = -1 / 2 := by ring
  have h_neg_phi : - (phi / 2) = -phi / 2 := by ring
  have h_neg_phi_inv : - (phi⁻¹ / 2) = -phi⁻¹ / 2 := by ring
  rw [← h_neg_half, ← h_neg_phi, ← h_neg_phi_inv]
  linear_combination h1 + 30 * h0 + 20 * h_half + 12 * h_phi + 12 * h_phi_inv

/-- **Parity Selection Rule for Off-Diagonal Mode Couplings on $S^3 / I^*$**:
Two representations $L$ and $L'$ have zero coupling under the icosahedral projection
whenever they have opposite parity ($L \not\equiv L' \pmod 2$). -/
theorem parity_selection_rule (L L' : ℕ) (h : L % 2 ≠ L' % 2) :
    off_diagonal_coupling L L' = 0 := by
  unfold off_diagonal_coupling mode_coupling
  rw [sum_chi_product_binaryIcosahedral_odd_sum L L' h]
  ring

/-- Quadratic golden ratio identity: $\phi^2 + (\phi^{-1})^2 = 3$. -/
lemma phi_sq_add_phi_inv_sq : phi ^ 2 + (phi⁻¹)^2 = 3 := by
  rw [phi_inv]
  linear_combination 2 * phi_sq

/-- Coupling with the trivial representation $\ell = 0$ reduces to the invariant multiplicity $m_\ell$. -/
theorem off_diagonal_coupling_zero_left (l : ℕ) :
    off_diagonal_coupling 0 l = m l := by
  unfold off_diagonal_coupling mode_coupling m sum_chi_product_binaryIcosahedral sum_chi_binaryIcosahedral
  simp only [chi_one, Nat.cast_zero, zero_add, mul_one, chi_centralInv, pow_zero,
    chi_re_zero_0, one_mul, chi_re_zero_half, chi_re_zero_neg_half,
    chi_re_zero_phi_half, chi_re_zero_neg_phi_half, chi_re_zero_phi_inv_half, chi_re_zero_neg_phi_inv_half]

/-- Coupling with the trivial representation on the right reduces to the invariant multiplicity $m_\ell$. -/
theorem off_diagonal_coupling_zero_right (l : ℕ) :
    off_diagonal_coupling l 0 = m l := by
  rw [off_diagonal_coupling_comm, off_diagonal_coupling_zero_left]

/-! ### Explicit Orthogonality for Low Multipole Cross-Terms -/

/-- Explicit parity orthogonality: $C(1, 2) = 0$. -/
theorem coupling_one_two : off_diagonal_coupling 1 2 = 0 :=
  parity_selection_rule 1 2 (by decide)

/-- Explicit parity orthogonality: $C(2, 3) = 0$. -/
theorem coupling_two_three : off_diagonal_coupling 2 3 = 0 :=
  parity_selection_rule 2 3 (by decide)

/-- Explicit parity orthogonality: $C(0, 1) = 0$. -/
theorem coupling_zero_one : off_diagonal_coupling 0 1 = 0 :=
  parity_selection_rule 0 1 (by decide)

/-- Explicit parity orthogonality: $C(0, 3) = 0$. -/
theorem coupling_zero_three : off_diagonal_coupling 0 3 = 0 :=
  parity_selection_rule 0 3 (by decide)

/-- Explicit parity orthogonality: $C(1, 4) = 0$. -/
theorem coupling_one_four : off_diagonal_coupling 1 4 = 0 :=
  parity_selection_rule 1 4 (by decide)

/-- Explicit parity orthogonality: $C(3, 4) = 0$. -/
theorem coupling_three_four : off_diagonal_coupling 3 4 = 0 :=
  parity_selection_rule 3 4 (by decide)

/-- Explicit parity orthogonality: $C(2, 5) = 0$. -/
theorem coupling_two_five : off_diagonal_coupling 2 5 = 0 :=
  parity_selection_rule 2 5 (by decide)

/-- Explicit parity orthogonality: $C(4, 5) = 0$. -/
theorem coupling_four_five : off_diagonal_coupling 4 5 = 0 :=
  parity_selection_rule 4 5 (by decide)

/-- Explicit parity orthogonality: $C(5, 6) = 0$. -/
theorem coupling_five_six : off_diagonal_coupling 5 6 = 0 :=
  parity_selection_rule 5 6 (by decide)

/-- Orthogonality of even cross-term $C(0, 2) = 0$. -/
theorem coupling_zero_two : off_diagonal_coupling 0 2 = 0 :=
  (off_diagonal_coupling_zero_left 2).trans m_two

/-- Orthogonality of even cross-term $C(0, 4) = 0$. -/
theorem coupling_zero_four : off_diagonal_coupling 0 4 = 0 :=
  (off_diagonal_coupling_zero_left 4).trans m_four

/-- Orthogonality of even cross-term $C(0, 6) = 0$. -/
theorem coupling_zero_six : off_diagonal_coupling 0 6 = 0 :=
  (off_diagonal_coupling_zero_left 6).trans m_six

/-- Orthogonality of even cross-term $C(0, 8) = 0$. -/
theorem coupling_zero_eight : off_diagonal_coupling 0 8 = 0 :=
  (off_diagonal_coupling_zero_left 8).trans m_eight

/-- Orthogonality of even cross-term $C(0, 10) = 0$. -/
theorem coupling_zero_ten : off_diagonal_coupling 0 10 = 0 :=
  (off_diagonal_coupling_zero_left 10).trans m_ten

/-- Orthogonality of even cross-term $C(1, 3) = 0$. -/
theorem coupling_one_three : off_diagonal_coupling 1 3 = 0 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 1, chi_one 3, chi_centralInv 1, chi_centralInv 3,
    chi_re_one_0, chi_re_three_0,
    chi_re_one_half, chi_re_three_half,
    chi_re_one_neg_half, chi_re_three_neg_half,
    chi_re_one_phi_half, chi_re_three_phi_half,
    chi_re_one_neg_phi_half, chi_re_three_neg_phi_half,
    chi_re_one_phi_inv_half, chi_re_three_phi_inv_half,
    chi_re_one_neg_phi_inv_half, chi_re_three_neg_phi_inv_half]
  linear_combination (24 / 120 : ℝ) * phi_sub_phi_inv

/-- Orthogonality of even cross-term $C(2, 4) = 0$. -/
theorem coupling_two_four : off_diagonal_coupling 2 4 = 0 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 2, chi_one 4, chi_centralInv 2, chi_centralInv 4,
    chi_re_two_0, chi_re_four_0,
    chi_re_two_half, chi_re_four_half,
    chi_re_two_neg_half, chi_re_four_neg_half,
    chi_re_two_phi_half, chi_re_four_phi_half,
    chi_re_two_neg_phi_half, chi_re_four_neg_phi_half,
    chi_re_two_phi_inv_half, chi_re_four_phi_inv_half,
    chi_re_two_neg_phi_inv_half, chi_re_four_neg_phi_inv_half]
  ring

/-- Orthogonality of even cross-term $C(2, 6) = 0$. -/
theorem coupling_two_six : off_diagonal_coupling 2 6 = 0 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 2, chi_one 6, chi_centralInv 2, chi_centralInv 6,
    chi_re_two_0, chi_re_six_0,
    chi_re_two_half, chi_re_six_half,
    chi_re_two_neg_half, chi_re_six_neg_half,
    chi_re_two_phi_half, chi_re_six_phi_half,
    chi_re_two_neg_phi_half, chi_re_six_neg_phi_half,
    chi_re_two_phi_inv_half, chi_re_six_phi_inv_half,
    chi_re_two_neg_phi_inv_half, chi_re_six_neg_phi_inv_half]
  linear_combination (-24 / 120 : ℝ) * phi_sq_add_phi_inv_sq

/-- Orthogonality of even cross-term $C(4, 6) = 0$. -/
theorem coupling_four_six : off_diagonal_coupling 4 6 = 0 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 4, chi_one 6, chi_centralInv 4, chi_centralInv 6,
    chi_re_four_0, chi_re_six_0,
    chi_re_four_half, chi_re_six_half,
    chi_re_four_neg_half, chi_re_six_neg_half,
    chi_re_four_phi_half, chi_re_six_phi_half,
    chi_re_four_neg_phi_half, chi_re_six_neg_phi_half,
    chi_re_four_phi_inv_half, chi_re_six_phi_inv_half,
    chi_re_four_neg_phi_inv_half, chi_re_six_neg_phi_inv_half]
  ring

/-- Diagonal normalization: $C(0, 0) = 1$. -/
theorem coupling_zero_zero : off_diagonal_coupling 0 0 = 1 :=
  (off_diagonal_coupling_zero_left 0).trans m_zero

/-- Diagonal normalization: $C(1, 1) = 1$ (2D spinor representation of $I^*$ is irreducible). -/
theorem coupling_one_one : off_diagonal_coupling 1 1 = 1 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 1, chi_centralInv 1,
    chi_re_one_0, chi_re_one_half, chi_re_one_neg_half,
    chi_re_one_phi_half, chi_re_one_neg_phi_half,
    chi_re_one_phi_inv_half, chi_re_one_neg_phi_inv_half]
  linear_combination (24 / 120 : ℝ) * phi_sq_add_phi_inv_sq

/-- Diagonal normalization: $C(2, 2) = 1$ (3D vector representation of $I^*$ is irreducible). -/
theorem coupling_two_two : off_diagonal_coupling 2 2 = 1 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 2, chi_centralInv 2,
    chi_re_two_0, chi_re_two_half, chi_re_two_neg_half,
    chi_re_two_phi_half, chi_re_two_neg_phi_half,
    chi_re_two_phi_inv_half, chi_re_two_neg_phi_inv_half]
  linear_combination (24 / 120 : ℝ) * phi_sq_add_phi_inv_sq

/-- Diagonal normalization: $C(4, 4) = 1$ (5D representation of $I^*$ is irreducible). -/
theorem coupling_four_four : off_diagonal_coupling 4 4 = 1 := by
  unfold off_diagonal_coupling mode_coupling sum_chi_product_binaryIcosahedral
  rw [chi_one 4, chi_centralInv 4,
    chi_re_four_0, chi_re_four_half, chi_re_four_neg_half,
    chi_re_four_phi_half, chi_re_four_neg_phi_half,
    chi_re_four_phi_inv_half, chi_re_four_neg_phi_inv_half]
  ring

/-- Non-trivial invariant pairing at degree 12: $C(0, 12) = 1$. -/
theorem coupling_zero_twelve : off_diagonal_coupling 0 12 = 1 :=
  (off_diagonal_coupling_zero_left 12).trans m_twelve

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(0, 1) = 0$. -/
theorem coupling_SO3_zero_one : off_diagonal_coupling_SO3 0 1 = 0 := coupling_zero_two

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(0, 2) = 0$. -/
theorem coupling_SO3_zero_two : off_diagonal_coupling_SO3 0 2 = 0 := coupling_zero_four

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(0, 3) = 0$. -/
theorem coupling_SO3_zero_three : off_diagonal_coupling_SO3 0 3 = 0 := coupling_zero_six

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(0, 4) = 0$. -/
theorem coupling_SO3_zero_four : off_diagonal_coupling_SO3 0 4 = 0 := coupling_zero_eight

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(0, 5) = 0$. -/
theorem coupling_SO3_zero_five : off_diagonal_coupling_SO3 0 5 = 0 := coupling_zero_ten

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(1, 2) = 0$. -/
theorem coupling_SO3_one_two : off_diagonal_coupling_SO3 1 2 = 0 := coupling_two_four

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(1, 3) = 0$. -/
theorem coupling_SO3_one_three : off_diagonal_coupling_SO3 1 3 = 0 := coupling_two_six

/-- $\mathrm{SO}(3)$ multipole orthogonality: $C^{\mathrm{SO}(3)}(2, 3) = 0$. -/
theorem coupling_SO3_two_three : off_diagonal_coupling_SO3 2 3 = 0 := coupling_four_six

/-- First non-trivial $\mathrm{SO}(3)$ icosahedral mode coupling: $C^{\mathrm{SO}(3)}(0, 6) = 1$. -/
theorem coupling_SO3_zero_six : off_diagonal_coupling_SO3 0 6 = 1 := coupling_zero_twelve

end PoincareDodecahedron
