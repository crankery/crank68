
#include "bankedMemory.h"
#include "machine.h"

int BankedMemory::getBankedMemoryAddr(uint16_t busAddr) const
{
    int bankNumber = Machine::instance().memory_io_.getBankedMemoryLatchValue();
    if (bankNumber > InstalledBanks)
    {
        return -1;
    }

    int baseAddress = busAddr - StartAddress; // 0x0000 - 0x1FFF
    return bankNumber * 0x2000 + baseAddress;
}

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
