#include <Arduino.h>
#include <avr/interrupt.h>
#include <util/atomic.h>
#include "key_logic.h"

#if !defined(__AVR_ATmega328P__) || F_CPU != 8000000UL
#error "Build for an ATmega328P clocked at 8 MHz"
#endif

// U4 on ../Vera: PD0..7 go to an external HCT573 bus latch.
// PB0=QS, PB1=/PL, PB2=CP, PB3..5=A0..2.
// PC0=BUS_OK, PC1=/KEY_READ (qualified read strobe), PC2=R/W,
// PC3=Caps LED cathode, PC4=/NMI, PC5=/RESET (open-drain style).
// /KEY_READ must be low only for a selected $E080 read with BUS_OK true.
namespace
{
    constexpr uint8_t Qs = _BV(PB0);
    constexpr uint8_t ParallelLoad = _BV(PB1);
    constexpr uint8_t Clock = _BV(PB2);
    constexpr uint8_t RowMask = _BV(PB3) | _BV(PB4) | _BV(PB5);
    constexpr uint8_t ReadStrobe = _BV(PC1);
    constexpr uint8_t CapsLed = _BV(PC3);
    constexpr uint8_t Nmi = _BV(PC4);
    constexpr uint8_t Reset = _BV(PC5);
    constexpr uint8_t ScanPeriodMs = 5;

    keyboard::State keys;
    volatile uint8_t staged = 0;
    volatile bool pendingRead = false;
    uint32_t lastScan = 0;

    void publish()
    {
        const uint8_t value = keys.front();
        PORTD = value;
        staged = value;
    }

    void finishRead()
    {
        // Called only after the read strobe has ended; the CPU has sampled PORTD.
        if (staged)
        {
            keys.consume();
        }

        publish();
        pendingRead = false;
        PCIFR = _BV(PCIF1);
        PCMSK1 |= ReadStrobe;
    }

    uint16_t scanRow(uint8_t row)
    {
        const uint8_t base = uint8_t((PORTB & ~RowMask) | (row << PB3) | ParallelLoad);
        PORTB = uint8_t(base & ~Clock);
        PORTB = uint8_t(base & ~ParallelLoad);
        asm volatile("nop\n\tnop\n\t");
        PORTB = base;

        uint16_t value = 0;
        for (uint8_t bit = 0; bit < 16; ++bit)
        {
            value = uint16_t((value << 1) | ((PINB & Qs) ? 1 : 0));
            PORTB = uint8_t(base | Clock);
            PORTB = base;
        }

        return uint16_t(~value & 0x07ff);
    }

    void pulseNmi()
    {
        PORTC &= uint8_t(~Nmi); // Never drive the shared /NMI line high.
        DDRC |= Nmi;
        delayMicroseconds(100);
        DDRC &= uint8_t(~Nmi);
    }

    void pulseReset()
    {
        PORTC &= uint8_t(~Reset); // Never drive the shared /RESET line high.
        DDRC |= Reset;
        delayMicroseconds(100);
        DDRC &= uint8_t(~Reset);
    }
}

ISR(PCINT1_vect)
{
    // PCINT latches even if this short bus pulse ends before ISR entry.
    // Mask both edges so one CPU read can consume at most one character.
    PCMSK1 &= uint8_t(~ReadStrobe);
    for (uint8_t tries = 0; tries < 64; ++tries)
    {
        if (PINC & ReadStrobe)
        {
            finishRead();
            return;
        }
    }

    // A held-low strobe cannot trap the AVR in an interrupt forever.
    pendingRead = true;
}

void setup()
{
    cli();
    PORTD = 0;
    DDRD = 0xff; // HCT573 isolates these outputs from the C68 data bus.

    PORTB = ParallelLoad;
    DDRB = uint8_t(ParallelLoad | Clock | RowMask);

    PORTC |= uint8_t(ReadStrobe | CapsLed);
    PORTC &= uint8_t(~(Nmi | Reset));
    DDRC = CapsLed; // NMI/RESET released; PC0/1/2 are inputs.

    PCMSK1 = ReadStrobe;
    PCIFR = _BV(PCIF1);
    PCICR |= _BV(PCIE1);
    lastScan = millis();
    sei();
}

void loop()
{
    if (pendingRead && (PINC & ReadStrobe))
    {
        ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
        {
            finishRead();
        }
    }

    const uint32_t now = millis();
    if (uint32_t(now - lastScan) < ScanPeriodMs)
    {
        return;
    }

    lastScan = now;
    uint16_t matrix[keyboard::Rows];
    for (uint8_t row = 0; row < keyboard::Rows; ++row)
    {
        matrix[row] = scanRow(row);
    }

    const keyboard::Events events = keys.scan(matrix);
    if (events.capsChanged)
    {
        if (keys.caps())
        {
            PORTC &= uint8_t(~CapsLed);
        }
        else
        {
            PORTC |= CapsLed;
        }
    }

    ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
    {
        publish();
    }

    if (events.breakPressed)
    {
        pulseNmi();
    }

    if (events.resetPressed)
    {
        pulseReset();
    }
}
