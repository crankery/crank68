
#include "memoryIO.h"

uint8_t MemoryIO::read(uint16_t addr) const
{
    // if (addr >= StartAddress && addr <= EndAddress)
    // {
    // }

    return 0xff; // For simplicity, we return 0xff for all IO reads in this toy emulator
}

void MemoryIO::write(uint16_t addr, uint8_t value)
{
    // if (addr >= StartAddress && addr <= EndAddress)
    // {
    // }
}
