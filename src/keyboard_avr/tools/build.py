#!/usr/bin/env python3
"""Compile keyboard firmware using the installed Arduino AVR toolchain."""
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
cli = os.environ.get('ARDUINO_CLI') or shutil.which('arduino-cli')
bundled = Path('/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli')
if not cli and bundled.is_file():
    cli = str(bundled)
if not cli:
    raise SystemExit('Install arduino-cli and arduino:avr, or set ARDUINO_CLI.')

build = ROOT / 'build'
build.mkdir(exist_ok=True)
config = build / 'arduino-cli.json'
config.write_text(json.dumps({
    'build_cache': {'path': str(build / 'arduino-cache')},
    'directories': {'downloads': str(build / 'downloads')},
}))
subprocess.run([
    cli, 'compile', '--config-file', str(config), '--fqbn', 'arduino:avr:uno',
    '--build-property', 'build.f_cpu=8000000L',
    '--build-property', 'compiler.cpp.extra_flags=-Wall -Wextra',
    '--build-path', str(build / 'avr'), '--output-dir', str(build),
    str(ROOT / 'firmware'),
], check=True)
