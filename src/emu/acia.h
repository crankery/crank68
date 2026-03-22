#pragma once

#include <cstring>
#include "memoryIODevice.h"
#include "byteBuffer.h"

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

    // status byte
    // rdrf  - receiver buffer is full
    // tdre  - transmit buffer is empty
    // dcd_n - data carrier detected
    // cts_n - clear to send
    // fe    - there is no framing error
    // ovrn  - there is no receiver overrun
    // pe   -  there is no parity error
    // irq_n - this acia has not issued an IRQ
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
        : MemoryIODevice(slot, offset, RegisterCount)
    {
    }

    virtual uint8_t in(uint8_t port) override;
    virtual void out(uint8_t port, uint8_t value) override;

    // terminal output
    void terminalOutAciaIn(uint8_t c);
    bool clearToSend();

    // terminal input
    std::optional<uint8_t> terminalInAciaOut();

    bool dataReady();

    static const uint8_t RegisterCount = 2;

private:
    ByteBuffer terminalInAciaOutBuffer;
    ByteBuffer terminalOutAciaInBuffer;
};