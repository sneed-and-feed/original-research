import os
import sys
import re

def main():
    print("=================================================================")
    print("       VERIFYING PAPER 2 (COSMOLOGY & POINCARÉ TOPOLOGY)        ")
    print("=================================================================")
    
    md_file = "papers/paper2_cosmology.md"
    tex_file = "papers/paper2_cosmology.tex"
    
    assert os.path.exists(md_file), f"Missing {md_file}"
    assert os.path.exists(tex_file), f"Missing {tex_file}"
    
    # 1. Read Markdown and LaTeX manuscripts
    with open(md_file, "r", encoding="utf-8") as f:
        md_text = f.read()
    with open(tex_file, "r", encoding="utf-8") as f:
        tex_text = f.read()
        
    markers = [
        "Cosmic Topology and Early Dark Energy",
        "Poincaré Dodecahedral Space",
        "Molien",
        "Conjugacy Classes",
        "Kinematic Dipole",
        "Integrated Sachs",
        "Boltzmann Perturbation Dynamics",
        "Diffusion Damping",
        "Early Dark Energy Dynamics",
        "SPT-3G",
        "Interacting Dark Radiation",
        "New Early Dark Energy",
        "Akaike Information Criterion",
        "Bayesian Information Criterion",
        "Without the SH0ES Prior",
        "With the SH0ES Prior",
        "Formal Mathematical Verification in Lean 4",
        "Growth ODE",
        "Eisenstein & Hu",
        "Transfer Function",
        "Quadrature",
        "144.7",
        "379.4",
        "73.24",
        "verify_tables.py",
        "run_mcmc_production.py",
        "test_cosmology.py"
    ]
    
    print("\n--- Markdown & LaTeX Cross-Verification ---")
    for m in markers:
        # Standardize search for latex/markdown
        norm_m = m.lower()
        md_pres = norm_m in md_text.lower() or norm_m.replace("poincaré", "poincare") in md_text.lower()
        tex_pres = (norm_m.replace("poincaré", "poincar\\'e") in tex_text.lower() or 
                    norm_m.replace("&", "\\&") in tex_text.lower() or
                    norm_m in tex_text.lower() or 
                    norm_m.replace("poincaré", "poincare") in tex_text.lower())
        print(f"[{'PASS' if md_pres else 'FAIL'}] Markdown: '{m}' | [{'PASS' if tex_pres else 'FAIL'}] LaTeX: '{m}'")
        assert md_pres, f"Missing Markdown marker: {m}"
        assert tex_pres, f"Missing LaTeX marker: {m}"

    # Specific ODE and equation checks
    assert "d^2 \\delta" in md_text and "d^2 \\delta" in tex_text, "Missing growth ODE derivative in manuscripts"
    assert "I_\\ell^{\\mathrm{ISW}}" in md_text or "I_\\ell" in md_text, "Missing ISW integral kernel in Markdown"
    assert "I_\\ell^{\\mathrm{ISW}}" in tex_text or "I_\\ell" in tex_text, "Missing ISW integral kernel in LaTeX"
    assert "T_{\\mathrm{EH98}}" in md_text and "T_{\\mathrm{EH98}}" in tex_text, "Missing Eisenstein-Hu transfer function in manuscripts"
    assert "T_{\\mathrm{IDR}}" in md_text and "T_{\\mathrm{IDR}}" in tex_text, "Missing IDR damping function in manuscripts"
    assert "W^2(k R_8)" in md_text or "W(k R_8)" in md_text, "Missing top-hat window function in Markdown"
    assert "W^2(k R_8)" in tex_text or "W(k R_8)" in tex_text, "Missing top-hat window function in LaTeX"

    print(f"\nMarkdown Size: {len(md_text)} chars, {len(md_text.splitlines())} lines")
    print(f"LaTeX Size: {len(tex_text)} chars, {len(tex_text.splitlines())} lines")
    print("\n[SUCCESS] All Markdown and LaTeX verification checks passed perfectly!")

if __name__ == "__main__":
    main()

