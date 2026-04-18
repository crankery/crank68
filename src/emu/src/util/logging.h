#pragma once

#include "logBuffer.h"
#include "symbols.h"

#define TRACEBACK_LENGTH 1024 * 64 * 16

class Logging
{
public:
    Logging() : traceMessages_(TRACEBACK_LENGTH), suslogs_(TRACEBACK_LENGTH)
    {
    }

    void trace(uint16_t pc);
    void log(std::string_view message);
    void suslog(std::string_view message);
    void dumpTraces(FILE *fp);

private:
    LogBuffer traceMessages_;
    LogBuffer suslogs_;
};