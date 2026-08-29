import sys, os
sys.path.insert(0, os.path.abspath('.'))
import numpy as np
from cosmology.model import CosmologicalParameters, PoincareEDEModel
from cosmology.likelihoods import PlanckLowEllLikelihood, JointLikelihood

print("=================================================================")
print("          AUDIT ROUND 2 FORENSIC INSPECTION SCRIPT             ")
print("=================================================================")

# 1. Low-ell Likelihood inspection
lik = PlanckLowEllLikelihood()
print("\n--- 1. Planck Low-ell Observational Target & Uncertainties ---")
for ell in lik.ell_values:
    print(f"ell={ell}: D_obs = {lik.d_obs[ell]:.1f} muK^2, sigma = {lik.sigma[ell]:.1f} muK^2")

p_lcdm = CosmologicalParameters(H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0, use_poincare_topology=False)
m_lcdm = PoincareEDEModel(p_lcdm)

p_ede = CosmologicalParameters(H0=73.24, omega_b=0.02253, omega_cdm=0.1302, Omega_k=-0.0008, f_EDE=0.122, log10_zc=3.56, use_poincare_topology=True)
m_ede = PoincareEDEModel(p_ede)

print("\n--- 2. Flat LCDM Low-ell Residuals ---")
bk_lcdm = lik.residual_breakdown(m_lcdm)
chi2_lcdm = lik.chi2(m_lcdm)
for ell in lik.ell_values:
    b = bk_lcdm[ell]
    print(f"ell={ell}: D_th = {b['D_ell_th']:>6.1f}, D_obs = {b['D_ell_obs']:>6.1f}, pull = {b['pull']:>+5.2f} sigma, chi2 = {b['chi2']:>6.2f}")
print(f"Total Low-ell Chi2 (Flat LCDM): {chi2_lcdm:.2f}")

print("\n--- 3. S^3/I* EDE Low-ell Residuals (Real Dynamical ISW + Projection) ---")
bk_ede = lik.residual_breakdown(m_ede)
chi2_ede = lik.chi2(m_ede)
for ell in lik.ell_values:
    b = bk_ede[ell]
    print(f"ell={ell}: D_th = {b['D_ell_th']:>6.1f}, D_obs = {b['D_ell_obs']:>6.1f}, pull = {b['pull']:>+5.2f} sigma, chi2 = {b['chi2']:>6.2f}")
print(f"Total Low-ell Chi2 (S^3/I* EDE): {chi2_ede:.2f} (Delta Chi2 = {chi2_ede - chi2_lcdm:.2f})")

# 2. S8 and ETHOS Damping Behavior
print("\n--- 4. S_8 Variation as a function of g_dark_coupling ---")
print(f"{'g_dark':<10} | {'Delta_N_idr':<12} | {'sigma_8':<10} | {'S_8':<10} | {'DES Y3 Pull':<12} | {'Weak Lensing Chi2':<18}")
from cosmology.likelihoods import WeakLensingLikelihood
wl = WeakLensingLikelihood()
for g in [0.0, 0.04, 0.08, 0.085, 0.12, 0.16, 0.20]:
    p_idr = CosmologicalParameters(H0=73.45, omega_b=0.02258, omega_cdm=0.1315, Omega_k=-0.0008, f_EDE=0.118, log10_zc=3.58, n_s=0.991, delta_N_idr=0.24, g_dark_coupling=g, use_poincare_topology=True, model_type="idr")
    m_idr = PoincareEDEModel(p_idr)
    wl_c2 = wl.chi2(m_idr)
    des_pull = (m_idr.S_8 - 0.776) / 0.017
    print(f"{g:<10.3f} | {0.24:<12.2f} | {m_idr.sigma_8:<10.4f} | {m_idr.S_8:<10.4f} | {des_pull:>+5.2f} sigma   | {wl_c2:<18.2f}")

# 3. Production MCMC Chain File Inspection
print("\n--- 5. Production MCMC Chain File Inspection ---")
chain_file = "cosmology/mcmc_production_results.npz"
summary_file = "cosmology/mcmc_production_summary.json"
if os.path.exists(chain_file):
    data = np.load(chain_file)
    print(f"Chain file '{chain_file}' exists! Keys: {list(data.keys())}")
    samples = data['samples']
    log_probs = data['log_probs']
    param_names = data['param_names']
    print(f"Samples shape: {samples.shape} (N_chains={samples.shape[0]}, N_steps={samples.shape[1]}, N_dim={samples.shape[2]})")
    print(f"Parameters: {list(param_names)}")
    print(f"Log-probs range: [{np.min(log_probs):.2f}, {np.max(log_probs):.2f}]")
else:
    print(f"Chain file '{chain_file}' NOT found!")

if os.path.exists(summary_file):
    import json
    with open(summary_file, 'r') as f:
        summ = json.load(f)
    print(f"\nSummary file '{summary_file}' exists!")
    print(f"N_samples: {summ['n_samples']}, N_dim: {summ['n_dim']}, Target: {summ['target_model']}")
    print(f"{'Parameter':<14} | {'Mean ± Std':<22} | {'Median (68% CI)':<28} | {'R_hat':<8} | {'ESS':<8}")
    for p in summ['param_names']:
        m = summ['means'][p]
        s = summ['stds'][p]
        med = summ['medians'][p]
        c68 = summ['ci_68'][p]
        r = summ['gelman_rubin_r_hat'][p]
        ess = summ['effective_sample_size'][p]
        print(f"{p:<14} | {m:>7.4f} ± {s:<7.4f}      | {med:>7.4f} [{c68[0]:>7.4f}, {c68[1]:<7.4f}] | {r:<8.4f} | {ess:<8.1f}")
