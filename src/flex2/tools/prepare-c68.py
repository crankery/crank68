#!/usr/bin/env python3
"""Apply the C68 hardware changes to the verified syntax-only source."""
from pathlib import Path
import re

s = Path('build/flex21.asm').read_text()
# Console and monitor exit are local routines, independent of ROM addresses.
for name, value in {'INCH1':'C68ECHO', 'INCH21':'C68ECHO', 'OUTCH1':'C68OUT',
                    'OUTC21':'C68OUT', 'CTLPOR':'$E010', 'MONITR':'C68MON'}.items():
    s, n = re.subn(rf'(?m)^({name}\s+EQU\s+)\S+', rf'\g<1>{value}', s)
    assert n == 1, name
# Timer interrupts and timer writes are unavailable. Keep instruction sizes so
# FLEX's original self-modifying operand offsets remain valid.
s = s.replace('SPOOL1\tLDAA\tTIMERA+2\tCLEAR TIMER INTERRUPT',
              'SPOOL1 RTI\n NOP\n NOP')
s = re.sub(r'(?m)^\s+STAA\s+TIMERA\+2[^\n]*', ' NOP\n NOP\n NOP', s)
# Do not allow FMEME to patch the NOPs above back into timer accesses.
s = re.sub(r'(?m)^\s+STX\s+(?:SPOOL1\+1|SCH4\+3)[^\n]*', ' NOP\n NOP\n NOP', s)
# Historical DRVX6 computes drive*6 in A, then mistakenly uses TBA.
# Transfer A to B so each drive gets its own six-byte free-chain cache.
s, n = re.subn(r'(?m)^\s*TBA(\s+INTO B[^\n]*)$', r' TAB\1', s)
assert n == 1, 'DRVX6 cache offset'
# No background printer is supported; make queue scheduler return immediately.
s = s.replace('SCH1\tNOP', 'SCH1 RTS')
# Replace only the physical disk implementation; keep the ABI and vector table.
start = s.index('\tORG\tBASE+$1EB3')
end = s.index('* AUTOBLOCK', start)
s = s[:start] + ''' org BASE+$1EB3
READ1 JMP C68READ
WRIT1 JMP C68WRITE
VER1 JMP C68OK
REST1 JMP C68DRIVE
DRVS1 JMP C68DRIVE
CDRR1 JMP C68READY
''' + s[end:]
s = s.replace(' end', '')
# Retain the flat binary's $A100 base; utilities may overwrite this padding.
s += '\n org $A100\n fcb 0\n org $BF00\n' + Path('platform/console.asm').read_text()
s += '\n' + Path('platform/ramdisk.asm').read_text() + '\n org $BFF8\nC68TICKS fdb 0\n end\n'
Path('build/c68flex.asm').write_text(s)
