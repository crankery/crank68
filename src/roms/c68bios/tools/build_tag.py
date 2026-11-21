"""Emit an assembler string identifying this C68 BIOS build."""

from datetime import datetime, timezone
from hashlib import sha256
import os
from pathlib import Path
import sys


def main() -> None:
    if len(sys.argv) < 3:
        raise SystemExit("usage: build_tag.py OUTPUT SOURCE...")
    output = Path(sys.argv[1])
    digest = sha256()
    for filename in sorted(sys.argv[2:]):
        path = Path(filename)
        digest.update(path.name.encode("ascii"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
    epoch = os.environ.get("SOURCE_DATE_EPOCH")
    when = (datetime.fromtimestamp(int(epoch), timezone.utc) if epoch is not None
            else datetime.now(timezone.utc))
    stamp = when.strftime("%Y%m%d")
    tag = digest.hexdigest()[:8]
    output.write_text(f'    .string "Build {stamp} {tag}"\n')
    print(f"{output}: Build {stamp} {tag}")


if __name__ == "__main__":
    main()
