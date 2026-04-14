
#include <stdio.h>
#include <optional>
#include <unistd.h>
#include <sys/select.h>
#include <termios.h>
#include <time.h>
#include <stdio.h>

#include "machine/machine.h"

struct LoadRequest
{
    std::string filename;
    uint16_t address;
};

std::vector<LoadRequest> loads_;
std::vector<uint16_t> breakpoints_;
struct termios orig_termios_;
bool show_control = false;

static uint64_t now_us()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000ULL + (uint64_t)ts.tv_nsec / 1000ULL;
}

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

void add_breakpoint(uint16_t addr)
{
    breakpoints_.push_back(addr);
}

int parse_args(int argc, char **argv)
{
    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];

        if (arg == "--show-control")
        {
            show_control = true;
            continue;
        }

        if (arg == "--break")
        {
            if (i + 1 >= argc)
            {
                std::fprintf(stderr, "--break requires an address\n");
                return 1;
            }

            auto addr = parse_hex16(argv[++i]);
            if (!addr)
            {
                std::fprintf(stderr, "invalid break address: %s\n", argv[i]);
                return 1;
            }

            add_breakpoint(*addr);
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
    snprintf(msg, sizeof(msg), "loaded %s @ 0x%04x:0x%04x\n", filename.c_str(), addr, current);
    Machine::instance().logging_.log(msg);

    return true;
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
        uint8_t b = Machine::instance().read8(static_cast<uint16_t>(addr));
        if (std::fwrite(&b, 1, 1, f) != 1)
        {
            std::perror("fwrite");
            break;
        }
    }

    std::fclose(f);
}

void dump_traceback()
{
    FILE *fp = fopen("emu_traceback.log", "w");
    fprintf(fp, "traceback:\r\n\r\n");
    Machine::instance().logging_.dumpTraces(fp);
    fprintf(fp, "\r\n(exit)\r\n");
    fflush(fp);
    fclose(fp);
}

void run()
{
    const uint64_t sleep_threshold_cycles = 1000; // sleep/check every 1000 cycles

    char message[256];
    uint16_t lastpc = 0x0000;
    uint64_t total_cycles;
    uint64_t last_sleep_check_cycles = 0;
    uint64_t start_us = now_us();
    bool lastBreakpoint = false;

    while (1)
    {
        total_cycles = Machine::instance().cpu_.cycles_;

        if ((total_cycles - last_sleep_check_cycles) >= sleep_threshold_cycles)
        {
            last_sleep_check_cycles = total_cycles;

            // At 1 MHz, 1 cycle = 1 microsecond
            uint64_t target_elapsed_us = total_cycles;
            uint64_t actual_elapsed_us = now_us() - start_us;

            if (target_elapsed_us > actual_elapsed_us)
            {
                uint64_t sleep_us = target_elapsed_us - actual_elapsed_us;

                // avoid giant sleeps if something odd happens
                if (sleep_us > 20000)
                {
                    sleep_us = 20000;
                }

                snprintf(message, sizeof(message), "(sleep for %lluµs)\r\n", sleep_us);
                Machine::instance().logging_.log(message);
                usleep((useconds_t)sleep_us);
            }
        }

        uint16_t pc = Machine::instance().cpu_.state().pc;

        if (!lastBreakpoint && std::find(breakpoints_.begin(), breakpoints_.end(), pc) != breakpoints_.end())
        {
            Machine::instance().logging_.trace(pc);
            snprintf(message, sizeof(message), "\r\nbreakpoint @ 0x%04x\r\n", pc);
            Machine::instance().logging_.log(message);
            printf("%s", message);

            // write out the traceback
            dump_traceback();

            // dump all memory on exit
            dump_memory_binary("emu_memorydump.bin", 0x0000, 0xBFFF);

            printf("\r\npress key to continue...");

            while (!(kbhit()))
            {
                usleep(5000);
            }

            if (getch() == (']' & 0x1f))
            {
                // exit if they pressed the exit key.
                return;
            }

            lastBreakpoint = true;
            continue;
        }

        lastBreakpoint = false;

        if (pc == lastpc)
        {
            Machine::instance().logging_.trace(pc);
            snprintf(message, sizeof(message), "\r\nloop detected @ 0x%04x\r\n", pc);
            Machine::instance().logging_.log(message);
            printf("%s", message);
            return;
        }

        lastpc = pc;

        Machine::instance().cpu_.step();

        if (kbhit())
        {
            int c = getch();

            // treat ctrl-] as a command to exit the emulator
            if (c == (']' & 0x1f))
            {
                snprintf(message, sizeof(message), "\r\n^] pressed @ 0x%04x\r\n", pc);
                Machine::instance().logging_.log(message);
                printf("%s", message);
                return;
            }

            // map delete to backspace
            if (c == 0x7F)
            {
                c = '\b';
            }

            // reverse meaning of caps lock - if it's on,
            // treat letters as lowercase, if it's off, treat letters as uppercase
            c = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
                    ? (c ^ 0x20)
                    : c;

            Machine::instance().memory_io_.acia_1_0_.terminalOutAciaIn(c);
        }

        auto c = Machine::instance().memory_io_.acia_1_0_.terminalInAciaOut();
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
                    putc(v, stdout);
                    break;
                case '\b':
                    putc('\b', stdout);
                    putc(' ', stdout);
                    putc('\b', stdout);
                    break;
                default:
                {
                    if (show_control)
                    {
                        printf("\\%02x", v);
                    }

                    break;
                }
                }
            }
            else
            {
                putc(v, stdout);
            }
        }
    }
}

int main(int argc, char **argv)
{
    char message[256];

    int parsed = parse_args(argc, argv);
    if (parsed != 0)
    {
        fprintf(stderr, "Failed to parse arguments\n");
        return -1;
    }

    // load all the binaries
    for (const auto &req : loads_)
    {
        load_binary(req.filename, req.address);
    }

    // set the config switches
    uint8_t acia0switches = 0b00010101;
    Machine::instance().memory_io_.config_switches_.setValue(acia0switches);

    set_conio_terminal_mode();
    setvbuf(stdout, NULL, _IONBF, 0);

    // reset the cpu (load the PC from the reset vector)
    Machine::instance().cpu_.reset();

    // run the emulation until error or ^]
    int result = 0;
    try
    {
        run();
    }
    catch (const std::exception &e)
    {
        Machine::instance().logging_.trace(Machine::instance().cpu_.s_.pc);
        fprintf(stderr, "%s", e.what());
        result = 1;
    }

    auto state = Machine::instance().cpu_.s_;
    snprintf(message, sizeof(message), "\r\nexit @ 0x%04x\r\n", state.pc);
    Machine::instance().logging_.log(message);
    snprintf(message,
             sizeof(message),
             "a:0x%02x b:0x%02x x:0x%04x sp:0x%04x cc:%c%c%c%c%c%c\r\n",
             state.a,
             state.b,
             state.x,
             state.sp,
             state.cc & C ? 'C' : '-',
             state.cc & V ? 'V' : '-',
             state.cc & Z ? 'Z' : '-',
             state.cc & N ? 'N' : '-',
             state.cc & I ? 'I' : '-',
             state.cc & H ? 'H' : '-');
    Machine::instance().logging_.log(message);

    // write out the traceback
    dump_traceback();

    // dump all memory on exit
    dump_memory_binary("emu_memorydump.bin", 0x0000, 0xBFFF);

    // go back to normal terminal io mode
    // the shell gets really unusable if you forget to do this
    reset_terminal_mode();

    printf("\r\n---\r\r\n(exit)\r\n");

    return result;
}
