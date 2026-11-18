#include "flex_harness.h"
#include <functional>

int main(int argc, char **argv) {
    try {
        require(argc == 3, "usage: ladder-test BIN LIST");
        Bus bus;
        Cpu cpu(bus);
        auto system = file("build/c68flex.bin");
        std::copy(system.begin(), system.end(), bus.ram.begin() + 0xA100);
        auto game = file(argv[1]);
        require(game.size() < 0x7B00, "game too large");
        std::copy(game.begin(), game.end(), bus.ram.begin() + 0x0300);
        cpu.s_.pc = 0x0300;
        cpu.s_.sp = 0x9FFD;
        auto address = [&](const char *name) { return symbol(argv[2], name); };
        auto game_loop = address("game_loop");
        auto x = address("player_x"), y = address("player_y");
        auto direction = address("direction"), jump = address("jump_step");
        auto run_until = [&](std::function<bool()> predicate, unsigned limit=3000000) {
            for (unsigned i=0; i<limit; ++i) {
                if (predicate()) return;
                cpu.step();
            }
            throw std::runtime_error("timed out at PC="+std::to_string(cpu.s_.pc));
        };
        run_until([&]{ return cpu.s_.pc == game_loop; });
        require(bus.output.find("Easy Street") != std::string::npos, "map/status absent");
        require(bus.output.find("\x1b[2J") != std::string::npos, "screen not cleared");
        require(bus.output.find("\x1b[19;6Hg") != std::string::npos, "Lad not at start");
        require(bus.ram[x] == 6 && bus.ram[y] == 19, "wrong start");
        bus.input = 'l';
        run_until([&]{ return bus.ram[x] == 7; });
        require(bus.ram[y] == 19, "walking fell through floor");
        bus.input = 'x';
        run_until([&]{ return bus.ram[direction] == 0 && bus.input < 0; });
        bus.ram[x] = 58;
        bus.ram[y] = 19;
        bus.input = 'k';
        run_until([&]{ return bus.ram[y] == 18; });
        require(bus.ram[x] == 58, "climb shifted column");
        bus.ram[direction] = 0;
        bus.ram[x] = 6;
        bus.ram[y] = 19;
        bus.input = ' ';
        run_until([&]{ return bus.ram[jump] != 0 && bus.ram[y] == 18; });
        require(bus.ram[x] == 6, "standing jump shifted column");
        bus.input = 'q';
        run_until([&]{ return bus.output.find("\x1b[?25h") != std::string::npos; });
        std::cout << "LADDER: map, walking, climbing, jumping and exit passed.\n";
        return 0;
    } catch (const std::exception &e) {
        std::cerr << e.what() << "\n";
        return 1;
    }
}
