import os
import sys
import typst
import pymupdf

def main():
    print("Compiling paper/paper2_cosmology.typ -> paper/paper2_cosmology.pdf...")
    typst.compile("paper/paper2_cosmology.typ", output="paper/paper2_cosmology.pdf")
    print("[SUCCESS] Compilation completed.")
    
    doc = pymupdf.open("paper/paper2_cosmology.pdf")
    print(f"Total Pages: {len(doc)}")
    
    full_text = " ".join(page.get_text() for page in doc)
    import re
    full_text = re.sub(r'\s+', ' ', full_text)
        
    markers = [
        "Cosmic Topology and Early Dark Energy",
        "Poincaré Dodecahedral Space",
        "Molien",
        "Conjugacy Classes",
        "Kinematic Dipole",
        "Integrated Sachs",
        "Early Dark Energy Dynamics",
        "Akaike Information Criterion",
        "Bayesian Information Criterion",
        "Without SH0ES Prior",
        "With SH0ES Prior",
        "Formal Mathematical Verification in Lean 4"
    ]
    print("\n--- Marker Verification ---")
    for m in markers:
        present = m.lower() in full_text.lower()
        print(f"[{'PASS' if present else 'FAIL'}] Marker: '{m}'")
        assert present, f"Missing marker {m}"

    print("\nAll verification checks passed perfectly!")

if __name__ == "__main__":
    main()
