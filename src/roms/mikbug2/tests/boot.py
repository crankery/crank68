"""Run with prebuilt sibling FLEX artifacts; all test outputs are temporary."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
emu = root.parent.parent / "emu"
flex = root.parent.parent / "flex2"
sources = sorted((emu / "src/cpu").glob("*.cpp"))
sources += sorted((emu / "src/gen").glob("*.g.cpp"))
sources += [emu / "src/util" / name for name in
            ("symbols.cpp", "logging.cpp", "logBuffer.cpp")]
with tempfile.TemporaryDirectory(prefix="mikbug2-test-") as tmp:
    executable = str(Path(tmp) / "boot")
    subprocess.run(["c++", "-std=c++17", "-O2", "-I" + str(emu / "src"),
                    str(root / "tests/boot.cpp"), *map(str, sources),
                    "-o", executable], check=True)
    for args in ([], ["direct"]):
        subprocess.run([executable, *args], cwd=flex, check=True)
