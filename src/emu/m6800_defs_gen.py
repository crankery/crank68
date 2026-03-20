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


def emit_defs_header(header_path: Path, header_template_path: Path, csv_file: Path) -> None:
    template = header_template_path.read_text(encoding="utf-8")
    lines = []
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
    template = template.replace("{{defs_h}}", out)
    header_path.write_text(template, encoding="utf-8")

def emit_defs_cpp(cpp_path: Path, cpp_template_path: Path, entries: dict[int, OpInfo]) -> None:
    template = cpp_template_path.read_text(encoding="utf-8")
    lines = [];
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

    out = "".join(lines)
    template = template.replace("{{defs_cpp}}", out)
    cpp_path.write_text(template, encoding="utf-8")

def main() -> None:
    print(f"{len(sys.argv)}\n");
    if len(sys.argv) == 6:
        csv_path = Path(sys.argv[1])
        defs_header_path = Path(sys.argv[2])
        defs_header_template_path = Path(sys.argv[3])
        defs_cpp_path = Path(sys.argv[4])
        defs_cpp_template_path = Path(sys.argv[5])

        entries = load_csv(csv_path)
        emit_defs_header(defs_header_path, defs_header_template_path, csv_path)
        emit_defs_cpp(defs_cpp_path, defs_cpp_template_path, entries)

        print(f"Loaded {len(entries)} documented opcodes from {csv_path}")
        print(f"Wrote {defs_header_path}")
        print(f"Wrote {defs_cpp_path}")
    else:
        print(f"usage: python3 {sys.argv[0]} [source.csv] [defs.h] [defs_h.template] [defs.cpp] [defs_cpp.template]")

if __name__ == "__main__":
    main()