import json5

with open("vt100-23-018E2.json") as f:
    rom = json5.load(f)

data = bytes(rom["bytes"])

with open("vt100-23-018E2.bin", "wb") as f:
    f.write(data)

print(f"Wrote {len(data)} bytes")