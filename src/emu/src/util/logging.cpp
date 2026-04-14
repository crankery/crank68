#include "logging.h"
#include "machine/machine.h"

void Logging::trace(uint16_t pc)
{
    uint8_t op = Machine::instance().read8(pc);
    OpInfo op_info = cpu_op_table[op];
    const char *op_name_s = op_info.op_name_s;
    addr_mode addr_mode = op_info.addr_mode;

    int argc = addr_mode == inh                                           ? 0
               : addr_mode == rel || addr_mode == imb || addr_mode == idx ? 1
                                                                          : 2;
    uint8_t argv[2];
    for (int i = 0; i < argc; i++)
    {
        argv[i] = Machine::instance().read8(pc + i + 1);
    }

    char args[10];
    char op_formatted[40];
    switch (argc)
    {
    case 0:
        args[0] = '\0';
        break;
    case 1:
        snprintf(args, sizeof(args), "%02x", Machine::instance().read8(pc + 1));
        break;
    case 2:
        snprintf(args, sizeof(args), "%02x %02x", Machine::instance().read8(pc + 1), Machine::instance().read8(pc + 2));
        break;
    }

    switch (addr_mode)
    {
    case inh:
        snprintf(op_formatted, sizeof(op_formatted), "%s", op_name_s);
        break;
    case imb:
    {
        snprintf(op_formatted, sizeof(op_formatted), "%s #$%02x", op_name_s, Machine::instance().read8(pc + 1));
        break;
    }
    case imw:
    {
        uint16_t target = (Machine::instance().read8(pc + 1) << 8) | Machine::instance().read8(pc + 2);
        auto symtarget = Machine::instance().symbols_.lookup(target);
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
        uint16_t target = Machine::instance().cpu_.s_.x + Machine::instance().read8(pc + 1);
        auto symtarget = Machine::instance().symbols_.lookup(target);
        char starget[20];

        if (symtarget && !symtarget->empty())
        {
            snprintf(starget, sizeof(starget), "$%04x <%s>", target, symtarget->front().name.c_str());
        }
        else
        {
            snprintf(starget, sizeof(starget), "$%04x", target);
        }

        snprintf(op_formatted, sizeof(op_formatted), "%s $%02x,x [%s]", op_name_s, Machine::instance().read8(pc + 1), starget);
        break;
    }
    case dir:
    {
        snprintf(op_formatted, sizeof(op_formatted), "%s $%02x", op_name_s, Machine::instance().read8(pc + 1));
        break;
    }
    case ext:
    {
        uint16_t target = (Machine::instance().read8(pc + 1) << 8) | Machine::instance().read8(pc + 2);
        auto symtarget = Machine::instance().symbols_.lookup(target);
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
        uint16_t target = pc + 2 + ((int8_t)Machine::instance().read8(pc + 1));
        auto symtarget = Machine::instance().symbols_.lookup(target);
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

    auto symbol = Machine::instance().symbols_.lookup(pc);
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
             "%-24s %02x %-5s %-30s a:%02x b:%02x x:%04x s:%04x | %c%c%c%c%c%c | %04d\n",
             pcsymbol,
             op,
             args,
             op_formatted,
             Machine::instance().cpu_.s_.a,
             Machine::instance().cpu_.s_.b,
             Machine::instance().cpu_.s_.x,
             Machine::instance().cpu_.s_.sp,
             Machine::instance().cpu_.s_.cc & C ? 'C' : ' ',
             Machine::instance().cpu_.s_.cc & V ? 'V' : ' ',
             Machine::instance().cpu_.s_.cc & Z ? 'Z' : ' ',
             Machine::instance().cpu_.s_.cc & N ? 'N' : ' ',
             Machine::instance().cpu_.s_.cc & I ? 'I' : ' ',
             Machine::instance().cpu_.s_.cc & H ? 'H' : ' ',
             Machine::instance().cpu_.cycles_ % 10000);

    log(message);
}

void Logging::log(std::string_view message)
{
    traceMessages_.log(message);
}

void Logging::dumpTraces(FILE *fp)
{
    for (const auto &message : traceMessages_.messages())
    {
        fprintf(fp, "%s", message.c_str());
    }
}