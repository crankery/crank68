#include "rom.h"
#include "bios.h"

uint8_t Rom::read(uint16_t addr) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        uint8_t v = ___roms_c68bios_bios_rom[addr - StartAddress + 0x100];
        return v;
        // return memory_[addr - StartAddress];
    }

    return 0xff;
}

// bool Rom::load(const char *path, uint16_t skip)
// {
//     printf("start address %04x end address %04x size %04x\n", startAddress_, endAddress_, Size);

//     printf("load %s at %04x.\n", path, startAddress_);
//     FILE *f = fopen(path, "rb");
//     if (f == NULL)
//     {
//         printf("unable to open %s\n", path);
//     }

//     fseek(f, 0, SEEK_END);
//     uint16_t fileSize = ftell(f);
//     rewind(f);

//     uint8_t *buf = (uint8_t *)malloc(fileSize * sizeof(uint8_t));
//     size_t bytesRead = fread(buf, 1, fileSize, f);
//     printf("bytes read: %4x\n", (unsigned int)bytesRead);
//     fclose(f);

//     printf("copying from file index %04x to memory of size %04x\n", skip, Size);
//     for (int bufIdx = 0x100; bufIdx < 0x1F00; ++bufIdx)
//     {
//         memory_.push_back(buf[bufIdx]);
//     }

//     printf("\n");
//     printf("...finished copy\n");

//     // int mp = 0;
//     // int count = 0;
//     // for (uint16_t addr = startAddress_; addr < endAddress_; addr++)
//     // {
//     //     if (count == 0)
//     //     {
//     //         printf("%04x %04x:", (uint16_t)addr, mp);
//     //     }

//     //     printf(" %04x|%02x|0%2x", mp, memory_[mp], MachineInstance.read(addr));

//     //     count++;
//     //     if (count >= 16)
//     //     {
//     //         count = 0;
//     //         printf("\n");
//     //     }

//     //     mp++;
//     // }

//     free(buf);

//     return true;
// }