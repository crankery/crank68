#include "rom.h"

uint8_t Rom::read(uint16_t addr) const
{
    if (addr >= StartAddress && addr <= EndAddress)
    {
        return memory_[addr - StartAddress];
    }

    return 0xff;
}

void Rom::write(uint16_t addr, uint8_t value)
{
}

bool Rom::load(const char *path, uint16_t offset)
{
    std::ifstream f(path, std::ios::binary);

    if (!f)
        return false;

    std::vector<uint8_t> data((std::istreambuf_iterator<char>(f)),
                              std::istreambuf_iterator<char>());

    if (data.size() - offset > this->size())
    {
        return false;
    }

    for (size_t i = 0; i < data.size(); ++i)
    {
        this->memory_[i] = data[i + offset];
    }

    return true;
}