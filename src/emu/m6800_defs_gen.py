#!/usr/bin/env python3

import csv
from dataclasses import dataclass
from pathlib import Path
import sys


@dataclass
class OpInfo:
    op_name_s: str
    op_name: str
    addr_mode: str
    cycles: int


HEADER_TEXT = """\
#pragma once

#include <cstdint>

enum addr_mode : uint8_t
{
    inh, /* inherent */
    rel, /* relative */
    imb, /* immediate (byte) */
    imw, /* immediate (word) */
    dir, /* direct address */
    ext, /* extended address */
    idx  /* x + byte offset */
};

enum class op_names : uint8_t;

struct OpInfo
{
    const char *op_name_s;
    op_names op_name;
    addr_mode addr_mode;
    uint8_t cycles;
    bool valid;
};

extern const OpInfo m6800_op_table[256];

"""

CPP_PREAMBLE_F = """\
#include "{header_path}"

const OpInfo m6800_op_table[256] =
{{
"""

CPP_POSTAMBLE = """\
};
"""


def parse_opcode_byte(s: str) -> int:
    s = s.strip()
    return int(s, 16)


def load_csv(csv_path: Path) -> dict[int, OpInfo]:
    table: dict[int, OpInfo] = {}

    with csv_path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        required = {"opcode_byte", "mnemonic", "addr_mode", "cycles"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"CSV missing required columns: {sorted(missing)}")

        for row in reader:
            opcode = parse_opcode_byte(row["opcode_byte"])
            op_name_s = row["mnemonic"].strip().lower()
            op_name = f"op_names::{row["mnemonic"].strip().lower()}"
            addr_mode = row["addr_mode"].strip()
            cycles = int(row["cycles"].strip())

            if opcode < 0 or opcode > 0xFF:
                raise ValueError(f"Opcode out of range: {row['opcode_byte']}")

            if opcode in table:
                raise ValueError(f"Duplicate opcode in CSV: {row['opcode_byte']}")

            table[opcode] = OpInfo(op_name_s, op_name, addr_mode, cycles)

    return table


def emit_header(header_path: Path, csv_file: Path) -> None:
    lines = [HEADER_TEXT]

    ops = []
    with open(csv_file) as f:
        reader = csv.DictReader(f)
        for row in reader:
            op = row["mnemonic"]
            if op not in ops:
                ops.append(op)

    lines.append("enum class op_names : uint8_t\n")
    lines.append("{\n")
    for op in ops:
        lines.append(f"    {op},\n")
    lines.append("    invalid\n")
    lines.append("};\n")
    lines.append("\n");

    out = "".join(lines)

    header_path.write_text(out, encoding="utf-8")


def emit_cpp(cpp_path: Path, h_path: Path, entries: dict[int, OpInfo]) -> None:
    lines = [CPP_PREAMBLE_F.format(header_path=h_path)]

    for opcode in range(256):
        if opcode in entries:
            op = entries[opcode]
            line = (
                f'    {{ "{op.op_name_s}", {op.op_name}, {op.addr_mode}, {op.cycles}, true }}, '
                f"// 0x{opcode:02X}\n"
            )
        else:
            line = (
                f'    {{ "invalid", op_names::invalid, inh, 0, false }}, '
                f"// 0x{opcode:02X}\n"
            )
        lines.append(line)

    lines.append(CPP_POSTAMBLE)

    out = "".join(lines)

    cpp_path.write_text(out, encoding="utf-8")


def main() -> None:
    if len(sys.argv) == 4:
        csv_path = Path(sys.argv[1])
        header_path = Path(sys.argv[2])
        cpp_path = Path(sys.argv[3])

        entries = load_csv(csv_path)
        emit_header(header_path, csv_path)
        emit_cpp(cpp_path, header_path, entries)

        print(f"Loaded {len(entries)} documented opcodes from {csv_path}")
        print(f"Wrote {header_path}")
        print(f"Wrote {cpp_path}")
    else:
        print(f"usage: python3 {sys.argv[0]} [source.csv] [output.h] [output.cpp]")

if __name__ == "__main__":
    main()