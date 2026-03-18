#include "acia.h"

#include <cstdint>

uint8_t Acia::in(uint8_t addr) const
{
    // uint8_t port = getPort(addr);
    switch (addr)
    {
    case 0:
    {
        // status register
        StatusByte sb;
        sb.rdrf = 0;  // receiver buffer is full <-- this one needs to be twiddled
        sb.tdre = 1;  //  transmit buffer is empty
        sb.dcd_n = 0; // data carrier detected
        sb.cts_n = 0; // clear to send
        sb.fe = 0;    // there is no framing error
        sb.ovrn = 0;  // there is no receiver overrun
        sb.pe = 0;    // there is no parity error
        sb.irq_n = 0; // this acia has not issued an IRQ -- another twiddler

        uint8_t sb_byte;
        memcpy((void *)&oldStatus, (void *)&sb, sizeof(StatusByte));
        memcpy((void *)&sb_byte, (void *)&sb, sizeof(StatusByte));

        return sb_byte;
    }

    case 1:
    {
        // receive regiter
        // gonna need a socket server sooner than later
        return 0xff;
    }

    default:
        // open bus
        // todo: this is weird if we get here, add assert
        return 0xff;
    }
}

void Acia::out(uint8_t addr, uint8_t value)
{
    switch (addr)
    {
    case 0:
        // control register
        ControlByte cb;
        memset(&cb, value, sizeof(ControlByte));
        oldControl = cb;
        break;
    case 1:
        // transmit register
        // send it on out to the output stream
        break;
    }

    // todo: this is weird, add assert
}
