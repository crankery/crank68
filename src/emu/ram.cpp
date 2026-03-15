#include "ram.h"

bool Ram::read(uint16_t addr, uint8_t &value) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        value = memory_[addr - StartAddress];
        return true;
    }

    return false;
}

bool Ram::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        memory_[addr - StartAddress] = value;
        return true;
    }

    return false;
}
