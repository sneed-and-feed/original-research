import os
import sys
import typst
import pymupdf

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    md_path = os.path.join(script_dir, "paper1_spectral_geometry.md")
    tex_path = os.path.join(script_dir, "paper1_spectral_geometry.tex")
    
    print("=" * 65)
    print("   VERIFYING PAPER 1 (SPECTRAL GEOMETRY & POINCARÉ SPHERE)   ")
    print("=" * 65)
    
    assert os.path.exists(md_path), f"Missing Markdown preprint: {md_path}"
    assert os.path.exists(tex_path), f"Missing LaTeX preprint: {tex_path}"
    
    with open(md_path, "r", encoding="utf-8") as f:
        md_text = f.read()
    with open(tex_path, "r", encoding="utf-8") as f:
        tex_text = f.read()
        
    required_keywords = [
        "Poincar",
        "Binary Icosahedral Group",
        "Molien",
        "Conjugacy Classes",
        "Seeley--DeWitt",
        "Heat Kernel Asymptotics",
        "Einstein--Hilbert",
        "Chamseddine--Connes",
        "Standard Model",
        "Spectral Triple",
        "Formal Lean 4 Verification"
    ]
    
    print("\n--- Markdown & LaTeX Cross-Verification ---")
    for kw in required_keywords:
        kw_norm = kw.replace("--", "-")
        in_md = kw in md_text or kw_norm in md_text
        in_tex = kw in tex_text or kw_norm in tex_text or kw.replace("é", r"\'e") in tex_text

        
        status_md = "[PASS]" if in_md else "[FAIL]"
        status_tex = "[PASS]" if in_tex else "[FAIL]"
        print(f"{status_md} Markdown: '{kw}' | {status_tex} LaTeX: '{kw}'")
        assert in_md, f"Missing '{kw}' in Markdown manuscript"
        assert in_tex, f"Missing '{kw}' in LaTeX manuscript"
        
    print(f"\nMarkdown Size: {len(md_text)} chars, {len(md_text.splitlines())} lines")
    print(f"LaTeX Size: {len(tex_text)} chars, {len(tex_text.splitlines())} lines")
    print("\n[SUCCESS] All Markdown and LaTeX verification checks passed perfectly!")

if __name__ == "__main__":
    main()
