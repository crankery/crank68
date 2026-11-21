
#!/usr/bin/env python3
"""Extract, edit, copy and rebuild 8-pixel-wide bitmap fonts."""

import argparse
from pathlib import Path

def glyph_art(data, index, height):
    start = index * height
    glyph = data[start:start + height]
    if len(glyph) != height:
        raise ValueError(f"Glyph {index:02X} is out of range")
    return [
        "".join("#" if byte & (0x80 >> x) else "."
                for x in range(8))
        for byte in glyph
    ]

def show(data, index, height):
    print(f"@{index:02X}")
    print("\n".join(glyph_art(data, index, height)))

def parse_patch(path, height):
    lines = Path(path).read_text().splitlines()
    operations = []
    i = 0

    while i < len(lines):
        line = lines[i].strip()
        i += 1

        if not line or line.startswith("#"):
            continue

        if line.lower().startswith("copy "):
            parts = line.split()
            if len(parts) != 3:
                raise ValueError("Expected: copy DEST SOURCE")
            operations.append(
                ("copy", int(parts[1], 16), int(parts[2], 16))
            )
            continue

        if line.startswith("@"):
            dest = int(line[1:].split()[0], 16)
            rows = []

            for _ in range(height):
                if i >= len(lines):
                    raise ValueError(f"Incomplete glyph @{dest:02X}")
                row = lines[i].strip()
                i += 1
                if len(row) != 8 or any(c not in ".#" for c in row):
                    raise ValueError(
                        f"Invalid bitmap row in glyph @{dest:02X}: {row}"
                    )
                rows.append(int(row.replace("#", "1")
                                   .replace(".", "0"), 2))

            operations.append(("draw", dest, bytes(rows)))
            continue

        raise ValueError(f"Unknown patch directive: {line}")

    return operations

def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)

    for command in ("show", "dump", "build"):
        sp = sub.add_parser(command)
        sp.add_argument("rom", type=Path)
        sp.add_argument("--height", type=int, default=8)

        if command == "show":
            sp.add_argument("index", type=lambda x: int(x, 16))
        elif command == "build":
            sp.add_argument("patch", type=Path)
            sp.add_argument("-o", "--output", type=Path, required=True)

    args = p.parse_args()
    if args.height <= 0:
        p.error("Glyph height must be positive")

    original = args.rom.read_bytes()
    if len(original) % args.height:
        p.error("ROM size is not divisible by glyph height")

    count = len(original) // args.height

    if args.command == "show":
        if not 0 <= args.index < count:
            p.error("Glyph index out of range")
        show(original, args.index, args.height)

    elif args.command == "dump":
        for index in range(count):
            show(original, index, args.height)
            print()

    elif args.command == "build":
        output = bytearray(original)
        operations = parse_patch(args.patch, args.height)
        modified = set()

        for op, dest, value in operations:
            if not 0 <= dest < count:
                p.error(f"Destination {dest:02X} out of range")

            modified.add(dest)
            start = dest * args.height

            if op == "copy":
                if not 0 <= value < count:
                    p.error(f"Source {value:02X} out of range")
                src = value * args.height
                glyph = original[src:src + args.height]
            else:
                glyph = value

            output[start:start + args.height] = glyph

        args.output.write_bytes(output)
        print(f"Wrote {args.output}: {len(output)} bytes, "
              f"{len(modified)} glyphs modified")

if __name__ == "__main__":
    main()
