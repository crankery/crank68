#include "ram.h"

uint8_t Ram::read(uint16_t addr) const
{
    if (addr >= startAddress_ && addr <= endAddress_)
    {
        printf("ram::read[%04x]: %02x\n", addr - startAddress_, memory_[addr - startAddress_]);
        return memory_[addr - startAddress_];
    }

    return 0xff;
}

void Ram::write(uint16_t addr, uint8_t value)
{
    printf("ram write\n");
    if (addr >= startAddress_ && addr <= endAddress_)
    {
        memory_[addr - startAddress_] = value;
        printf("ram::write[%04x]=%02x: %02x\n", value, addr - startAddress_, memory_[addr - startAddress_]);
    }
}
