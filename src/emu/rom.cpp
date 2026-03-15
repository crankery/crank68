#include "rom.h"

bool Rom::read(uint16_t addr, uint8_t &value) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        value = memory_[addr - StartAddress];
        return true;
    }

    return false;
}

bool Rom::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        // ROM is read-only, so we ignore writes to it
        return true;
    }

    return false;
}

bool Rom::load_binary(const char *path, uint16_t base)
{
    std::ifstream f(path, std::ios::binary);

    std::cout << "Loading binary file '" << path << "' at base address 0x"
              << std::hex << std::uppercase << std::setw(4) << std::setfill('0') << base
              << '\n';

    if (!f)
        return false;

    std::vector<uint8_t> data((std::istreambuf_iterator<char>(f)),
                              std::istreambuf_iterator<char>());

    if (base + data.size() > mem.size())
    {

        std::cout << "base address: 0x" << std::hex << std::uppercase << std::setw(4) << std::setfill('0') << base
                  << ", file size: " << data.size() << " bytes\n";
        std::cout << "Binary file is too large to fit in memory\n";
        return false;
    }

    for (size_t i = 0; i < data.size(); ++i)
    {
        mem[base + i] = data[i];
    }

    return true;
}