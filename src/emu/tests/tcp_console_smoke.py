#!/usr/bin/env python3
"""Exercise the real executable, 6800, ACIA, TCP console and SRAM exit save."""
from pathlib import Path
import signal
import os
import select
import socket
import subprocess
import sys
import tempfile
import time

emulator = Path(sys.argv[1] if len(sys.argv) > 1 else 'build/bin/emu').resolve()


def receive(sock, count):
    result = bytearray()
    while len(result) < count:
        part = sock.recv(count - len(result))
        if not part:
            raise AssertionError('Console disconnected before expected output')
        result.extend(part)
    return bytes(result)


with tempfile.TemporaryDirectory(prefix='crank68-tcp-') as temporary:
    root = Path(temporary)
    # A tiny MC6800 program: configure ACIA #1, print a mixed-case banner,
    # then echo bytes exactly. Guest Ctrl-] is data, not a shutdown command.
    program = bytearray.fromhex('0f 8e 9fff 86 03 b7 e010 86 15 b7 e010')
    banner = b'Ready\r\n'
    for value in banner:
        program.extend(bytes([0x86, value, 0xb7, 0xe0, 0x11]))
    program.extend(bytes.fromhex('b6 e010 85 01 27 f9 b6 e011 b7 e011 20 f1'))
    (root / 'echo.bin').write_bytes(program)
    (root / 'vector.bin').write_bytes(bytes.fromhex('e100'))
    with socket.socket() as reservation:
        reservation.bind(('127.0.0.1', 0))
        port = reservation.getsockname()[1]
    command = [str(emulator), '--tcp-console', str(port),
               '--load', f'{root / "echo.bin"}@E100',
               '--load', f'{root / "vector.bin"}@FFFE',
               '--sram-image', str(root / 'session.dsk')]
    with (root / 'stderr.log').open('w+') as errors:
        process = subprocess.Popen(command, cwd=root, stdin=subprocess.DEVNULL,
                                   stdout=subprocess.DEVNULL, stderr=errors)
        try:
            deadline = time.monotonic() + 5
            while True:
                if process.poll() is not None:
                    raise AssertionError(f'Emulator exited at startup: {(root / "stderr.log").read_text()}')
                try:
                    client = socket.create_connection(('127.0.0.1', port), timeout=1)
                    break
                except ConnectionRefusedError:
                    if time.monotonic() >= deadline:
                        raise
                    time.sleep(0.01)
            with client:
                client.settimeout(5)
                assert receive(client, len(banner)) == banner, 'Startup banner lost'
                payload = b'aAzZ\x00\x08\x1b[31m\x1d\xff'
                client.sendall(payload)
                assert receive(client, len(payload)) == payload, 'ACIA bytes were transformed'
            time.sleep(0.05)  # Allow the emulator to detect the disconnect.
            with socket.create_connection(('127.0.0.1', port), timeout=5) as client:
                client.settimeout(5)
                client.sendall(b'Reconnect')
                assert receive(client, 9) == b'Reconnect', 'Reconnect reset or lost the guest'
            process.send_signal(signal.SIGTERM)
            assert process.wait(timeout=5) == 0, (root / 'stderr.log').read_text()
            assert (root / 'session.dsk').stat().st_size == 1048576, 'Exit did not save SRAM'
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
    # Default local console retains its historical case swap and Ctrl-] exit.
    local = subprocess.Popen([str(emulator), '--load', f'{root / "echo.bin"}@E100',
                              '--load', f'{root / "vector.bin"}@FFFE'], cwd=root,
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.DEVNULL)
    def local_read(count):
        data = bytearray()
        while len(data) < count:
            ready, _, _ = select.select([local.stdout], [], [], 5)
            assert ready, 'Local console output timed out'
            part = os.read(local.stdout.fileno(), count-len(data))
            assert part, 'Local console exited early'
            data.extend(part)
        return bytes(data)
    try:
        assert local_read(len(banner)) == banner
        local.stdin.write(b'a'); local.stdin.flush()
        assert local_read(1) == b'A'
        local.stdin.write(b'A'); local.stdin.flush()
        assert local_read(1) == b'a'
        local.stdin.write(b'\x1d'); local.stdin.flush()
        assert local.wait(timeout=5) == 0
    finally:
        if local.poll() is None:
            local.kill(); local.wait()
        local.stdin.close(); local.stdout.close()
    for value in ('0', '-1', '65536', 'xyz', ''):
        result = subprocess.run([str(emulator), '--tcp-console', value], cwd=root,
                                capture_output=True, timeout=5)
        assert result.returncode != 0 and b'invalid TCP console port' in result.stderr
    result = subprocess.run([str(emulator), '--tcp-console'], cwd=root,
                            capture_output=True, timeout=5)
    assert result.returncode != 0 and b'requires a decimal port' in result.stderr
print('TCP console executable smoke test passed: banner, raw ACIA bytes, reconnect, SRAM save and legacy local console.')
