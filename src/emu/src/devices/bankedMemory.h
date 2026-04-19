#pragma once

#include <array>
#include <cstdint>
#include <functional>
#include <utility>

#include "mem.h"

class BankedMemory : public Mem
{
public:
    using BankSelector = std::function<int()>;

    explicit BankedMemory(BankSelector selector) : Mem(StartAddress, EndAddress),
                                                   selector_(std::move(selector))
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

private:
    int getBankedMemoryAddr(uint16_t busAddr) const
    {
        int bankNumber = selector_();

        if (bankNumber < 0 || bankNumber >= InstalledBanks)
            return -1;

        int baseAddress = busAddr - StartAddress;
        return bankNumber * 0x2000 + baseAddress;
    }

    static const int InstalledBanks = 8 * 8; // 8x8KB * 8 64K chips
    static const uint16_t StartAddress = 0xC000;
    static const uint16_t EndAddress = 0xDFFF;
    static const uint16_t Size = 0x2000;

    std::array<uint8_t, InstalledBanks * Size> bankedMemory_;

    BankSelector selector_;
};