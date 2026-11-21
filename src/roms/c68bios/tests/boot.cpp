#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <regex>
#include <stdexcept>
#include <string>
#include <vector>
#include "cpu/cpu.h"

static void check(bool ok, const char *message) {
    if (!ok) throw std::runtime_error(message);
}
static std::vector<uint8_t> file(const char *path) {
    std::ifstream input(path, std::ios::binary);
    check(bool(input), "cannot open test input");
    return {std::istreambuf_iterator<char>(input), {}};
}
static uint16_t symbol(const char *path, const std::string &name) {
    std::ifstream input(path);
    check(bool(input), "cannot open listing");
    std::regex pattern("^" + name + " +[AS]:([0-9A-Fa-f]{4})$");
    std::string line;
    std::smatch match;
    while (std::getline(input, line))
        if (std::regex_match(line, match, pattern))
            return uint16_t(std::stoul(match[1], nullptr, 16));
    throw std::runtime_error("missing symbol " + name);
}
struct Bus : IBus {
    explicit Bus(const char *disk_path) : disk(file(disk_path)) {}
    std::array<uint8_t,65536> ram{};
    std::vector<uint8_t> disk;
    uint8_t page = 0;
    int input = -1;
    std::string output;
    uint8_t read8(uint16_t address) override {
        if (address >= 0xC000 && address < 0xD000)
            return disk[size_t(page) * 4096 + (address & 4095)];
        if (address == 0xE001) return 0x11;
        if (address == 0xE010) return 2 | (input >= 0 ? 1 : 0);
        if (address == 0xE011) {
            check(input >= 0, "empty ACIA read");
            const int c = input;
            input = -1;
            return uint8_t(c);
        }
        if (address >= 0xE000 && address < 0xE100)
            throw std::runtime_error("unexpected I/O read");
        return ram[address];
    }
    void write8(uint16_t address, uint8_t value) override {
        if (address >= 0xC000 && address < 0xD000) {
            disk[size_t(page) * 4096 + (address & 4095)] = value;
            return;
        }
        if (address == 0xE000 || address == 0xE010) return;
        if (address == 0xE002) { page = value; return; }
        if (address == 0xE011) { output += char(value); return; }
        if (address == 0xE060) return;
        if (address >= 0xE000 && address < 0xE100)
            throw std::runtime_error("unexpected I/O write");
        ram[address] = value;
    }
};
int main(int argc, char **argv) {
    try {
        Bus bus(argc > 2 ? argv[2] : "../../flex2/build/flex2.dsk");
        Cpu cpu(bus);
        const auto rom = file(argc > 1 ? argv[1] : "c68.rom");
        check(rom.size() == 8192, "ROM size");
        std::copy(rom.begin(), rom.end(), bus.ram.begin() + 0xE000);
        const uint16_t inwait = symbol(argc > 3 ? argv[3] :
                                       "../../flex2/build/c68flex.lst", "C68INW");
        cpu.reset();
        const std::string date = "11,01,26\r";
        size_t next = 0;
        bool booted = false;
        for (unsigned step = 0; step < 3000000; ++step) {
            if (cpu.s_.pc == inwait && bus.input < 0 && next < date.size())
                bus.input = uint8_t(date[next++]);
            cpu.step();
            if (next == date.size() && bus.output.find("+++") != std::string::npos &&
                cpu.s_.pc == inwait) { booted = true; break; }
        }
        check(booted, "reset did not boot FLEX and reach its console");
        const auto startup = bus.output.find("C68 BIOS v0.01\r\nDave Hamilton 2026\r\nBuild ");
        check(startup != std::string::npos && startup < bus.output.find("+++"),
              "startup banner missing before FLEX");
        check(std::regex_search(bus.output,
              std::regex(R"(Build [0-9]{8} [0-9a-f]{8}\r\n)")),
              "build tag has wrong format");
        const auto prompt_before_nmi = bus.output.rfind("+++");
        check(prompt_before_nmi != std::string::npos, "FLEX prompt missing before NMI");
        cpu.requestNmi();
        cpu.step();
        check(cpu.s_.pc == 0xFFF4 || cpu.s_.pc == 0xFFF8 || cpu.s_.pc >= 0xE100,
              "NMI vector invalid");
        bool monitor = false;
        for (unsigned step = 0; step < 100000; ++step) {
            cpu.step();
            if (bus.output.find("C68 BIOS v0.01", startup + 1) != std::string::npos &&
                bus.output.find("Dave Hamilton 2026", startup + 1) != std::string::npos &&
                bus.output.back() == ':') { monitor = true; break; }
        }
        check(monitor, "FLEX NMI did not enter monitor");
        check(bus.output.find("+++\r\nC68 BIOS v0.01", prompt_before_nmi) ==
              prompt_before_nmi, "NMI banner did not start on the next line");
        const size_t prior_output = bus.output.size();
        const std::string replay = "F\r";
        size_t replay_key = 0;
        next = 0;
        bool rebooted = false;
        for (unsigned step = 0; step < 3000000; ++step) {
            if (bus.input < 0 && replay_key < replay.size())
                bus.input = uint8_t(replay[replay_key++]);
            else if (bus.input < 0 && replay_key == replay.size() &&
                     cpu.s_.pc == inwait && next < date.size())
                bus.input = uint8_t(date[next++]);
            cpu.step();
            if (next == date.size() &&
                bus.output.find("+++", prior_output) != std::string::npos &&
                cpu.s_.pc == inwait) { rebooted = true; break; }
        }
        check(rebooted, "monitor F command did not reboot FLEX");

        const size_t before_mon = bus.output.size();
        const std::string mon_command = "MON\r";
        size_t mon_key = 0;
        bool mon_entered = false;
        for (unsigned step = 0; step < 3000000; ++step) {
            if (cpu.s_.pc == inwait && bus.input < 0 &&
                mon_key < mon_command.size())
                bus.input = uint8_t(mon_command[mon_key++]);
            cpu.step();
            if (mon_key == mon_command.size() &&
                bus.output.find("C68 BIOS v0.01", before_mon) != std::string::npos &&
                bus.output.back() == ':') { mon_entered = true; break; }
        }
        check(mon_entered, "FLEX MON did not enter warm monitor");
        const size_t before_reset = bus.output.size();
        cpu.reset();
        bool reset_entered = false;
        for (unsigned step = 0; step < 100000; ++step) {
            cpu.step();
            if (bus.output.find("C68 BIOS v0.01", before_reset) != std::string::npos &&
                bus.output.back() == ':') { reset_entered = true; break; }
        }
        check(reset_entered, "warm hardware reset did not enter monitor promptly");

        auto monitor_command = [&](const std::string &line,
                                   const std::string &expected) {
            const size_t before = bus.output.size();
            size_t key = 0;
            for (unsigned step = 0; step < 100000; ++step) {
                if (bus.input < 0 && key < line.size())
                    bus.input = uint8_t(line[key++]);
                cpu.step();
                if (key == line.size() && bus.input < 0 &&
                    bus.output.find(expected, before) != std::string::npos &&
                    bus.output.back() == ':') return;
            }
            throw std::runtime_error("monitor command failed: " + line);
        };
        for (unsigned i = 0; i < 18; ++i)
            bus.ram[0x300 + i] = uint8_t(0x11 + i);
        bus.ram[0x300] = 0xC1; // high bit strips to printable 'A'
        bus.ram[0x310] = 0xE1; // high bit strips to printable 'a'
        monitor_command("300\r", "0300: C1\r\n");
        monitor_command("300.311\r",
                        "0300: C1 12 13 14 15 16 17 18"
                        " 19 1A 1B 1C 1D 1E 1F 20  |A.............. |\r\n"
                        "0310: E1 22" + std::string(42, ' ') +
                        "  |a\"|\r\n");
        monitor_command("F800\r", "F800: 00\r\n");
        monitor_command("300.2FF\r", "Unknown command");

        Bus key_bus(argc > 2 ? argv[2] : "../../flex2/build/flex2.dsk");
        Cpu key_cpu(key_bus);
        std::copy(rom.begin(), rom.end(), key_bus.ram.begin() + 0xE000);
        key_cpu.reset();
        for (unsigned step = 0; step < 100000; ++step) key_cpu.step();
        check(key_bus.output.find("C68 BIOS v0.01") != std::string::npos &&
              key_bus.output.find("DATE (MM,DD,YY)") == std::string::npos,
              "startup key window did not wait after banner");
        key_bus.input = 'x';
        bool key_monitor = false;
        for (unsigned step = 0; step < 100000; ++step) {
            key_cpu.step();
            if (!key_bus.output.empty() && key_bus.output.back() == ':') {
                key_monitor = true;
                break;
            }
        }
        check(key_monitor && key_bus.input < 0,
              "startup key did not enter monitor and get consumed");
        check(key_bus.output.find("C68 BIOS v0.01",
              key_bus.output.find("C68 BIOS v0.01") + 1) == std::string::npos,
              "startup key printed the banner twice");
        std::cout << "C68 BIOS boot, monitor examine, NMI, MON, and warm reset passed.\n";
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
