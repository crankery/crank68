#!/usr/bin/env python3

# translate ancient assembly for the M6800 to build with vasm6800_std
# this is not expected to be complete
# tested with mikbug2, tsc microbasic

from pathlib import Path
import re
import shlex
import sys

accumulators = ["A", "B"]
accumulatorDirectives = ["ADC", "ADD", "AND", "ASL", "ASR", "BIT", "COM", "CLR", "CMP", "DEC", "EOR", "INC", "LDA", "LSR", "ORA", "NEG", "PSH", "PUL", "ROL", "ROR", "SBC", "STA", "SUB", "TST"]

instructionDict = {
    "equ": ".equ",
    "rmb": ".space",
    "org": ".org",
    "fdb": ".word", # form double byte
    "fcb": ".byte", # form constant bytes
    "fcc": ".byte", # form constant characters
    "end": "; end of listing"
}

implicitInstructions = [
    "asla",
    "aslb",
    "aba",
    "clc",
    "cld",
    "cli",
    "clra",
    "clrb",
    "clv",
    "daa",
    "des",
    "dex",
    "deca",
    "decb",
    "ins",
    "inx",
    "inca",
    "incb",
    "lsra",
    "lsrb",
    "nega",
    "negb",
    "psha",
    "pshb",
    "pula",
    "pulb",
    "rola",
    "rolb",
    "rora",
    "rorb",
    "sec",
    "sei",
    "sed",
    "sev",
    "rts",
    "rti",
    "tab",
    "tap",
    "tba",
    "tsta",
    "tstb",
    "tsx"
]

def fix_instruction(instruction: str) -> str:
    if instruction in instructionDict:
        return instructionDict[instruction]
    else:
        return instruction

import re

line_re = re.compile(
    r'''
    ^(?:
        (?P<label>[A-Za-z_.$][\w.$]*:)?   # optional label
    )?
    [ \t]*
    (?P<op>\.[A-Za-z]+|[A-Za-z]+)?        # opcode or directive
    [ \t]*
    (?P<arg>[^;]*)?                       # operand field
    (?P<comment>;.*)?                     # optional comment
    $
    ''',
    re.VERBOSE
)

import re

asm_re = re.compile(r'''
    ^
    \s*
    (?:(?P<label>[A-Za-z_.$][\w.$]*:)\s*)?
    (?P<op>\.[A-Za-z]+|[A-Za-z][\w.]*)?
    (?:\s+(?P<arg>[^;]*?))?
    \s*
    (?P<comment>;.*)?
    $
''', re.VERBOSE)

OPCOL = 12
COMMENTCOL = 40

def format_line(line: str) -> str:
    line = line.rstrip("\n")

    if not line.strip():
        return ""

    if line.lstrip().startswith(";"):
        return line.lstrip()

    m = asm_re.match(line.expandtabs(12))
    if not m:
        return line.expandtabs(12)

    label = m.group("label") or ""
    op = m.group("op") or ""
    arg = (m.group("arg") or "").strip()
    comment = m.group("comment") or ""

    out = ""

    if label:
        out += label
    if len(out) < OPCOL:
        out += " " * (OPCOL - len(out))
    else:
        out += " "

    if op:
        out += op

    if arg:
        out += " " + arg

    if comment:
        if len(out) < COMMENTCOL:
            out += " " * (COMMENTCOL - len(out))
        else:
            out += "  "
        out += comment

    return out.rstrip()

def xlate(file_path: Path) -> list[str]:
    lines1 = []

    # clean up comments and fix accumulator directives
    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith("*<") or line.startswith("*>"):
                lines1.append(line.rstrip())
                continue
            else:
                # replace all whitespace with single spaces
                l = re.sub(r'\s+', ' ', line).rstrip() + " "

                # fix single line comments
                if l.startswith("*"):
                    lines1.append(f";{l.replace('*', '')}")
                    continue

                firstSpace = l.find(" ")
                secondSpace = l.find(" ", firstSpace + 1) if firstSpace >= 0 else -1
                thirdSpace = l.find(" ", secondSpace + 1) if secondSpace >= 0 else -1
                
                if firstSpace >= 0 and secondSpace >= 0 and thirdSpace >= 0:
                    op = l[firstSpace + 1:secondSpace]
                    acc = l[secondSpace + 1: thirdSpace]

                    if acc in accumulators and op in accumulatorDirectives:
                        l = l[0:firstSpace] + " " \
                            + f"{op}{acc} " \
                            + l[thirdSpace+1:] + " "

                lines1.append(l.rstrip())

    out = []
    for line in lines1:
        if line.startswith("*<"):
            # skip over line removal marker
            continue 

        elif line.startswith("*>"):
            # add verbatim substitution
            out.append(line[2:])
            continue

        # try to fix it
        line = line.lower()

        if (len(line) == 0):
            out.append(line)
            continue

        if (line.startswith(";")):
            out.append(line)
            continue

        # this is going to require adding the closing ' on #' literals
        literalIndex = line.find("#'")
        if (literalIndex != -1):
            line = f"{line[0:literalIndex-1]} {line[literalIndex:literalIndex+3]}\'{line[literalIndex+3:]}"

        fields = []
        field = ""
        inQuotes = False
        inSingleQuotes = False
        for c in line:
            if c.isspace() and not inQuotes and not inSingleQuotes:
                fields.append(field.strip())
                field = ""

            if c == ';' or c == '/':
                field += "\""
                inQuotes = not inQuotes
            elif c == '\'':
                # this doesn't quite work for lines like " MCL FCB $A,$D,$14,0,0,0,0,'*,4 LF,CR,PUNCH"
                # a singe quote should consume the next character as the value and only worry about the value after that if it's another single quote
                field += "\'"
                if (inSingleQuotes):
                    fields.append(field.strip())
                    field = ""
                inSingleQuotes = not inSingleQuotes
            else:
                field += c

        if (field):
            fields.append(field.strip())

        label = fields.pop(0) if len(fields) > 0 else ""
        label = label + ":" if label else ""

        instruction = fields.pop(0) if len(fields) > 0 else ""
        instruction = fix_instruction(instruction)

        operand = ""
        if (instruction not in implicitInstructions):
            operand = fields.pop(0) if len(fields) > 0 else ""
            operand = operand.replace("$", "0x")
            operand = operand.replace("%", "0b")

        if operand == "*" and instruction == ".equ":
            # just convert these to labels
            operand = ""
            instruction = ""

        comment = f'; {" ".join(fields)}' if len(fields) > 0 else ""

        if (instruction == ".equ"):
            out.append(f"\t{instruction} {label[:len(label)-1]}, {operand}\t{comment}".rstrip()) 
        else:
            out.append(f"{label}\t{instruction}{" " if operand else ""}{operand}\t{comment}".rstrip())

    fixed = []
    for line in out:
        f = re.sub(r'(["\'])(.*?)\1', lambda m: m.group(1) + m.group(2).upper() + m.group(1), line)
        fixed.append(format_line(f))

    return fixed

def main() -> None:
    
    if len(sys.argv) == 2:
        sourcePath = Path(sys.argv[1])
        out = xlate(sourcePath)

        print ("\r\n".join(out))

if __name__ == "__main__":
    main()