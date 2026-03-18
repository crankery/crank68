#include "machine.h"

uint8_t Machine::read(uint16_t addr) const
{
    printf("machine read %04x\n", addr);

    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        printf("ram read %04x\n", addr);
        return ram_.read(addr);
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        printf("rom read %04x\n", addr);
        return rom_.read(addr);
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        printf("io read %04x\n", addr);
        return memory_io_.read(addr);
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        printf("bank read %04x\n", addr);
        return banked_memory_.read(addr);
    }

    printf("unk read %04x\n", addr);
    return 0xff;
}

void Machine::write(uint16_t addr, uint8_t value)
{
    printf("machine write %04x <-- %02x\n", addr, value);

    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        printf("ram write %04x\n", addr);
        ram_.write(addr, value);
        return;
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        printf("rom write %04x\n", addr);
        rom_.write(addr, value);
        return;
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        printf("io write %04x\n", addr);

        memory_io_.write(addr, value);
        return;
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        printf("bank write %04x\n", addr);

        banked_memory_.write(addr, value);
        return;
    }

    printf("unk write %04x\n", addr);
}
