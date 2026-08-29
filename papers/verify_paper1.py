import os
import sys
import typst
import pymupdf

def main():
    pdf_path = "papers/paper1_spectral_geometry.pdf"
    typ_path = "papers/paper1_spectral_geometry.typ"
    
    print(f"Compiling {typ_path} -> {pdf_path}...")
    typst.compile(typ_path, output=pdf_path)
    print("Compilation succeeded.")
    
    doc = pymupdf.open(pdf_path)
    print(f"Total Pages: {len(doc)}")
    
    full_text = ""
    for i, page in enumerate(doc):
        text = page.get_text()
        images = page.get_images()
        full_text += text
        lines = [l.strip() for l in text.split("\n") if l.strip()]
        first_line = lines[0] if lines else ""
        last_line = lines[-1] if lines else ""
        print(f"Page {i+1}: {len(text)} chars, {len(images)} images | Header/Top: '{first_line[:50]}' | Bottom: '{last_line[:50]}'")
        
    # Check for required keywords & concepts (normalized dashes)
    norm_text = full_text.replace("\u2013", "--").replace("\u2014", "--").lower()
    
    required_keywords = [
        "poincaré homology 3-sphere",
        "binary icosahedral group",
        "molien invariant theory",
        "conjugacy classes",
        "seeley--dewitt",
        "heat kernel asymptotics",
        "einstein--hilbert",
        "chamseddine--connes",
        "renormalization group",
        "archimedean fiber",
        "adèlic spacetime",
        "formal lean 4 verification"
    ]
    
    print("\nVerifying keywords:")
    for kw in required_keywords:
        assert kw in norm_text, f"Missing keyword: {kw}"
        print(f"  [PASS] {kw}")
        
    print("\nAll verification checks passed perfectly!")

if __name__ == "__main__":
    main()
