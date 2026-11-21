#!/usr/bin/env python3
"""Make syntax-only adaptations; preserve original source line numbers."""
from pathlib import Path
import re

lines = []
for line in Path('6800Flex/FLEX21.ASM').read_text().splitlines():
    if re.match(r'\s+(TTL|PAG)\b', line):
        line = '; ' + line
    elif re.match(r'\s+END\b', line):
        line = ' end'
    else:
        line = re.sub(r'(\bEQU\s+)\$(?=\s*$)', r'\1*', line)
        # Rename only the label and its reference, never SWI instructions.
        line = re.sub(r'^SWI(?=\s)', 'SWIENT', line)
        line = re.sub(r'#SWI\b', '#SWIENT', line)
    if re.match(r'\s+ORG\s+FMSFLG\+\$19', line):
        # FMSFLG is BASE+$C30; vasm ORG requires an absolute expression.
        line = ' org BASE+$C49'
    if re.match(r'\s+SWI\b', line):
        line = re.sub(r'^(\s+SWI)\s*(.*)$', r'\1 ; \2', line)
    if 'FCC' in line and chr(92) in line:
        line = line.replace(chr(92), '"')
    lines.append(line)
Path('build').mkdir(exist_ok=True)
Path('build/flex21.asm').write_text('\n'.join(lines) + '\n')
