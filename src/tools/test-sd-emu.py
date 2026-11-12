#!/usr/bin/env python3
"""Boot the real emulator and catalog the configured SD drive through FLEX."""
import argparse
import os
from pathlib import Path
import select
import shutil
import subprocess
import tempfile
import time

parser = argparse.ArgumentParser()
parser.add_argument('--drive-layout', choices=('sram-first', 'sd-first'), required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
drive = 2 if args.drive_layout == 'sram-first' else 0
disk_name = b'C68DATA' if drive == 2 else b'C68SYS'

with tempfile.TemporaryDirectory(prefix='crank68-sd-emu-') as directory:
    work = Path(directory)
    shutil.copyfile(root / 'build/system/flex2.dsk', work / 'sram.dsk')
    shutil.copyfile(root / 'build/system/FLEX.DSK', work / 'sd.dsk')
    command = [str(root / 'build/system/emu'),
               '--load', str(root / 'build/system/mikbug2.rom') + '@E000',
               '--sram-image', str(work / 'sram.dsk'),
               '--sd-image', str(work / 'sd.dsk')]
    with (work / 'stderr.log').open('wb') as errors:
        process = subprocess.Popen(command, cwd=work, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=errors)
        output = bytearray()

        def until(marker):
            deadline = time.monotonic() + 90
            while marker not in output:
                if process.poll() is not None:
                    raise RuntimeError(f'Emulator exited {process.returncode}: '
                                       f'{output[-600:]!r}, {(work / "stderr.log").read_text()}')
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    raise TimeoutError(f'Waiting for {marker!r}: {output[-600:]!r}')
                readable, _, _ = select.select([process.stdout], [], [], min(remaining, 0.5))
                if readable:
                    output.extend(os.read(process.stdout.fileno(), 4096))

        try:
            until(b'MIKBUG 2/C68')
            process.stdin.write(b'f\r')
            process.stdin.flush()
            until(b'DATE (MM,DD,YY)?')
            process.stdin.write(b'11,03,26\r')
            process.stdin.flush()
            until(b'+++')
            process.stdin.write(f'cat {drive}\r'.encode())
            process.stdin.flush()
            until(f'CATALOG OF DRIVE NUMBER {drive}'.encode())
            until(disk_name)
        finally:
            if process.poll() is None:
                process.stdin.write(b'\x1d')
                process.stdin.flush()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()

print(f'Emulator direct SD: FLEX CAT {drive} opened {disk_name.decode()} through the ROM and direct registers.')
