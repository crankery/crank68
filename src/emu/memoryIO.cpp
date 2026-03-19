
#include "memoryIO.h"

uint8_t MemoryIO::read(uint16_t addr) const
{
    int8_t port = acia_0_.getPort(addr);
    if (port >= 0)
    {
        return acia_0_.in(port);
    }

    port = acia_1_.getPort(addr);
    if (port >= 0)
    {
        return acia_1_.in(port);
    }

    port = banked_memory_latch_.getPort(addr);
    if (port >= 0)
    {
        return banked_memory_latch_.in(port);
    }

    return 0xff;
}

void MemoryIO::write(uint16_t addr, uint8_t value)
{
    int8_t port = acia_0_.getPort(addr);
    if (port >= 0)
    {
        acia_0_.out(port, value);
    }

    port = acia_1_.getPort(addr);
    if (port >= 0)
    {
        acia_1_.out(port, value);
    }

    port = banked_memory_latch_.getPort(addr);
    if (port >= 0)
    {
        banked_memory_latch_.out(port, value);
    }
}