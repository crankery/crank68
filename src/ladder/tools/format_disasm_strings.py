"""Render self-contained Ladder string descriptors as readable Z80 data."""

from pathlib import Path
import re


COM = Path("cpm/LADDER.COM")
LISTING = Path("analysis/disasm/ladder_110.asm")
FIRST_DATA = 0x58DF
END_DATA = 0x617D
ORIGIN = 0x0100
CHUNK = 48
RAW_TEXT = ((0x6167, 0x617D),)

byte_line = re.compile(r"^\tdefb ([0-9a-f]{3})h\t\t;([0-9a-f]{4})\t([0-9a-f]{2})\t")
label_line = re.compile(r"^([A-Za-z_][A-Za-z_0-9]*):$")


def data_line(directive: str, address: int, raw: bytes) -> str:
    hex_bytes = " ".join(f"{value:02x}" for value in raw)
    ascii_bytes = "".join(chr(value) if 32 <= value <= 126 else "." for value in raw)
    return f"\t{directive}\t\t;{address:04x}\t{hex_bytes}\t\t|{ascii_bytes}|\n"


def main() -> None:
    binary = COM.read_bytes()
    lines = LISTING.read_text().splitlines(keepends=True)
    bytes_in_listing: dict[int, int] = {}
    labels: set[int] = set()
    pending_label = False
    for line in lines:
        if label_line.match(line.strip()):
            pending_label = True
            continue
        match = byte_line.match(line)
        if match:
            address = int(match[2], 16)
            bytes_in_listing[address] = int(match[3], 16)
            if pending_label:
                labels.add(address)
        pending_label = False

    replacements: dict[int, str] = {}
    skip: set[int] = set()
    records = 0
    for address in range(FIRST_DATA, END_DATA - 3):
        offset = address - ORIGIN
        length = binary[offset]
        pointer = int.from_bytes(binary[offset + 1 : offset + 3], "little")
        end = pointer + length
        if pointer != address + 3 or not length or end > END_DATA:
            continue
        content = binary[pointer - ORIGIN : end - ORIGIN]
        if not all(32 <= value <= 126 for value in content):
            continue
        if any(bytes_in_listing.get(pos) != binary[pos - ORIGIN] for pos in range(address, end)):
            raise ValueError(f"Listing does not match string at ${address:04X}")
        if any(pos in skip or pos in replacements for pos in range(address, end)):
            raise ValueError(f"Overlapping descriptor at ${address:04X}")

        replacements[address] = data_line(f"defb {length:03x}h", address, bytes([length]))
        replacements[address + 1] = data_line(
            f"defw {pointer:05x}h", address + 1, binary[offset + 1 : offset + 3]
        )
        skip.add(address + 2)

        pos = pointer
        while pos < end:
            value = binary[pos - ORIGIN]
            if value in (ord('"'), ord("\\")):
                replacements[pos] = data_line(f"defb {value:03x}h", pos, bytes([value]))
                pos += 1
                continue
            segment_end = pos
            while segment_end < end and segment_end - pos < CHUNK:
                next_value = binary[segment_end - ORIGIN]
                if next_value in (ord('"'), ord("\\")) or (segment_end > pos and segment_end in labels):
                    break
                segment_end += 1
            if segment_end < end and segment_end - pos == CHUNK and segment_end not in labels:
                space = binary.rfind(b" ", pos - ORIGIN + 1, segment_end - ORIGIN)
                if space >= pos - ORIGIN + CHUNK // 2:
                    segment_end = space + ORIGIN + 1
            raw = binary[pos - ORIGIN : segment_end - ORIGIN]
            replacements[pos] = data_line(f'defm "{raw.decode("ascii")}"', pos, raw)
            skip.update(range(pos + 1, segment_end))
            pos = segment_end
        records += 1

    for start, end in RAW_TEXT:
        raw = binary[start - ORIGIN : end - ORIGIN]
        if not all(32 <= value <= 126 and value not in (ord('"'), ord("\\")) for value in raw):
            raise ValueError(f"Unsupported plain text at ${start:04X}")
        if any(bytes_in_listing.get(pos) != binary[pos - ORIGIN] for pos in range(start, end)):
            raise ValueError(f"Listing does not match plain text at ${start:04X}")
        if any(pos in skip or pos in replacements for pos in range(start, end)):
            raise ValueError(f"Overlapping plain text at ${start:04X}")
        replacements[start] = data_line(f'defm "{raw.decode("ascii")}"', start, raw)
        skip.update(range(start + 1, end))

    rendered = []
    for line in lines:
        match = byte_line.match(line)
        if not match:
            rendered.append(line)
            continue
        address = int(match[2], 16)
        if address in replacements:
            rendered.append(replacements[address])
        elif address not in skip:
            rendered.append(line)
    LISTING.write_text("".join(rendered))
    print(f"Formatted {records} string descriptors and {len(RAW_TEXT)} plain text spans")


if __name__ == "__main__":
    main()
