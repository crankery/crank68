#pragma once

#include "cpu/cpu.h"
#include "devices/ram.h"
#include "devices/rom.h"
#include "devices/memoryIO.h"
#include "devices/bankedMemory.h"
#include "util/logging.h"
#include "util/symbols.h"

#include <cstdio>
#include <deque>
#include <string>
#include <string_view>

class Machine
{
public:
    static Machine &instance()
    {
        static Machine instance;
        return instance;
    }

    Machine(const Machine &) = delete;
    Machine &operator=(const Machine &) = delete;

    uint8_t read8(uint16_t addr) const;
    void write8(uint16_t addr, uint8_t value);

    uint16_t read16(uint16_t addr) const;
    void write16(uint16_t addr, uint16_t value);

    Machine() = default;

    void load(uint16_t baseAddr, uint8_t data);

    // void trace(uint16_t pc);
    // void log(std::string_view message);
    // void dumpTraces(FILE *fp);

    void expandchar(uint8_t value, char *buf, size_t n);

    // it'd be better if these guys were private
    Cpu cpu_;
    Ram ram_;
    Rom rom_;
    MemoryIO memory_io_;
    BankedMemory banked_memory_;
    Logging logging_;
    Symbols symbols_;

private:
    bool loading_ = false;
};