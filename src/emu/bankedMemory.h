#pragma once

#include <array>
#include <cstdint>

#include "mem.h"

class BankedMemory : Mem
{
public:
    BankedMemory() : Mem()
    {
    }

    static const uint16_t StartAddress = 0xC000;
    static const uint16_t EndAddress = 0xDFFF;

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

protected:
    virtual uint16_t size() const override
    {
        return EndAddress - StartAddress + 1;
    }
};