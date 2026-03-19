#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"

// devices
#include "memoryIODevice.h"

#include "latch.h"
#include "acia.h"

class MemoryIO : public Mem
{
public:
    MemoryIO()
        : Mem(StartAddress, EndAddress),
          banked_memory_latch_(SlotLatch, OffsetBankedMemoryLatch),
          acia_0_(SlotCom0, OffsetAcia),
          acia_1_(SlotCom1, OffsetAcia)
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

    uint8_t getBankedMemoryLatchValue()
    {
        return banked_memory_latch_.getValue();
    }

private:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    static const uint8_t SlotLatch = 0x0;
    static const uint8_t OffsetBankedMemoryLatch = 0x0;

    static const uint8_t SlotCom0 = 0x1;
    static const uint8_t SlotCom1 = 0x2;
    static const uint8_t OffsetAcia = 0x0;

    Latch banked_memory_latch_;
    Acia acia_0_;
    Acia acia_1_;
};