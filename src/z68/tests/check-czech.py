#!/usr/bin/env python3
"""Strict conformance gate: bootstrap success is not CZECH success."""
import json
from pathlib import Path
import sys

status = json.loads(Path(sys.argv[1]).read_text())
if status.get('czech_status') != 'passed':
    raise SystemExit(f"CZECH is {status.get('czech_status')}: {status.get('blocker', status.get('detail', 'unknown'))}; "
                     f"{status.get('czech_checks_passed', 0)} upstream checks passed. See build/czech-actual.txt.")
if status.get('czech_checks_passed') != 349:
    raise SystemExit('Incomplete upstream automatic-test count')
print('CZECH V3 automatic conformance gate passed; review visual print checks separately.')
