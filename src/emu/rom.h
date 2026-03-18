#pragma once

#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <vector>

#include "mem.h"

static const uint16_t StartAddress = 0xE100;
static const uint16_t EndAddress = 0xFFFF;

class Rom : Mem
{
public:
    Rom() : Mem(StartAddress, EndAddress)
    {
        memory_.reserve(size());
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;
    bool load(const char *path, uint16_t offset = 0);

private:
    std::vector<uint8_t> memory_;
};
