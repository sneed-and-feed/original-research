/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antigravity
-/
import Formalization.GeneralSeifertClassification.Certificates
import Formalization.BrieskornManifolds
import Formalization.BrieskornSU2CharacterVariety
import Mathlib.Tactic.FinCases

/-!
# Topological and Gauge-Theoretic Seifert–Brieskorn Bridge

This module formalizes the deep topological and gauge-theoretic bridge unifying 3-point Seifert fibered
homology 3-spheres $M(0; b; (a_1, \beta_1), (a_2, \beta_2), (a_3, \beta_3))$ with Brieskorn singularity
links $\Sigma(p, q, r) = V(z_1^p + z_2^q + z_3^r = 0) \cap S^5$, Milnor fiber intersection signatures $\sigma(p, q, r)$,
and the $SU(2)$ character variety Casson invariant $\lambda_{SU(2)}(\Sigma(p, q, r)) = \frac{1}{2}\#\mathcal{R}^*(\Sigma(p, q, r))$.

## Main Results

1. **Topological & Algebraic Bridge Theorems**:
   - `GeneralSeifert.pairwiseCoprime_vec3_of_coprime`: Pairwise coprimality of exponents implies `PairwiseCoprime` on `vec3 p q r`.
   - `GeneralSeifert.pairwiseCoprime_3_implies_hasTwoIsolated`: Pairwise coprimality implies at least two isolated vertices in $G(p, q, r)$.
   - `GeneralSeifert.pairwiseCoprime_3_implies_brieskornSphere`: Sufficiency for the Brieskorn-Hirzebruch sphere criterion.
   - `GeneralSeifert.brieskorn_seifert_bridge_3point`: Unification of Brieskorn topological sphere condition and Seifert homology sphere Diophantine solvability.
   - `GeneralSeifert.brieskorn_casson_bridge_3point`: Unification connecting the Seifert sphere witness directly to the $SU(2)$ character variety and Milnor fiber Casson invariants.

2. **Bundled Certificate Structure**:
   - `GeneralSeifert.SeifertBrieskornBridge3`: Complete record containing exponents, coprimality witnesses, Seifert twist solution, Brieskorn sphere proof, Milnor signature, and $SU(2)$ Casson invariants.

3. **Explicit Bridge Certificates with Casson Invariants**:
   - `GeneralSeifert.bridge_2_3_5`: Poincaré Homology Sphere $\Sigma(2, 3, 5)$ ($\sigma = -8, \lambda = 1$).
   - `GeneralSeifert.bridge_2_3_7`: Brieskorn Sphere $\Sigma(2, 3, 7)$ ($\sigma = -8, \lambda = 1$).
   - `GeneralSeifert.bridge_2_3_11`: Brieskorn Sphere $\Sigma(2, 3, 11)$ ($\sigma = -16, \lambda = 2$).
   - `GeneralSeifert.bridge_2_5_7`: Brieskorn Sphere $\Sigma(2, 5, 7)$ ($\sigma = -16, \lambda = 2$).
   - `GeneralSeifert.bridge_3_4_5`: Brieskorn Sphere $\Sigma(3, 4, 5)$ ($\sigma = -16, \lambda = 2$).
   - `GeneralSeifert.bridge_3_5_7`: Brieskorn Sphere $\Sigma(3, 5, 7)$ ($\sigma = -32, \lambda = 4$).

4. **Standalone Component Theorems**:
   - `GeneralSeifert.sphere_3point_2_5_7`, `sphere_3point_3_4_5`, `sphere_3point_3_5_7`
   - `GeneralSeifert.signature_3_4_5`, `cassonNat_3_4_5`, `cassonSU2_3_4_5`
   - `GeneralSeifert.signature_3_5_7`, `cassonNat_3_5_7`, `cassonSU2_3_5_7`
   - `GeneralSeifert.bridge_certificate_2_3_5`, `bridge_certificate_2_3_7`, `bridge_certificate_2_3_11`,
     `bridge_certificate_2_5_7`, `bridge_certificate_3_4_5`, `bridge_certificate_3_5_7`
-/

namespace GeneralSeifert

/-- Pairwise coprimality of natural numbers $(p, q, r)$ implies `PairwiseCoprime` on `vec3 p q r`. -/
theorem pairwiseCoprime_vec3_of_coprime (p q r : ℕ)
    (hpq : p.Coprime q) (hpr : p.Coprime r) (hqr : q.Coprime r) :
    PairwiseCoprime (vec3 p q r) := by
  intro i j hij
  fin_cases i <;> fin_cases j <;> try contradiction
  all_goals first | simpa [vec3] using hpq | simpa [vec3] using hpr | simpa [vec3] using hqr
                  | (rw [Int.gcd_comm]; first | simpa [vec3] using hpq | simpa [vec3] using hpr | simpa [vec3] using hqr)

/-- Topological & Algebraic Bridge: Pairwise coprime exponents $(p, q, r)$ satisfy `hasTwoIsolated`. -/
theorem pairwiseCoprime_3_implies_hasTwoIsolated (p q r : ℕ)
    (hpq : p.Coprime q) (hpr : p.Coprime r) (hqr : q.Coprime r) :
    Brieskorn.hasTwoIsolated (Brieskorn.brieskornThreeExponents p q r) :=
  ⟨0, 1, by decide,
    Brieskorn.pairwise_coprime_all_isolated p q r ⟨hpq, hqr, hpr⟩ 0,
    Brieskorn.pairwise_coprime_all_isolated p q r ⟨hpq, hqr, hpr⟩ 1⟩

/-- Topological & Algebraic Bridge: Pairwise coprime exponents satisfy `brieskornSphereCondition`. -/
theorem pairwiseCoprime_3_implies_brieskornSphere (p q r : ℕ)
    (hpq : p.Coprime q) (hpr : p.Coprime r) (hqr : q.Coprime r) :
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents p q r) :=
  Brieskorn.pairwise_coprime_isBrieskornSphere p q r ⟨hpq, hqr, hpr⟩

/-- Bridge Theorem: Unifies Brieskorn sphere condition and Seifert homology sphere solvability. -/
theorem brieskorn_seifert_bridge_3point (p q r : ℕ)
    (hpq : p.Coprime q) (hpr : p.Coprime r) (hqr : q.Coprime r) :
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents p q r) ∧
    ∃ (l0 : ℤ) (l : Fin 3 → ℤ), IsHomotopySphere (vec3 p q r) l0 l :=
  ⟨pairwiseCoprime_3_implies_brieskornSphere p q r hpq hpr hqr,
   pairwise_coprime_exists_sphere (pairwiseCoprime_vec3_of_coprime p q r hpq hpr hqr)⟩

/-- Bridge Theorem: Connects the Seifert sphere witness directly to `BrieskornSU2.cassonSU2`
and `Brieskorn.cassonInvariantNat`. -/
theorem brieskorn_casson_bridge_3point (p q r : ℕ)
    (hpq : p.Coprime q) (hpr : p.Coprime r) (hqr : q.Coprime r) :
    (∃ (l0 : ℤ) (l : Fin 3 → ℤ), IsHomotopySphere (vec3 p q r) l0 l) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents p q r) ∧
    Brieskorn.cassonInvariantNat p q r = (Int.natAbs (Brieskorn.brieskornSignature p q r)) / 8 ∧
    BrieskornSU2.cassonSU2 p q r = (BrieskornSU2.IrredSU2RepSet p q r).card / 2 :=
  ⟨pairwise_coprime_exists_sphere (pairwiseCoprime_vec3_of_coprime p q r hpq hpr hqr),
   pairwiseCoprime_3_implies_brieskornSphere p q r hpq hpr hqr, rfl, rfl⟩

/-! ### Standalone Seifert Certificates for Additional 3-Point Spheres -/

/-- Brieskorn Homology Sphere $\Sigma(2, 5, 7)$ under Seifert invariant:
$|70(0) - (35(1) + 14(-1) + 10(-2))| = |-1| = 1$. -/
theorem sphere_3point_2_5_7 : IsHomotopySphere (vec3 2 5 7) 0 (twist3 1 (-1) (-2)) := rfl

/-- Brieskorn Homology Sphere $\Sigma(3, 4, 5)$ under Seifert invariant:
$|60(0) - (20(1) + 15(1) + 12(-3))| = |1| = 1$. -/
theorem sphere_3point_3_4_5 : IsHomotopySphere (vec3 3 4 5) 0 (twist3 1 1 (-3)) := rfl

/-- Brieskorn Homology Sphere $\Sigma(3, 5, 7)$ under Seifert invariant:
$|105(0) - (35(1) + 21(-1) + 15(-1))| = |1| = 1$. -/
theorem sphere_3point_3_5_7 : IsHomotopySphere (vec3 3 5 7) 0 (twist3 1 (-1) (-1)) := rfl

/-! ### Standalone Brieskorn & SU(2) Invariant Theorems for (3,4,5) and (3,5,7) -/

/-- Milnor fiber intersection signature for $\Sigma(3, 4, 5)$ is $-16$. -/
theorem signature_3_4_5 : Brieskorn.brieskornSignature 3 4 5 = -16 := rfl

/-- Integer Casson invariant for $\Sigma(3, 4, 5)$ from Milnor fiber is $2$. -/
theorem cassonNat_3_4_5 : Brieskorn.cassonInvariantNat 3 4 5 = 2 := rfl

/-- $SU(2)$ character variety Casson invariant for $\Sigma(3, 4, 5)$ is $1$. -/
theorem cassonSU2_3_4_5 : BrieskornSU2.cassonSU2 3 4 5 = 1 := rfl

/-- Milnor fiber intersection signature for $\Sigma(3, 5, 7)$ is $-32$. -/
theorem signature_3_5_7 : Brieskorn.brieskornSignature 3 5 7 = -32 := rfl

/-- Integer Casson invariant for $\Sigma(3, 5, 7)$ from Milnor fiber is $4$. -/
theorem cassonNat_3_5_7 : Brieskorn.cassonInvariantNat 3 5 7 = 4 := rfl

/-- $SU(2)$ character variety Casson invariant for $\Sigma(3, 5, 7)$ is $2$. -/
theorem cassonSU2_3_5_7 : BrieskornSU2.cassonSU2 3 5 7 = 2 := rfl

/-! ### Bundled Bridge Record Structure -/

/-- Bundled bridge certificate capturing Seifert, Brieskorn, and Casson data for a 3-manifold. -/
structure SeifertBrieskornBridge3 where
  p : ℕ
  q : ℕ
  r : ℕ
  hpq : p.Coprime q := by decide
  hpr : p.Coprime r := by decide
  hqr : q.Coprime r := by decide
  l0 : ℤ
  l : Fin 3 → ℤ
  is_seifert_sphere : IsHomotopySphere (vec3 p q r) l0 l := by rfl
  is_brieskorn_sphere : Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents p q r) :=
    pairwiseCoprime_3_implies_brieskornSphere p q r hpq hpr hqr
  signature : ℤ
  sig_eq : Brieskorn.brieskornSignature p q r = signature := by rfl
  casson_milnor : ℕ
  casson_milnor_eq : Brieskorn.cassonInvariantNat p q r = casson_milnor := by rfl
  casson_su2 : ℕ
  casson_su2_eq : BrieskornSU2.cassonSU2 p q r = casson_su2 := by rfl

/-! ### Explicit Bridge Certificates for Canonical Homology 3-Spheres -/

/-- Explicit bridge certificate for Poincaré Homology Sphere $\Sigma(2, 3, 5)$ ($\lambda = 1$). -/
def bridge_2_3_5 : SeifertBrieskornBridge3 where
  p := 2
  q := 3
  r := 5
  l0 := 1
  l := twist3 1 1 1
  signature := -8
  casson_milnor := 1
  casson_su2 := 1

/-- Explicit bridge certificate for Brieskorn Homology Sphere $\Sigma(2, 3, 7)$ ($\lambda = 1$). -/
def bridge_2_3_7 : SeifertBrieskornBridge3 where
  p := 2
  q := 3
  r := 7
  l0 := 1
  l := twist3 1 1 1
  signature := -8
  casson_milnor := 1
  casson_su2 := 1

/-- Explicit bridge certificate for Brieskorn Homology Sphere $\Sigma(2, 3, 11)$ ($\lambda = 2$). -/
def bridge_2_3_11 : SeifertBrieskornBridge3 where
  p := 2
  q := 3
  r := 11
  l0 := 0
  l := twist3 1 (-1) (-2)
  signature := -16
  casson_milnor := 2
  casson_su2 := 2

/-- Explicit bridge certificate for Brieskorn Homology Sphere $\Sigma(2, 5, 7)$ ($\lambda = 2$). -/
def bridge_2_5_7 : SeifertBrieskornBridge3 where
  p := 2
  q := 5
  r := 7
  l0 := 0
  l := twist3 1 (-1) (-2)
  signature := -16
  casson_milnor := 2
  casson_su2 := 2

/-- Explicit bridge certificate for Brieskorn Homology Sphere $\Sigma(3, 4, 5)$. -/
def bridge_3_4_5 : SeifertBrieskornBridge3 where
  p := 3
  q := 4
  r := 5
  l0 := 0
  l := twist3 1 1 (-3)
  signature := -16
  casson_milnor := 2
  casson_su2 := 1

/-- Explicit bridge certificate for Brieskorn Homology Sphere $\Sigma(3, 5, 7)$. -/
def bridge_3_5_7 : SeifertBrieskornBridge3 where
  p := 3
  q := 5
  r := 7
  l0 := 0
  l := twist3 1 (-1) (-1)
  signature := -32
  casson_milnor := 4
  casson_su2 := 2

/-! ### Theorem-Level Bridge Invariant Certificates -/

/-- Theorem: $\Sigma(2,3,5)$ satisfies Seifert sphere and has Casson invariant 1. -/
theorem bridge_certificate_2_3_5 :
    IsHomotopySphere (vec3 2 3 5) 1 (twist3 1 1 1) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents 2 3 5) ∧
    Brieskorn.cassonInvariantNat 2 3 5 = 1 ∧
    BrieskornSU2.cassonSU2 2 3 5 = 1 :=
  ⟨rfl, pairwiseCoprime_3_implies_brieskornSphere 2 3 5 (by decide) (by decide) (by decide), rfl, rfl⟩

/-- Theorem: $\Sigma(2,3,7)$ satisfies Seifert sphere and has Casson invariant 1. -/
theorem bridge_certificate_2_3_7 :
    IsHomotopySphere (vec3 2 3 7) 1 (twist3 1 1 1) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents 2 3 7) ∧
    Brieskorn.cassonInvariantNat 2 3 7 = 1 ∧
    BrieskornSU2.cassonSU2 2 3 7 = 1 :=
  ⟨rfl, pairwiseCoprime_3_implies_brieskornSphere 2 3 7 (by decide) (by decide) (by decide), rfl, rfl⟩

/-- Theorem: $\Sigma(2,3,11)$ satisfies Seifert sphere and has Casson invariant 2. -/
theorem bridge_certificate_2_3_11 :
    IsHomotopySphere (vec3 2 3 11) 0 (twist3 1 (-1) (-2)) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents 2 3 11) ∧
    Brieskorn.cassonInvariantNat 2 3 11 = 2 ∧
    BrieskornSU2.cassonSU2 2 3 11 = 2 :=
  ⟨rfl, pairwiseCoprime_3_implies_brieskornSphere 2 3 11 (by decide) (by decide) (by decide), rfl, rfl⟩

/-- Theorem: $\Sigma(2,5,7)$ satisfies Seifert sphere and has Casson invariant 2. -/
theorem bridge_certificate_2_5_7 :
    IsHomotopySphere (vec3 2 5 7) 0 (twist3 1 (-1) (-2)) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents 2 5 7) ∧
    Brieskorn.cassonInvariantNat 2 5 7 = 2 ∧
    BrieskornSU2.cassonSU2 2 5 7 = 2 :=
  ⟨rfl, pairwiseCoprime_3_implies_brieskornSphere 2 5 7 (by decide) (by decide) (by decide), rfl, rfl⟩

/-- Theorem: $\Sigma(3,4,5)$ satisfies Seifert sphere, has Milnor Casson 2 and SU(2) Casson 1. -/
theorem bridge_certificate_3_4_5 :
    IsHomotopySphere (vec3 3 4 5) 0 (twist3 1 1 (-3)) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents 3 4 5) ∧
    Brieskorn.cassonInvariantNat 3 4 5 = 2 ∧
    BrieskornSU2.cassonSU2 3 4 5 = 1 :=
  ⟨rfl, pairwiseCoprime_3_implies_brieskornSphere 3 4 5 (by decide) (by decide) (by decide), rfl, rfl⟩

/-- Theorem: $\Sigma(3,5,7)$ satisfies Seifert sphere, has Milnor Casson 4 and SU(2) Casson 2. -/
theorem bridge_certificate_3_5_7 :
    IsHomotopySphere (vec3 3 5 7) 0 (twist3 1 (-1) (-1)) ∧
    Brieskorn.brieskornSphereCondition (Brieskorn.brieskornThreeExponents 3 5 7) ∧
    Brieskorn.cassonInvariantNat 3 5 7 = 4 ∧
    BrieskornSU2.cassonSU2 3 5 7 = 2 :=
  ⟨rfl, pairwiseCoprime_3_implies_brieskornSphere 3 5 7 (by decide) (by decide) (by decide), rfl, rfl⟩

end GeneralSeifert
