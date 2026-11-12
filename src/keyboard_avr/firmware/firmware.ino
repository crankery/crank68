#include <Arduino.h>
#include <avr/interrupt.h>
#include "key_logic.h"

#if !defined(__AVR_ATmega328P__) || F_CPU != 8000000UL
#error "Build for an ATmega328P clocked at 8 MHz"
#endif

// Instore U4. The two HCT573s isolate PD0..7 from the C68 data bus.
// PB0=/KBD_STATUS, PB1=/KBD_DATA, PB2=Caps LED cathode, PB3=read ACK,
// PB4=status latch LE, PB5=data latch LE, PB6=/NMI, PB7=system /RESET.
// PC0=QS, PC1=/PL, PC2=CP, PC3..5=row A0..2.
namespace
{
    constexpr uint8_t Qs = _BV(PC0);
    constexpr uint8_t ParallelLoad = _BV(PC1);
    constexpr uint8_t Clock = _BV(PC2);
    constexpr uint8_t RowMask = _BV(PC3) | _BV(PC4) | _BV(PC5);
    constexpr uint8_t CapsLed = _BV(PB2);
    constexpr uint8_t ReadAck = _BV(PB3); // U7 Q rises when a data read ends.
    constexpr uint8_t StatusLoad = _BV(PB4);
    constexpr uint8_t DataLoad = _BV(PB5);
    constexpr uint8_t Nmi = _BV(PB6);
    constexpr uint8_t Reset = _BV(PB7);
    constexpr uint8_t Ready = _BV(0);
    constexpr uint8_t Sequence = _BV(1);
    constexpr uint8_t ScanPeriodMs = 5;

    keyboard::State keys;
    volatile bool externalReset = false;
    bool stagedReady = false;
    bool sequence = false;
    uint32_t lastScan = 0;

    void loadLatch(uint8_t enable)
    {
        PORTB |= enable;
        asm volatile("nop\n\tnop\n\t");
        PORTB &= uint8_t(~enable);
    }

    void publish(bool advanceSequence)
    {
        // U12 holds the byte throughout the C68 read. Its load pulse also
        // clears U7's read acknowledgment before the next byte is offered.
        const uint8_t value = keys.front();
        PORTD = value;
        loadLatch(DataLoad);
        stagedReady = value != 0;

        if (advanceSequence)
        {
            sequence = !sequence;
        }

        // U11 is a separate status latch. Publish status only after data.
        PORTD = uint8_t((stagedReady ? Ready : 0) |
                        (sequence ? Sequence : 0));
        loadLatch(StatusLoad);
    }

    void serviceRead()
    {
        if (PINB & ReadAck)
        {
            if (stagedReady)
            {
                keys.consume();
            }
            publish(true);
        }
        else if (!stagedReady && keys.front())
        {
            publish(true);
        }
    }

    uint16_t scanRow(uint8_t row)
    {
        const uint8_t base = uint8_t((PORTC & ~RowMask) |
                                     (row << PC3) | ParallelLoad);
        PORTC = uint8_t(base & ~Clock);
        PORTC = uint8_t(base & ~ParallelLoad);
        asm volatile("nop\n\tnop\n\t");
        PORTC = base;

        uint16_t value = 0;
        for (uint8_t bit = 0; bit < 16; ++bit)
        {
            value = uint16_t((value << 1) | ((PINC & Qs) ? 1 : 0));
            PORTC = uint8_t(base | Clock);
            PORTC = base;
        }

        return uint16_t(~value & 0x07ff);
    }

    void pulseNmi()
    {
        PORTB &= uint8_t(~Nmi);
        DDRB |= Nmi; // Sink the shared line; never drive it high.
        delayMicroseconds(100);
        DDRB &= uint8_t(~Nmi);
    }

    void pulseReset()
    {
        // Do not mistake our own pulse for an externally requested reset.
        PCMSK0 &= uint8_t(~Reset);
        PORTB &= uint8_t(~Reset);
        DDRB |= Reset;
        delayMicroseconds(100);
        DDRB &= uint8_t(~Reset);
        PCIFR = _BV(PCIF0);
        PCMSK0 |= Reset;
    }

    void clearOnExternalReset()
    {
        keys = keyboard::State();
        PORTB |= CapsLed;
        stagedReady = false;
        sequence = false;
        publish(false);
    }
}

ISR(PCINT0_vect)
{
    if (!(PINB & Reset))
    {
        externalReset = true;
    }
}

void setup()
{
    cli();
    PORTD = 0;
    DDRD = 0xff;

    // Load pins start low, the LED starts off, and NMI/RESET float.
    PORTB = CapsLed;
    DDRB = uint8_t(CapsLed | StatusLoad | DataLoad);
    PORTC = ParallelLoad;
    DDRC = uint8_t(ParallelLoad | Clock | RowMask);
    publish(false);

    externalReset = !(PINB & Reset);
    PCMSK0 = Reset;
    PCIFR = _BV(PCIF0);
    PCICR |= _BV(PCIE0);
    lastScan = millis();
    sei();
}

void loop()
{
    if (externalReset)
    {
        externalReset = false;
        clearOnExternalReset();
    }

    serviceRead();

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
            PORTB &= uint8_t(~CapsLed);
        }
        else
        {
            PORTB |= CapsLed;
        }
    }

    serviceRead();
    if (events.breakPressed)
    {
        pulseNmi();
    }
    if (events.resetPressed)
    {
        pulseReset();
    }
}
