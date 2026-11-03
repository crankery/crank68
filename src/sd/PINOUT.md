# Inspected board wiring

Sources: `../../SD/SD.kicad_sch`, `SD.kicad_pcb`, and
`../../IO/IO.kicad_pcb`, inspected 2026-11-03. U2/U3 schematic values are
**74HCT574** (the earlier LS symbol values were corrected). U2 captures C68
output on CA2's rising edge; U3 retains the AVR's response independently of
its shared data bus.

| U1 DIP pin(s) | AVR function | Net / firmware use |
| --- | --- | --- |
| 2–6, 11–13 | PD0–PD7 | Shared byte bus, bit-for-bit to latch D/Q0–7 |
| 14 | PB0 | `/PA_OE`: U2 output enable, pulled high by R7 |
| 15 | PB1 | `PB_CLK`: U3 rising-edge latch clock |
| 16 | PB2 / Arduino 10 | SD CS, pulled high by R8 |
| 17 | PB3 / Arduino 11 | MOSI via U5 level shifter |
| 18 | PB4 / Arduino 12 | MISO directly from SD card |
| 19 | PB5 / Arduino 13 | SCK via U5 level shifter |
| 23 | PC0 | CA1: AVR acknowledgment of C68-to-AVR byte, output |
| 24 | PC1 | CA2: C68 request / U2 capture clock, input with pull-up |
| 25 | PC2 | CB1: AVR response-byte ready, output |
| 26 | PC3 | CB2: C68 consumption ACK, input with pull-up |
| 27 | PC4 | D1 status LED cathode: active low |
| 28 | PC5 | D2 activity LED cathode: active low |
| 9, 10 | PB6/PB7 | Unused; internal oscillator selected |
| 1 | RESET | Connected to the new J3 six-pin ISP header |

J3 is a standard AVR ISP signal layout:

| J3 pin | Signal |
| --- | --- |
| 1 | MISO |
| 2 | +5 V |
| 3 | SCK |
| 4 | MOSI |
| 5 | RESET |
| 6 | Ground |

Both latch data mappings preserve bit order: U2 D0=PA0, Q0=PD0; U3 D0=PD0,
Q0=PB0, and likewise for bits 1–7. U3 /OE is grounded; the host must configure
PIA B as inputs before using the bridge. U2 /OE is under AVR control and is
high before the AVR drives Port D. Port D returns to inputs after clocking U3.

J2 matches the IO board's PIA-1 J2 logical pinout:

| J2 pins | Nets |
| --- | --- |
| 1, 2 | +5 V |
| 3,5,7,9,11,13,15,17 | PA0–PA7 |
| 4,6,8,10,12,14,16,18 | PB0–PB7 |
| 19,20,21,22 | CA1, CB1, CA2, CB2 |
| 23,24 | Ground |

Connector mounting/orientation is a mechanical check. Firmware does not
renumber pins to compensate for mirrored power or connector rows.
