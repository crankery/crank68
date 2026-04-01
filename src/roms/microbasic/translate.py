#!/usr/bin/env python3

from pathlib import Path
import re
import shlex

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
            l = line.rstrip() + " "

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
                    # print("0:" + l + f"({len(lines1)})" )
                    # print("1:" + l[0:firstSpace] + " ")
                    # print(f"A: |{l[firstSpace+1:thirdSpace]}| |{directive}{acc}|")
                    # print("2:" + f"{directive}{acc} ")
                    # print("3:" + l[thirdSpace+1:]+ " ")
                    l = l[0:firstSpace] + " " \
                        + f"{op}{acc} " \
                        + l[thirdSpace+1:] + " "
                    # print("4:" + l)

                    #print(f"0: |{op}{acc}| |{l}|" )

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

            if c == ';':
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

        if operand == "*":
            operand = label[:len(label)-1]

        comment = f'; {" ".join(fields)}' if len(fields) > 0 else ""

        if (instruction == ".equ"):
            out.append(f"\t{instruction} {label[:len(label)-1]}, {operand}\t{comment}".rstrip()) 
        else:
            out.append(f"{label}\t{instruction}{" " if operand else ""}{operand}\t{comment}".rstrip())

    return out

def main() -> None:
    out = xlate(Path('microbas.asm'))

    for line in out:
        print(line)

if __name__ == "__main__":
    main()