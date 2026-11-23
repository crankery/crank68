# CV4 SPI Timing

![CV4 SPI timing diagram](SPI_Timing.svg)

This shows a transfer to DAC1 (`DAC_SEL = 0`); DAC2 remains deselected. U6 and U7 load the high and low command bytes before `SPI_ACTIVE` begins. The MCP4822 samples SDI on each SCK rising edge. The 165s, U5, and U11B clock on `SHIFT_CLK = NOT SCK`, so each falling SCK edge advances the data and the count. TC rises after the fifteenth shift; U11B captures it on the sixteenth shift, setting `SPI_DONE`. That lowers RUN and releases DAC1's chip select while SCK is low.

The load strobes, counter reset, start, and clearing of BUSY are shown as the intended sequence; their 6800 control logic is not wired yet. Once BUSY clears after `SPI_DONE`, U8B samples it on the next falling Phi2 edge and `SPI_ACTIVE` returns low. RUN is already low, so there is no extra SCK pulse while ACTIVE catches up.

The diagram is generated from [SPI_Timing.json5](SPI_Timing.json5). Run `make docs` from `src/` after editing the source.

