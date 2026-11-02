#!/usr/bin/env python3
"""Adapt the sibling BASIC source for the FLEX command build."""
from pathlib import Path
import sys

# BASIC starts at $0000, has its own no-echo console, and uses B for characters.
basic = Path(sys.argv[1] if len(sys.argv) > 1 else '../roms/basic680/c68basic.s').read_text()
assert 'Z1926   INX' in basic
basic = basic.replace('Z1926   INX', '''Z1926   INX
        CPX     #$8000
        BEQ     Z1946''')
# Clamp explicit MEMORY SIZE answers too, not just automatic probing.
basic = basic.replace('Z1946   DEX', """Z1946   CPX     #$8000
        BLS     C68BASLIMIT
        LDX     #$8000
C68BASLIMIT DEX""")
# BASIC marks the final string character with bit 7; a 7-bit terminal used to
# discard it. Our ACIA is 8-bit, so discard it in the output routine instead.
basic = basic.replace('                tab\n                stab aciad',
                      '                anda #$7f\n                tab\n                stab aciad')
Path('build/msbasic.asm').write_text(basic)
