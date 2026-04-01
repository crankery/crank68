#include "machine.h"

uint8_t Machine::read(uint16_t addr) const
{
    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        uint8_t v = ram_.read(addr);
        //        printf("machine read ram[%04x]: %02x\n", addr, v);
        return v;
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        uint8_t v = rom_.read(addr);
        //      printf("machine read rom[%04x]: %02x\n", addr, v);
        return v;
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        return memory_io_.read(addr);
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        return banked_memory_.read(addr);
    }

    return 0xff;
}

void Machine::write(uint16_t addr, uint8_t value)
{
    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        ram_.write(addr, value);
        return;
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        rom_.write(addr, value);
        return;
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        memory_io_.write(addr, value);
        return;
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        banked_memory_.write(addr, value);
        return;
    }
}

void Machine::beginTrace()
{
    if (tracing_)
    {
        fprintf(traceFp_, "\r\n---\r\nEnd of file %d\r\n---\r\n", traceFile_);
        fflush(traceFp_);
        fclose(traceFp_);

        traces_ = 0;
        tracing_ = false;
        traceFile_++;
    }
    else
    {
        traceFile_ = 0;
    }

    char fn[16];
    snprintf(fn, sizeof(fn), "emu_trace_%d.log", traceFile_ % 2);

    traceFp_ = fopen(fn, "w");
    traces_ = 0;
    tracing_ = true;

    fprintf(traceFp_, "\r\n---\r\nStart of file %d\r\n---\r\n", traceFile_);
}

void Machine::trace(char *message)
{
    if (tracing_)
    {
        fprintf(traceFp_, "%s", message);

        // switch files every so often
        if (traces_++ > 10000)
        {
            beginTrace();
        }
    }
}

void Machine::endTrace()
{
    if (tracing_)
    {
        fflush(traceFp_);
        fclose(traceFp_);
        tracing_ = false;
    }
}