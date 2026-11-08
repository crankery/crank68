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
# C68's VT100-style terminal needs the erase sequence after echoing BS.
s, n = re.subn(r'(?m)^BSECHO\s+FCB\s+0(\s+BACKSPACE ECHO CHAR)$',
               r'BSECHO FCB 8\1', s)
assert n == 1, 'backspace echo default'
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
# FLEX folds case in its resident-command table, but file lookup sees the
# original FCB name. Wrap the parser at its public vector and internal calls,
# leaving the line buffer and input delivered to programs untouched.
s, n = re.subn(r'(?m)^(GETFIL\s+JMP\s+)GETFI1(\s+GET FILE SPECIFICATION)$',
               r'\1C68FILECASE\2', s)
assert n == 1, 'public file parser vector'
s, n = re.subn(r'(?m)^(\s+JSR\s+)GETFI1(\s+GET FILE NAME(?: FROM BUFFER)?)$',
               r'\1C68FILECASE\2', s)
assert n == 2, 'internal file parser calls'
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
# The SD byte transport lives in MIKBUG ROM. Thin adapters fit after the
# complete startup FCB, without consuming application memory.
s += '\n org $A400\n' + Path('platform/sound.asm').read_text()
s += '\n org $A980\n' + Path('platform/sdcard.asm').read_text()
s += '\n' + Path('platform/cmdcase.asm').read_text()
s += '\n org $A100\n fcb 0\n org $BF00\n' + Path('platform/console.asm').read_text()
s += '\n' + Path('build/drive-config.asm').read_text()
s += '\n' + Path('platform/ramdisk.asm').read_text() + '\n org $BFF8\nC68TICKS fdb 0\n end\n'
Path('build/c68flex.asm').write_text(s)
