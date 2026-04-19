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

class Machine final : public IBus
{
public:
    static Machine create_default()
    {
        return Machine(
            std::make_unique<Ram>(),
            std::make_unique<Rom>(),
            std::make_unique<MemoryIO>());
    }

    Machine(std::unique_ptr<Ram> ram,
            std::unique_ptr<Rom> rom,
            std::unique_ptr<MemoryIO> memory_io)
        : ram_(std::move(ram)),
          rom_(std::move(rom)),
          memory_io_(std::move(memory_io)),
          banked_memory_(std::make_unique<BankedMemory>(
              [this]()
              {
                  return memory_io_->bankedMemoryLatch().getValue();
              }))
    {
        cpu_ = std::make_unique<Cpu>(*this);
    }

    uint8_t read8(uint16_t addr) override;
    void write8(uint16_t addr, uint8_t value) override;

    // load data into memory
    // marks the loading flag during this operation to allow for writing to read only memory types
    void load(uint16_t baseAddr, uint8_t data);

    static void expandchar(uint8_t value, char *buf, size_t n)
    {
        if (value < ' ' || value > 0x7e)
        {
            switch (value)
            {
            case '\n':
                snprintf(buf, n, "\\n");
                break;
            case '\r':
                snprintf(buf, n, "\\r");
                break;
            case '\b':
                snprintf(buf, n, "\\b");
                break;
            default:
                snprintf(buf, n, "\\%02x", value);
                break;
            }
        }
        else
        {
            snprintf(buf, n, "%c", value);
        }
    }

    std::unique_ptr<Cpu> cpu_;
    std::unique_ptr<Ram> ram_;
    std::unique_ptr<Rom> rom_;
    std::unique_ptr<MemoryIO> memory_io_;
    std::unique_ptr<BankedMemory> banked_memory_;

private:
    // flag to indicate read only devices can be written
    bool loading_ = false;
};