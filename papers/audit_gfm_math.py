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

    # 3. Fix disallowed \operatorname macro -> \mathrm
    content = content.replace(r'\operatorname{Vol}', r'\mathrm{Vol}')
    content = content.replace(r'\operatorname{Tr}', r'\mathrm{Tr}')
    content = content.replace(r'\operatorname{Ric}', r'\mathrm{Ric}')
    content = content.replace(r'\operatorname{diag}', r'\mathrm{diag}')
    content = content.replace(r'\operatorname{IsEinstein}', r'\mathrm{IsEinstein}')
    content = content.replace(r'\operatorname{Im}', r'\mathrm{Im}')
    content = content.replace(r'\operatorname{Area}', r'\mathrm{Area}')
    content = content.replace(r'\operatorname{Res}', r'\mathrm{Res}')
    content = content.replace(r'\operatorname{Gr}', r'\mathrm{Gr}')
    content = content.replace(r'\operatorname{rank}', r'\mathrm{rank}')
    content = content.replace(r'\operatorname{End}', r'\mathrm{End}')
    content = content.replace(r'\operatorname{toricRank}', r'\mathrm{toricRank}')
    content = content.replace(r'\operatorname{abelianRank}', r'\mathrm{abelianRank}')
    content = content.replace(r'\operatorname{codim}', r'\mathrm{codim}')
    content = content.replace(r'\operatorname{FLT}', r'\mathrm{FLT}')
    content = re.sub(r'\\operatorname\{([^{}]+)\}', r'\\mathrm{\1}', content)

    # 3b. Fix Lie group underscore subscripts and widetilde multi-letter fonts to prevent MathJax / CommonMark collisions
    lie_replacements = [
        (r'\\widetilde\{\\mathrm\{SL\}\}_2\(\\mathbb\{R\}\)', r'\\tilde{\\mathrm{SL}}(2, \\mathbb{R})'),
        (r'\\widetilde\{\\mathrm\{SL\}\}_\{2\}\(\\mathbb\{R\}\)', r'\\tilde{\\mathrm{SL}}(2, \\mathbb{R})'),
        (r'\\widetilde\{\\mathrm\{SL\}\}_2', r'\\tilde{\\mathrm{SL}}(2, \\mathbb{R})'),
        (r'\\widetilde\{\\mathrm\{SL\}\}_\{2\}', r'\\tilde{\\mathrm{SL}}(2, \\mathbb{R})'),
        (r'\\widetilde\{\\mathrm\{SL\}\}\(2,\s*\\mathbb\{R\}\)', r'\\tilde{\\mathrm{SL}}(2, \\mathbb{R})'),
        (r'\\widetilde\{\\mathrm\{SL\}\}', r'\\tilde{\\mathrm{SL}}'),
        (r'\\mathfrak\{sl\}_2\(\\mathbb\{R\}\)', r'\\mathfrak{sl}(2, \\mathbb{R})'),
        (r'\\mathfrak\{sl\}_\{2\}\(\\mathbb\{R\}\)', r'\\mathfrak{sl}(2, \\mathbb{R})'),
        (r'\\mathfrak\{sl\}_2\(\\mathbb\{C\}\)', r'\\mathfrak{sl}(2, \\mathbb{C})'),
        (r'\\mathfrak\{sl\}_2', r'\\mathfrak{sl}(2, \\mathbb{R})'),
        (r'\\mathrm\{SL\}_([0-9a-zA-Z]+)\(([^)]+)\)', r'\\mathrm{SL}(\1, \2)'),
        (r'\\mathrm\{PSL\}_([0-9a-zA-Z]+)\(([^)]+)\)', r'\\mathrm{PSL}(\1, \2)'),
        (r'\\mathrm\{GL\}_([0-9a-zA-Z]+)\(([^)]+)\)', r'\\mathrm{GL}(\1, \2)'),
        (r'\\mathrm\{SO\}_([0-9a-zA-Z]+)\(([^)]+)\)', r'\\mathrm{SO}(\1, \2)'),
        (r'\\mathrm\{SU\}_([0-9a-zA-Z]+)\(([^)]+)\)', r'\\mathrm{SU}(\1, \2)'),
        (r'\\mathrm\{SL\}_\{([0-9a-zA-Z]+)\}\(([^)]+)\)', r'\\mathrm{SL}(\1, \2)'),
        (r'\\mathrm\{PSL\}_\{([0-9a-zA-Z]+)\}\(([^)]+)\)', r'\\mathrm{PSL}(\1, \2)'),
        (r'\\mathrm\{GL\}_\{([0-9a-zA-Z]+)\}\(([^)]+)\)', r'\\mathrm{GL}(\1, \2)'),
        (r'\\mathrm\{SO\}_\{([0-9a-zA-Z]+)\}\(([^)]+)\)', r'\\mathrm{SO}(\1, \2)'),
        (r'\\mathrm\{SU\}_\{([0-9a-zA-Z]+)\}\(([^)]+)\)', r'\\mathrm{SU}(\1, \2)'),
        (r'\\mathrm\{SL\}_2', r'\\mathrm{SL}(2, \\mathbb{R})'),
        (r'\\mathrm\{PSL\}_2', r'\\mathrm{PSL}(2, \\mathbb{R})'),
        (r'\\mathrm\{GL\}_2', r'\\mathrm{GL}(2, \\mathbb{R})'),
        (r'\\mathrm\{SO\}_3', r'\\mathrm{SO}(3)'),
        (r'\\mathrm\{SU\}_2', r'\\mathrm{SU}(2)'),
        (r'\\mathrm\{SL\}_3', r'\\mathrm{SL}(3, \\mathbb{Z})'),
        (r'\\mathrm\{GL\}_3', r'\\mathrm{GL}(3, \\mathbb{R})'),
        (r'\\mathrm\{GL\}_4', r'\\mathrm{GL}(4, \\mathbb{Z})'),
        (r'\\mathfrak\{sol\}_3', r'\\mathfrak{sol}^3'),
    ]
    for pat, rep in lie_replacements:
        content = re.sub(pat, rep, content)

    # 3c. Fix parenthesized math ($...$) containing internal parentheses by moving parentheses inside math
    def paren_repl(m):
        math_body = m.group(1)
        if '(' in math_body or ')' in math_body:
            return f"$({math_body})$"
        return m.group(0)

    content = re.sub(r'\(\$([^\$\n]+)\$\)', paren_repl, content)

    # 3d. Fix brace-preceded underscore subscripts to eliminate CommonMark emphasis openers
    brace_sub_replacements = [
        (r'\\mathcal\{H\}_F', r'\\mathcal H_F'),
        (r'\\mathcal\{A\}_F', r'\\mathcal A_F'),
        (r'\\mathcal\{D\}_F', r'\\mathcal D_F'),
        (r'\\mathbb\{Z\}_p', r'\\mathbb Z_p'),
        (r'\\mathbb\{Q\}_p', r'\\mathbb Q_p'),
        (r'\\mathbb\{N\}_0', r'\\mathbb N_0'),
        (r'\\mathrm\{Vol\}_0', r'\\mathrm{Vol}'),
        (r'\\mathcal\{R\}_0', r'\\mathcal{R}'),
    ]
    for pat, rep in brace_sub_replacements:
        content = re.sub(pat, rep, content)

    # 4. Fix backtick math in table cells:
    content = content.replace(r'`m_SO3_one` $\dots$ `m_SO3_five`', r'`m_SO3_one` .. `m_SO3_five`')
    content = content.replace(r'`m_zero` $\dots$ `m_twelve`', r'`m_zero` .. `m_twelve`')
    content = content.replace(r'`heatTrace`, `heatTraceTerm_zero` $\dots$ `heatTraceTerm_twelve`', r'`heatTrace`, `heatTraceTerm_zero` .. `heatTraceTerm_twelve`')

    # 5. Fix leading math in list prefixes and eliminate subscript collisions in list titles
    content = content.replace(
        '6. $\\widetilde{\\mathrm{SL}}_2(\\mathbb{R})$ **Geometry**:',
        '6. **Universal Cover Geometry** ($\\widetilde{\\mathrm{SL}}(2, \\mathbb{R})$):'
    )
    content = content.replace(
        '6. **Universal Cover Geometry** ($\\widetilde{\\mathrm{SL}}_2(\\mathbb{R})$): We formalize the Lie algebra $\\mathfrak{sl}_2(\\mathbb{R})$',
        '6. **Universal Cover Geometry** ($\\widetilde{\\mathrm{SL}}(2, \\mathbb{R})$): We formalize the Lie algebra $\\mathfrak{sl}(2, \\mathbb{R})$'
    )
    content = content.replace(
        '7. $\\mathbb{S}^2 \\times \\mathbb{R}$ **Product Geometry**:',
        '7. **Spherical Cylinder Geometry** ($\\mathbb{S}^2 \\times \\mathbb{R}$):'
    )
    content = content.replace(
        '8. $\\mathbb{H}^2 \\times \\mathbb{R}$ **Product Geometry**:',
        '8. **Hyperbolic Cylinder Geometry** ($\\mathbb{H}^2 \\times \\mathbb{R}$):'
    )
    content = content.replace(
        '2. $\\mathrm{PSL}(2, \\mathbb{C})$ **Character Variety Scheme & Bridge Isomorphism**:',
        '2. **$\\mathrm{PSL}(2, \\mathbb{C})$ Character Variety Scheme & Bridge Isomorphism**:'
    )
    content = content.replace(
        '2. **$\\mathrm{PSL}(2, \\mathbb{C})$ Character Variety Scheme & Bridge Isomorphism**:',
        '2. **PSL(2, C) Character Variety Scheme & Bridge Isomorphism**:'
    )
    content = content.replace(
        '3. **Central Spin-Lift Cohomology Action &** $\\mathrm{SL}(2, \\mathbb{C})$ **Bridge Isomorphism**:',
        '3. **Central Spin-Lift Cohomology Action & SL(2, C) Bridge Isomorphism**:'
    )
    content = content.replace(
        '3. **Central Spin-Lift Cohomology Action & $\\mathrm{SL}(2, \\mathbb{C})$ Bridge Isomorphism**:',
        '3. **Central Spin-Lift Cohomology Action & SL(2, C) Bridge Isomorphism**:'
    )
    content = content.replace(
        '- $R > 0$: $\\mathbb{S}^3 (+6)$ and $\\mathbb{S}^2 \\times \\mathbb{R} (+2)$.',
        '   - **Positive Scalar Curvature** ($R > 0$): $\\mathbb{S}^3 (+6)$ and $\\mathbb{S}^2 \\times \\mathbb{R} (+2)$.'
    )
    content = content.replace(
        '- $R = 0$: $\\mathbb{E}^3 (0)$.',
        '   - **Zero Scalar Curvature** ($R = 0$): $\\mathbb{E}^3 (0)$.'
    )
    content = content.replace(
        '- $R < 0$: $\\mathbb{H}^3 (-6)',
        '   - **Negative Scalar Curvature** ($R < 0$): $\\mathbb{H}^3 (-6)'
    )

    # 6. Flatten indented ```math blocks to Column 0 and outdent 4+ space continuation lines
    lines = content.splitlines(keepends=False)
    new_lines = []
    in_math_block = False

    for idx, line in enumerate(lines):
        stripped = line.strip()
        if stripped == '```math':
            in_math_block = True
            if new_lines and new_lines[-1].strip() != '':
                new_lines.append('')
            new_lines.append('```math')
            continue

        if in_math_block:
            if stripped == '```':
                in_math_block = False
                new_lines.append('```')
                continue
            else:
                new_lines.append(line.strip())
                continue

        if len(new_lines) > 0 and new_lines[-1] == '```' and stripped != '':
            new_lines.append('')

        # Outdent 4+ spaces non-list continuation lines
        if re.match(r'^[ ]{4,}[^ \t\-*+\d>]', line):
            line = '   ' + line.lstrip()

        new_lines.append(line)

    content = '\n'.join(new_lines) + '\n'

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Applied fixes to {os.path.basename(filepath)} ({orig_len} -> {len(content)} chars)")

def run_strict_linter(fpath):
    with open(fpath, 'r', encoding='utf-8') as f:
        text = f.read()

    lines = text.splitlines(keepends=True)
    violations = []

    in_code_block = False
    in_display_math_code = False
    in_display_math_dollars = False

    for idx, raw_line in enumerate(lines):
        line_num = idx + 1
        line = raw_line.rstrip('\r\n')
        stripped = line.strip()

        # 1. Display math via ```math
        if stripped == '```math':
            if not in_display_math_code and not in_code_block:
                in_display_math_code = True
                # Rule 8: Column 0 check
                if not line.startswith('```math'):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 8: Display Math Block Alignment',
                        'detail': f"Opening '```math' is indented (not at Column 0): '{line}'"
                    })
                # Blank line before
                if idx > 0:
                    prev_line = lines[idx-1].rstrip('\r\n').strip()
                    if prev_line != '' and not prev_line.startswith('>'):
                        violations.append({
                            'file': fpath,
                            'line': line_num,
                            'rule': 'Rule 8: Display Math Blank Line Before',
                            'detail': f"No blank line before '```math'. Previous line: '{prev_line}'"
                        })
                continue

        if in_display_math_code:
            if stripped == '```':
                in_display_math_code = False
                # Rule 8: Closing ``` at column 0
                if not line.startswith('```'):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 8: Display Math Block Alignment',
                        'detail': f"Closing '```' is indented (not at Column 0): '{line}'"
                    })
                # Blank line after
                if idx + 1 < len(lines):
                    next_line = lines[idx+1].rstrip('\r\n').strip()
                    if next_line != '' and not next_line.startswith('>'):
                        violations.append({
                            'file': fpath,
                            'line': line_num,
                            'rule': 'Rule 8: Display Math Blank Line After',
                            'detail': f"No blank line after '```'. Next line: '{next_line}'"
                        })
                continue

            # Inside display math ```math block
            if r'\operatorname' in line:
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 11: Disallowed KaTeX Macro \\operatorname',
                    'detail': f"Found '\\operatorname' in display math (disallowed on GitHub, use '\\mathrm'): '{line.strip()}'"
                })
            if re.search(r'\\text(?:rm|bf|normal|it)?\{--\}', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 4: KaTeX Ligatures',
                    'detail': f"Found '\\text{{--}}' in display math: '{line.strip()}'"
                })
            mb_matches = re.findall(r'\\mathbf\{([^{}]*)\}', line)
            for inner in mb_matches:
                if re.search(r'=|\+|-|\\pm|\\times|\\le|\\ge|\\approx|\\neq|\\sim|\\to|\\equiv', inner):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 5: KaTeX \\mathbf with Operators',
                        'detail': f"Operator inside \\mathbf: '\\mathbf{{{inner}}}'"
                    })
            if re.search(r'(?<!\\)\*', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 7: Math Asterisk Escapes',
                    'detail': f"Raw '*' in display math: '{line.strip()}'"
                })
            continue

        # Standard code blocks (not ```math)
        if stripped.startswith('```'):
            in_code_block = not in_code_block
            continue

        if in_code_block:
            continue

        # 2. Display math via $$
        if stripped.startswith('$$'):
            is_blockquote = stripped.startswith('>') or line.lstrip().startswith('>')
            if not in_display_math_dollars:
                in_display_math_dollars = True
                if not is_blockquote and not line.startswith('$$'):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 8: Display Math Block Alignment',
                        'detail': f"Opening '$$' is indented (not at Column 0): '{line}'"
                    })
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
                in_display_math_dollars = False
                if not is_blockquote and not line.startswith('$$'):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 8: Display Math Block Alignment',
                        'detail': f"Closing '$$' is indented (not at Column 0): '{line}'"
                    })
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

        if in_display_math_dollars:
            if r'\operatorname' in line:
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 11: Disallowed KaTeX Macro \\operatorname',
                    'detail': f"Found '\\operatorname' in display math (disallowed on GitHub, use '\\mathrm'): '{line.strip()}'"
                })
            if re.search(r'\\text(?:rm|bf|normal|it)?\{--\}', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 4: KaTeX Ligatures',
                    'detail': f"Found '\\text{{--}}' in display math: '{line.strip()}'"
                })
            mb_matches = re.findall(r'\\mathbf\{([^{}]*)\}', line)
            for inner in mb_matches:
                if re.search(r'=|\+|-|\\pm|\\times|\\le|\\ge|\\approx|\\neq|\\sim|\\to|\\equiv', inner):
                    violations.append({
                        'file': fpath,
                        'line': line_num,
                        'rule': 'Rule 5: KaTeX \\mathbf with Operators',
                        'detail': f"Operator inside \\mathbf: '\\mathbf{{{inner}}}'"
                    })
            if re.search(r'(?<!\\)\*', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 7: Math Asterisk Escapes',
                    'detail': f"Raw '*' in display math: '{line.strip()}'"
                })
            continue

        # In standard prose / table line
        # Rule 12: 4+ space indented prose block (triggers code block in CommonMark)
        if re.match(r'^[ ]{4,}[^ \t\-*+\d>]', line):
            violations.append({
                'file': fpath,
                'line': line_num,
                'rule': 'Rule 12: 4+ Space Indented Prose',
                'detail': f"Prose line indented by 4+ spaces (parsed as indented code block by CommonMark): '{line}'"
            })

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

        # Rule 10: Leading math in list item prefix (e.g. "6. $math$ **Label**:")
        if re.match(r'^\s*(\d+\.|[-*+])\s+\$', line):
            violations.append({
                'file': fpath,
                'line': line_num,
                'rule': 'Rule 10: Leading Math in List Prefix',
                'detail': f"List item starts with inline math before label: '{line.strip()}'"
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
        is_table = line.strip().startswith('|') and line.strip().endswith('|')

        for m in inline_spans:
            math_content = m.group(1)
            full_match = m.group(0)

            # Rule 11: Disallowed \operatorname macro
            if r'\operatorname' in math_content:
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 11: Disallowed KaTeX Macro \\operatorname',
                    'detail': f"Found '\\operatorname' in inline math (disallowed on GitHub, use '\\mathrm'): '{full_match}'"
                })

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

            # Rule 13: Lie Group & Matrix Group Underscore Subscripts & Extensible Font Accents
            if re.search(r'\\(?:widetilde\{\\mathrm\{SL\}\}|tilde\{\\mathrm\{SL\}\}|mathrm\{SL\}|mathrm\{PSL\}|mathfrak\{sl\}|mathrm\{GL\}|mathrm\{SO\}|mathrm\{SU\})_\{?[0-9a-zA-Z]+\}?', math_content):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 13: Lie Group Underscore Subscript',
                    'detail': f"Lie group with underscore subscript (causes CommonMark emphasis collision, use parameter syntax like '\\mathrm{{SL}}(2, \\mathbb{{R}})' or '\\mathrm{{SU}}(2)'): '{full_match}'"
                })
            # Rule 14: Parenthesis Delimiter Nesting Collision
            # Flag ($math$) where math contains ( or )
            if re.search(r'\(\$(?:[^\$\n]*[\(\)][^\$\n]*)\$\)', line):
                violations.append({
                    'file': fpath,
                    'line': line_num,
                    'rule': 'Rule 14: Parenthesis Delimiter Collision',
                    'detail': f"Outer '($...$)' wrapping math with internal parentheses creates delimiter parser collision. Move parentheses inside math '$ ( ... ) $': '{line.strip()}'"
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
