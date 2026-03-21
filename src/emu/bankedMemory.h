#pragma once

#include <array>
#include <cstdint>

#include "mem.h"

class BankedMemory : public Mem
{
public:
    BankedMemory()
        : Mem(StartAddress, EndAddress)
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

private:
    int getBankedMemoryAddr(uint16_t addr) const;

    static const int InstalledBanks = 8 * 8; // 8x8KB * 8 64K chips
    static const uint16_t StartAddress = 0xC000;
    static const uint16_t EndAddress = 0xDFFF;
    static const uint16_t Size = EndAddress - StartAddress + 1;

    std::array<uint8_t, InstalledBanks * Size> bankedMemory_;
};