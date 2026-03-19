#include "ram.h"

uint8_t Ram::read(uint16_t addr) const
{
    if (addr >= startAddress_ && addr <= endAddress_)
    {
        return memory_[addr - startAddress_];
    }

    return 0xff;
}

void Ram::write(uint16_t addr, uint8_t value)
{
    if (addr >= startAddress_ && addr <= endAddress_)
    {
        memory_[addr - startAddress_] = value;
    }
}
