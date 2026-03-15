#pragma once

#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <vector>

class Bus
{
public:
    Bus();
    uint8_t read(uint16_t addr);
    void write(uint16_t addr, uint8_t value);

private:
    std::array<uint8_t, 65536> memory_;
};