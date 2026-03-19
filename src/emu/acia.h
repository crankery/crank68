#pragma once

#include <cstring>
#include "memoryIODevice.h"

static const uint8_t AciaRegisterCount = 2;

class Acia : public MemoryIODevice
{
public:
    // control register - 0bITTWWWDD
    //
    // I (bit 7): receive interrupt enable (/DCD is low) (CR7)
    // 0b0: disable rx interrupts
    // 0b1: enable rx interrupts
    //
    // TT (bits 5-6): transmitter control bits (/RTS is low) (CR5-6)
    // 0b00 = tx interrupt disabled
    // 0b01 = tx interrupt enabled
    // 0xb10 = tx interrupt disabled
    // 0xb11 = tx break level on tx data out, tx interrupt disabled
    //
    // WWWW (bits 2-4): word select (CR2-4)
    // 0xb000 = 7E2 (7 bits, even parity, 2 stop)
    // 0xb001 = 7O2 (7 bits, odd parity, 1 stop)
    // 0xb010 = 7E1
    // 0xb011 = 7O1
    // 0xb100 = 8N2 (8 bits, no parity, 2 stop)
    // 0xb101 = 8N1
    // 0xb110 = 8E1 (the money option)
    // 0xb111 = 8O1
    //
    // DD (bits 0-1): counter divide select bits (CR0-1)
    // 0b00 = /1
    // 0b01 = /16
    // 0b10 = /64
    // 0b11 = reset - set to 0x11 to reset device then select clock divisor
    struct ControlByte
    {
        unsigned char divisorSelectAndReset : 2;
        unsigned char wordSelect : 3;
        unsigned char transmitterControl : 2;
        unsigned char receiveInterruptEnable : 1;
    };

    struct StatusByte
    {
        unsigned char rdrf : 1;
        unsigned char tdre : 1;
        unsigned char dcd_n : 1;
        unsigned char cts_n : 1;
        unsigned char fe : 1;
        unsigned char ovrn : 1;
        unsigned char pe : 1;
        unsigned char irq_n : 1;
    };

    Acia(const uint8_t slot, const uint8_t offset)
        : MemoryIODevice(slot, offset, AciaRegisterCount)
    {
        // clear the old state
        // these are just to note what changed
        ControlByte cb;
        cb.divisorSelectAndReset = 0;
        cb.receiveInterruptEnable = 0;
        cb.transmitterControl = 0;
        cb.wordSelect = 0;
        oldControl = cb;

        StatusByte sb;
        sb.cts_n = 0;
        sb.dcd_n = 0;
        sb.fe = 0;
        sb.irq_n = 0;
        sb.ovrn = 0;
        sb.pe = 0;
        sb.rdrf = 0;
        sb.tdre = 0;
        oldStatus = sb;
    }

    virtual uint8_t in(uint8_t port) const override;
    virtual void out(uint8_t port, uint8_t value) override;

private:
    ControlByte oldControl;
    StatusByte oldStatus;
    // uint8_t oldReceive = 0;
    // uint8_t oldTransmit = 0;
};