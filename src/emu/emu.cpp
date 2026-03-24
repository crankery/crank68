
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

struct termios orig_termios;

void reset_terminal_mode()
{
    tcsetattr(0, TCSANOW, &orig_termios);
}

void set_conio_terminal_mode()
{
    struct termios new_termios;

    /* take two copies - one for now, one for later */
    tcgetattr(0, &orig_termios);
    memcpy(&new_termios, &orig_termios, sizeof(new_termios));

    /* register cleanup handler, and set the new terminal mode */
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

void run(int cycles = 0)
{
    int cycleCount = 0;
    while (cycles == 0 || cycleCount++ < cycles)
    {
        Machine::instance().cpu_.step();

        if (Machine::instance().memory_io_.acia_0_.clearToSend())
        {
            if (kbhit())
            {
                int c = getchar();
                printf("key:%c\r\n", c);
                if (c == '~')
                {
                    return;
                }

                Machine::instance().memory_io_.acia_0_.terminalOutAciaIn(c);
            }
        }

        if (Machine::instance().memory_io_.acia_0_.dataReady())
        {
            std::optional<uint8_t> c = Machine::instance().memory_io_.acia_0_.terminalInAciaOut();

            if (c.has_value())
            {
                // printf("acia 0:%02x \n", c.value());
                printf("%c", c.value());
            }
        }
    }
}

int main(int argc, char **argv)
{
    set_conio_terminal_mode();

    Machine::instance().beginTrace();

    if (argc > 1)
    {
        if (!Machine::instance().rom_.load(argv[1], 0x100))
        {
            fprintf(stderr, "Failed to load ROM\n");
            return 1;
        }
    }
    else
    {
        fprintf(stderr, "No ROM image provided\n");
        return 1;
    }

    Machine::instance().cpu_.reset();

    int result = 0;
    try
    {
        run(argc > 2 ? atoi(argv[2]) : 0);
    }
    catch (const std::exception &e)
    {
        fprintf(stderr, "CPU stopped: %s\n", e.what());
        result = 1;
    }

    Machine::instance().endTrace();

    return result;
}
