
#include "bankedMemory.h"
#include "machine/machine.h"

uint8_t BankedMemory::read(uint16_t addr) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        int bankedMemmoryAddr = getBankedMemoryAddr(addr);
        if (bankedMemmoryAddr >= 0)
        {
            return bankedMemory_[bankedMemmoryAddr];
        }
    }

    return 0xff;
}

void BankedMemory::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        int bankedMemmoryAddr = getBankedMemoryAddr(addr);
        if (bankedMemmoryAddr >= 0)
        {
            bankedMemory_[bankedMemmoryAddr] = value;
        }
    }
}
