
#include "memoryIO.h"

MemoryIO::read(uint16_t addr, uint8_t &value) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        value = 0; // For simplicity, we return 0 for all IO reads in this toy emulator
        return true;
    }

    return false;
}

MemoryIO::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        // For simplicity, we ignore all IO writes in this toy emulator
        return true;
    }

    return false;
}
