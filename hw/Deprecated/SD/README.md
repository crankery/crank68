# PIA-based SD daughterboard — inactive legacy add-on

This board connects an AVR SD bridge to PIA 1. Hardware work has moved to the
[Instore keyboard and SD board](../../Instore/), which uses a direct C68 bus
interface. The KiCad design remains here for reference.

The existing PIA firmware, emulator and FLEX path remain documented in
[src/sd](../../../src/sd/README.md); they are not compatible with Instore's SD AVR.
