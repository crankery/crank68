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
    "clv",
    "cli",
    "cld",
    "daa",
    "clra",
    "clrb",
    "deca",
    "decb",
    "dex",
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

def xlate(file_path: Path) -> list[str]:
    lines1 = []

    # clean up comments and fix accumulator directives
    with open(file_path, 'r') as file:
        for line in file:
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

        if operand == "*" and instruction == ".equ":
            # just convert these to labels
            operand = ""
            instruction = ""

        comment = f'; {" ".join(fields)}' if len(fields) > 0 else ""

        if (instruction == ".equ"):
            out.append(f"\t{instruction} {label[:len(label)-1]}, {operand}\t{comment}".rstrip()) 
        else:
            out.append(f"{label}\t{instruction}{" " if operand else ""}{operand}\t{comment}".rstrip())

    return out

def main() -> None:
    
    if len(sys.argv) == 2:
        sourcePath = Path(sys.argv[1])
        out = xlate(sourcePath)

        print ("\r\n".join(out))

if __name__ == "__main__":
    main()