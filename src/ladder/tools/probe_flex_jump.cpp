// Exercise the assembled FLEX Ladder jump routine on the project 6800 CPU.
#include <array>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <iterator>
#include <map>
#include <regex>
#include <stdexcept>
#include <string>
#include <vector>

#include "cpu/cpu.h"

class RamBus final : public IBus {
public:
    std::array<uint8_t, 65536> bytes{};
    uint8_t read8(uint16_t address) override { return bytes[address]; }
    void write8(uint16_t address, uint8_t value) override { bytes[address] = value; }
};

static void require(bool condition, const std::string &message) {
    if (!condition) throw std::runtime_error(message);
}

static std::map<std::string, uint16_t> read_symbols(const std::string &path) {
    std::ifstream listing(path);
    require(bool(listing), "cannot open assembler listing");
    std::regex symbol_line(R"(^([A-Za-z_][A-Za-z0-9_]*)\s+A:([0-9A-Fa-f]{4})$)");
    std::map<std::string, uint16_t> symbols;
    std::string line;
    while (std::getline(listing, line)) {
        std::smatch match;
        if (std::regex_match(line, match, symbol_line))
            symbols[match[1]] = uint16_t(std::stoul(match[2], nullptr, 16));
    }
    for (const char *name : {"move_jump", "player_x", "player_y", "direction",
                             "jump_step", "level_map", "move_down", "move_player",
                             "key_jump", "old_x", "old_y", "game_loop"})
        require(symbols.count(name) == 1, std::string("missing symbol ") + name);
    return symbols;
}

class Probe {
public:
    Probe(const std::vector<uint8_t> &binary,
          const std::map<std::string, uint16_t> &symbols)
        : cpu(bus), symbols(symbols) {
        require(binary.size() < 65536 - 0x300, "binary too large");
        std::copy(binary.begin(), binary.end(), bus.bytes.begin() + 0x300);
        bus.bytes[0xAD0F] = 0x39; // FLEX outch stub: RTS.
    }

    void position(uint8_t x, uint8_t y, uint8_t direction) {
        bus.bytes[at("player_x")] = x;
        bus.bytes[at("player_y")] = y;
        bus.bytes[at("old_x")] = x;
        bus.bytes[at("old_y")] = y;
        bus.bytes[at("direction")] = direction;
        bus.bytes[at("jump_step")] = 1;
    }

    void set_direction(uint8_t value) { bus.bytes[at("direction")] = value; }
    void set_jump_step(uint8_t value) { bus.bytes[at("jump_step")] = value; }

    void set_tile(uint8_t x, uint8_t y, char tile) {
        bus.bytes[at("level_map") + (y - 1) * 79 + (x - 1)] = uint8_t(tile);
    }

    char tile_at(uint8_t x, uint8_t y) const {
        return char(bus.bytes[at("level_map") + (y - 1) * 79 + (x - 1)]);
    }

    void step(const char *routine = "move_jump") {
        // RTS pops the sentinel address; JSR calls use the same stack.
        cpu.s_.pc = at(routine);
        cpu.s_.sp = 0xEFFE;
        bus.bytes[0xEFFF] = 0xF0;
        bus.bytes[0xF000] = 0x00;
        for (int instructions = 0; instructions < 10000; ++instructions) {
            if (cpu.s_.pc == 0xF000) return;
            cpu.step();
        }
        throw std::runtime_error(std::string(routine) + " did not return");
    }

    void tick(int key = -1) {
        // FLEX poll returns carry set when a key is ready; getc returns it in A.
        bus.bytes[0xBF2A] = key < 0 ? 0x0C : 0x0D; // CLC / SEC
        bus.bytes[0xBF2B] = 0x39;                   // RTS
        bus.bytes[0xBF00] = 0x86;                   // LDAA immediate
        bus.bytes[0xBF01] = uint8_t(key);
        bus.bytes[0xBF02] = 0x39;                   // RTS
        if (!tick_started) {
            cpu.s_.pc = at("game_loop");
            cpu.s_.sp = 0xEFFE;
            tick_started = true;
        }
        bool entered = false;
        for (int instructions = 0; instructions < 100000; ++instructions) {
            if (entered && cpu.s_.pc == at("game_loop")) return;
            entered = true;
            cpu.step();
        }
        throw std::runtime_error("game_loop did not finish one tick");
    }

    void expect(uint8_t x, uint8_t y, uint8_t direction, uint8_t step,
                const std::string &case_name) const {
        const int actual_x = bus.bytes[at("player_x")];
        const int actual_y = bus.bytes[at("player_y")];
        const int actual_direction = bus.bytes[at("direction")];
        const int actual_step = bus.bytes[at("jump_step")];
        require(actual_x == x && actual_y == y &&
                actual_direction == direction && actual_step == step,
                case_name + ": got " + std::to_string(actual_x) + "," +
                std::to_string(actual_y) + "," +
                std::to_string(actual_direction) + "," +
                std::to_string(actual_step));
    }

private:
    uint16_t at(const std::string &name) const { return symbols.at(name); }
    RamBus bus;
    Cpu cpu;
    const std::map<std::string, uint16_t> &symbols;
    bool tick_started = false;
};

int main(int argc, char **argv) {
    try {
        require(argc == 3, "usage: probe_flex_jump ladder.bin ladder.lst");
        std::ifstream input(argv[1], std::ios::binary);
        require(bool(input), "cannot open assembled binary");
        std::vector<uint8_t> binary{std::istreambuf_iterator<char>(input),
                                    std::istreambuf_iterator<char>()};
        const auto symbols = read_symbols(argv[2]);

        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            const uint8_t ys[] = {18, 17, 17, 17, 18, 19};
            for (int i = 0; i < 6; ++i) {
                p.step();
                p.expect(6, ys[i], 0, i == 5 ? 0 : uint8_t(i + 2),
                         "standing step " + std::to_string(i + 1));
            }
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 2);
            p.step(); p.expect(7, 18, 2, 2, "right ascent 1");
            p.step(); p.expect(8, 17, 2, 3, "right ascent 2");
            p.set_direction(1);
            p.step(); p.expect(7, 17, 1, 4, "midair reverse");
            p.set_direction(0);
            p.step(); p.expect(7, 17, 0, 5, "midair stop");
            p.set_direction(2);
            p.step(); p.expect(8, 18, 2, 6, "midair resume");
            p.step(); p.expect(9, 19, 2, 0, "running landing");
        }
        {
            Probe p(binary, symbols);
            p.position(79, 7, 2);
            p.step(); p.expect(79, 7, 1, 1, "wall turn and pause");
            p.step(); p.expect(78, 6, 1, 2, "wall rebound step");
        }
        {
            Probe p(binary, symbols);
            p.position(7, 19, 2);
            p.set_tile(8, 18, '|');
            p.step(); p.expect(7, 19, 1, 1, "interior wall turn and pause");
            p.step(); p.expect(6, 18, 1, 2, "interior wall rebound step");
        }
        {
            Probe p(binary, symbols);
            p.position(58, 19, 0);
            p.step(); p.expect(58, 18, 0, 0, "ladder interruption");
        }
        {
            Probe p(binary, symbols);
            p.position(58, 19, 4);
            p.set_jump_step(0);
            p.step("move_player");
            p.expect(58, 19, 4, 0, "down request retained at ladder base");
            p.step("key_jump");
            p.expect(58, 19, 4, 1, "space arms ladder-base jump");
            p.step("move_player");
            p.expect(58, 18, 4, 0, "downward request survives ladder hop");
            p.step("move_player");
            p.expect(58, 19, 4, 0, "downward request returns Lad to base");
        }
        {
            Probe p(binary, symbols);
            p.position(39, 3, 3);
            p.set_jump_step(0);
            p.set_tile(39, 3, ' ');
            p.set_tile(39, 4, '=');
            p.set_tile(39, 2, 'H');
            p.step("move_player");
            p.expect(39, 2, 3, 0, "climb into ladder from supported plain cell");
        }
        {
            Probe p(binary, symbols);
            p.position(40, 3, 3);
            p.set_jump_step(0);
            p.set_tile(40, 3, ' ');
            p.set_tile(40, 4, '=');
            p.set_tile(40, 2, ' ');
            p.step("move_player");
            p.expect(40, 3, 3, 0, "up blocked without ladder above");
        }
        {
            Probe p(binary, symbols);
            p.position(38, 3, 3);
            p.set_jump_step(0);
            p.set_tile(38, 3, ' ');
            p.set_tile(38, 4, ' ');
            p.set_tile(38, 2, 'H');
            p.step("move_player");
            p.expect(38, 4, 3, 0, "unsupported up request falls");
        }
        {
            Probe p(binary, symbols);
            p.position(52, 16, 3);
            p.set_jump_step(0);
            p.set_tile(52, 16, ' ');
            p.set_tile(52, 17, '=');
            p.set_tile(52, 15, '&');
            p.step("move_player");
            p.expect(52, 15, 3, 0, "climb into statue from supported plain cell");
        }
        {
            Probe p(binary, symbols);
            p.position(17, 10, 3);
            p.set_jump_step(0);
            p.set_tile(17, 10, ' ');
            p.set_tile(17, 11, 'H');
            p.set_tile(17, 9, '&');
            p.step("move_player");
            p.expect(17, 11, 3, 0, "ladder below does not support player");
        }
        {
            const char glyphs[] = {' ', '-', '=', '$', '|', 'V', 'H', '*', '^', '.', '&'};
            for (int code = 0; code <= 10; ++code) {
                Probe p(binary, symbols);
                p.position(73, 18, 0);
                p.set_jump_step(0);
                p.set_tile(73, 18, ' ');
                p.set_tile(73, 19, glyphs[code]);
                p.set_tile(73, 20, '=');
                p.step("move_player");
                if (code == 8)
                    p.expect(6, 19, 0, 0, "fire on fall");
                else
                    p.expect(73, code >= 1 && code <= 5 ? 18 : 19, 0, 0,
                             "support tile code " + std::to_string(code));
            }
        }
        {
            Probe p(binary, symbols);
            p.position(73, 19, 2);
            p.set_jump_step(0);
            p.set_tile(74, 19, '=');
            p.step("move_player");
            p.expect(73, 19, 2, 0, "right request retained at floor wall");
            p.set_tile(74, 19, ' ');
            p.step("move_player");
            p.expect(74, 19, 2, 0, "right resumes after obstacle clears");
        }
        {
            Probe p(binary, symbols);
            p.position(58, 18, 4);
            p.set_jump_step(0);
            p.set_tile(58, 18, 'H');
            p.set_tile(58, 19, 'V');
            p.step("move_player");
            p.expect(58, 18, 4, 0, "down request retained at dispenser");
            p.set_tile(58, 19, ' ');
            p.step("move_player");
            p.expect(58, 19, 4, 0, "down resumes after obstacle clears");
        }
        {
            Probe p(binary, symbols);
            p.position(40, 3, 3);
            p.set_jump_step(0);
            p.set_tile(40, 3, ' ');
            p.set_tile(40, 4, '=');
            p.set_tile(40, 2, ' ');
            p.step("move_player");
            p.expect(40, 3, 3, 0, "up request retained without ladder");
            p.set_tile(40, 2, 'H');
            p.step("move_player");
            p.expect(40, 2, 3, 0, "up resumes when ladder appears");
        }
        {
            const char glyphs[] = {' ', '-', '=', '$', '|', 'V', 'H', '*', '^', '.', '&'};
            for (int code = 0; code <= 10; ++code) {
                Probe p(binary, symbols);
                p.position(73, 19, 0);
                p.set_tile(73, 18, glyphs[code]);
                p.set_tile(73, 20, '=');
                p.step("move_player");
                if (code == 8)
                    p.expect(6, 19, 0, 0, "jump into fire");
                else if (code == 2)
                    p.expect(73, 19, 0, 0, "jump into solid floor");
                else if (code == 4)
                    p.expect(73, 19, 0, 1, "jump into wall pauses");
                else if (code == 3 || code == 6)
                    p.expect(73, 18, 0, 0, "jump entry interrupts or wins");
                else
                    p.expect(73, 18, 0, 2,
                             "jump destination code " + std::to_string(code));
            }
        }
        {
            for (char tile : {'-', '=', '$', '|', 'V'}) {
                Probe p(binary, symbols);
                p.position(73, 18, 0);
                p.set_jump_step(0);
                p.set_tile(73, 18, ' ');
                p.set_tile(73, 19, tile);
                p.step("key_jump");
                p.expect(73, 18, 0, 1, "jump arms above support tile");
                p.step("move_player");
                p.expect(73, 17, 0, 2, "jump rises above support tile");
            }
        }
        {
            const char glyphs[] = {' ', '-', '=', '$', '|', 'V', 'H', '*', '^', '.', '&'};
            for (int code = 0; code <= 10; ++code) {
                Probe p(binary, symbols);
                p.position(73, 19, 2);
                p.set_jump_step(0);
                p.set_tile(73, 19, ' ');
                p.set_tile(74, 19, glyphs[code]);
                p.set_tile(73, 20, '=');
                p.step("move_player");
                if (code == 8)
                    p.expect(6, 19, 0, 0, "horizontal fire contact");
                else if (code == 3)
                    p.expect(74, 19, 0, 0, "horizontal treasure entry");
                else
                    p.expect(code == 2 || code == 4 ? 73 : 74, 19, 2, 0,
                             "horizontal destination code " + std::to_string(code));
            }
        }
        {
            const char glyphs[] = {' ', '-', '=', '$', '|', 'V', 'H', '*', '^', '.', '&'};
            for (int code = 0; code <= 10; ++code) {
                Probe p(binary, symbols);
                p.position(58, 18, 4);
                p.set_jump_step(0);
                p.set_tile(58, 18, 'H');
                p.set_tile(58, 19, glyphs[code]);
                p.step("move_player");
                if (code == 8)
                    p.expect(6, 19, 0, 0, "downward fire contact");
                else if (code == 3)
                    p.expect(58, 19, 0, 0, "downward treasure entry");
                else
                    p.expect(58, code == 1 || code == 2 || code == 4 || code == 5
                                 ? 18 : 19, 4, 0,
                             "downward destination code " + std::to_string(code));
            }
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_tile(6, 18, '=');
            p.step(); p.expect(6, 19, 0, 0, "solid ceiling");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_tile(6, 18, '-');
            p.step(); p.expect(6, 18, 0, 2, "disposable ceiling");
        }
        {
            Probe p(binary, symbols);
            p.position(25, 7, 2);
            p.set_jump_step(0);
            p.set_tile(25, 7, ' ');
            p.set_tile(26, 7, ' ');
            p.set_tile(25, 8, '-');
            p.set_tile(26, 8, '-');
            p.step("move_player");
            p.expect(26, 7, 2, 0, "leave disposable floor");
            require(p.tile_at(25, 8) == ' ', "departed floor remains");
            p.set_direction(1);
            p.step("move_player");
            p.expect(25, 7, 1, 0, "return above removed floor");
            p.step("move_player");
            p.expect(25, 8, 1, 0, "fall through removed floor");
        }
        {
            Probe p(binary, symbols);
            p.position(28, 5, 2);
            p.set_jump_step(3);
            p.set_tile(28, 6, '-');
            p.set_tile(29, 5, ' ');
            p.step("move_player");
            p.expect(29, 5, 2, 4, "jump apex sideways movement");
            require(p.tile_at(28, 6) == '-', "jump apex removed floor");
        }
        {
            Probe p(binary, symbols);
            p.position(25, 7, 2);
            p.set_jump_step(0);
            p.set_tile(25, 7, ' ');
            p.set_tile(26, 7, ' ');
            p.set_tile(25, 8, '-');
            p.step("move_player");
            require(p.tile_at(25, 8) == ' ', "floor not removed before death");
            p.set_tile(27, 7, '^');
            p.step("move_player");
            p.expect(6, 19, 0, 0, "fire restart after floor removal");
            require(p.tile_at(25, 8) == ' ', "fire restart restored removed floor");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.tick('d'); p.expect(6, 19, 2, 0, "right request is delayed");
            p.tick(); p.expect(7, 19, 2, 0, "right movement next tick");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.tick(' '); p.expect(6, 19, 0, 1, "space arms after movement");
            p.tick(); p.expect(6, 18, 0, 2, "jump rises next tick");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 2);
            p.set_jump_step(0);
            p.tick(' '); p.expect(7, 19, 2, 1, "running space request");
            p.tick('a'); p.expect(8, 18, 1, 2, "reverse request after first jump step");
            p.tick('x'); p.expect(7, 17, 0, 3, "stop request after reverse step");
            p.tick(); p.expect(7, 17, 0, 4, "stopped midair next tick");
        }
        {
            Probe p(binary, symbols);
            p.position(10, 17, 2);
            p.set_jump_step(0);
            p.set_tile(10, 17, ' ');
            p.set_tile(10, 18, '=');
            p.set_tile(11, 17, ' ');
            p.set_tile(11, 18, ' ');
            p.set_tile(11, 19, '=');
            p.set_tile(12, 17, ' ');
            p.set_tile(12, 18, ' ');
            p.set_tile(12, 19, '=');
            p.tick(' '); p.expect(11, 17, 2, 0, "space ignored over gap");
            p.tick(' '); p.expect(11, 18, 2, 1, "space arms after landing");
            p.tick(); p.expect(12, 17, 2, 2, "jump after supported poll");
        }
        {
            Probe p(binary, symbols);
            p.position(10, 17, 2);
            p.set_jump_step(0);
            p.set_tile(10, 17, ' ');
            p.set_tile(10, 18, '=');
            p.set_tile(11, 17, ' ');
            p.set_tile(11, 18, ' ');
            p.set_tile(11, 19, '=');
            p.set_tile(12, 18, ' ');
            p.set_tile(12, 19, '=');
            p.tick(); p.expect(11, 17, 2, 0, "step off ledge");
            p.tick(); p.expect(11, 18, 2, 0, "one-row fall");
            p.tick(); p.expect(12, 18, 2, 0, "right request resumes after fall");
        }
        std::cout << "FLEX jump CPU probes passed\n";
        return 0;
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
