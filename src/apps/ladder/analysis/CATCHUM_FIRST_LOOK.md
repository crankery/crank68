# First look at Yahoo Software's CatChum files

The `cpm/catchum` directory contains `CATCHUM.COM` (28,160 bytes), `CATCONF.COM` (22,528 bytes), and `CATCHUM.DAT` (512 bytes). The game binary includes `(c) 1982 Yahoo Software`, an ASCII maze, menu text, high-score text, sound and wisecrack options, and instructions for four movement keys and a hyperspace key.

## Connection to Ladder

`CATCONF.COM` contains the exact banner `BASLIB #500203 5.2 - OWNED BY MICROSOFT, 1979`, also found in the original `LADDER.COM` and `LADCONF.COM`. The two configuration COM files are each 22,528 bytes and have 251 identical bytes in their first 256 bytes. `rel_anchors.py` finds the same 21 OBSLIB 5.3 module/area/base anchor groups in both; the `Disk` module begins at `$4231` in `LADCONF.COM` and `$423A` in `CATCONF.COM`, a nine-byte shift. The banner likewise shifts by nine bytes (file offsets `$23EE` and `$23F7`). This is strong evidence that the configuration programs share substantial compiled code and the same BASLIB 5.2 runtime version, with different game-specific text and data.

The two 512-byte `.DAT` files have 475 matching bytes at the same offsets. Both begin with the same TeleVideo 950 terminal name and cursor-control settings. Differences include option/key fields at `$C0–$FF` and high-score fields at `$100–$19F`. Their file formats appear closely related.

`CATCHUM.COM` differs substantially from Ladder's game binary. It contains no `BASLIB` banner. The existing absolute-byte REL anchor search found zero OBSLIB 5.3 and zero BASLIB 5.3 module matches in it, and the distinctive `$IMUG` and `$SASA` wrappers seen in Ladder were absent. This does **not** establish which language or tools built CatChum, but the game executable does not show Ladder's linked BASIC runtime pattern. It begins `JP $379C` followed by bytes containing `CATCHUM fs`.

### Likely CB-80 provenance

Further research points toward Digital Research's CB-80 compiled BASIC system. `CATCHUM.COM` contains the runtime text `improper input - reenter`. The [CB-80 Language Manual](https://www.cpm.z80.de/manuals/CB80LM.pdf) lists the same warning, and describes CHAIN between a root `.COM` and `.OVL` files produced by its LK-80 linker. CatChum's binary also contains `overlay does not match root$` and uses an overlay/linking path when handing control to `CATCONF.COM`. These independent clues make CB-80 a strong hypothesis, including an explanation for the missing Microsoft BASLIB banner. A byte comparison against a known CB-80 linked COM would establish it more firmly; the warning text also appears in the related earlier CBASIC system, so the phrase alone is not unique.

## Emulator check

Only copies under `/private/tmp/catchum-look` were run. The unconfigured game printed `CatChum not configured`, then `Unable to link to CATCONF.COM`, even though `CATCONF.COM` was present. Running `CATCONF.COM` directly displayed its V1.10 terminal menu and accepted TeleVideo 950, sound, wisecrack, and movement-key selections. It updated the temporary `CATCHUM.DAT`. The subsequent attempt to hand control back to the game still printed the same link error. The reason for the overlay/link failure under `iz-cpm` has not been established, so this check does not show whether the game itself runs in a different CP/M environment.
