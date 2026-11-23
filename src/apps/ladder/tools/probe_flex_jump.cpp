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
                             "key_jump", "old_x", "old_y", "game_loop", "start_level",
                             "restart_after_death", "death_flag", "lives",
                             "death_pause", "death_ptr", "death_char", "death_glyphs",
                             "game_over", "move_rocks", "rock_slots", "rock_count", "rng0",
                             "rng_three", "rng_next", "start_screen", "menu_key",
                             "menu_entry", "saved_sp",
                             "menu_action", "change_speed", "play_speed", "tick_delay",
                             "menu_idle_tick", "menu_idle_count", "menu_idle_state",
                             "bonus_tick", "bonus_remaining", "bonus_ticks", "bonus_points",
                             "reset_bonus", "add_bonus", "score", "active_map",
                             "active_rows", "active_status", "row_pointers",
                             "easy_status_text", "active_config", "level_configs",
                             "rock_limit", "level_number"})
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
        bus.bytes[at("death_pause")] = 0x39; // Skip real-time delay in CPU probes.
        bus.bytes[at("lives")] = 5;
        bus.bytes[at("bonus_points")] = 35;
        bus.bytes[at("bonus_remaining")] = 35;
        bus.bytes[at("bonus_ticks")] = 25;
        bus.bytes[at("rock_limit")] = 5;
        bus.bytes[at("level_number")] = 1;
        const auto set_word = [this](const char *name, uint16_t value) {
            bus.bytes[at(name)] = uint8_t(value >> 8);
            bus.bytes[at(name) + 1] = uint8_t(value);
        };
        set_word("active_map", at("level_map"));
        set_word("active_rows", at("row_pointers"));
        set_word("active_status", at("easy_status_text"));
        set_word("active_config", at("level_configs"));
        step("find_dispensers");
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
    void restart_if_dead() {
        require(bus.bytes[at("death_flag")] == 1, "expected death flag");
        step("restart_after_death");
        const uint16_t next = uint16_t(bus.bytes[at("death_ptr")]) << 8 |
                              bus.bytes[at("death_ptr") + 1];
        require(next == at("death_glyphs") + 11 &&
                bus.bytes[at("death_char")] == '_',
                "death glyph sequence did not finish");
    }
    void set_rock_count(uint8_t count) { bus.bytes[at("rock_count")] = count; }
    void set_rock_limit(uint8_t limit) { bus.bytes[at("rock_limit")] = limit; }
    void set_level_number(uint8_t level) { bus.bytes[at("level_number")] = level; }
    uint8_t level_number() const { return bus.bytes[at("level_number")]; }
    uint8_t won_level() const { return bus.bytes[at("won_level")]; }
    void set_rock(int slot, uint8_t x, uint8_t y, uint8_t state) {
        require(slot >= 0 && slot < 5, "invalid rock slot");
        const uint16_t address = at("rock_slots") + 3 * slot;
        bus.bytes[address] = x;
        bus.bytes[address + 1] = y;
        bus.bytes[address + 2] = state;
    }
    void expect_rock(int slot, uint8_t x, uint8_t y, uint8_t state,
                     const std::string &name) const {
        const uint16_t address = at("rock_slots") + 3 * slot;
        require(bus.bytes[address] == x && bus.bytes[address + 1] == y &&
                bus.bytes[address + 2] == state,
                name + ": got " + std::to_string(bus.bytes[address]) + "," +
                std::to_string(bus.bytes[address + 1]) + "," +
                std::to_string(bus.bytes[address + 2]));
    }
    void expect_lives(uint8_t value, const std::string &name) const {
        require(bus.bytes[at("lives")] == value, name + ": wrong lives");
    }
    void set_lives(uint8_t value) { bus.bytes[at("lives")] = value; }
    void set_bonus(uint8_t remaining, uint8_t ticks = 25) {
        bus.bytes[at("bonus_remaining")] = remaining;
        bus.bytes[at("bonus_ticks")] = ticks;
    }
    uint8_t bonus() const { return bus.bytes[at("bonus_remaining")]; }
    uint8_t bonus_ticks() const { return bus.bytes[at("bonus_ticks")]; }
    void set_score(uint16_t value) {
        bus.bytes[at("score")] = uint8_t(value >> 8);
        bus.bytes[at("score") + 1] = uint8_t(value);
    }
    uint16_t score() const {
        return uint16_t(bus.bytes[at("score")]) << 8 | bus.bytes[at("score") + 1];
    }
    uint8_t death_flag() const { return bus.bytes[at("death_flag")]; }
    void set_tick_delay(uint16_t value) {
        bus.bytes[at("tick_delay")] = uint8_t(value >> 8);
        bus.bytes[at("tick_delay") + 1] = uint8_t(value);
    }
    void expect_game_over(uint8_t value, const std::string &name) const {
        require(bus.bytes[at("game_over")] == value, name + ": wrong game-over flag");
    }
    void expect_rock_count(uint8_t value, const std::string &name) const {
        require(bus.bytes[at("rock_count")] == value, name + ": wrong rock count");
    }
    void set_rng(uint32_t value) {
        for (int i = 0; i < 3; ++i)
            bus.bytes[at("rng0") + i] = uint8_t(value >> (i * 8));
    }
    uint32_t rng() const {
        return uint32_t(bus.bytes[at("rng0")]) |
               (uint32_t(bus.bytes[at("rng0") + 1]) << 8) |
               (uint32_t(bus.bytes[at("rng0") + 2]) << 16);
    }
    uint8_t accumulator() const { return cpu.s_.a; }
    uint8_t menu_key(char key) {
        cpu.s_.a = uint8_t(key);
        step("menu_key");
        return bus.bytes[at("menu_action")];
    }
    void set_menu_idle(uint16_t count, uint8_t state) {
        bus.bytes[at("menu_idle_count")] = uint8_t(count >> 8);
        bus.bytes[at("menu_idle_count") + 1] = uint8_t(count);
        bus.bytes[at("menu_idle_state")] = state;
    }
    uint8_t menu_idle_state() const { return bus.bytes[at("menu_idle_state")]; }
    uint8_t play_speed() const { return bus.bytes[at("play_speed")]; }
    uint16_t tick_delay() const {
        return uint16_t(bus.bytes[at("tick_delay")]) << 8 |
               bus.bytes[at("tick_delay") + 1];
    }
    void menu_start_with_play_key() {
        bus.bytes[0xBF2A] = 0x0D; // SEC
        bus.bytes[0xBF2B] = 0x39; // RTS
        bus.bytes[0xBF00] = 0x86; // LDAA #'P'
        bus.bytes[0xBF01] = 'P';
        bus.bytes[0xBF02] = 0x39; // RTS
        step("start_screen");
    }
    void replay_after_final_death() {
        bus.bytes[at("saved_sp")] = 0xEF;
        bus.bytes[at("saved_sp") + 1] = 0xFE;
        bus.bytes[0xBF2A] = 0x0D; // SEC: P available at menu.
        bus.bytes[0xBF2B] = 0x39;
        bus.bytes[0xBF00] = 0x86;
        bus.bytes[0xBF01] = 'P';
        bus.bytes[0xBF02] = 0x39;
        cpu.s_.pc = at("game_loop");
        cpu.s_.sp = 0xEFFE;
        bool saw_menu = false;
        for (int instructions = 0; instructions < 500000; ++instructions) {
            if (cpu.s_.pc == at("menu_entry")) {
                saw_menu = true;
                expect_lives(0, "final death reaches menu");
                expect_game_over(1, "game over shown before menu");
            }
            if (saw_menu && cpu.s_.pc == at("game_loop")) return;
            cpu.step();
        }
        throw std::runtime_error("final death did not replay from menu");
    }

    void set_tile(uint8_t x, uint8_t y, char tile) {
        bus.bytes[active_map_address() + (y - 1) * 79 + (x - 1)] = uint8_t(tile);
    }

    char tile_at(uint8_t x, uint8_t y) const {
        return char(bus.bytes[active_map_address() + (y - 1) * 79 + (x - 1)]);
    }

    char source_tile_at(uint16_t map, uint8_t x, uint8_t y) const {
        return char(bus.bytes[map + (y - 1) * 79 + (x - 1)]);
    }

    void set_source_tile(uint16_t map, uint8_t x, uint8_t y, char tile) {
        bus.bytes[map + (y - 1) * 79 + (x - 1)] = uint8_t(tile);
    }

    uint16_t symbol(const char *name) const { return at(name); }

    void step(const char *routine = "move_jump") {
        // RTS pops the sentinel address; JSR calls use the same stack.
        cpu.s_.pc = at(routine);
        cpu.s_.sp = 0xEFFE;
        bus.bytes[0xEFFF] = 0xF0;
        bus.bytes[0xF000] = 0x00;
        for (int instructions = 0; instructions < 100000; ++instructions) {
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
    uint16_t active_map_address() const {
        return uint16_t(bus.bytes[at("active_map")]) << 8 |
               bus.bytes[at("active_map") + 1];
    }
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
                if (code == 9) p.set_rng(0); // Isolate falling support from the bounce.
                p.step("move_player");
                if (code == 8) {
                    p.restart_if_dead();
                    p.expect(6, 19, 0, 0, "fire on fall");
                }
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
                if (code == 9) p.set_rng(0); // Keep jump-phase check independent of bounce.
                p.step("move_player");
                if (code == 8) {
                    p.restart_if_dead();
                    p.expect(6, 19, 0, 0, "jump into fire");
                }
                else if (code == 2)
                    p.expect(73, 19, 0, 0, "jump into solid floor");
                else if (code == 4)
                    p.expect(73, 19, 0, 1, "jump into wall pauses");
                else if (code == 3)
                    p.expect(18, 19, 0, 0, "treasure starts Long Island");
                else if (code == 6)
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
                if (code == 9) p.set_rng(0); // Keep entry check independent of bounce.
                p.step("move_player");
                if (code == 8) {
                    p.restart_if_dead();
                    p.expect(6, 19, 0, 0, "horizontal fire contact");
                }
                else if (code == 3)
                    p.expect(18, 19, 0, 0, "horizontal treasure starts Long Island");
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
                if (code == 9) p.set_rng(0); // Keep descent check independent of bounce.
                p.step("move_player");
                if (code == 8) {
                    p.restart_if_dead();
                    p.expect(6, 19, 0, 0, "downward fire contact");
                }
                else if (code == 3)
                    p.expect(18, 19, 0, 0, "downward treasure starts Long Island");
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
            p.restart_if_dead();
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
        for (uint32_t seed : {0u, 0x111111u, 0x222222u}) {
            Probe p(binary, symbols);
            p.position(53, 7, 2);
            p.set_jump_step(0);
            p.set_tile(53, 7, ' ');
            p.set_tile(54, 7, '.');
            p.set_tile(55, 7, ' ');
            p.set_tile(55, 6, ' ');
            for (uint8_t x : {53, 54, 55}) p.set_tile(x, 8, '=');
            p.set_rng(seed);
            p.step("move_player");
            if (seed == 0) {
                p.expect(54, 7, 2, 0, "trampoline keeps direction");
                p.step("move_player");
                p.expect(55, 7, 2, 0, "keep outcome continues right");
            } else if (seed == 0x111111u) {
                p.expect(54, 7, 1, 0, "trampoline reverses direction");
                p.step("move_player");
                p.expect(53, 7, 1, 0, "reverse outcome moves left");
            } else {
                p.expect(54, 7, 2, 1, "trampoline starts moving jump");
                p.step("move_player");
                p.expect(55, 6, 2, 2, "jump outcome rises right");
            }
        }
        {
            Probe p(binary, symbols);
            p.set_level_number(2);
            p.step("start_level");
            p.position(53, 7, 2);
            p.set_jump_step(0);
            p.set_rng(0x111111);
            p.step("move_player");
            p.expect(54, 7, 1, 0, "Long Island trampoline reverses Lad");
        }
        {
            Probe p(binary, symbols);
            p.position(54, 7, 0);
            p.set_jump_step(0);
            p.set_tile(54, 7, '.');
            p.set_tile(54, 6, ' ');
            p.set_tile(54, 8, '=');
            p.set_rng(0x111111);
            p.step("move_player");
            p.expect(54, 7, 0, 0, "stopped trampoline reversal stays stopped");
            p.set_rng(0x222222);
            p.step("move_player");
            p.expect(54, 7, 0, 1, "stationary trampoline retries and jumps");
            p.step("move_player");
            p.expect(54, 6, 0, 2, "stopped trampoline jump rises in place");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.step("move_rocks");
            p.expect_rock(0, 40, 2, 2, "new rock waits at dispenser");
            p.step("move_rocks");
            p.expect_rock(0, 40, 3, 2, "rock falls one cell");
            p.step("move_rocks");
            p.expect_rock_count(3, "third release");
            // Row 4 is solid: the first rock stays on row 3 and turns.
            p.expect_rock(0, 40, 3, 4, "landing pauses and picks direction");
            for (int i = 0; i < 5; ++i) p.step("move_rocks");
            p.expect_rock_count(5, "Easy Street rock cap");
        }
        {
            Probe p(binary, symbols);
            p.set_level_number(3); // Ghost Town has three dispensers.
            p.step("start_level");
            p.set_rng(0);
            p.step("release_rock");
            p.expect_rock(0, 29, 2, 2, "first Ghost Town dispenser");
            p.set_rng(0x111111);
            p.step("release_rock");
            p.expect_rock(1, 45, 2, 2, "second Ghost Town dispenser");
            p.set_rng(0x222222);
            p.step("release_rock");
            p.expect_rock(2, 57, 2, 2, "third Ghost Town dispenser");
        }
        {
            Probe p(binary, symbols);
            p.set_level_number(5); // Point of No Return has dispensers on two rows.
            p.step("start_level");
            p.set_rng(0);
            p.step("release_rock");
            p.expect_rock(0, 62, 3, 2, "first lower-row dispenser");
            p.set_rng(0x200000);
            p.step("release_rock");
            p.expect_rock(1, 30, 6, 2, "second lower-row dispenser");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_rock_count(5);
            p.set_tile(78, 19, '=');
            p.set_tile(79, 19, '=');
            p.set_rock(0, 79, 18, 4);
            p.step("move_rocks");
            p.expect_rock(0, 79, 18, 3, "right edge reverses in place");
            p.step("move_rocks");
            p.expect_rock(0, 78, 18, 3, "reversed rock moves next tick");
            p.set_tile(79, 19, '*');
            p.set_rock(0, 78, 19, 4);
            p.step("move_rocks");
            p.expect_rock(0, 79, 19, 4, "rock enters eater");
            p.step("move_rocks");
            p.expect_rock(0, 79, 19, 0, "eater retires occupied rock");
            p.expect_rock_count(4, "eater frees capacity");
            p.step("move_rocks");
            p.expect_rock(0, 40, 2, 2, "eaten slot released next tick");
        }
        {
            Probe p(binary, symbols);
            p.position(79, 19, 0);
            p.set_rock_count(5);
            p.set_rock(0, 78, 19, 4);
            p.set_tile(79, 19, '*');
            p.step("move_rocks");
            p.expect_rock(0, 79, 19, 4, "rock reaches Lad on eater");
            require(p.death_flag() == 1, "arrival on eater must kill Lad");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_rock_count(5);
            p.set_rock(0, 79, 19, 4);
            p.set_tile(79, 19, '*');
            p.step("move_rocks");
            p.expect_rock(0, 79, 19, 0, "eater deactivates rock");
            p.position(79, 19, 0);
            p.step("check_player_rocks");
            require(p.death_flag() == 0, "eaten rock must not kill Lad");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.set_rock_count(5);
            p.set_rock(0, 7, 19, 3);
            p.tick();
            p.expect(6, 19, 0, 0, "rock contact restarts Lad");
            p.expect_lives(4, "rock contact costs one Lad");
            p.expect_rock_count(0, "death clears rock pool");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.set_rock_count(5);
            p.set_rock(0, 6, 19, 3);
            p.tick();
            p.expect_lives(4, "standing on a rock costs one Lad");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            for (int life = 4; life >= 0; --life) {
                p.step("restart_after_death");
                p.expect_lives(uint8_t(life), "life countdown");
                p.expect_game_over(life == 0, "fifth death ends game");
            }
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.set_lives(1);
            p.set_rock_count(5);
            p.set_rock(0, 7, 19, 3);
            p.replay_after_final_death();
            p.expect_lives(5, "new game restores five Lads");
            p.expect_game_over(0, "new game clears game over");
            p.expect_rock_count(0, "new game clears old rocks");
            p.expect(6, 19, 0, 0, "new game resets Lad position");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_rock_count(5);
            p.set_rock(0, 75, 19, 4);
            p.set_rock(1, 77, 19, 3);
            p.step("move_rocks");
            p.expect_rock(0, 76, 19, 4, "first rock enters shared cell");
            p.expect_rock(1, 76, 19, 3, "second rock enters shared cell");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_rock_count(5);
            p.set_rock(0, 73, 19, 4);
            p.set_tile(74, 19, '|');
            p.step("move_rocks");
            p.expect_rock(0, 73, 19, 3, "wall turns rock without travel");
            p.set_rock(0, 73, 17, 4);
            p.set_tile(73, 18, 'H');
            p.step("move_rocks");
            p.expect_rock(0, 73, 18, 2, "rock descends into ladder below");
        }
        {
            Probe p(binary, symbols);
            for (uint32_t seed : {0u, 0x332211u, 0xFFFFFFu, 0x008000u}) {
                p.set_rng(seed);
                p.step("rng_next");
                require(p.rng() == ((5 * seed + 3) & 0xFFFFFF),
                        "rock RNG recurrence");
            }
            // 5 is invertible modulo 2^24; its inverse is 0xCCCCCD.
            for (uint32_t output : {0x555555u, 0x555556u,
                                    0xAAAAAAu, 0xAAAAABu}) {
                const uint32_t seed = ((output - 3) * 0xCCCCCDu) & 0xFFFFFF;
                p.set_rng(seed);
                p.step("rng_three");
                require(p.rng() == output, "rock RNG bucket setup");
                require(p.accumulator() == (output <= 0x555555 ? 0 :
                        output <= 0xAAAAAA ? 1 : 2), "rock RNG thirds");
            }
        }
        {
            Probe p(binary, symbols);
            for (char key : {'p', 'P'}) require(p.menu_key(key) == 1, "menu play key");
            for (char key : {'e', 'E'}) require(p.menu_key(key) == 2, "menu exit key");
            for (char key : {'i', 'I'}) require(p.menu_key(key) == 3, "menu instructions key");
            for (char key : {'l', 'L'}) require(p.menu_key(key) == 4, "menu speed key");
            require(p.menu_key('x') == 0, "unknown menu key");
            p.menu_start_with_play_key();
            require(p.menu_key('P') == 1, "menu returns to play");
            for (int speed = 2; speed <= 5; ++speed) {
                p.step("change_speed");
                require(p.play_speed() == speed &&
                        p.tick_delay() == uint16_t(24000 >> (speed - 1)),
                        "menu speed cycle");
            }
            p.step("change_speed");
            require(p.play_speed() == 1 && p.tick_delay() == 24000,
                    "menu speed wraps to one");
            p.set_menu_idle(29999, 0);
            p.step("menu_idle_tick");
            require(p.menu_idle_state() == 1, "first menu idle taunt");
            p.set_menu_idle(29999, 3);
            p.step("menu_idle_tick");
            require(p.menu_idle_state() == 0, "menu idle taunt cycle wraps");
        }
        {
            Probe p(binary, symbols);
            for (int update = 1; update < 25; ++update) p.step("bonus_tick");
            require(p.bonus() == 35 && p.bonus_ticks() == 1,
                    "bonus holds through update 24");
            p.step("bonus_tick");
            require(p.bonus() == 34 && p.bonus_ticks() == 25,
                    "bonus falls on update 25 and reloads the phase");
            p.set_score(42);
            p.step("add_bonus");
            require(p.score() == 76, "score uses remaining bonus");
            p.step("reset_bonus");
            require(p.bonus() == 35 && p.bonus_ticks() == 25,
                    "new board resets bonus and phase");
        }
        {
            Probe p(binary, symbols);
            p.set_level_number(2);
            const uint16_t map = p.symbol("long_island_map");
            p.set_source_tile(map, 18, 19, ' ');
            p.set_source_tile(map, 1, 1, 'p');
            p.step("start_level");
            p.expect(1, 1, 0, 0, "Long Island start comes from p tile");
            require(p.bonus() == 45 && p.bonus_ticks() == 25,
                    "Long Island loads its own starting bonus");
        }
        {
            Probe p(binary, symbols);
            p.set_score(0);
            p.step("start_level");
            const std::array<std::pair<uint8_t, uint8_t>, 7> goals{{
                {58, 1}, {75, 1}, {73, 1}, {6, 18}, {10, 1}, {47, 7}, {62, 15}
            }};
            const std::array<std::pair<uint8_t, uint8_t>, 6> next_starts{{
                {18, 19}, {6, 3}, {77, 17}, {74, 4}, {34, 9}, {7, 3}
            }};
            for (size_t board = 0; board < goals.size(); ++board) {
                const auto [x, y] = goals[board];
                require(p.tile_at(x, y) == '$', "board treasure missing");
                p.position(x - 1, y, 2);
                p.set_jump_step(3); // Apex step moves horizontally onto '$'.
                p.step("move_player");
                if (board < next_starts.size()) {
                    require(p.level_number() == board + 2,
                            "treasure did not advance displayed level");
                    p.expect(next_starts[board].first, next_starts[board].second,
                             0, 0, "next board starts at its p tile");
                } else {
                    require(p.level_number() == 7 && p.won_level() == 1,
                            "GangLand treasure did not complete seven boards");
                }
            }
            require(p.score() == 255, "seven treasures tally their bonuses");
        }
        {
            Probe p(binary, symbols);
            p.step("start_level");
            require(p.tile_at(17, 9) == '&', "Easy Street statue loaded");
            p.position(17, 10, 0);
            p.step("move_player");
            p.expect(17, 9, 0, 2, "Lad collects Easy Street statue");
            require(p.tile_at(17, 9) == ' ', "collection removes statue");
            require(p.source_tile_at(p.symbol("level_map"), 17, 9) == '&',
                    "collected statue leaves source map intact");
            p.step("restart_after_death");
            require(p.tile_at(17, 9) == ' ', "collected statue survives life restart");
            p.step("start_level");
            require(p.tile_at(17, 9) == '&', "new board reloads statue");
        }
        {
            Probe p(binary, symbols);
            p.set_level_number(4);
            p.step("start_level");
            p.position(12, 3, 2);
            p.set_jump_step(0);
            p.step("move_player");
            p.expect(13, 3, 2, 0, "leave Tunnel Vision floor");
            require(p.tile_at(12, 4) == ' ', "departure removes floor");
            require(p.source_tile_at(p.symbol("tunnel_vision_map"), 12, 4) == '-',
                    "removed floor leaves source map intact");
            p.step("restart_after_death");
            require(p.tile_at(12, 4) == ' ', "removed floor survives life restart");
            p.step("start_level");
            require(p.tile_at(12, 4) == '-', "new board reloads floor");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.set_rock_limit(0);
            p.set_tick_delay(1);
            for (int update = 1; update < 25; ++update) p.tick();
            require(p.bonus() == 35 && p.bonus_ticks() == 1,
                    "whole-loop bonus holds through update 24");
            p.tick();
            require(p.bonus() == 34 && p.bonus_ticks() == 25,
                    "whole-loop bonus falls on update 25");
        }
        {
            Probe p(binary, symbols);
            p.position(6, 19, 0);
            p.set_jump_step(0);
            p.set_tick_delay(1);
            p.set_score(42);
            p.set_bonus(1, 1);
            p.tick();
            p.expect_lives(4, "bonus expiry costs one Lad");
            require(p.score() == 42 && p.bonus() == 35 && p.bonus_ticks() == 24,
                    "bonus expiry keeps score and restarts timer");
            p.expect_game_over(0, "bonus expiry restarts current board");
            for (int update = 1; update < 24; ++update) p.step("bonus_tick");
            require(p.bonus() == 35 && p.bonus_ticks() == 1,
                    "restarted bonus holds until the next 25-update boundary");
            p.step("bonus_tick");
            require(p.bonus() == 34 && p.bonus_ticks() == 25,
                    "restarted bonus phase matches original timeout probe");
        }
        std::cout << "FLEX movement, rock, and bonus CPU probes passed\n";
        return 0;
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
