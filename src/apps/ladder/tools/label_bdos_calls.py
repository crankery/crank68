"""Name CP/M BDOS calls in a z80dasm listing without changing numeric constants."""

from pathlib import Path
import re


listing = Path("analysis/disasm/ladder_110.asm")
source = listing.read_text()
if "BDOS:\tequ 0x0005" not in source:
    source = source.replace("\torg 00100h\n", "\torg 00100h\n; CP/M BDOS entry\nBDOS:\tequ 0x0005\n", 1)
source = re.sub(r"(\tcall(?: [a-z]+,| ))00005h(?=\t)", r"\1BDOS", source)

functions = {
    0x05: "list output",
    0x06: "direct console I/O",
    0x09: "print string",
    0x0C: "get version number",
    0x0D: "reset disk system",
    0x0E: "select disk",
    0x0F: "open file",
    0x10: "close file",
    0x11: "search for first",
    0x12: "search for next",
    0x13: "delete file",
    0x14: "write sequential",
    0x16: "make file",
    0x17: "rename file",
    0x19: "get current disk",
    0x1A: "set DMA address",
}
lines = source.splitlines(keepends=True)
for call_index in reversed(range(len(lines))):
    if not re.match(r"\tcall(?: [a-z]+,| )BDOS\t", lines[call_index]):
        continue
    for setup_index in range(call_index - 1, max(-1, call_index - 11), -1):
        setup = lines[setup_index]
        match = re.match(r"\tld c,([0-9a-f]+)h\t", setup)
        if match:
            number = int(match.group(1), 16)
            comment = f"; BDOS {number}: {functions[number]}\n"
        elif "\tld bc,0ff05h\t" in setup:
            comment = "; BDOS 5: list output (C is the low byte of BC)\n"
        elif "\tld c,a\t" in setup:
            comment = "; BDOS function number comes from A\n"
        else:
            continue
        if setup_index == 0 or lines[setup_index - 1] != comment:
            lines.insert(setup_index, comment)
        break
    else:
        raise ValueError(f"No BDOS function setup found before: {lines[call_index].strip()}")

listing.write_text("".join(lines))
