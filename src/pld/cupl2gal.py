#!/usr/bin/env python3

import re
import sys
from pathlib import Path

DEVICE_MAP = {
    "g16v8": "GAL16V8",
    "g20v8": "GAL20V8",
    "g22v10": "GAL22V10",
}

IGNORE_PREFIXES = {
    "name", "partno", "date", "revision",
    "designer", "company", "assembly", "location"
}


def remove_comments(text):

    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r";.*", "", text)

    return text


def fix_name(name):

    name = name.strip()

    if name.startswith("/"):
        name = name[1:]

    return name


def fix_expr(expr):

    expr = expr.replace("#", "|")

    expr = re.sub(
        r'(?<![A-Za-z0-9_])/([A-Za-z_][A-Za-z0-9_]*)',
        r'\1',
        expr
    )

    expr = re.sub(r"\s+", " ", expr)

    return expr.strip()


def convert_statement(stmt):

    stmt = stmt.strip()

    if not stmt:
        return None

    m = re.match(r"(?i)^device\s+([A-Za-z0-9_]+)$", stmt)

    if m:
        dev = m.group(1).lower()

        if dev in DEVICE_MAP:
            return DEVICE_MAP[dev]

        raise ValueError(f"Unsupported device {dev}")

    first = stmt.split()[0].lower()

    if first in IGNORE_PREFIXES:
        return None

    m = re.match(r"(?i)^pin\s+(\d+)\s*=\s*(.+)$", stmt)

    if m:
        pin = m.group(1)
        sig = fix_name(m.group(2))

        return f"PIN {pin} = {sig}"

    if "=" in stmt:

        lhs, rhs = stmt.split("=", 1)

        lhs = fix_name(lhs)
        rhs = fix_expr(rhs)

        return f"{lhs} = {rhs}"

    return None


def convert_text(text):

    text = remove_comments(text)

    statements = text.split(";")

    out = []

    for stmt in statements:

        converted = convert_statement(stmt)

        if converted:
            out.append(converted)

    return "\r\n".join(out) + "\r\n"


def main():

    if len(sys.argv) < 2:
        print("usage: cupl2gal.py input.pld [output.pld]")
        sys.exit(1)

    inp = Path(sys.argv[1]).read_text()

    result = convert_text(inp)

    if len(sys.argv) == 3:
        Path(sys.argv[2]).write_text(result)
    else:
        print(result)


if __name__ == "__main__":
    main()

