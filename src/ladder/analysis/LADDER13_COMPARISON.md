# The `ladder13` archive compared with our Ladder copy

`cpm/ladder13` contains `LADDER.COM`, `LADCONF.COM`, and `LADDER.DAT`.
The files were inspected read-only; the emulator runs below used temporary
copies so high-score writes could not touch the archive.

| File | Earlier copy | `ladder13` copy |
| --- | ---: | ---: |
| `LADDER.COM` | 39,936 bytes | 40,320 bytes |
| `LADCONF.COM` | 22,528 bytes | 22,784 bytes |
| `LADDER.DAT` | 512 bytes | 512 bytes |
| Game version shown | 1.10 | 1.30 |
| Copyright shown | 1982 Yahoo Software | 1982, 1983 Yahoo Software |

The bundled DAT files differ in only 18 of 512 bytes. The earlier DAT
selects **TeleVideo 950** and movement keys `2/4/6/8`; `ladder13` selects
**KayPro II** and `D/L/R/U`. The 1.30 COM runs with either DAT: its bundled
one displays the [KayPro menu](ladder13-kaypro-menu.txt), while a temporary
copy paired with the old DAT displays the
[TeleVideo menu](ladder13-televideo-menu.txt). Both runs used iz-cpm's
ADM-3A output translation. The KayPro-configured run reached
[Easy Street](ladder13-level1.txt), then the normal game-over/high-score
screen and menu.

The COM difference is more than a terminal configuration patch. The new
binary contains the version string `1.30` where the earlier one has `1.10`,
and both contain exactly `BASLIB #500203 5.2 - OWNED BY MICROSOFT, 1979`.
Long stretches of code and map data match, but many addresses have moved.
The BASLIB identification string moved from `$667D` to `$6852`, a shift of
`$1D5` bytes. Several known runtime entries have closely matching code at
that same shift:

| Earlier runtime entry | `ladder13` entry | Existing reading |
| --- | --- | --- |
| `$617D` | `$6352` | keyboard poll |
| `$6FEA` | `$71BF` | PRINT/output setup |
| `$768E` | `$7863` | [multiply by inline factor](MULTIPLY_INLINE.md) |

Those new addresses also appear as `CALL` targets in the 1.30 COM. The
matching code is interspersed with changed address operands, as expected
when a linker relocates the same routines. This provides a second linked
copy of BASLIB 5.2 for matching routine boundaries and call conventions.
It does not imply that every runtime byte or game routine is identical.

The main game changes can be studied separately from the KayPro terminal
settings by pairing each COM with the same DAT in **temporary copies**.
