# Changing the initial displayed level to 2

The original COM bytes at memory `$4375..$437A` are:

```text
$4375: 21 01 00       LD HL,1
$4378: 22 69 0F       LD ($0F69),HL
```

I changed the immediate byte at memory `$4376` (COM file offset `$4276`)
from `$01` to `$02` in a **temporary copy** of `LADDER.COM`. The original
COM and DAT files were untouched. I ran the copy in iz-cpm, selected `P`,
and saved [the first board as text](level-display-2-map-1.txt).

The HUD reads `Level    2`, but the map is still Easy Street: the dispenser
`V` is at column 40, the treasure `$` and long right ladder are at column
58, and the bottom ladder remains at column 58. Thus `$0F69` is confirmed as
the displayed level number, not the control that selects the level-one map.
The actual map-selection state remains to be identified.

The one-byte patch can be reproduced on another temporary copy with:

```python
from pathlib import Path
p = Path("LADDER.COM")
b = bytearray(p.read_bytes())
assert b[0x4275:0x4278] == bytes.fromhex("21 01 00")
b[0x4276] = 2
p.write_bytes(b)
```

The `$0F6B` word initialized to `1` nearby is used by the extra-lad award
routine at `$573A..$5750`, so it does not look like a map selector either.
