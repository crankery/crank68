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

def get_op_names(entries: dict[int, OpInfo]) -> list[str]:
    op_names = []
    for opcode in range(256):
        if opcode in entries:
            op = entries[opcode]
            op_name = op.op_name_s
            if op_name not in op_names:
                op_names.append(op_name)

    op_names.sort()
    return op_names

def emit_defs_header(header_path: Path, header_template_path: Path, entries: dict[int, OpInfo]) -> None:
    template = header_template_path.read_text(encoding="utf-8")
    lines = []
    op_names = get_op_names(entries)
    lines.append("enum class op_names : uint8_t\n")
    lines.append("{\n")
    for op_name in op_names:
        lines.append(f"    {op_name},\n")
    lines.append("    inv\n")
    lines.append("};\n")
    lines.append("\n");

    out = "".join(lines)
    template = template.replace("{{defs_h}}", out)
    header_path.write_text(template, encoding="utf-8")

    print(f"wrote {header_path}")


def emit_defs_cpp(cpp_path: Path, cpp_template_path: Path, entries: dict[int, OpInfo]) -> None:
    template = cpp_template_path.read_text(encoding="utf-8")
    lines = []
    for opcode in range(256):
        if opcode in entries:
            op = entries[opcode]
            line = (
                f'    {{ "{op.op_name_s}", {op.op_name}, {op.addr_mode}, {op.cycles}, true }}, '
                f"// 0x{opcode:02X}\n"
            )
        else:
            line = (
                f'    {{ "inv", op_names::inv, inh, 0, false }}, '
                f"// 0x{opcode:02X}\n"
            )
        lines.append(line)

    out = "".join(lines)
    template = template.replace("{{defs_cpp}}", out)
    cpp_path.write_text(template, encoding="utf-8")

    print(f"wrote {cpp_path}")


def emit_dispatch_cpp(dispatch_cpp_path: Path, operations_cpp_path: Path, dispatch_cpp_template_path: Path, entries: dict[int, OpInfo]) -> None:
    impl = operations_cpp_path.read_text(encoding="utf-8")
    template = dispatch_cpp_template_path.read_text(encoding="utf-8")

    lines = []
    
    op_names = get_op_names(entries)
    for op_name in op_names:
        decl = f"op_{op_name}(uint8_t opcode, op_names op, addr_mode mode)"
        implemented = impl.find(decl) >= 0

        lines.append(f"    {"" if implemented else "// "}case op_names::{op_name}:\n")
        lines.append(f"    {"" if implemented else "// "}    result = op_{op_name}(op, op_info.op_name, op_info.addr_mode);\n")            
        lines.append(f"    {"" if implemented else "// "}    break;\n")

    out = "".join(lines)
    template = template.replace("{{dispatch_cpp}}", out)
    dispatch_cpp_path.write_text(template, encoding="utf-8")

    print(f"wrote {dispatch_cpp_path}")


def emit_operations_header(operations_header_path: Path, operations_cpp_path: Path, operations_header_template_path: Path,entries: dict[int, OpInfo]) -> None:
    impl = operations_cpp_path.read_text(encoding="utf-8")
    template = operations_header_template_path.read_text(encoding="utf-8")
    lines = []

    op_names = get_op_names(entries)
    for op_name in op_names:
        decl = f"op_{op_name}(uint8_t opcode, op_names op, addr_mode mode)"
        implemented = impl.find(decl)

        lines.append(f"    {"" if implemented >= 0 else "// "}bool {decl};\n");

    out = "".join(lines)
    template = template.replace("{{operations}}", out)
    operations_header_path.write_text(template, encoding="utf-8")

    print(f"wrote {operations_header_path}")


def main() -> None:
    CPU_OPERATIONS = "cpu_operations"
    CPU_OPERATIONS_CSV = Path(f"{CPU_OPERATIONS}.csv")
    CPU_OPERATIONS_H_IN = Path(f"{CPU_OPERATIONS}_h.in")
    CPU_OPERATIONS_H = Path(f"{CPU_OPERATIONS}.g.h")
    CPU_OPERATIONS_CPP = Path(f"{CPU_OPERATIONS}.cpp")
    
    CPU_DEFS = "cpu_defs"
    CPU_DEFS_H = Path(f"{CPU_DEFS}.g.h")
    CPU_DEFS_H_IN = Path(f"{CPU_DEFS}_h.in")
    CPU_DEFS_CPP = Path(f"{CPU_DEFS}.g.cpp")
    CPU_DEFS_CPP_IN = Path(f"{CPU_DEFS}_cpp.in")

    CPU_DISPATCH = "cpu_dispatch"
    CPU_DISPATCH_CPP = Path(f"{CPU_DISPATCH}.g.cpp")
    CPU_DISPATCH_CPP_IN = Path(f"{CPU_DISPATCH}_cpp.in")

    entries = load_csv(CPU_OPERATIONS_CSV)

    print(f"Loaded {len(entries)} documented opcodes from {CPU_OPERATIONS_CSV}")

    emit_defs_header(CPU_DEFS_H, CPU_DEFS_H_IN, entries)
    emit_defs_cpp(CPU_DEFS_CPP, CPU_DEFS_CPP_IN, entries)
    emit_dispatch_cpp(CPU_DISPATCH_CPP, CPU_OPERATIONS_CPP, CPU_DISPATCH_CPP_IN, entries)
    emit_operations_header(CPU_OPERATIONS_H, CPU_OPERATIONS_CPP, CPU_OPERATIONS_H_IN, entries)

if __name__ == "__main__":
    main()