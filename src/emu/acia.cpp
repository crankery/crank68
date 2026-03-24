#include "acia.h"
#include "machine.h"

uint8_t Acia::in(uint8_t port)
{
    switch (port & 0xf)
    {
    case 0:
    {
        uint8_t status = getStatusByte();

        char buf[80];
        snprintf(buf, sizeof(buf), "Acia read status byte: %02x\n", status);
        Machine::instance().trace(buf);

        return status;
    }
    case 1:
    {
        std::optional<uint8_t> c = terminalOutAciaInBuffer.next();
        if (c.has_value())
        {
            lastOut = c.value();
        }

        // no data avaiable, probably shouldn't have called this :)
        // assume the acia would have just returned whatever the heck it had prepared in the buffer last time
        return lastOut;
    }
    default:
        return 0xff;
    }
}

void Acia::out(uint8_t port, uint8_t value)
{
    switch (port & 0xf)
    {
    case 0:
    {
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
        char buf[80];
        snprintf(buf, sizeof(buf), "Acia control byte set to %02x\n", value);
        Machine::instance().trace(buf);
        // control
        controlByte = value;
        break;
    }
    case 1:
    {
        terminalInAciaOutBuffer.push(value);
        break;
    }
    default:
        break;
    }
}

void Acia::terminalOutAciaIn(uint8_t c)
{
    terminalOutAciaInBuffer.push(c);
}

bool Acia::clearToSend()
{
    // I don't think it really matters much
    return true;
}

std::optional<uint8_t> Acia::terminalInAciaOut()
{
    return terminalInAciaOutBuffer.next();
}

bool Acia::dataReady()
{
    return !terminalOutAciaInBuffer.empty();
}

uint8_t Acia::getStatusByte()
{
    uint8_t status = (dataReady() ? status_rdrf : 0) // if there's data ready, rdrf is set
                     | status_tdre                   // the terminal is good to go
                     | status_irq_n;                 // there are no interrupts

    return status;
}