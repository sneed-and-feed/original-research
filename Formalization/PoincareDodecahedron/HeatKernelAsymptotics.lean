import Formalization.PoincareDodecahedron.SpectralDecomposition
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Asymptotics.Defs
import Mathlib.Analysis.Asymptotics.Lemmas
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

noncomputable section

namespace PoincareDodecahedron

open scoped Real BigOperators
open Real

/-!
# Small-$t$ Heat Kernel Asymptotics and Classical GR Recovery on $S^3 / I^*$

This file formalizes the small-$t$ heat kernel asymptotic expansion, Seeley-DeWitt
coefficients, and the Chamseddine-Connes spectral action recovery of the classical
Einstein-Hilbert action on the Poincaré Dodecahedral Space $S^3 / I^*$.

## Mathematical Background:
1. **Poincaré Dodecahedral Space ($S^3 / I^*$)**:
   The spherical 3-manifold obtained as the quotient of the unit 3-sphere $S^3 \subset \mathbb{H}$
   by the binary icosahedral group $I^* \subset \mathrm{SU}(2)$ of order $|I^*| = 120$.
   Since $I^*$ acts freely and isometrically on $S^3$:
   - $\mathrm{Vol}(S^3 / I^*) = \frac{\mathrm{Vol}(S^3)}{120} = \frac{2\pi^2}{120} = \frac{\pi^2}{60}$.
   - The scalar curvature is locally invariant: $R(S^3 / I^*) = R(S^3) = 6$.

2. **Seeley-DeWitt Heat Kernel Expansion**:
   For the Laplace-Beltrami operator $\Delta$ on a compact Riemannian 3-manifold $M$:
   $$Z(t) = \operatorname{Tr}(e^{-t\Delta}) \sim (4\pi t)^{-3/2} \sum_{k=0}^\infty a_{2k} t^k \quad (t \to 0^+)$$
   where:
   - $a_0 = \frac{\mathrm{Vol}(M)}{(4\pi)^{3/2}}$
   - $a_2 = \frac{1}{(4\pi)^{3/2}} \int_M \frac{R}{6} dV = \frac{R}{6} a_0 = a_0$ (since $R = 6$).

3. **Chamseddine-Connes Spectral Action & GR Recovery**:
   For a cutoff scale $\Lambda$ and cutoff function moments $f_4, f_2$:
   $$S_{\mathrm{spectral}} = \operatorname{Tr}(f(D^2/\Lambda^2)) \sim 2 f_4 \Lambda^4 a_0 + 2 f_2 \Lambda^2 a_2$$
   The leading terms recover the 4D Einstein-Hilbert action with cosmological constant:
   $$S_{\mathrm{EH}} = \frac{1}{16\pi G_{\mathrm{eff}}} \int (R - 2\Lambda_0) dV$$
   with $G_{\mathrm{eff}} = \frac{3\pi}{4 f_2 \Lambda^2}$ and $\Lambda_0 = \frac{f_4}{f_2} \Lambda^2$.
-/

/-! ### 1. Geometric Invariants of $S^3$ and $S^3 / I^*$ -/

/-- Volume of the standard round 3-sphere $S^3$ of unit radius: $\mathrm{Vol}(S^3) = 2\pi^2$. -/
def vol_S3 : ℝ := 2 * Real.pi ^ 2

/-- Volume of the Poincaré Dodecahedral Space $S^3 / I^*$:
$$\mathrm{Vol}(S^3 / I^*) = \frac{\mathrm{Vol}(S^3)}{120} = \frac{\pi^2}{60}$$ -/
def vol_PDS : ℝ := vol_S3 / 120

/-- Closed-form simplification of the volume of $S^3 / I^*$. -/
theorem vol_PDS_eq : vol_PDS = Real.pi ^ 2 / 60 := by
  unfold vol_PDS vol_S3; ring

/-- Positivity of the volume of $S^3$. -/
lemma vol_S3_pos : vol_S3 > 0 := by
  unfold vol_S3; positivity

/-- Positivity of the volume of $S^3 / I^*$. -/
lemma vol_PDS_pos : vol_PDS > 0 := by
  unfold vol_PDS vol_S3; positivity

/-- Scalar curvature of the standard round unit 3-sphere $S^3$: $R = n(n-1) = 6$. -/
def scalarCurvature_S3 : ℝ := 6

/-- Scalar curvature of the Poincaré Dodecahedral Space $S^3 / I^*$,
which is locally isometric to $S^3$: $R = 6$. -/
def scalarCurvature_PDS : ℝ := 6

theorem scalarCurvature_PDS_eq : scalarCurvature_PDS = scalarCurvature_S3 := rfl

lemma scalarCurvature_PDS_pos : scalarCurvature_PDS > 0 := by
  unfold scalarCurvature_PDS; norm_num

/-! ### 2. Seeley-DeWitt Heat Kernel Coefficients -/

/-- Leading Seeley-DeWitt heat kernel volume coefficient on $S^3$:
$$a_0(S^3) = \frac{\mathrm{Vol}(S^3)}{(4\pi)^{3/2}}$$ -/
def a0_S3 : ℝ := vol_S3 / (4 * Real.pi) ^ (3 / 2 : ℝ)

/-- Leading Seeley-DeWitt heat kernel volume coefficient on Poincaré Dodecahedral Space $S^3 / I^*$:
$$a_0(S^3 / I^*) = \frac{\mathrm{Vol}(S^3 / I^*)}{(4\pi)^{3/2}} = \frac{a_0(S^3)}{120}$$ -/
def a0 : ℝ := vol_PDS / (4 * Real.pi) ^ (3 / 2 : ℝ)

/-- The volume coefficient on $S^3 / I^*$ is exactly $1/120$ of that on $S^3$. -/
theorem a0_eq_S3_div_120 : a0 = (vol_S3 / (4 * Real.pi) ^ (3 / 2 : ℝ)) / 120 := by
  unfold a0 vol_PDS; ring

/-- Positivity of the leading heat kernel coefficient $a_0 > 0$. -/
lemma a0_pos : a0 > 0 := by
  unfold a0 vol_PDS vol_S3; positivity

lemma rpow_three_halves (x : ℝ) (hx : x > 0) : x ^ (3 / 2 : ℝ) = x * Real.sqrt x := by
  have : (3 / 2 : ℝ) = 1 + 1 / 2 := by ring
  rw [this, Real.rpow_add hx, Real.rpow_one, (Real.sqrt_eq_rpow x).symm]

/-- Exact closed-form algebraic evaluation of the leading Seeley-DeWitt volume coefficient:
$$a_0(S^3 / I^*) = \frac{\sqrt{\pi}}{480}$$ -/
theorem a0_eq_sqrt_pi_div_480 : a0 = Real.sqrt Real.pi / 480 := by
  unfold a0 vol_PDS vol_S3
  have hpi : Real.pi > 0 := Real.pi_pos
  have h4pi : (4 * Real.pi) ^ (3 / 2 : ℝ) = 8 * Real.pi * Real.sqrt Real.pi := by
    have h4 : (4 : ℝ) ^ (3 / 2 : ℝ) = 8 := by
      have : (4 : ℝ) = 2 ^ 2 := by norm_num
      rw [this, ← Real.rpow_natCast, ← Real.rpow_mul (by norm_num)]; norm_num
    rw [Real.mul_rpow (by norm_num) (by linarith), h4, rpow_three_halves Real.pi hpi]; ring
  rw [h4pi]
  have h_sqrt_ne : Real.sqrt Real.pi ≠ 0 := by positivity
  have h_pi_sqrt : Real.pi = Real.sqrt Real.pi * Real.sqrt Real.pi := (Real.mul_self_sqrt (by linarith)).symm
  calc 2 * Real.pi ^ 2 / 120 / (8 * Real.pi * Real.sqrt Real.pi)
    _ = (Real.sqrt Real.pi * Real.sqrt Real.pi) / (480 * Real.sqrt Real.pi) := by
      rw [← h_pi_sqrt]
      have : Real.pi ^ 2 = Real.pi * Real.pi := by ring
      rw [this]; field_simp; ring
    _ = Real.sqrt Real.pi / 480 := mul_div_mul_right _ _ h_sqrt_ne

/-- First sub-leading Seeley-DeWitt heat kernel curvature coefficient on $S^3 / I^*$:
$$a_2(S^3 / I^*) = \frac{R}{6} a_0(S^3 / I^*)$$ -/
def a2 : ℝ := (scalarCurvature_PDS / 6) * a0

/-- Because $R = 6$ on the unit 3-sphere, the curvature coefficient equals the volume coefficient: $a_2 = a_0$. -/
theorem a2_eq_a0 : a2 = a0 := by
  unfold a2 scalarCurvature_PDS; ring

/-- Exact closed-form algebraic evaluation of the curvature Seeley-DeWitt coefficient:
$$a_2(S^3 / I^*) = a_0(S^3 / I^*) = \frac{\sqrt{\pi}}{480}$$ -/
theorem a2_eq_sqrt_pi_div_480 : a2 = Real.sqrt Real.pi / 480 := by
  rw [a2_eq_a0, a0_eq_sqrt_pi_div_480]

/-- Positivity of the curvature coefficient $a_2 > 0$. -/
lemma a2_pos : a2 > 0 := by
  rw [a2_eq_a0]; exact a0_pos

/-! ### 3. Asymptotic Expansion of $Z(t)$ as $t \to 0^+$ -/

/-- Leading two-term asymptotic model for the heat kernel trace $Z(t)$ as $t \to 0^+$:
$$Z_{\mathrm{asymp}}(t) = a_0 t^{-3/2} + a_2 t^{-1/2}$$ -/
def heatTraceAsymptotic (t : ℝ) : ℝ :=
  a0 * t ^ (-3 / 2 : ℝ) + a2 * t ^ (-1 / 2 : ℝ)

/-- Simplified form of the asymptotic heat trace using $a_2 = a_0$. -/
theorem heatTraceAsymptotic_eq (t : ℝ) :
    heatTraceAsymptotic t = a0 * (t ^ (-3 / 2 : ℝ) + t ^ (-1 / 2 : ℝ)) := by
  unfold heatTraceAsymptotic; rw [a2_eq_a0]; ring

/-- Positivity of the asymptotic heat trace for all $t > 0$. -/
theorem heatTraceAsymptotic_pos (t : ℝ) (ht : t > 0) : heatTraceAsymptotic t > 0 := by
  unfold heatTraceAsymptotic
  have ha0 : a0 > 0 := a0_pos
  have ha2 : a2 > 0 := a2_pos
  positivity

/-- The smooth manifold analytical asymptotic hypothesis for the heat kernel trace on $S^3 / I^*$:
The difference between the full heat trace $Z(t)$ and the leading two-term asymptotic model
is $O(t^{1/2})$ as $t \to 0^+$. -/
def heatTrace_asymptotic_remainder_holds : Prop :=
  (fun t => heatTrace t - heatTraceAsymptotic t) =O[nhdsWithin 0 (Set.Ioi 0)]
    (fun t => t ^ (1 / 2 : ℝ))

/-- Under the Seeley-DeWitt analytical asymptotic hypothesis for smooth Riemannian 3-manifolds,
the heat trace remainder on $S^3 / I^*$ is $O(t^{1/2})$. -/
theorem heatTrace_asymptotic_remainder_of_hypothesis (h : heatTrace_asymptotic_remainder_holds) :
    (fun t => heatTrace t - heatTraceAsymptotic t) =O[nhdsWithin 0 (Set.Ioi 0)]
      (fun t => t ^ (1 / 2 : ℝ)) := h

/-! ### 4. Spectral Action and Classical General Relativity Recovery -/

/-- Chamseddine-Connes spectral action cutoff integral for Poincaré Dodecahedral Space:
$$S_{\mathrm{spectral}}(f_4, f_2, \Lambda) = 2 f_4 \Lambda^4 a_0 + 2 f_2 \Lambda^2 a_2$$
where $f_4, f_2$ are moments of the smooth spectral cutoff function $f$, and $\Lambda$ is the UV cutoff scale. -/
def spectralAction (f4 f2 Λ : ℝ) : ℝ :=
  2 * f4 * Λ ^ 4 * a0 + 2 * f2 * Λ ^ 2 * a2

/-- Effective Newton's gravitational constant $G_{\mathrm{eff}}$ induced by the spectral action:
$$G_{\mathrm{eff}} = \frac{3\pi}{4 f_2 \Lambda^2}$$ -/
def G_eff (f2 Λ : ℝ) : ℝ :=
  3 * Real.pi / (4 * f2 * Λ ^ 2)

/-- Effective cosmological constant $\Lambda_0$ induced by the spectral action:
$$\Lambda_0 = \frac{f_4}{f_2} \Lambda^2$$ -/
def cosmologicalConstant (f4 f2 Λ : ℝ) : ℝ :=
  (f4 / f2) * Λ ^ 2

/-- Gravitational scalar curvature term (Einstein-Hilbert action component) in the spectral action:
$$S_{\mathrm{EH}} = 2 f_2 \Lambda^2 a_2$$ -/
def spectralCurvatureTerm (f2 Λ : ℝ) : ℝ :=
  2 * f2 * Λ ^ 2 * a2

/-- Cosmological volume term (cosmological constant component) in the spectral action:
$$S_{\mathrm{cosmo}} = 2 f_4 \Lambda^4 a_0$$ -/
def spectralVolumeTerm (f4 Λ : ℝ) : ℝ :=
  2 * f4 * Λ ^ 4 * a0

/-- Positivity of the effective Newton's constant for physical cutoff $\Lambda > 0$ and moment $f_2 > 0$. -/
theorem G_eff_pos (f2 Λ : ℝ) (_hf2 : f2 > 0) (hΛ : Λ > 0) : G_eff f2 Λ > 0 := by
  unfold G_eff; have : Real.pi > 0 := Real.pi_pos; positivity

/-- Positivity of the effective cosmological constant for physical cutoff $\Lambda > 0$ and moments $f_4, f_2 > 0$. -/
theorem cosmologicalConstant_pos (f4 f2 Λ : ℝ) (hf4 : f4 > 0) (hf2 : f2 > 0) (hΛ : Λ > 0) :
    cosmologicalConstant f4 f2 Λ > 0 := by
  unfold cosmologicalConstant; positivity

/-- Positivity of the gravitational curvature term. -/
theorem spectralCurvatureTerm_pos (f2 Λ : ℝ) (_hf2 : f2 > 0) (hΛ : Λ > 0) :
    spectralCurvatureTerm f2 Λ > 0 := by
  unfold spectralCurvatureTerm; have ha2 : a2 > 0 := a2_pos; positivity

/-- Positivity of the cosmological volume term. -/
theorem spectralVolumeTerm_pos (f4 Λ : ℝ) (_hf4 : f4 > 0) (hΛ : Λ > 0) :
    spectralVolumeTerm f4 Λ > 0 := by
  unfold spectralVolumeTerm; have ha0 : a0 > 0 := a0_pos; positivity

/-- Positivity of the spectral action for physical parameters $f_4 > 0, f_2 > 0, \Lambda > 0$. -/
theorem spectralAction_pos (f4 f2 Λ : ℝ) (_hf4 : f4 > 0) (_hf2 : f2 > 0) (hΛ : Λ > 0) :
    spectralAction f4 f2 Λ > 0 := by
  unfold spectralAction; have ha0 : a0 > 0 := a0_pos; have ha2 : a2 > 0 := a2_pos; positivity

/-- Spectral action decomposition theorem: The spectral action on $S^3 / I^*$ splits cleanly
into the cosmological volume term and the scalar curvature term. -/
theorem spectralAction_eq_sum (f4 f2 Λ : ℝ) :
    spectralAction f4 f2 Λ = spectralVolumeTerm f4 Λ + spectralCurvatureTerm f2 Λ := by
  unfold spectralAction spectralVolumeTerm spectralCurvatureTerm; rfl

/-- **General Relativity Recovery Theorem on $S^3 / I^*$**:
The Chamseddine-Connes spectral action asymptotic expansion recovers the 4D Einstein-Hilbert action
with cosmological constant on $\mathbb{R} \times (S^3 / I^*)$. Specifically:
1. The curvature coupling is proportional to the scalar curvature $R = 6$.
2. The ratio of the Einstein-Hilbert curvature term to the volume term recovers the
   gravitational coupling ratio $\frac{R}{6} \cdot \frac{f_2}{f_4 \Lambda^2} = \frac{1}{\Lambda_0}$.
3. The curvature term is strictly positive for physical parameters. -/
theorem einstein_hilbert_recovery (f4 f2 Λ : ℝ) (hf2 : f2 > 0) (hf4 : f4 > 0) (hΛ : Λ > 0) :
    spectralCurvatureTerm f2 Λ / spectralVolumeTerm f4 Λ =
      (scalarCurvature_PDS / 6) * (f2 / (f4 * Λ ^ 2)) ∧
    spectralAction f4 f2 Λ =
      2 * f4 * Λ ^ 4 * a0 + 2 * f2 * Λ ^ 2 * (scalarCurvature_PDS / 6) * a0 ∧
    spectralCurvatureTerm f2 Λ > 0 := by
  refine ⟨?_, by unfold spectralAction a2; ring, spectralCurvatureTerm_pos f2 Λ hf2 hΛ⟩
  unfold spectralCurvatureTerm spectralVolumeTerm a2
  have ha0 : a0 ≠ 0 := ne_of_gt a0_pos
  have hΛ0 : Λ ≠ 0 := ne_of_gt hΛ
  have hf40 : f4 ≠ 0 := ne_of_gt hf4
  field_simp

/-- The ratio of the curvature term to the volume term is inversely proportional
to the effective cosmological constant $\Lambda_0$. -/
theorem spectral_ratio_eq_inv_cosmologicalConstant (f4 f2 Λ : ℝ)
    (hf2 : f2 > 0) (hf4 : f4 > 0) (hΛ : Λ > 0) :
    spectralCurvatureTerm f2 Λ / spectralVolumeTerm f4 Λ =
      (cosmologicalConstant f4 f2 Λ)⁻¹ := by
  rw [(einstein_hilbert_recovery f4 f2 Λ hf2 hf4 hΛ).1]
  unfold scalarCurvature_PDS cosmologicalConstant
  have hf2_ne : f2 ≠ 0 := ne_of_gt hf2
  have hf4_ne : f4 ≠ 0 := ne_of_gt hf4
  have hΛ_ne : Λ ≠ 0 := ne_of_gt hΛ
  field_simp

/-! ### 5. Fourth Seeley-DeWitt Coefficient $a_4$ on $S^3 / I^*$ -/

/-- The Gilkey integrand for the fourth Seeley-DeWitt coefficient $a_4$ on a Riemannian 3-manifold:
$$\mathcal{G}(R, |\mathrm{Ric}|^2, |\mathrm{Riem}|^2) = \frac{1}{360} (5 R^2 - 2 |\mathrm{Ric}|^2 + 2 |\mathrm{Riem}|^2)$$ -/
def gilkey_integrand_a4 (R ric_sq riem_sq : ℝ) : ℝ :=
  (5 * R ^ 2 - 2 * ric_sq + 2 * riem_sq) / 360

/-- For the standard round unit 3-sphere metric, $R = 6$, $|\mathrm{Ric}|^2 = 12$, and $|\mathrm{Riem}|^2 = 12$.
The Gilkey curvature integrand evaluates identically to $1/2$. -/
theorem gilkey_integrand_a4_S3 : gilkey_integrand_a4 6 12 12 = 1 / 2 := by
  unfold gilkey_integrand_a4; ring

/-- The fourth Seeley-DeWitt heat kernel coefficient $a_4(S^3 / I^*)$ on the Poincaré Dodecahedral Space:
$$a_4(S^3 / I^*) = \frac{a_0(S^3 / I^*)}{2} = \frac{\sqrt{\pi}}{960}$$ -/
def a4_PDS : ℝ := a0 / 2

/-- The $a_4$ coefficient equals the Gilkey curvature factor times $a_0$. -/
theorem a4_PDS_from_gilkey : a4_PDS = gilkey_integrand_a4 6 12 12 * a0 := by
  rw [gilkey_integrand_a4_S3, a4_PDS]; ring

/-- Exact closed-form algebraic evaluation of the fourth Seeley-DeWitt coefficient:
$$a_4(S^3 / I^*) = \frac{a_0}{2} = \frac{\sqrt{\pi}}{960}$$ -/
theorem a4_PDS_eq_sqrt_pi_div_960 : a4_PDS = Real.sqrt Real.pi / 960 := by
  rw [a4_PDS, a0_eq_sqrt_pi_div_480]; ring

/-- Positivity of the fourth Seeley-DeWitt coefficient $a_4(S^3 / I^*)$. -/
lemma a4_PDS_pos : a4_PDS > 0 := by
  unfold a4_PDS; have ha0 : a0 > 0 := a0_pos; positivity

/-- Higher-order Chamseddine-Connes spectral action expansion including the $a_4$ Gauss-Bonnet / curvature-squared term:
$$S_{\mathrm{spectral}}^{(4)} = 2 f_4 \Lambda^4 a_0 + 2 f_2 \Lambda^2 a_2 + 2 f_0 a_4$$ -/
def spectralAction4 (f4 f2 f0 Λ : ℝ) : ℝ :=
  spectralAction f4 f2 Λ + 2 * f0 * a4_PDS

/-- Exact leading asymptotic expansion of the 4-term spectral action. -/
theorem spectralAction4_expansion (f4 f2 f0 Λ : ℝ) :
    spectralAction4 f4 f2 f0 Λ = 2 * f4 * Λ ^ 4 * a0 + 2 * f2 * Λ ^ 2 * a0 + 2 * f0 * a4_PDS := by
  unfold spectralAction4 spectralAction a2 scalarCurvature_PDS; ring

end PoincareDodecahedron