#pragma once
#include <Arduino.h>
#include <avr/interrupt.h>
#include <util/atomic.h>
#include <util/delay.h>
#include "link.h"
#if !defined(__AVR_ATmega328P__) || F_CPU != 8000000UL
#error "This board requires an ATmega328P with F_CPU=8000000UL"
#endif

// ../SD/SD.kicad_pcb U1: PD0..7 shared latch bus, PB0=/PA_OE,
// PB1=PB_CLK, PB2..5=SD SPI, PC0=CA1, PC1=CA2, PC2=CB1,
// PC3=CB2, PC4/5=active-low status/activity LEDs. No UART on PD0/1.
namespace board
{
static const uint8_t TxAck = _BV(PC0), RxRequest = _BV(PC1), RxReady = _BV(PC2),
                     TxConsume = _BV(PC3);
static const uint8_t ReceiveEvent = sdbridge::ReceiveEvent, ConsumeEvent = sdbridge::ConsumeEvent,
                     OverrunEvent = sdbridge::OverrunEvent;
extern volatile uint8_t events;
extern volatile uint8_t previousControl;
inline void init()
{
    PORTB |= _BV(PB0) | _BV(PB2); // Isolate U2 and deselect SD before enabling outputs.
    PORTB &= uint8_t(~_BV(PB1));
    DDRB |= _BV(PB0) | _BV(PB1) | _BV(PB2);
    DDRD = 0;
    PORTD = 0;
    // Request/consume lines idle high; pull-ups keep an unattached or reset
    // host quiet. Host pulses low then high; the rising edge clocks U2.
    PORTC =
        uint8_t((PORTC & ~uint8_t(TxAck | RxReady)) | RxRequest | TxConsume | _BV(PC4) | _BV(PC5));
    DDRC =
        uint8_t((DDRC & ~uint8_t(RxRequest | TxConsume)) | TxAck | RxReady | _BV(PC4) | _BV(PC5));
    _delay_us(2);
    previousControl = PINC;
    events = 0;
    PCMSK1 |= RxRequest | TxConsume;
    PCIFR = _BV(PCIF1);
    PCICR |= _BV(PCIE1);
}

inline uint8_t takeEvents()
{
    uint8_t value;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
    {
        value = events;
        events = 0;
    }

    return value;
}

inline uint8_t receiveByte()
{
    DDRD = 0;
    PORTD = 0;
    PORTB &= uint8_t(~_BV(PB0));
    _delay_us(1);
    const uint8_t value = PIND;
    PORTB |= _BV(PB0);
    return value;
}

inline void acknowledgeReceive()
{
    PORTC |= TxAck;
    _delay_us(4);
    PORTC &= uint8_t(~TxAck);
}

inline void publishByte(uint8_t value)
{
    PORTB |= _BV(PB0); // U2 must be high impedance before the AVR drives Port D.
    PORTD = value;
    DDRD = 0xff;
    _delay_us(1);
    PORTB |= _BV(PB1);
    _delay_us(1);
    PORTB &= uint8_t(~_BV(PB1));
    DDRD = 0;
    PORTD = 0; // U3 retains the byte for as long as the host needs it.
    PORTC |= RxReady;
}

inline void withdrawByte()
{
    PORTC &= uint8_t(~RxReady);
}

inline void idle()
{
    PORTB |= _BV(PB0);
    DDRD = 0;
    PORTD = 0;
    PORTC &= uint8_t(~uint8_t(TxAck | RxReady));
}

inline void statusLed(bool on)
{
    if (on)
        PORTC &= uint8_t(~_BV(PC4));
    else
        PORTC |= _BV(PC4);
}

inline void activityLed(bool on)
{
    if (on)
        PORTC &= uint8_t(~_BV(PC5));
    else
        PORTC |= _BV(PC5);
}
} // namespace board

struct BoardLink
{
    uint32_t now() const
    {
        return millis();
    }

    uint8_t receiveByte()
    {
        return board::receiveByte();
    }

    void acknowledgeReceive()
    {
        board::acknowledgeReceive();
    }

    void publishByte(uint8_t value)
    {
        board::publishByte(value);
    }

    void withdrawByte()
    {
        board::withdrawByte();
    }

    void idle()
    {
        board::idle();
    }
};
