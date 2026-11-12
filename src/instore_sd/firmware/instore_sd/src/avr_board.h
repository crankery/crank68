#pragma once
#include <Arduino.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#if !defined(__AVR_ATmega328P__) || F_CPU != 8000000UL
#error "Build for an ATmega328P clocked at 8 MHz"
#endif

// Instore SD U1: PD0..7 shared between input and output 573s;
// PB2..5 SD SPI, PB6=R/W input, PB7=74HCT595 /OE;
// PC0=command pending, PC1=data-write pending, PC2=data-read pending,
// PC3=595 SER, PC4=SRCLK, PC5=RCLK.
namespace board
{
static const uint8_t CmdOE = _BV(0), DataInOE = _BV(1), CmdClear = _BV(2),
                     WriteClear = _BV(3), ReadClear = _BV(4),
                     StatusLoad = _BV(5), DataOutLoad = _BV(6);
static const uint8_t IdleControl = CmdOE | DataInOE | CmdClear |
                                   WriteClear | ReadClear;
static const uint8_t PendingMask = _BV(PC0) | _BV(PC1) | _BV(PC2);
static uint8_t control = IdleControl;

inline void shiftControl()
{
    // U17 Q0..Q6 follow bits 0..6 after the storage-clock rising edge.
    for (int8_t bit = 7; bit >= 0; --bit)
    {
        if (control & _BV(bit)) PORTC |= _BV(PC3);
        else PORTC &= uint8_t(~_BV(PC3));
        PORTC |= _BV(PC4);
        PORTC &= uint8_t(~_BV(PC4));
    }
    PORTC |= _BV(PC5);
    PORTC &= uint8_t(~_BV(PC5));
}

inline void setControl(uint8_t value)
{
    control = value;
    shiftControl();
}

inline void init()
{
    // R1 holds the 595 disabled while the AVR resets. Select no SD card,
    // keep the 595 disabled, and leave the shared Port D as input first.
    PORTB |= _BV(PB2) | _BV(PB7);
    DDRB |= _BV(PB2) | _BV(PB7);
    DDRD = 0;
    PORTD = 0;
    PORTC = 0;
    DDRC = _BV(PC3) | _BV(PC4) | _BV(PC5);
    control = IdleControl;
    shiftControl();
    PORTB &= uint8_t(~_BV(PB7));
}

inline uint8_t pending()
{
    return PINC & PendingMask;
}

inline uint8_t takeInput(uint8_t enable, uint8_t clear)
{
    DDRD = 0;
    PORTD = 0;
    setControl(uint8_t(control & ~enable));
    _delay_us(1);
    const uint8_t value = PIND;
    setControl(uint8_t(control | enable));
    setControl(uint8_t(control & ~clear));
    setControl(uint8_t(control | clear));
    return value;
}

inline void clearPending(uint8_t clear)
{
    setControl(uint8_t(control & ~clear));
    setControl(uint8_t(control | clear));
}

inline void clearAll()
{
    setControl(IdleControl);
    setControl(uint8_t(IdleControl & ~uint8_t(CmdClear | WriteClear | ReadClear)));
    setControl(IdleControl);
}

inline void stage(uint8_t value, uint8_t load)
{
    // Both input latch outputs are disabled before Port D drives a byte.
    setControl(uint8_t(control | CmdOE | DataInOE));
    PORTD = value;
    DDRD = 0xff;
    _delay_us(1);
    setControl(uint8_t(control | load));
    setControl(uint8_t(control & ~load));
    DDRD = 0;
    PORTD = 0;
}

inline void stageData(uint8_t value) { stage(value, DataOutLoad); }
inline void stageStatus(uint8_t value) { stage(value, StatusLoad); }
} // namespace board

struct BoardIO
{
    static const uint8_t CommandPending = _BV(PC0),
                         DataWritePending = _BV(PC1),
                         DataReadPending = _BV(PC2);

    uint8_t pending() const { return board::pending(); }
    uint8_t takeCommand() { return board::takeInput(board::CmdOE, board::CmdClear); }
    uint8_t takeDataWrite() { return board::takeInput(board::DataInOE, board::WriteClear); }
    void clearDataRead() { board::clearPending(board::ReadClear); }
    void clearAll() { board::clearAll(); }
    void stageData(uint8_t value) { board::stageData(value); }
    void stageStatus(uint8_t value) { board::stageStatus(value); }
    uint32_t now() const { return millis(); }
};
