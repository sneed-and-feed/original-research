import re
import os
import sys

FILES = [
    r"c:\Users\x\Documents\antigravity\original-research\papers\paper1_spectral_geometry.md",
    r"c:\Users\x\Documents\antigravity\original-research\papers\paper3_thurston_spectral_geometry.md",
    r"c:\Users\x\Documents\antigravity\original-research\README.md"
]

def verify_files():
    bold_pattern = re.compile(r'\*\*([^*]+|\*(?!\*))+\*\*')
    italic_pattern = re.compile(r'(?<!\*)\*([^*]+)\*(?!\*)')
    # Check for \text{K}, \text{ K}, \mu\text{K}, \text{mK}, \text{μK}, \text{K}^2 etc. (temperature units in text mode)
    text_k_pattern = re.compile(r'\\text\{\s*(?:\\mu|μ|m)?K\s*\}|\\mu\\text\{K\}|\\text\{K\b')

    total_errors = 0

    print("=" * 70)
    print("   MARKDOWN & KATEX GITHUB ENGINE COMPLIANCE AUDIT")
    print("=" * 70)

    for filepath in FILES:
        basename = os.path.basename(filepath)
        print(f"\nScanning: {basename}")
        print("-" * 50)
        
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()

        file_errors = 0

        # Check 1: ** wrapping math ($)
        for idx, line in enumerate(lines, 1):
            for m in bold_pattern.finditer(line):
                if '$' in m.group(0):
                    print(f"  [ERROR] Line {idx}: Bold wrapping math: {m.group(0)}")
                    file_errors += 1
            for m in italic_pattern.finditer(line):
                if '$' in m.group(0):
                    print(f"  [ERROR] Line {idx}: Italic wrapping math: {m.group(0)}")
                    file_errors += 1

        # Check 2: Indented continuation lines following $$ blocks
        in_display_math = False
        display_math_end_line = -100
        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped == '$$':
                if not in_display_math:
                    in_display_math = True
                else:
                    in_display_math = False
                    display_math_end_line = idx
                continue
            if not in_display_math and 0 < (idx - display_math_end_line) <= 20:
                if (line.startswith(' ') or line.startswith('\t')) and stripped:
                    print(f"  [ERROR] Line {idx} (after $$ at line {display_math_end_line}): Indented continuation line: {line.rstrip()[:80]}")
                    file_errors += 1
                elif stripped and not (line.startswith(' ') or line.startswith('\t')):
                    display_math_end_line = -100

        # Check 3: \text{K} or \mu\text{K} in math mode
        for idx, line in enumerate(lines, 1):
            for m in text_k_pattern.finditer(line):
                print(f"  [ERROR] Line {idx}: \\text{{K}} unit found: {m.group(0)} in: {line.rstrip()[:80]}")
                file_errors += 1

        # Check 4: \hline or \begin{array} table in math mode (triggers Misplaced \hline in KaTeX)
        for idx, line in enumerate(lines, 1):
            if r'\hline' in line:
                print(f"  [ERROR] Line {idx}: Banned \\hline in math/markdown (use GFM tables instead): {line.rstrip()[:80]}")
                file_errors += 1

        if file_errors == 0:
            print(f"  [PASS] All checks passed for {basename}! (0 violations)")
        else:
            print(f"  [FAIL] {file_errors} violations in {basename}")
        total_errors += file_errors

    print("\n" + "=" * 70)
    if total_errors == 0:
        print("[SUCCESS] 0 violations across all files! Markdown & KaTeX syntax is 100% compliant.")
        return 0
    else:
        print(f"[FAILURE] Total violations found: {total_errors}")
        return 1

if __name__ == "__main__":
    sys.exit(verify_files())
