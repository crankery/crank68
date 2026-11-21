#!/usr/bin/env python3
"""Compile only: use installed Arduino tools; never install, flash or set fuses."""
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
cli = os.environ.get('ARDUINO_CLI') or shutil.which('arduino-cli')
mac_cli = Path('/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli')
if not cli and mac_cli.is_file():
    cli = str(mac_cli)
if not cli:
    raise SystemExit('Install arduino-cli and arduino:avr; or set ARDUINO_CLI to its executable.')

build = ROOT / 'build'
build.mkdir(exist_ok=True)
config = build / 'arduino-cli.json'
config.write_text(json.dumps({'build_cache': {'path': str(build / 'arduino-cache')},
                              'directories': {'downloads': str(build / 'downloads')}}))
command = [cli, 'compile', '--config-file', str(config), '--fqbn', 'arduino:avr:uno',
           '--build-property', 'build.f_cpu=8000000L',
           '--build-property', 'upload.maximum_size=32768',
           '--build-property', 'compiler.cpp.extra_flags=-Wall -Wextra',
           '--build-path', str(build / 'avr'), '--output-dir', str(build)]
library = os.environ.get('SD_LIBRARY')
if not library:
    for candidate in (Path.home() / 'Library/Arduino15/libraries/SD',
                      Path.home() / 'Documents/Arduino/libraries/SD',
                      Path.home() / 'Arduino/libraries/SD'):
        if (candidate / 'library.properties').is_file():
            library = str(candidate)
            break
if library:
    command += ['--library', library]
command.append(str(ROOT / 'firmware/sd_bridge'))
print('ATmega328P, internal 8 MHz firmware; no programming/fuse operations.', flush=True)
subprocess.run(command, check=True)
