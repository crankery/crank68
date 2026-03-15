#include "ram.h"

uint8_t Ram::read(uint16_t addr) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        return memory_[addr - StartAddress];
    }

    return 0xff;
}

void Ram::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        memory_[addr - StartAddress] = value;
    }
}
