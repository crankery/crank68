#pragma once

#include <cstdio>
#include <deque>
#include <string>
#include <string_view>

#include "cpu/cpu.h"
#include "devices/ram.h"
#include "devices/rom.h"
#include "devices/memoryIO.h"
#include "devices/bankedMemory.h"
#include "util/logging.h"
#include "util/symbols.h"

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

    // todo: move these read/write operations to a bus class
    // everything is too tightly coupled to the Machine right now
    // it'd be nicer if everything had to go through a shared mediator to
    // access the bus
    uint8_t read8(uint16_t addr) const;
    uint16_t read16(uint16_t addr) const;
    void write8(uint16_t addr, uint8_t value);
    void write16(uint16_t addr, uint16_t value);

    Machine() = default;

    // load data into memory
    // marks the loading flag during this operation to allow for writing to read only memory types
    void load(uint16_t baseAddr, uint8_t data);

    // todo: move this to a static utility class
    void expandchar(uint8_t value, char *buf, size_t n);

    // it'd be better if these guys were private and had access to a shared bus type class instead
    Cpu cpu_;
    Ram ram_;
    Rom rom_;
    MemoryIO memory_io_;
    BankedMemory banked_memory_;

    // todo: these don't really belong here
    Logging logging_;
    Symbols symbols_;

private:
    // flag to indicate read only devices can be written
    bool loading_ = false;
};