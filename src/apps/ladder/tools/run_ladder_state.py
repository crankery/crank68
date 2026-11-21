#!/usr/bin/env python3
"""Run an instrumented original Ladder state capture at a chosen play speed."""

import argparse
import errno
import os
from pathlib import Path
import pty
import re
import select
import shutil
import subprocess
import tempfile
import time


ROOT = Path(__file__).resolve().parents[1]
SPEED = re.compile(rb"Play speed: ([1-5])")


def capture(emulator: Path, output: Path, speed: int, updates: int,
            timeout: float, first_key: str | None, when: str | None,
            key_at: str | None, name: str | None, poke_after: str | None,
            score_events: bool, rock_events: bool, map_dump: bool,
            tile_events: bool, rng_events: bool,
            start_level: int, stop_pc: str | None) -> None:
    output.mkdir(parents=True, exist_ok=True)
    stem = name or (f"speed{speed}-level{start_level}" +
                    (f"-key{ord(first_key):02x}" if first_key else ""))
    state = output / f"{stem}.csv"
    terminal = output / f"{stem}.ansi"
    errors = output / f"{stem}.log"
    score_log = output / f"{stem}.score.csv"
    rock_log = output / f"{stem}.rock.csv"
    rng_log = output / f"{stem}.rng.csv"
    map_log = output / f"{stem}.map.csv"
    tile_log = output / f"{stem}.tile.csv"
    with tempfile.TemporaryDirectory(prefix="ladder-state-") as directory:
        work = Path(directory)
        shutil.copyfile(ROOT / "cpm/LADDER.COM", work / "LADDER.COM")
        shutil.copyfile(ROOT / "cpm/LADDER.DAT", work / "LADDER.DAT")
        master, slave = pty.openpty()
        command = [
            str(emulator), "--terminal", "adm3a", "--disk-a", str(work),
            "--ladder-state", str(state), "--ladder-max-updates", str(updates),
        ]
        if first_key:
            command.extend(["--ladder-inject-key", first_key])
        if when:
            command.extend(["--ladder-key-when", when])
        if key_at:
            command.extend(["--ladder-key-at", key_at])
        if poke_after:
            command.extend(["--ladder-poke-after", poke_after])
        if score_events:
            command.extend(["--ladder-score-events", str(score_log)])
        if rock_events:
            command.extend(["--ladder-rock-events", str(rock_log)])
        if rng_events:
            command.extend(["--ladder-rng-events", str(rng_log)])
        if map_dump:
            command.extend(["--ladder-map", str(map_log)])
        if tile_events:
            command.extend(["--ladder-tile-events", str(tile_log)])
        if start_level != 1:
            command.extend(["--ladder-start-level", str(start_level)])
        if stop_pc:
            command.extend(["--ladder-stop-pc", stop_pc])
        command.append("LADDER.COM")
        with errors.open("wb") as error_file, terminal.open("wb") as terminal_file:
            process = subprocess.Popen(
                command, cwd=work, stdin=slave, stdout=slave, stderr=error_file,
                start_new_session=True,
            )
            os.close(slave)
            buffer = b""
            chosen = False
            displayed_speed = None
            awaiting_speed = False
            deadline = time.monotonic() + timeout
            try:
                while process.poll() is None:
                    if time.monotonic() >= deadline:
                        raise TimeoutError(f"Ladder capture exceeded {timeout:g} seconds")
                    readable, _, _ = select.select([master], [], [], 0.2)
                    if not readable:
                        continue
                    try:
                        chunk = os.read(master, 65536)
                    except OSError as error:
                        if error.errno == errno.EIO and process.poll() is not None:
                            break
                        raise
                    if not chunk:
                        break
                    terminal_file.write(chunk)
                    buffer = (buffer + chunk)[-4096:]
                    matches = list(SPEED.finditer(buffer))
                    if matches:
                        current = int(matches[-1][1])
                        if current != displayed_speed:
                            displayed_speed = current
                            awaiting_speed = False
                    if b"Enter one of the above:" in buffer and not chosen and not awaiting_speed:
                        if displayed_speed == speed:
                            os.write(master, b"P")
                            chosen = True
                            buffer = b""
                        elif displayed_speed is not None:
                            os.write(master, b"L")
                            awaiting_speed = True
                            buffer = b""
                code = process.wait(timeout=5)
                if code != 0:
                    raise RuntimeError(f"iz-cpm exited {code}; see {errors}")
                if not chosen or not state.exists():
                    raise RuntimeError(f"Ladder did not reach the state trace; see {terminal}")
            finally:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=5)
                os.close(master)
    print(f"Saved {state} ({updates} requested updates at speed {speed})")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--emulator", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--speed", type=int, choices=range(1, 6), required=True)
    parser.add_argument("--start-level", type=int, default=1)
    parser.add_argument("--updates", type=int, default=125)
    parser.add_argument("--timeout", type=float, default=60)
    parser.add_argument("--first-key", help="Inject one ASCII key at the first gameplay poll")
    parser.add_argument("--when", help="Inject ordered keys at X:Y:HEX coordinates, comma separated")
    parser.add_argument("--key-at", help="Inject keys at UPDATE:HEX state rows, comma separated")
    parser.add_argument("--poke-after", help="Write test words after UPDATE:HEXADDR:HEXWORD samples")
    parser.add_argument("--score-events", action="store_true", help="Log original rock-jump score writes")
    parser.add_argument("--rock-events", action="store_true", help="Log rock dispenser and direction decisions")
    parser.add_argument("--rng-events", action="store_true", help="Log random state before and after each generator call")
    parser.add_argument("--map", action="store_true", help="Dump the selected board's tile codes")
    parser.add_argument("--tile-events", action="store_true", help="Log trampoline choice values")
    parser.add_argument("--stop-pc", help="Stop when the original reaches a hex code address")
    parser.add_argument("--name", help="Output file stem")
    args = parser.parse_args()
    if args.updates < 1:
        parser.error("--updates must be positive")
    if not 1 <= args.start_level <= 255:
        parser.error("--start-level must be between 1 and 255")
    if args.first_key and (len(args.first_key) != 1 or not args.first_key.isascii()):
        parser.error("--first-key needs one ASCII character")
    if (args.when or args.key_at or args.poke_after) and not args.name:
        parser.error("--when, --key-at and --poke-after require --name to identify the capture")
    capture(args.emulator.resolve(), args.output.resolve(), args.speed,
            args.updates, args.timeout, args.first_key, args.when, args.key_at, args.name,
            args.poke_after, args.score_events, args.rock_events, args.map,
            args.tile_events, args.rng_events,
            args.start_level, args.stop_pc)


if __name__ == "__main__":
    main()
