#pragma once

#include <cstdint>
#include <array>

#include "mem.h"

class Ram : public Mem
{
public:
    Ram()
        : Mem(StartAddress, EndAddress)
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

private:
    static const uint16_t StartAddress = 0x0000;
    static const uint16_t EndAddress = 0xbfff;

    std::array<uint8_t, EndAddress - StartAddress + 1> memory_;
};