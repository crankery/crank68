#include "rom.h"
#include "machine.h"

#define ROM_SIZE 0x2000

uint8_t Rom::read(uint16_t addr) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        return memory_[addr - StartAddress];
    }

    return 0xff;
}

bool Rom::load(const char *path, uint16_t skip)
{
    uint8_t buf[ROM_SIZE];
    FILE *f = fopen(path, "rb");

    if (f == NULL)
    {
        printf("unable to open %s\n", path);
        return false;
    }

    fseek(f, 0, SEEK_END);
    uint16_t fileSize = ftell(f);
    rewind(f);
    if (fileSize != ROM_SIZE)
    {
        return false;
    }

    fseek(f, skip, 0);
    fread(buf, 1, Size, f);
    fclose(f);

    for (int i = 0; i < Size; ++i)
    {
        memory_[i] = buf[i];
    }

    return true;
}