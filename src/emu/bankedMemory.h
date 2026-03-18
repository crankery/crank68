#pragma once

#include <array>
#include <cstdint>

#include "mem.h"

class BankedMemory : public Mem
{
public:
    static const uint16_t StartAddress = 0xC000;
    static const uint16_t EndAddress = 0xDFFF;

    BankedMemory()
        : Mem(StartAddress, EndAddress)
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;
};