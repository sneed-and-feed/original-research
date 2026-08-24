import Formalization.TriangleModularGroup
import Formalization.SeifertSphereFibrations

/-!
# Original Research Formalization Suite: Triangle Groups & Seifert Homology Spheres

This repository contains original machine-checked mathematical research formalized in Lean 4
and Mathlib.

## Module Index

1. **`Formalization.TriangleModularGroup`**:
   - Discrete matrix representation of the hyperbolic triangle group $\Delta(3,4,\infty)$ in $\mathrm{GL}_4(\mathbb{Z})$.
   - Verification of group relations $T_1^3 = I_4$, $T_2^4 = I_4$, $(T_1 T_2) T_0 = I_4$.
   - Unipotent cusp monodromy $N = T_0 - I_4$ satisfying $N^2 = 0$.
   - Nilpotent action on the basis $(\gamma, u, w, \delta)$: $N\gamma = 0, Nu = 0, Nw = -u, N\delta = \gamma$.
   - Evaluation of the $(3,4,\infty)$ Seifert order invariant $|12(0) - 4(1) - 3(-1)| = 1 \implies \pi_1(X) \cong 0$.

2. **`Formalization.SeifertSphereFibrations`**:
   - General Diophantine classification of sphere-yielding Seifert fibrations over $S^2(a_1, a_2, \infty)$ and $S^2(a_1, a_2, a_3)$.
   - Constructive Bézout existence theorem (`coprime_exists_sphere`, `coprime_witnesses_isHomotopySphere`) via `Int.gcdA` and `Int.gcdB`.
   - Divisibility obstruction theorem (`noncoprime_obstruction`): common factors $d > 1$ preclude any homology sphere.
   - Classification of canonical hyperbolic triangle families: $(2,3,\infty)$, $(3,4,\infty)$, $(2,5,\infty)$, $(3,5,\infty)$.
   - Pairwise coprime solvability for 3-point compact Seifert 3-manifolds (`pairwise_coprime_exists_sphere3`).
   - Formal certificates for Poincaré $\Sigma(2,3,5)$ and Brieskorn $\Sigma(2,3,7)$ homology spheres.
-/
