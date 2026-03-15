#include "machine.h"

uint8_t Machine::read(uint16_t addr) const
{
    if (addr >= Ram::StartAddress && addr <= Ram::EndAddress)
    {
        return ram_.read(addr);
    }
    else if (addr >= Rom::StartAddress && addr <= Rom::EndAddress)
    {
        return rom_.read(addr);
    }
    else if (addr >= MemoryIO::StartAddress && addr <= MemoryIO::EndAddress)
    {
        return memory_io_.read(addr);
    }
    else if (addr >= BankedMemory::StartAddress && addr <= BankedMemory::EndAddress)
    {
        return banked_memory_.read(addr);
    }

    return 0xff;
}

void Machine::write(uint16_t addr, uint8_t value)
{
    if (addr >= Ram::StartAddress && addr <= Ram::EndAddress)
    {
        ram_.write(addr, value);
    }
    else if (addr >= Rom::StartAddress && addr <= Rom::EndAddress)
    {
        rom_.write(addr, value);
    }
    else if (addr >= MemoryIO::StartAddress && addr <= MemoryIO::EndAddress)
    {
        memory_io_.write(addr, value);
    }
    else if (addr >= BankedMemory::StartAddress && addr <= BankedMemory::EndAddress)
    {
        banked_memory_.write(addr, value);
    }
}
