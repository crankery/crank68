#pragma once

#include <array>
#include <cstdint>
#include <functional>
#include <string>
#include <utility>

#include "mem.h"

class BankedMemory : public Mem
{
public:
    using BankSelector = std::function<uint8_t(unsigned)>;
    static constexpr size_t PageSize = 0x1000;
    static constexpr size_t ImageSize = 0x100000;

    explicit BankedMemory(BankSelector selector)
        : Mem(StartAddress, EndAddress), selector_(std::move(selector)) {}

    uint8_t read(uint16_t addr) const override;
    void write(uint16_t addr, uint8_t value) override;

    // Raw image: 256 consecutive 4 KB pages, ordered by latch value.
    // Loading validates the entire file before changing SRAM.
    void loadImage(const std::string &filename);
    void saveImage(const std::string &filename) const;

private:
    size_t memoryAddress(uint16_t addr) const
    {
        unsigned window = (addr - StartAddress) / PageSize;
        return size_t(selector_(window)) * PageSize + (addr & (PageSize - 1));
    }

    static constexpr uint16_t StartAddress = 0xC000;
    static constexpr uint16_t EndAddress = 0xDFFF;
    std::array<uint8_t, ImageSize> bankedMemory_{};
    BankSelector selector_;
};
