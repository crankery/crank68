#pragma once

#include "logBuffer.h"

#define TRACEBACK_LENGTH 1024

class Logging
{
public:
    static void log(std::string_view message)
    {
        instance().traceMessages_.log(message);
    }

    static void dumpTraces(FILE *fp)
    {
        instance().dumpTracesImpl(fp);
    }

private:
    static Logging &instance()
    {
        static Logging instance;
        return instance;
    }

    Logging() : traceMessages_(TRACEBACK_LENGTH)
    {
    }

    void dumpTracesImpl(FILE *fp);

    LogBuffer traceMessages_;
};