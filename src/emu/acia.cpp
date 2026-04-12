#include "acia.h"
#include "machine.h"

uint8_t Acia::in(uint8_t port)
{
    char buf[80];
    switch (port & 0xf)
    {
    case 0:
    {
        uint8_t status = getStatusByte();

        snprintf(buf, sizeof(buf), "%s status in %02x\n", name(), status);
        Machine::instance().log(buf);

        return status;
    }
    case 1:
    {
        std::optional<uint8_t> c = terminalOutAciaInBuffer.next();
        if (c.has_value())
        {
            snprintf(buf, sizeof(buf), "%s data in %02x\r\n", name(), c.value());
            lastOut = c.value();
        }

        return lastOut;
    }
    default:
        return 0xa5;
    }
}

void Acia::out(uint8_t port, uint8_t value)
{
    char buf[80];

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

        snprintf(buf, sizeof(buf), "%s control out %02x\n", name(), value);
        Machine::instance().log(buf);
        // control
        controlByte = value;
        break;
    }
    case 1:
    {
        snprintf(buf, sizeof(buf), "%s data out %02x\n", name(), value);
        Machine::instance().log(buf);

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

    // printf("terminalOutAciaIn: %c, terminalOutAciaInBuffer length: %d\r\n", c, terminalOutAciaInBuffer.length());
}

bool Acia::terminalOutAciaInReady()
{
    return !terminalOutAciaInBuffer.empty();
}

std::optional<uint8_t> Acia::terminalInAciaOut()
{
    return terminalInAciaOutBuffer.next();
}

bool Acia::terminalInAciaOutReady()
{
    return !terminalInAciaOutBuffer.empty();
}

uint8_t Acia::getStatusByte()
{
    uint8_t status = (terminalOutAciaInReady() ? status_rdrf : 0) // receive buffer full, that is there's at least one byte in the queue
                     | status_tdre                                // "transmit buffer empty", but really we have a basically infinite queue
                     | status_irq_n;                              // there are no interrupts

    return status;
}