# Notes

## Bus Signals


| Pin | Name   | Origin | Pin | Name                                                | Origin     |
| --- | ------ | ------ | --- | --------------------------------------------------- | ---------- |
| 1   | A0     | CPU    | 2   | R/<span style="text-decoration:overline">W</span>   | Controller |
| 3   | A1     | CPU    | 4   | BANK0                                               | Controller |
| 5   | A2     | CPU    | 6   | BANK1                                               | Controller |
| 7   | A3     | CPU    | 8   | BANK2                                               | Controller |
| 9   | A4     | CPU    | 10  | BANK3                                               | Controller |
| 11  | A5     | CPU    | 12  | BANK4                                               | Controller |
| 13  | A6     | CPU    | 14  | BANK5                                               | Controller |
| 15  | A7     | CPU    | 16  | BANK6                                               | Controller |
| 17  | A8     | CPU    | 18  | BANK7                                               | Controller |
| 19  | A9     | CPU    | 20  | <span style="text-decoration:overline">IO0</span>   | Controller |
| 21  | A10    | CPU    | 22  | <span style="text-decoration:overline">IO1</span>   | Controller |
| 23  | A11    | CPU    | 24  | <span style="text-decoration:overline">IO2</span>   | Controller |
| 25  | A12    | CPU    | 26  | <span style="text-decoration:overline">IO3</span>   | Controller |
| 27  | A13    | CPU    | 28  |                                                     |            |
| 29  | A14    | CPU    | 30  |                                                     |            |
| 31  | A15    | CPU    | 32  |                                                     |            |
| 33  | BUS_OK | CPU    | 34  |                                                     |            |
| 35  | D0     | CPU    | 36  | <span style="text-decoration:overline">RESET</span> | Controller |
| 37  | D1     | CPU    | 38  | <span style="text-decoration:overline">RESET</span> | Controller |
| 39  | D2     | CPU    | 40  | <span style="text-decoration:overline">RESET</span> | Controller |
| 41  | D3     | CPU    | 42  | <span style="text-decoration:overline">RESET</span> | Controller |
| 43  | D4     | CPU    | 44  | <span style="text-decoration:overline">NMI</span>   | Controller |
| 45  | D5     | CPU    | 46  | BUS_OK                                              | CPU        |
| 47  | D6     | CPU    | 48  | <span style="text-decoration:overline">IRQ</span>   | CPU        |
| 49  | D7     | CPU    | 50  | <span style="text-decoration:overline">RESET</span> | CPU        |

| Signal   | Notes                                                      |
| -------- | ---------------------------------------------------------- |
| A[0..15] | CPU Address Bus                                            |
| D[0.7]   | CPU data bus                                               |
| BUS_OK   | Combination of VMA & Φ2, the bus is ready to transmit data |

## CPU Signals Not On Bus

| Signal                                             | Notes                                             |
| -------------------------------------------------- | ------------------------------------------------- |
| DBE                                                | Not using DMA, no need to disable the data bus    |
| <span style="text-decoration:overline">TSC</span>  | Not using DMA, no need to disable the address bus |
| <span style="text-decoration:overline">HALT</span> | Not using DMA, no need to halt the CPU            |
| <span style="text-decoration:overline">NMI</span>  | Not using non-maskable interrupts                 |
| BA                                                 | Not using DMA                                     |
| VMA                                                | Combined in BUS_OK                                |