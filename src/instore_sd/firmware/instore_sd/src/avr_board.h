#pragma once
#include <Arduino.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#if !defined(__AVR_ATmega328P__) || F_CPU != 8000000UL
#error "Build for an ATmega328P clocked at 8 MHz"
#endif

// U1 pin map: PD0..7 is the shared byte bus between the four 74HCT573s.
// PB2..5 serve SD SPI; PB6 is the unused C68 R/W input; PB7 drives U17 /OE.
// PC0..2 read the command-write, data-write, and data-read pending flags.
// PC3..5 drive U17 (74HCT595) SER, shift clock, and storage clock.
namespace board
{
// U17 output bits Q0..Q7, in the same order as these named bit positions:
//   Q0 /OE U5 command input       Q1 /OE U9 data-write input
//   Q2 clear command pending      Q3 clear data-write pending
//   Q4 clear data-read pending    Q5 LE U8 status output
//   Q6 LE U10 response-data output  Q7 activity LED (high = off)
// The /OE and clear lines are active low; the two latch LE lines are active
// high. Idle therefore disables both input latches and releases all clears,
// while leaving the output latches holding their previous bytes.
#define U17_CMD_OE_BIT       0
#define U17_DATA_IN_OE_BIT   1
#define U17_CMD_CLEAR_BIT    2
#define U17_WRITE_CLEAR_BIT  3
#define U17_READ_CLEAR_BIT   4
#define U17_STATUS_LOAD_BIT  5
#define U17_DATA_OUT_LOAD_BIT 6
#define U17_ACTIVITY_LED_BIT 7
static const uint8_t CmdOE = _BV(U17_CMD_OE_BIT),
                     DataInOE = _BV(U17_DATA_IN_OE_BIT),
                     CmdClear = _BV(U17_CMD_CLEAR_BIT),
                     WriteClear = _BV(U17_WRITE_CLEAR_BIT),
                     ReadClear = _BV(U17_READ_CLEAR_BIT),
                     StatusLoad = _BV(U17_STATUS_LOAD_BIT),
                     DataOutLoad = _BV(U17_DATA_OUT_LOAD_BIT),
                     ActivityLedOff = _BV(U17_ACTIVITY_LED_BIT);
static const uint16_t ActivityHoldMs = 50;
static const uint8_t IdleControl = CmdOE | DataInOE | CmdClear |
                                   WriteClear | ReadClear;
static const uint8_t PendingMask = _BV(PC0) | _BV(PC1) | _BV(PC2);
static uint8_t control = IdleControl;
static uint32_t activityEndedAt;
static bool activityTail = false;

inline void shiftControl()
{
    // Send bit 7 first: each PC4 pulse shifts PC3 into U17. PC5 then copies
    // the full byte to Q0..Q7 at once, so no intermediate control pattern
    // reaches the latches or pending-flag clears.
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

// QH sinks LED current when low. Keep it high during card I/O, and for a
// short tail afterward so a quick sector access produces a visible flicker.
inline void beginActivity()
{
    activityTail = false;
    setControl(uint8_t(control | ActivityLedOff));
}

inline void endActivity()
{
    activityEndedAt = millis();
    activityTail = true;
}

inline void serviceActivity()
{
    if (activityTail && uint32_t(millis() - activityEndedAt) >= ActivityHoldMs)
    {
        activityTail = false;
        setControl(uint8_t(control & ~ActivityLedOff));
    }
}

inline void init()
{
    // R1 holds U17 /OE high during reset. Drive PB2 high before making it an
    // output so SD CS stays inactive; keep PB7 high until U17 is programmed.
    PORTB |= _BV(PB2) | _BV(PB7);
    DDRB |= _BV(PB2) | _BV(PB7);
    // No 573 may share PD0..7 with an AVR output during startup.
    DDRD = 0;
    PORTD = 0;
    // PC0..2 remain inputs for the pending flags; PC3..5 drive U17.
    PORTC = 0;
    DDRC = _BV(PC3) | _BV(PC4) | _BV(PC5);
    control = IdleControl;
    activityTail = false;
    shiftControl();
    // Expose the safe idle controls only after they have been latched in U17.
    PORTB &= uint8_t(~_BV(PB7));
}

inline uint8_t pending()
{
    // These are the three hardware flip-flop Q outputs, not Port C outputs.
    return PINC & PendingMask;
}

inline uint8_t takeInput(uint8_t enable, uint8_t clear)
{
    // Release PD0..7 before enabling U5 or U9 onto the shared byte bus.
    DDRD = 0;
    PORTD = 0;
    // Pull the selected 573 /OE low, let its byte settle, then sample PIND.
    setControl(uint8_t(control & ~enable));
    _delay_us(1);
    const uint8_t value = PIND;
    // Remove the 573 from the bus before clearing its pending flip-flop.
    setControl(uint8_t(control | enable));
    // The clear input is active low; return it high for the next host write.
    setControl(uint8_t(control & ~clear));
    setControl(uint8_t(control | clear));
    return value;
}

inline void clearPending(uint8_t clear)
{
    // A data read has no input byte to sample; only acknowledge its flag.
    setControl(uint8_t(control & ~clear));
    setControl(uint8_t(control | clear));
}

inline void clearAll()
{
    // Disable incoming 573 outputs, pulse all three pending clears low,
    // then release them together. Output latch bytes are unaffected.
    setControl(IdleControl);
    setControl(uint8_t(IdleControl & ~uint8_t(CmdClear | WriteClear | ReadClear)));
    setControl(IdleControl);
}

inline void stage(uint8_t value, uint8_t load)
{
    // Disconnect U5 and U9 before the AVR becomes the PD0..7 bus driver.
    setControl(uint8_t(control | CmdOE | DataInOE));
    // Set the output value before switching the port to outputs.
    PORTD = value;
    DDRD = 0xff;
    _delay_us(1);
    // A high LE makes U8 or U10 transparent; the falling edge holds the byte
    // for C68 reads while the AVR returns the shared bus to input mode.
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
