#pragma once

#include <cstring>
#include "memoryIODevice.h"
#include "byteBuffer.h"

class Acia : public MemoryIODevice
{
public:
    // status
    // rdrf  - receiver buffer is full
    // tdre  - transmit buffer is empty
    // dcd_n - data carrier detected
    // cts_n - clear to send
    // fe    - there is no framing error
    // ovrn  - there is no receiver overrun
    // pe   -  there is no parity error
    // irq_n - this acia has not issued an IRQ
    static const uint8_t status_rdrf = 0x01;
    static const uint8_t status_tdre = 0x02;
    static const uint8_t status_dcd_n = 0x04;
    static const uint8_t status_cts_n = 0x08;
    static const uint8_t status_fe = 0x10;
    static const uint8_t status_ovrn = 0x20;
    static const uint8_t status_pe = 0x40;
    static const uint8_t status_irq_n = 0x80;

    Acia(const uint8_t slot, const uint8_t offset)
        : MemoryIODevice(slot, offset, RegisterCount)
    {
        snprintf(name_, sizeof(name_), "acia(%x:%x)", slot, offset);
    }

    virtual uint8_t in(uint8_t port) override;
    virtual void out(uint8_t port, uint8_t value) override;

    // terminal output
    void terminalOutAciaIn(uint8_t c);
    bool terminalOutAciaInReady();

    virtual char *name() override
    {
        return name_;
    }

    // terminal input
    std::optional<uint8_t> terminalInAciaOut();
    bool terminalInAciaOutReady();

    static const uint8_t RegisterCount = 2;

private:
    uint8_t getStatusByte();

    ByteBuffer terminalInAciaOutBuffer;
    ByteBuffer terminalOutAciaInBuffer;

    uint8_t controlByte;
    uint8_t lastOut;

    char name_[25];
};