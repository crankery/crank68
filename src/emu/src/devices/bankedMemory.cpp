#include "bankedMemory.h"

#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <vector>

uint8_t BankedMemory::read(uint16_t addr) const
{
    if (addr < StartAddress || addr > EndAddress)
        return 0xff;
    return bankedMemory_[memoryAddress(addr)];
}

void BankedMemory::write(uint16_t addr, uint8_t value)
{
    if (addr >= StartAddress && addr <= EndAddress)
        bankedMemory_[memoryAddress(addr)] = value;
}

void BankedMemory::loadImage(const std::string &filename)
{
    std::ifstream file(filename, std::ios::binary | std::ios::ate);
    if (!file || file.tellg() != std::streampos(ImageSize))
        throw std::runtime_error("SRAM image must be exactly 1048576 bytes: " + filename);
    std::vector<uint8_t> image(ImageSize);
    file.seekg(0);
    if (!file.read(reinterpret_cast<char *>(image.data()), image.size()))
        throw std::runtime_error("Cannot read SRAM image: " + filename);
    std::copy(image.begin(), image.end(), bankedMemory_.begin());
}

void BankedMemory::saveImage(const std::string &filename) const
{
    // Replace the destination only after a complete write and successful close.
    const std::string temporary = filename + ".tmp";
    std::ofstream file(temporary, std::ios::binary | std::ios::trunc);
    file.write(reinterpret_cast<const char *>(bankedMemory_.data()), bankedMemory_.size());
    file.close();
    if (!file)
        throw std::runtime_error("Cannot write SRAM image: " + temporary);
    std::filesystem::rename(temporary, filename);
}
