
#include <stdio.h>
#include <optional>
#include <unistd.h>
#include <sys/select.h>
#include <termios.h>

#include <stdio.h>
#include "cpu.h"
#include "ram.h"
#include "rom.h"
#include "memoryIO.h"
#include "machine.h"

struct LoadRequest
{
    std::string filename;
    uint16_t address;
};

std::vector<LoadRequest> loads_;
std::vector<uint16_t> halt_addresses_;
struct termios orig_termios_;

std::optional<uint16_t> parse_hex16(std::string_view text)
{
    std::string s(text);

    if (!s.empty() && s[0] == '$')
    {
        s.erase(0, 1);
    }
    else if (s.size() > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
    {
        s.erase(0, 2);
    }

    char *end = nullptr;
    unsigned long value = std::strtoul(s.c_str(), &end, 16);

    if (end == s.c_str() || *end != '\0' || value > 0xffff)
    {
        return std::nullopt;
    }

    return static_cast<uint16_t>(value);
}

void reset_terminal_mode()
{
    tcsetattr(0, TCSANOW, &orig_termios_);
}

void set_conio_terminal_mode()
{
    struct termios new_termios;

    // take two copies - one for now, one for later
    tcgetattr(0, &orig_termios_);
    memcpy(&new_termios, &orig_termios_, sizeof(new_termios));

    // register cleanup handler, and set the new terminal mode
    atexit(reset_terminal_mode);
    cfmakeraw(&new_termios);
    tcsetattr(0, TCSANOW, &new_termios);
}

bool kbhit()
{
    struct timeval tv = {0L, 0L};
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(0, &fds);
    return select(1, &fds, NULL, NULL, &tv) > 0;
}

int getch()
{
    int r;
    unsigned char c;
    if ((r = read(0, &c, sizeof(c))) < 0)
    {
        return r;
    }
    else
    {
        return c;
    }
}

bool parse_lst(std::string_view arg)
{
    return Machine::instance().symbols_.load(arg);
}

std::optional<LoadRequest> parse_load(std::string_view arg)
{
    auto at = arg.find('@');

    if (at == std::string_view::npos)
        return std::nullopt;

    std::string filename(arg.substr(0, at));
    std::string addr_str(arg.substr(at + 1));

    auto addr = parse_hex16(addr_str);
    if (!addr)
        return std::nullopt;

    return LoadRequest{filename, *addr};
}

void add_halt_address(uint16_t addr)
{
    halt_addresses_.push_back(addr);
}

int parse_args(int argc, char **argv)
{
    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];

        if (arg == "--halt")
        {
            if (i + 1 >= argc)
            {
                std::fprintf(stderr, "--halt requires an address\n");
                return 1;
            }

            auto addr = parse_hex16(argv[++i]);
            if (!addr)
            {
                std::fprintf(stderr, "invalid halt address: %s\n", argv[i]);
                return 1;
            }

            add_halt_address(*addr);
            continue;
        }

        if (arg == "--load")
        {
            if (i + 1 >= argc)
            {
                std::fprintf(stderr, "--load requires file@addr\n");
                return 1;
            }

            auto req = parse_load(argv[++i]);
            if (!req)
            {
                std::fprintf(stderr, "invalid --load argument\n");
                return 1;
            }

            loads_.push_back(*req);
            continue;
        }

        if (arg == "--lst")
        {
            if (i + 1 >= argc)
            {
                std::fprintf(stderr, "--lst requires a .lst file\n");
                return 1;
            }

            parse_lst(argv[++i]);
        }
    }

    return 0;
}

bool load_binary(const std::string &filename, uint16_t addr)
{
    FILE *f = std::fopen(filename.c_str(), "rb");
    if (!f)
    {
        std::perror(filename.c_str());
        return false;
    }

    uint16_t current = addr;

    int c;
    while ((c = std::fgetc(f)) != EOF)
    {
        if (current > 0xFFFF)
        {
            return false;
        }

        Machine::instance().load(current++, static_cast<uint8_t>(c));
    }

    std::fclose(f);

    char msg[256];
    snprintf(msg, sizeof(msg), "loaded %s @ %04x\n", filename.c_str(), addr);
    Machine::instance().log(msg);

    return true;
}

void run()
{
    char message[256];
    uint16_t lastpc = 0x0;
    while (1)
    {
        uint16_t pc = Machine::instance().cpu_.state().pc;

        if (std::find(halt_addresses_.begin(), halt_addresses_.end(), pc) != halt_addresses_.end())
        {
            snprintf(message, sizeof(message), "\r\nhalt address @ 0x%04x\r\n", pc);
            Machine::instance().log(message);
            printf("%s", message);
            return;
        }

        if (pc == lastpc)
        {
            snprintf(message, sizeof(message), "\r\nloop detected @ 0x%04x\r\n", pc);
            Machine::instance().log(message);
            printf("%s", message);
            return;
        }

        lastpc = pc;

        Machine::instance().cpu_.step();

        if (kbhit())
        {
            int c = getchar();
            if (c == 0x03)
            {
                return;
            }

            Machine::instance().memory_io_.acia_0_.terminalOutAciaIn(c);
        }

        auto c = Machine::instance().memory_io_.acia_0_.terminalInAciaOut();

        if (c.has_value())
        {
            uint8_t v = c.value();

            if (v < ' ')
            {
                switch (v)
                {
                case '\r':
                case '\n':
                case '\t':
                case 0x0c: // ^L
                    break;
                default:
                    v = 0;
                }
            }
            else if (v > 127)
            {
                v = 0;
            }

            if (v)
            {
                write(1, &c.value(), 1);
            }
        }

        usleep(2500);
    }
}

void dump_memory_binary(const char *filename, uint16_t start, uint16_t end)
{
    FILE *f = std::fopen(filename, "wb");
    if (!f)
    {
        std::perror("fopen");
        return;
    }

    for (uint32_t addr = start; addr <= end; ++addr)
    {
        uint8_t b = Machine::instance().read(static_cast<uint16_t>(addr));
        if (std::fwrite(&b, 1, 1, f) != 1)
        {
            std::perror("fwrite");
            break;
        }
    }

    std::fclose(f);
}

int main(int argc, char **argv)
{
    Machine::instance().startLog();

    uint8_t acia0switches = 0b00010101;

    Machine::instance().memory_io_.config_switches_.setValue(acia0switches);

    int parsed = parse_args(argc, argv);
    if (parsed != 0)
    {
        fprintf(stderr, "Failed to parse arguments\n");
        return -1;
    }

    for (const auto &req : loads_)
    {
        load_binary(req.filename, req.address);
    }

    set_conio_terminal_mode();
    setvbuf(stdout, NULL, _IONBF, 0);

    Machine::instance().cpu_.reset();

    int result = 0;
    try
    {
        run();
    }
    catch (const std::exception &e)
    {
        reset_terminal_mode();
        fprintf(stderr, "%s", e.what());
        result = 1;
    }

    Machine::instance().endLog(true);

    // write out the traceback
    FILE *fp = fopen("emu_traceback.log", "w");
    fprintf(fp, "traceback:\r\n\r\n");

    Machine::instance().dumpTraces(fp);

    fprintf(fp, "\r\n(exit)\r\n");
    fflush(fp);
    fclose(fp);

    reset_terminal_mode();

    dump_memory_binary("emu_memorydump.bin", 0x0000, 0xBFFF);

    printf("\r\n---\r\r\n(exit)\r\n");

    return result;
}
