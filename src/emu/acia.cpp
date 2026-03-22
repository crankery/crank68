// #include <cstdint>
// #include <stdio.h>
// #include "acia.h"

// uint8_t Acia::in(const uint8_t port) const
// {
//     switch (port)
//     {
//     case 0:
//     {
//         // status register
//         Acia::StatusByte sb;
//         sb.rdrf = Acia::dataReady(); // there's data available
//         sb.tdre = 1;                 // the data terminal is ready to go
//         sb.dcd_n = 0;                // data carrier detected - always connected
//         sb.cts_n = 0;                // clear to send
//         sb.fe = 0;                   // there is no framing error
//         sb.ovrn = 0;                 // there is no receiver overrun
//         sb.pe = 0;                   // there is no parity error
//         sb.irq_n = 1;                // this acia has not issued an IRQ

//         uint8_t sb_byte;
//         memcpy((void *)&sb_byte, (void *)&sb, sizeof(StatusByte));

//         return sb_byte;
//     }

//     case 1:
//     {
//         if (Acia::dataReady())
//         {
//             return terminalIn();
//         }
//     }
//     }

//     return 0xff;
// }

// void Acia::out(uint8_t port, uint8_t value)
// {
//     printf("acia out %x: %02x\r\n", port, value);
//     switch (port)
//     {
//     case 0:
//     {
//         printf("control write: %02x\r\n", value);

//         // control register
//         ControlByte cb;
//         memset(&cb, value, sizeof(ControlByte));

//         // don't really care much about this yet
//         break;
//     }
//     case 1:
//     {
//         printf("terminal out: %02x\r\n", value);
//         terminalOut(value);
//         break;
//     }
//     }
// }

// // receive data from terminal
// char Acia::terminalIn() const
// {
//     // make sure there's really data first
//     if (TerminalInBufferIdx > 0)
//     {
//         // take the first one off
//         char c = TerminalBuffer[0];

//         // move them all up one spot
//         for (int i = 0; i < TerminalInBufferIdx; i++)
//         {
//             TerminalInBuffer[TerminalInBufferIdx] = TerminalInBuffer[TerminalInBufferIdx + 1];
//         }

//         // decrement the buffer index
//         TerminalInBufferIdx--;

//         // sanity
//         if (TerminalInBufferIdx < 0)
//         {
//             TerminalInBufferIdx = 0;
//         }
//         return c;
//     }

//     // return a sensible value when called with no data
//     return '\0';
// }

// // terminal has data ready to receive
// bool Acia::dataReady() const
// {
//     printf("checking terminal ready buffer index = %x\r\n", TerminalInBufferIdx);
//     return TerminalInBufferIdx > 0;
// }

// // data out from terminal
// void Acia::terminalOut(char c) const
// {
//     if (AciaBufferIdx < AciaBufferSize)
//     {
//         TerminalOutBuffer[TerminalOutBufferIdx++] = c;
//         printf("terminal out %02x, bufidx = %1x\r\n", c, TerminalOutBufferIdx);
//     }

//     // else overrun
// }

// // ready to send data out from terminal
// bool Acia::clearToSend() const
// {
//     return TerminalOutBufferIdx < BufferSize;
// }

#include "acia.h"
#include "machine.h"

uint8_t Acia::in(uint8_t port)
{
    switch (port & 0xf)
    {
    case 0:
        // status byte
        // status register
        Acia::StatusByte sb;
        sb.rdrf = !terminalOutAciaInBuffer.empty(); // there's data available
        sb.tdre = 1;                                // the data terminal is ready to go
        sb.dcd_n = 0;                               // data carrier detected
        sb.cts_n = 0;                               // clear to send
        sb.fe = 0;                                  // there is no framing error
        sb.ovrn = 0;                                // there is no receiver overrun
        sb.pe = 0;                                  // there is no parity error
        sb.irq_n = 1;                               // this acia has not issued an IRQ

        uint8_t sb_byte;
        memcpy((void *)&sb_byte, (void *)&sb, sizeof(StatusByte));

        return sb_byte;
    case 1:
        // data
        if (!terminalOutAciaInBuffer.empty())
        {
            std::optional<uint8_t> c = terminalOutAciaInBuffer.next();
            if (c.has_value())
            {
                return c.value();
            }
            else
            {
                return 0xff;
            }
        }
        else
            return 0xff;

    default:
        return 0xff;
    }
}

void Acia::out(uint8_t port, uint8_t value)
{
    switch (port & 0xf)
    {
    case 0:
        // control
    case 1:
        // data;
        terminalInAciaOutBuffer.push(value);
        break;

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
    return !terminalInAciaOutBuffer.empty();
}
