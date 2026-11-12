#include <avr/power.h>
#include "src/avr_board.h"
#include "src/protocol.h"
#include "src/direct_link.h"
#include "src/sd_storage.h"

SdStorage storage;
sdbridge::Engine<SdStorage> engine(storage);
BoardIO boardIO;
sdbridge::DirectLink<sdbridge::Engine<SdStorage>, BoardIO> link(engine, boardIO);

void setup()
{
    // Clock fuses select the internal RC oscillator; undo factory CKDIV8.
    clock_prescale_set(clock_div_1);
    board::init();
    // Make early status reads harmless while FAT mounting is still in progress.
    board::stageData(0);
    board::stageStatus(0);
    storage.begin();
    link.begin();
}

void loop()
{
    link.poll();
    board::serviceActivity();
}
