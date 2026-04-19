#include "logging.h"
#include "machine/machine.h"

void Logging::dumpTracesImpl(FILE *fp)
{
    for (const auto &message : traceMessages_.messages())
    {
        fprintf(fp, "%s", message.c_str());
    }
}
