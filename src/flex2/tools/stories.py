"""Local raw V3 stories to install on FLEX drive 3 (never load records)."""
from pathlib import Path
import re

STORIES_DIR = Path(__file__).resolve().parents[2] / 'z68' / 'stories'


def story_files():
    files = {}
    for path in sorted(STORIES_DIR.glob('*')):
        if not path.is_file() or path.suffix.lower() not in ('.dat', '.z3'):
            continue
        stem = path.stem.upper()
        if not re.fullmatch(r'[A-Z][A-Z0-9_-]{0,7}', stem):
            raise ValueError(f'{path}: use a FLEX name of 1-8 characters, starting with a letter')
        name = stem + '.DAT'
        if name in files:
            raise ValueError(f'Duplicate FLEX story name: {name}')
        payload = path.read_bytes()
        if len(payload) < 64 or payload[0] != 3:
            raise ValueError(f'{path}: expected a raw Version 3 story with a 64-byte header')
        files[name] = payload
    return list(files.items())
