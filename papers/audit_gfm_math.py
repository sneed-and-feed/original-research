import os
import sys
import re

FILES = [
    r'c:\Users\x\Documents\antigravity\original-research\papers\paper3_thurston_spectral_geometry.md',
    r'c:\Users\x\Documents\antigravity\original-research\papers\paper1_spectral_geometry.md',
    r'c:\Users\x\Documents\antigravity\original-research\README.md',
]

def fix_content(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    orig_len = len(content)

    # 1. Fix KaTeX ligatures: \text{--} -> \text{-}
    content = content.replace(r'\text{--}', r'\text{-}')
    content = content.replace(r'\textrm{--}', r'\textrm{-}')
    content = content.replace(r'\mathrm{--}', r'\mathrm{-}')
    content = content.replace(r'\textbf{--}', r'\textbf{-}')

    # 2. Fix raw asterisks in math: 2\chi_* -> 2\chi_\ast
    content = content.replace(r'2\chi_*', r'2\chi_\ast')
    content = content.replace(r'\chi_*', r'\chi_\ast')

    # 3. Fix backtick math in table cells:
    # `m_SO3_one` $\dots$ `m_SO3_five` -> `m_SO3_one` .. `m_SO3_five`
    content = content.replace(r'`m_SO3_one` $\dots$ `m_SO3_five`', r'`m_SO3_one` .. `m_SO3_five`')
    content = content.replace(r'`m_zero` $\dots$ `m_twelve`', r'`m_zero` .. `m_twelve`')
    content = content.replace(r'`heatTrace`, `heatTraceTerm_zero` $\dots$ `heatTraceTerm_twelve`', r'`heatTrace`, `heatTraceTerm_zero` .. `heatTraceTerm_twelve`')

    # 4. Fix specific display math blocks in paper2_cosmology.md
    if 'paper2_cosmology.md' in filepath:
        # Fix indented $$ in list items 1 & 2
        # Target block around Eisenstein & Hu (1998)
        content = content.replace(
            "1. **Eisenstein & Hu (1998) Transfer Function $T_{\\mathrm{EH98}}(k)$**:\n"
            "   Incorporates the exact baryon fraction $f_b = \\omega_b / \\omega_m$, CDM fraction $f_c = \\omega_{\\mathrm{cdm}} / \\omega_m$, sound horizon at drag epoch $s = r_d$, Silk damping wavenumber $k_{\\mathrm{Silk}}$, and scale-dependent suppression:\n"
            "   \n"
            "   $$\n"
            "   T_{\\mathrm{EH98}}(k) = f_b T_b(k) + f_c T_c(k)\n"
            "   $$\n",
            "1. **Eisenstein & Hu (1998) Transfer Function $T_{\\mathrm{EH98}}(k)$**:\n"
            "   Incorporates the exact baryon fraction $f_b = \\omega_b / \\omega_m$, CDM fraction $f_c = \\omega_{\\mathrm{cdm}} / \\omega_m$, sound horizon at drag epoch $s = r_d$, Silk damping wavenumber $k_{\\mathrm{Silk}}$, and scale-dependent suppression:\n"
            "\n"
            "$$\n"
            "T_{\\mathrm{EH98}}(k) = f_b T_b(k) + f_c T_c(k)\n"
            "$$\n"
        )
        # Target block around ETHOS / IDR DAO
        content = content.replace(
            "2. **ETHOS / IDR Dark Acoustic Oscillation (DAO) Damping Envelope $T_{\\mathrm{IDR}}(k)$**:\n"
            "   Scattering between dark matter and dark radiation introduces collisional drag, creating a characteristic sub-horizon damping envelope:\n"
            "   \n"
            "   $$\n"
            "   T_{\\mathrm{IDR}}(k) = \\left[ 1 + \\left( \\alpha_{\\mathrm{idr}}\\,k \\right)^{2\\beta_{\\mathrm{idr}}} \\right]^{-\\gamma_{\\mathrm{idr}}}\n"
            "   $$\n"
            "   \n"
            "   parameterized by the dark sector coupling strength $g_{\\mathrm{dark}}$ and relativistic contribution $\\Delta N_{\\mathrm{idr}}$:\n"
            "   \n"
            "   $$\n"
            "   \\alpha_{\\mathrm{idr}} = 5.70\\,\\frac{\\sqrt{g_{\\mathrm{dark}}}\\,\\sqrt{1 + \\Delta N_{\\mathrm{idr}}}}{h}\\text{ Mpc}, \\quad \\beta_{\\mathrm{idr}} = 1.0, \\quad \\gamma_{\\mathrm{idr}} = 1.5\n"
            "   $$\n",
            "2. **ETHOS / IDR Dark Acoustic Oscillation (DAO) Damping Envelope $T_{\\mathrm{IDR}}(k)$**:\n"
            "   Scattering between dark matter and dark radiation introduces collisional drag, creating a characteristic sub-horizon damping envelope:\n"
            "\n"
            "$$\n"
            "T_{\\mathrm{IDR}}(k) = \\left[ 1 + \\left( \\alpha_{\\mathrm{idr}}\\,k \\right)^{2\\beta_{\\mathrm{idr}}} \\right]^{-\\gamma_{\\mathrm{idr}}}\n"
            "$$\n"
            "\n"
            "   parameterized by the dark sector coupling strength $g_{\\mathrm{dark}}$ and relativistic contribution $\\Delta N_{\\mathrm{idr}}$:\n"
            "\n"
            "$$\n"
            "\\alpha_{\\mathrm{idr}} = 5.70\\,\\frac{\\sqrt{g_{\\mathrm{dark}}}\\,\\sqrt{1 + \\Delta N_{\\mathrm{idr}}}}{h}\\text{ Mpc}, \\quad \\beta_{\\mathrm{idr}} = 1.0, \\quad \\gamma_{\\mathrm{idr}} = 1.5\n"
            "$$\n"
        )
        # Target blank lines around C_norm equation
        content = content.replace(
            "and full relativistic Boltzmann solvers (CAMB / CLASS, which yield $\\sigma_8^{\\mathrm{CAMB}} = 0.811$):\n"
            "$$\n"
            "\\mathcal{C}_{\\mathrm{norm}} = \\left( \\frac{\\sigma_8^{\\mathrm{CAMB}}}{\\sigma_8^{\\mathrm{EH98}}} \\right)^2 = \\left( \\frac{0.811}{0.752} \\right)^2 = 1.162.\n"
            "$$\n"
            "Physically,",
            "and full relativistic Boltzmann solvers (CAMB / CLASS, which yield $\\sigma_8^{\\mathrm{CAMB}} = 0.811$):\n"
            "\n"
            "$$\n"
            "\\mathcal{C}_{\\mathrm{norm}} = \\left( \\frac{\\sigma_8^{\\mathrm{CAMB}}}{\\sigma_8^{\\mathrm{EH98}}} \\right)^2 = \\left( \\frac{0.811}{0.752} \\right)^2 = 1.162.\n"
            "$$\n"
            "\n"
            "Physically,"
        )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Applied fixes to {os.path.basename(filepath)} ({orig_len} -> {len(content)} chars)")

def run_strict_linter(fpath):
    with open(fpath, 'r', encoding='utf-8') as f:
        text = f.read()

    lines = text.splitlines(keepends=True)
    violations = []

    in_code_block = False
    in_display_math = False

    for idx, raw_line in enumerate(lines):
        line_num = idx + 1
        line = raw_line.rstrip('\r\n')
        stripped = line.strip()

        # 1. Code block tracking
        if stripped.startswith('```'):
            in_code_block = not in_code_block
            continue

        if in_code_block:
            continue

        # 2. Display math tracking
        if stripped.startswith('$$'):
            is_blockquote = stripped.startswith('>') or line.lstrip().startswith('>')
            if not in_display_math:
                in_display_math = True
                # Rule 8: Opening $$ at column 0
                if not is_blockquote and not line.startswith('$$'):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 8: Display Math Block Alignment',
                        'detail': f"Opening '$$' is indented (not at Column 0): '{line}'"
                    })
                # Rule 8: Blank line before opening $$
                if idx > 0:
                    prev_line = lines[idx-1].rstrip('\r\n').strip()
                    if prev_line != '' and not prev_line.startswith('>'):
                        violations.append({
                            'file': fpath,
                            'line': line_num,
                            'rule': 'Rule 8: Display Math Blank Line Before',
                            'detail': f"No blank line before '$$'. Previous line: '{prev_line}'"
                        })
            else:
                in_display_math = False
                # Rule 8: Closing $$ at column 0
                if not is_blockquote and not line.startswith('$$'):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 8: Display Math Block Alignment',
                        'detail': f"Closing '$$' is indented (not at Column 0): '{line}'"
                    })
                # Rule 8: Blank line after closing $$
                if idx + 1 < len(lines):
                    next_line = lines[idx+1].rstrip('\r\n').strip()
                    if next_line != '' and not next_line.startswith('>'):
                        violations.append({
                            'file': fpath,
                            'line': line_num,
                            'rule': 'Rule 8: Display Math Blank Line After',
                            'detail': f"No blank line after '$$'. Next line: '{next_line}'"
                        })
            continue

        if in_display_math:
            # Inside display math block
            # Rule 4: KaTeX ligatures in display math
            if re.search(r'\\text(?:rm|bf|normal|it)?\{--\}', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 4: KaTeX Ligatures',
                    'detail': f"Found '\\text{{--}}' in display math: '{line.strip()}'"
                })
            # Rule 5: \mathbf with operators in display math
            mb_matches = re.findall(r'\\mathbf\{([^{}]*)\}', line)
            for inner in mb_matches:
                if re.search(r'=|\+|-|\\pm|\\times|\\le|\\ge|\\approx|\\neq|\\sim|\\to|\\equiv', inner):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 5: KaTeX \\mathbf with Operators',
                        'detail': f"Operator inside \\mathbf: '\\mathbf{{{inner}}}'"
                    })
            # Rule 7: Asterisk escapes in display math
            if re.search(r'(?<!\\)\*', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 7: Math Asterisk Escapes',
                    'detail': f"Raw '*' in display math: '{line.strip()}'"
                })
            continue

        # In standard prose / table line
        # Rule 1: Backtick math
        if re.search(r'\$`|`\$|\$\s*`|`\s*\$', line):
            violations.append({
                'file': fpath,
                'line': line_num,
                'rule': 'Rule 1: Backtick Math',
                'detail': f"Backtick adjacent to math delimiter in: '{line.strip()}'"
            })

        # Rule 9: Hyphen math
        hm_matches = re.finditer(r'\b([A-Za-z]+)-\$([^\$\n]+)\$', line)
        for hm in hm_matches:
            violations.append({
                'file': fpath,
                'line': line_num,
                'rule': 'Rule 9: Hyphen Math',
                'detail': f"Hyphen outside math: '{hm.group(0)}' in '{line.strip()}'"
            })

        # Rule 3: Delimiter balance on line (strip inline code first)
        line_no_code = re.sub(r'`[^`]+`', '', line)
        dollars = re.findall(r'(?<!\\)\$', line_no_code)
        if len(dollars) % 2 != 0:
            violations.append({
                'file': fpath,
                'line': line_num,
                'rule': 'Rule 3: Delimiter Balance',
                'detail': f"Unclosed '$' delimiter (found {len(dollars)} '$'): '{line.strip()}'"
            })

        # Tokenize inline math
        inline_spans = list(re.finditer(r'(?<!\\)\$(?!\$)(.*?)(?<!\\)\$', line_no_code))
        is_table = '|' in line

        for m in inline_spans:
            math_content = m.group(1)
            full_match = m.group(0)

            # Rule 2: Delimiter whitespace
            if math_content.startswith(' ') or math_content.startswith('\t') or math_content.endswith(' ') or math_content.endswith('\t'):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 2: Delimiter Whitespace',
                    'detail': f"Leading/trailing space in inline math: '{full_match}'"
                })

            # Rule 4: KaTeX ligatures
            if re.search(r'\\text(?:rm|bf|normal|it)?\{--\}', math_content):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 4: KaTeX Ligatures',
                    'detail': f"Found '\\text{{--}}' in inline math: '{full_match}'"
                })

            # Rule 5: \mathbf operators
            mb_matches = re.findall(r'\\mathbf\{([^{}]*)\}', math_content)
            for inner in mb_matches:
                if re.search(r'=|\+|-|\\pm|\\times|\\le|\\ge|\\approx|\\neq|\\sim|\\to|\\equiv', inner):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 5: KaTeX \\mathbf with Operators',
                        'detail': f"Operator inside \\mathbf: '\\mathbf{{{inner}}}'"
                    })

            # Rule 6: Table cell integrity
            if is_table:
                mc_cleaned = re.sub(r'\\(?:mid|lvert|rvert|vert|lVert|rVert|parallel|\|)', '', math_content)
                if '|' in mc_cleaned:
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 6: Table Cell Integrity',
                        'detail': f"Raw '|' in table inline math: '{full_match}'"
                    })

            # Rule 7: Asterisk escapes
            if re.search(r'(?<!\\)\*', math_content):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 7: Math Asterisk Escapes',
                    'detail': f"Raw '*' in inline math: '{full_match}'"
                })

    return violations

def main():
    print("=======================================================")
    print("      EXECUTING AUTOMATIC CORRECTIONS                  ")
    print("=======================================================")
    for f in FILES:
        fix_content(f)

    print("\n=======================================================")
    print("      RE-RUNNING STRICT GFM MATH VERIFICATION AUDIT    ")
    print("=======================================================")
    total = 0
    for f in FILES:
        v = run_strict_linter(f)
        total += len(v)
        status = "[PASS: 0 VIOLATIONS]" if len(v) == 0 else f"[FAIL: {len(v)} VIOLATIONS]"
        print(f"{status} - {os.path.basename(f)} ({f})")
        for item in v:
            print(f"  Line {item['line']:4d} | [{item['rule']}] {item['detail']}")

    print(f"\n=======================================================")
    print(f"FINAL AUDIT RESULT: {total} TOTAL VIOLATIONS")
    print(f"=======================================================")
    if total != 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
