#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"

class Ram : public Mem
{
public:
    static const uint16_t StartAddress = 0x0000;
    static const uint16_t EndAddress = 0xbfff;

    Ram()
        : Mem(StartAddress, EndAddress)
    {
        memory_.resize(size());
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

private:
    std::vector<uint8_t> memory_;
};