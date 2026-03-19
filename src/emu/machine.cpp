#include "machine.h"

uint8_t Machine::read(uint16_t addr) const
{
    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        uint8_t v = ram_.read(addr);
        //        printf("machine read ram[%04x]: %02x\n", addr, v);
        return v;
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        uint8_t v = rom_.read(addr);
        //      printf("machine read rom[%04x]: %02x\n", addr, v);
        return v;
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
    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        ram_.write(addr, value);
        return;
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        rom_.write(addr, value);
        return;
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        memory_io_.write(addr, value);
        return;
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        banked_memory_.write(addr, value);
        return;
    }
}