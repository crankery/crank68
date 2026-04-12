#include "machine.h"

void LogBuffer::log(std::string_view message)
{
    // Store a copy in the ring buffer
    messages_.emplace_back(message);

    // Trim oldest if over capacity
    if (messages_.size() > max_messages_)
    {
        messages_.pop_front();
    }
}

void Machine::trace(uint16_t pc)
{
    uint8_t op = cpu_.read8(pc);
    OpInfo op_info = cpu_op_table[op];
    const char *op_name_s = op_info.op_name_s;
    addr_mode addr_mode = op_info.addr_mode;

    int argc = addr_mode == inh                                           ? 0
               : addr_mode == rel || addr_mode == imb || addr_mode == idx ? 1
                                                                          : 2;
    uint8_t argv[2];
    for (int i = 0; i < argc; i++)
    {
        argv[i] = cpu_.read8(pc + i + 1);
    }

    char args[10];
    char op_formatted[40];
    switch (argc)
    {
    case 0:
        args[0] = '\0';
        break;
    case 1:
        snprintf(args, sizeof(args), "%02x", cpu_.read8(pc + 1));
        break;
    case 2:
        snprintf(args, sizeof(args), "%02x %02x", cpu_.read8(pc + 1), cpu_.read8(pc + 2));
        break;
    }

    switch (addr_mode)
    {
    case inh:
        snprintf(op_formatted, sizeof(op_formatted), "%s", op_name_s);
        break;
    case imb:
    {
        snprintf(op_formatted, sizeof(op_formatted), "%s #$%02x", op_name_s, cpu_.read8(pc + 1));
        break;
    }
    case imw:
    {
        uint16_t target = (cpu_.read8(pc + 1) << 8) | cpu_.read8(pc + 2);
        auto symtarget = symbols_.lookup(target);
        char starget[20];

        if (symtarget && !symtarget->empty())
        {
            snprintf(starget, sizeof(starget), "#$%04x <%s>", target, symtarget->front().name.c_str());
        }
        else
        {
            snprintf(starget, sizeof(starget), "#$%04x", target);
        }

        snprintf(op_formatted, sizeof(op_formatted), "%s %s", op_name_s, starget);
        break;
    }
    case idx:
    {
        uint16_t target = cpu_.s_.x + cpu_.read8(pc + 1);
        auto symtarget = symbols_.lookup(target);
        char starget[20];

        if (symtarget && !symtarget->empty())
        {
            snprintf(starget, sizeof(starget), "$%04x <%s>", target, symtarget->front().name.c_str());
        }
        else
        {
            snprintf(starget, sizeof(starget), "$%04x", target);
        }

        snprintf(op_formatted, sizeof(op_formatted), "%s $%02x,x [%s]", op_name_s, cpu_.read8(pc + 1), starget);
        break;
    }
    case dir:
    {
        snprintf(op_formatted, sizeof(op_formatted), "%s $%02x", op_name_s, cpu_.read8(pc + 1));
        break;
    }
    case ext:
    {
        uint16_t target = (cpu_.read8(pc + 1) << 8) | cpu_.read8(pc + 2);
        auto symtarget = symbols_.lookup(target);
        char starget[20];

        if (symtarget && !symtarget->empty())
        {
            snprintf(starget, sizeof(starget), "%04x <%s>", target, symtarget->front().name.c_str());
        }
        else
        {
            snprintf(starget, sizeof(starget), "%04x", target);
        }

        snprintf(op_formatted, sizeof(op_formatted), "%s %s", op_name_s, starget);
        break;
    }
    case rel:
    {
        uint16_t target = pc + 2 + ((int8_t)cpu_.read8(pc + 1));
        auto symtarget = symbols_.lookup(target);
        char starget[20];

        if (symtarget && !symtarget->empty())
        {
            snprintf(starget, sizeof(starget), "$%04x <%s>", target, symtarget->front().name.c_str());
        }
        else
        {
            snprintf(starget, sizeof(starget), "$%04x", target);
        }

        snprintf(op_formatted, sizeof(op_formatted), "%s %s", op_name_s, starget);
        break;
    }
    default:
        break;
    }

    auto symbol = symbols_.lookup(pc);
    char pcsymbol[16];
    pcsymbol[0] = '\0';

    if (symbol && !symbol->empty())
    {
        snprintf(pcsymbol, sizeof(pcsymbol), "%04x <%s>", pc, symbol->front().name.c_str());
    }
    else
    {
        snprintf(pcsymbol, sizeof(pcsymbol), "%04x", pc);
    }

    char message[256];
    snprintf(message,
             sizeof(message),
             "%-24s %02x %-5s %-30s a:%02x b:%02x x:%04x s:%04x | %c%c%c%c%c%c | %05d\n",
             pcsymbol,
             op,
             args,
             op_formatted,
             cpu_.s_.a,
             cpu_.s_.b,
             cpu_.s_.x,
             cpu_.s_.sp,
             cpu_.s_.cc & C ? 'C' : ' ',
             cpu_.s_.cc & V ? 'V' : ' ',
             cpu_.s_.cc & Z ? 'Z' : ' ',
             cpu_.s_.cc & N ? 'N' : ' ',
             cpu_.s_.cc & I ? 'I' : ' ',
             cpu_.s_.cc & H ? 'H' : ' ',
             cpu_.cycles_ % 10000);

    log(message);
}

const std::deque<std::string> &LogBuffer::messages() const
{
    return messages_;
}

void Machine::load(uint16_t addr, uint8_t data)
{
    bool origLoading = loading_;
    loading_ = true;

    write(addr, data);

    loading_ = origLoading;
}

uint8_t Machine::read(uint16_t addr) const
{
    if (addr >= ram_.getStartAddress() && addr <= ram_.getEndAddress())
    {
        uint8_t v = ram_.read(addr);
        return v;
    }
    else if (addr >= rom_.getStartAddress() && addr <= rom_.getEndAddress())
    {
        uint8_t v = rom_.read(addr);
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
        if (loading_)
        {
            rom_.write(addr, value);
        }
    }
    else if (addr >= memory_io_.getStartAddress() && addr <= memory_io_.getEndAddress())
    {
        if (!loading_)
        {
            memory_io_.write(addr, value);
        }
    }
    else if (addr >= banked_memory_.getStartAddress() && addr <= banked_memory_.getEndAddress())
    {
        banked_memory_.write(addr, value);
    }
}

void Machine::startLog()
{
    if (logging_)
    {
        endLog();
        logFileCount_++;
    }
    else
    {
        logFileCount_ = 0;
    }

    char fn[16];
    snprintf(fn, sizeof(fn), "emu_trace_%d.log", logFileCount_ % 2);

    logFile_ = fopen(fn, "w");
    traces_ = 0;
    logging_ = true;

    fprintf(logFile_, "\r\n---\r\nStart of file %d\r\n---\r\n", logFileCount_);
}

void Machine::endLog(bool quiet)
{
    if (logging_)
    {
        if (!quiet)
        {
            fprintf(logFile_, "\r\n---\r\nEnd of file %d\r\n---\r\n", logFileCount_);
        }

        fflush(logFile_);
        fclose(logFile_);
        logging_ = false;
    }
}

void Machine::log(std::string_view message)
{
    if (logging_)
    {
        fprintf(logFile_, "%s", std::string(message).c_str());

        traceMessages_.log(message);

        // switch files every so often
        if (traces_++ > 25000)
        {
            startLog();
        }
    }
}

void Machine::dumpTraces(FILE *fp)
{
    for (const auto &message : traceMessages_.messages())
    {
        fprintf(fp, "%s", message.c_str());
    }
}