#include "machine.h"

void Machine::load(uint16_t addr, uint8_t data)
{
    bool origLoading = loading_;
    loading_ = true;

    write8(addr, data);

    loading_ = origLoading;
}

uint8_t Machine::read8(uint16_t addr)
{
    if (addr >= ram_->getStartAddress() && addr <= ram_->getEndAddress())
    {
        uint8_t v = ram_->read(addr);
        return v;
    }
    else if (addr >= rom_->getStartAddress() && addr <= rom_->getEndAddress())
    {
        uint8_t v = rom_->read(addr);
        return v;
    }
    else if (addr >= memory_io_->getStartAddress() && addr <= memory_io_->getEndAddress())
    {
        return memory_io_->read(addr);
    }
    // else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    // {
    //     return banked_memory_.read(addr);
    // }

    return 0xff;
}

void Machine::write8(uint16_t addr, uint8_t value)
{
    // if (addr == 0xc8 || addr == 0xc9)
    // {
    //     char buf[256];
    //     snprintf(buf, sizeof(buf), "%04x = %02x @ %04x\r\n", addr, value, cpu_.s_.pc);
    //     logging_.suslog(buf);
    // }

    if (addr >= ram_->getStartAddress() && addr <= ram_->getEndAddress())
    {
        ram_->write(addr, value);
        return;
    }
    else if (addr >= rom_->getStartAddress() && addr <= rom_->getEndAddress())
    {
        if (loading_)
        {
            rom_->write(addr, value);
        }
    }
    else if (addr >= memory_io_->getStartAddress() && addr <= memory_io_->getEndAddress())
    {
        if (!loading_)
        {
            memory_io_->write(addr, value);
        }
    }
    // else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    // {
    //     banked_memory_.write(addr, value);
    // }
}