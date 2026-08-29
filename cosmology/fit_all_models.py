import sys, os
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__) + '/..'))
import numpy as np
from scipy.optimize import minimize
from cosmology.model import CosmologicalParameters, PoincareEDEModel
from cosmology.likelihoods import JointLikelihood

joint_noshoes = JointLikelihood(include_shoes=False)
joint_shoes = JointLikelihood(include_shoes=True)

# LCDM
p_lcdm = CosmologicalParameters(H0=67.36, omega_b=0.02237, omega_cdm=0.1200, Omega_k=0.0, f_EDE=0.0, n_s=0.9649, sigma8_0=0.811, use_poincare_topology=False)
m_lcdm = PoincareEDEModel(p_lcdm)
print("=== FLAT LCDM ===")
print("LCDM Chi2 (No SH0ES):", joint_noshoes.chi2(m_lcdm), "With SH0ES:", joint_shoes.chi2(m_lcdm))
print("LCDM breakdown:", joint_shoes.chi2_breakdown(m_lcdm))
print("LCDM S8:", m_lcdm.S_8, "sigma8:", m_lcdm.sigma_8)

# EDE
def loss_ede(x):
    p = CosmologicalParameters(H0=x[0], omega_b=x[1], omega_cdm=x[2], Omega_k=x[3], f_EDE=x[4], log10_zc=x[5], w0=x[6], wa=x[7], n_s=x[8], use_poincare_topology=True, model_type='axion_ede')
    return joint_shoes.chi2(PoincareEDEModel(p))

res_ede = minimize(loss_ede, [72.5, 0.0224, 0.145, -0.002, 0.10, 3.56, -0.90, -0.30, 0.98], method='Nelder-Mead', options={'maxiter': 3000})
p_ede = CosmologicalParameters(H0=res_ede.x[0], omega_b=res_ede.x[1], omega_cdm=res_ede.x[2], Omega_k=res_ede.x[3], f_EDE=res_ede.x[4], log10_zc=res_ede.x[5], w0=res_ede.x[6], wa=res_ede.x[7], n_s=res_ede.x[8], use_poincare_topology=True, model_type='axion_ede')
m_ede = PoincareEDEModel(p_ede)
print("\n=== S^3/I* EDE (CANONICAL) ===")
print("EDE Chi2 (No SH0ES):", joint_noshoes.chi2(m_ede), "With SH0ES:", joint_shoes.chi2(m_ede))
print("EDE params:", f"H0={p_ede.H0:.4f}, omega_b={p_ede.omega_b:.5f}, omega_cdm={p_ede.omega_cdm:.5f}, Omega_k={p_ede.Omega_k:.5f}, f_EDE={p_ede.f_EDE:.4f}, n_s={p_ede.n_s:.4f}, log10_zc={p_ede.log10_zc:.4f}, w0={p_ede.w0:.4f}, wa={p_ede.wa:.4f}")
print("EDE breakdown:", joint_shoes.chi2_breakdown(m_ede))
print("EDE S8:", m_ede.S_8, "sigma8:", m_ede.sigma_8)

# IDR
def loss_idr(x):
    p = CosmologicalParameters(H0=x[0], omega_b=x[1], omega_cdm=x[2], Omega_k=x[3], f_EDE=x[4], log10_zc=x[5], w0=x[6], wa=x[7], n_s=x[8], delta_N_idr=x[9], g_dark_coupling=x[10], use_poincare_topology=True, model_type='idr')
    return joint_shoes.chi2(PoincareEDEModel(p))

res_idr = minimize(loss_idr, [72.8, 0.0224, 0.155, -0.002, 0.12, 3.56, -0.90, -0.30, 0.98, 0.30, 0.15], method='Nelder-Mead', options={'maxiter': 4000})
p_idr = CosmologicalParameters(H0=res_idr.x[0], omega_b=res_idr.x[1], omega_cdm=res_idr.x[2], Omega_k=res_idr.x[3], f_EDE=res_idr.x[4], log10_zc=res_idr.x[5], w0=res_idr.x[6], wa=res_idr.x[7], n_s=res_idr.x[8], delta_N_idr=res_idr.x[9], g_dark_coupling=res_idr.x[10], use_poincare_topology=True, model_type='idr')
m_idr = PoincareEDEModel(p_idr)
print("\n=== S^3/I* + IDR (CONCORDANCE) ===")
print("IDR Chi2 (No SH0ES):", joint_noshoes.chi2(m_idr), "With SH0ES:", joint_shoes.chi2(m_idr))
print("IDR params:", f"H0={p_idr.H0:.4f}, omega_b={p_idr.omega_b:.5f}, omega_cdm={p_idr.omega_cdm:.5f}, Omega_k={p_idr.Omega_k:.5f}, f_EDE={p_idr.f_EDE:.4f}, n_s={p_idr.n_s:.4f}, delta_N_idr={p_idr.delta_N_idr:.4f}, g_dark={p_idr.g_dark_coupling:.4f}")
print("IDR breakdown:", joint_shoes.chi2_breakdown(m_idr))
print("IDR S8:", m_idr.S_8, "sigma8:", m_idr.sigma_8)
