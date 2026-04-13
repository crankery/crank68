#pragma once

#include "cpu.h"
#include "ram.h"
#include "rom.h"
#include "memoryIO.h"
#include "bankedMemory.h"
#include "symbols.h"

#include <cstdio>
#include <deque>
#include <string>
#include <string_view>

class LogBuffer
{
public:
    explicit LogBuffer(std::size_t max_messages = 25)
        : max_messages_(max_messages)
    {
    }

    void log(std::string_view message);
    const std::deque<std::string> &messages() const;

private:
    std::size_t max_messages_;
    std::deque<std::string> messages_;
};

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

    uint8_t read(uint16_t addr) const;
    void write(uint16_t addr, uint8_t value);

    Cpu cpu_;
    Ram ram_;
    Rom rom_;
    MemoryIO memory_io_;
    BankedMemory banked_memory_;
    Symbols symbols_;

    Machine() = default;

    void trace(uint16_t pc);

    void load(uint16_t baseAddr, uint8_t data);

    void startLog();
    void endLog(bool quiet = false);
    void log(std::string_view message);
    void dumpTraces(FILE *fp);

private:
    FILE *logFile_;
    bool logging_ = false;
    int traces_ = 0;
    int logFileCount_ = 0;
    LogBuffer traceMessages_;
    bool loading_ = false;
};