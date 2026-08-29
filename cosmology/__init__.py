"""
Poincaré Dodecahedral Adèlic Cosmology ($S^3/I^*$) MCMC & Likelihood Suite.

Package Exports:
- CosmologicalParameters, PoincareEDEModel, PoincareTopology
- ObservationalLikelihood, PlanckLikelihood, PlanckLowEllLikelihood, DESI2024Likelihood, PantheonPlusLikelihood, JointLikelihood
- MCMCSampler, MCMCChain, PosteriorSummary, gelman_rubin_diagnostic, compute_information_criteria
"""

from .model import (
    SPEED_OF_LIGHT,
    T_CMB_FIDUCIAL,
    N_EFF_STANDARD,
    PoincareTopology,
    CosmologicalParameters,
    PoincareEDEModel
)

from .likelihoods import (
    ObservationalLikelihood,
    PlanckLikelihood,
    PlanckLowEllLikelihood,
    DESI2024Likelihood,
    PantheonPlusLikelihood,
    JointLikelihood
)

from .mcmc import (
    MCMCChain,
    PosteriorSummary,
    MCMCSampler,
    gelman_rubin_diagnostic,
    compute_information_criteria
)

__all__ = [
    "SPEED_OF_LIGHT",
    "T_CMB_FIDUCIAL",
    "N_EFF_STANDARD",
    "PoincareTopology",
    "CosmologicalParameters",
    "PoincareEDEModel",
    "ObservationalLikelihood",
    "PlanckLikelihood",
    "PlanckLowEllLikelihood",
    "DESI2024Likelihood",
    "PantheonPlusLikelihood",
    "JointLikelihood",
    "MCMCChain",
    "PosteriorSummary",
    "MCMCSampler",
    "gelman_rubin_diagnostic",
    "compute_information_criteria"
]

__version__ = "1.0.0"
