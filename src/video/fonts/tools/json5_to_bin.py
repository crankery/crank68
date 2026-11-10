
#!/usr/bin/env python3
"""Convert a PCjs-style JSON/JSON5 ROM dump to raw binary."""
import argparse
from pathlib import Path
import json5

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("output")
    args = ap.parse_args()

    obj = json5.loads(Path(args.source).read_text())

    if isinstance(obj, list):
        data = obj
    elif isinstance(obj, dict):
        data = obj.get("values", obj.get("bytes"))
        if data is None:
            raise ValueError("Expected 'values' or 'bytes' array")
    else:
        raise ValueError("Unsupported JSON5 ROM format")

    raw = bytes(data)
    Path(args.output).write_bytes(raw)
    print(f"{args.output}: {len(raw)} bytes")

if __name__ == "__main__":
    main()
