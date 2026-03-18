#include "machine.h"

uint8_t Machine::read(uint16_t addr) const
{
    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        return ram_.read(addr);
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        return rom_.read(addr);
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        return memory_io_.read(addr);
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        return banked_memory_.read(addr);
    }

    return 0xff;
}

void Machine::write(uint16_t addr, uint8_t value)
{
    if (addr >= ram_.getStartAddress() && addr <= ram_.getStartAddress())
    {
        ram_.write(addr, value);
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getStartAddress())
    {
        rom_.write(addr, value);
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getStartAddress())
    {
        memory_io_.write(addr, value);
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getStartAddress())
    {
        banked_memory_.write(addr, value);
    }
}
