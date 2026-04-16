#pragma once

#include "logBuffer.h"
#include "symbols.h"

#define TRACEBACK_LENGTH 1024 * 8

class Logging
{
public:
    Logging() : traceMessages_(TRACEBACK_LENGTH)
    {
    }

    void trace(uint16_t pc);
    void log(std::string_view message);
    void dumpTraces(FILE *fp);

private:
    LogBuffer traceMessages_;
};