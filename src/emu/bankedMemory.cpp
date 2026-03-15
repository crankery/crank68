
#include "bankedMemory.h"

uint8_t BankedMemory::read(uint16_t addr) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        return 0xff;
        return true;
    }

    return false;
}

void BankedMemory::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        return;
    }
}
