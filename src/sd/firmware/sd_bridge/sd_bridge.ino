#include <avr/power.h>
#include "src/avr_board.h"
#include "src/protocol.h"
#include "src/sd_storage.h"

volatile uint8_t board::events = 0;
volatile uint8_t board::previousControl = 0;
ISR(PCINT1_vect)
{
    const uint8_t current = PINC;
    const uint8_t rising = uint8_t(current & ~board::previousControl);
    board::previousControl = current;
    uint8_t pending = 0;
    if (rising & board::RxRequest)
        pending |= board::ReceiveEvent;
    if (rising & board::TxConsume)
        pending |= board::ConsumeEvent;
    if (board::events & pending)
        pending |= board::OverrunEvent;
    board::events |= pending;
}

SdStorage storage;
sdbridge::Engine<SdStorage> engine(storage);
BoardLink boardLink;
sdbridge::Link<sdbridge::Engine<SdStorage>, BoardLink> link(engine, boardLink);

void setup()
{
    // Select the internal 8 MHz source in fuses; also undo factory CKDIV8.
    clock_prescale_set(clock_div_1);
    board::init();
    storage.begin();
    link.begin();
    board::statusLed(storage.status() == sdbridge::Status::Ok);
}

void loop()
{
    link.poll(board::takeEvents());
    board::statusLed(storage.status() == sdbridge::Status::Ok);
    board::activityLed(engine.active());
}
