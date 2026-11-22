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
    uint8_t high_page = 0;
    unsigned low_page_zero_writes = 0;
    unsigned high_page_zero_writes = 0;
    int input = -1;
    std::string output;
    uint8_t read8(uint16_t address) override {
        if (address >= 0xC000 && address < 0xD000)
            return disk[size_t(page) * 4096 + (address & 4095)];
        if (address >= 0xD000 && address < 0xE000)
            return disk[size_t(high_page) * 4096 + (address & 4095)];
        if (address == 0xE001) return 0x11;
        if (address == 0xE070 || address == 0xE071) return 0xff;
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
        if (address >= 0xD000 && address < 0xE000) {
            disk[size_t(high_page) * 4096 + (address & 4095)] = value;
            return;
        }
        if (address == 0xE010) return;
        if (address == 0xE070 || address == 0xE071) return;
        if (address == 0xE002) {
            page = value;
            low_page_zero_writes += value == 0;
            return;
        }
        if (address == 0xE003) {
            high_page = value;
            high_page_zero_writes += value == 0;
            return;
        }
        if (address == 0xE011) { output += char(value); return; }
        if (address == 0xE060) return;
        if (address >= 0xE000 && address < 0xE100)
            throw std::runtime_error("unexpected I/O write");
        ram[address] = value;
    }
};
int main(int argc, char **argv) {
    try {
        Bus bus(argc > 2 ? argv[2] : "../../../os/flex2/build/flex2.dsk");
        Cpu cpu(bus);
        const auto rom = file(argc > 1 ? argv[1] : "c68.rom");
        check(rom.size() == 8192, "ROM size");
        std::copy(rom.begin(), rom.end(), bus.ram.begin() + 0xE000);
        const uint16_t inwait = symbol(argc > 3 ? argv[3] :
                                       "../../../os/flex2/build/c68flex.lst", "C68INW");
        bus.page = 37;
        bus.high_page = 91;
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
        check(bus.low_page_zero_writes >= 2 && bus.high_page_zero_writes >= 2,
              "cold start or FLEX handoff did not select both SRAM page zeros");
        const auto startup = bus.output.find("C68 BIOS v0.01\r\nDave Hamilton 2026\r\n\r\nStarting OS...\r\n");
        check(startup != std::string::npos && startup < bus.output.find("+++"),
              "startup countdown missing before FLEX");
        check(bus.output.find("Build ") == std::string::npos,
              "build tag leaked into startup banner");
        const auto prompt_before_nmi = bus.output.rfind("+++");
        check(prompt_before_nmi != std::string::npos, "FLEX prompt missing before NMI");
        const uint16_t interrupted_sp = cpu.s_.sp;
        const uint8_t interrupted_low_page = bus.page;
        const uint8_t interrupted_high_page = bus.high_page;
        const unsigned low_page_writes = bus.low_page_zero_writes;
        const unsigned high_page_writes = bus.high_page_zero_writes;
        std::array<uint8_t, 0x22> interrupted_zero_page{};
        std::array<uint8_t, 0x100> interrupted_input_ram{};
        std::copy_n(bus.ram.begin(), interrupted_zero_page.size(),
                    interrupted_zero_page.begin());
        std::copy_n(bus.ram.begin() + 0x100, interrupted_input_ram.size(),
                    interrupted_input_ram.begin());
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
        check(bus.page == interrupted_low_page &&
              bus.high_page == interrupted_high_page &&
              bus.low_page_zero_writes == low_page_writes &&
              bus.high_page_zero_writes == high_page_writes,
              "NMI monitor changed the SRAM page selection");
        check(bus.output.find("+++\r\nC68 BIOS v0.01", prompt_before_nmi) ==
              prompt_before_nmi, "NMI banner did not start on the next line");
        check(bus.output.find("Dave Hamilton 2026\r\n(Interrupt)\r\n:",
                              prompt_before_nmi) != std::string::npos,
              "NMI marker is not immediately before the first monitor prompt");
        const uint16_t monitor_sp = cpu.s_.sp;
        const uint16_t monitor_pc = cpu.s_.pc;
        const size_t output_before_nested_nmi = bus.output.size();
        cpu.requestNmi();
        cpu.step();
        for (unsigned step = 0; step < 10 && cpu.s_.pc != monitor_pc; ++step)
            cpu.step();
        check(cpu.s_.pc == monitor_pc && cpu.s_.sp == monitor_sp &&
              bus.output.size() == output_before_nested_nmi,
              "nested NMI did not return to the monitor");
        const size_t before_resume = bus.output.size();
        const std::string resume = "R\r";
        size_t resume_key = 0;
        bool resumed = false;
        for (unsigned step = 0; step < 100000; ++step) {
            if (bus.input < 0 && resume_key < resume.size())
                bus.input = uint8_t(resume[resume_key++]);
            cpu.step();
            if (resume_key == resume.size() && bus.input < 0 &&
                cpu.s_.pc == inwait) { resumed = true; break; }
        }
        check(resumed && cpu.s_.sp == interrupted_sp,
              "R did not restore FLEX's NMI stack frame");
        check(std::equal(interrupted_zero_page.begin(), interrupted_zero_page.end(),
                         bus.ram.begin()) &&
              std::equal(interrupted_input_ram.begin(), interrupted_input_ram.end(),
                         bus.ram.begin() + 0x100),
              "NMI monitor changed FLEX's low RAM");
        check(bus.output.find("Starting OS", before_resume) == std::string::npos,
              "R rebooted instead of resuming FLEX");

        const size_t before_second_nmi = bus.output.size();
        cpu.requestNmi();
        cpu.step();
        bool second_monitor = false;
        for (unsigned step = 0; step < 100000; ++step) {
            cpu.step();
            if (bus.output.find("C68 BIOS v0.01", before_second_nmi) !=
                    std::string::npos && bus.output.back() == ':') {
                second_monitor = true;
                break;
            }
        }
        check(second_monitor, "second NMI did not re-enter monitor");
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
        check(bus.low_page_zero_writes >= 3 && bus.high_page_zero_writes >= 3,
              "monitor F command did not select both SRAM page zeros");

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
        check(bus.page == 0 && bus.high_page == 0,
              "FLEX MON did not select both SRAM page zeros");
        const size_t before_reset = bus.output.size();
        bus.page = 37;
        bus.high_page = 91;
        cpu.reset();
        bool reset_entered = false;
        for (unsigned step = 0; step < 100000; ++step) {
            cpu.step();
            if (bus.output.find("C68 BIOS v0.01", before_reset) != std::string::npos &&
                bus.output.back() == ':') { reset_entered = true; break; }
        }
        check(reset_entered, "warm hardware reset did not enter monitor promptly");
        check(bus.page == 0 && bus.high_page == 0,
              "warm hardware reset did not select both SRAM page zeros");

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
        monitor_command("R\r", "No interrupted program");
        for (unsigned i = 0; i < 18; ++i)
            bus.ram[0x300 + i] = uint8_t(0x11 + i);
        bus.ram[0x300] = 0xC1; // high bit strips to printable 'A'
        bus.ram[0x310] = 0xE1; // high bit strips to printable 'a'
        monitor_command("300\r", "0300: C1\r\n");
        monitor_command("300.311\r",
                        "0300: C1 12 13 14 15 16 17 18"
                        " 19 1A 1B 1C 1D 1E 1F 20  | A" +
                        std::string(15, ' ') + "\r\n"
                        "0310: E1 22" + std::string(42, ' ') +
                        "  | a\"\r\n");
        monitor_command("F800\r", "F800: 00\r\n");
        monitor_command("300.2FF\r", "Unknown command");
        const size_t help_start=bus.output.size();
        monitor_command("H\r", "addressU            - Enter binary upload mode");
        check(std::regex_search(bus.output.substr(help_start),
              std::regex(R"(C68 BIOS v0\.01\r\nDave Hamilton 2026\r\nBuild [0-9]{8} [0-9a-f]{8}\r\n\r\nH \(\?\))")),
              "help header, build tag, or blank line is wrong");
        check(bus.output.find(
                  "H (?)               - Display help\r\n"
                  "F                   - Boot FLEX from SRAM\r\n"
                  "R                   - Resume after NMI\r\n"
                  "address             - Examine one byte\r\n"
                  "start.end           - Examine inclusive range\r\n"
                  "address: bytes      - Write hex bytes to memory\r\n"
                  ": bytes             - Continue at next address\r\n"
                  "addressG            - Run code (RTS returns here)\r\n"
                  "addressU            - Enter binary upload mode\r\n",
                  help_start) != std::string::npos,
              "help columns or command descriptions are wrong");
        monitor_command("400: 86 2A B7 05 00 39\r", ":");
        check(std::equal(bus.ram.begin()+0x400, bus.ram.begin()+0x406,
                         std::array<uint8_t,6>{0x86,0x2a,0xb7,0x05,0x00,0x39}.begin()),
              "address deposit wrote incorrect bytes");
        monitor_command(": 12 34\r", ":");
        check(bus.ram[0x406]==0x12 && bus.ram[0x407]==0x34,
              "continuation deposit used wrong address");
        monitor_command("500:\r", ":");
        monitor_command("300\r", "0300: C1\r\n");
        monitor_command(": AA BB\r", ":");
        check(bus.ram[0x500]==0xaa && bus.ram[0x501]==0xbb,
              "empty address deposit did not set continuation");
        const uint8_t before_invalid=bus.ram[0x400];
        monitor_command("400: 11 345\r", "Unknown command");
        check(bus.ram[0x400]==before_invalid,
              "invalid deposit partially changed memory");
        monitor_command("400G junk\r", "Unknown command");
        monitor_command("400G\r", ":");
        check(bus.ram[0x500]==0x2a,
              "G did not run code and return via RTS");

        // Drive the actual monitor through the ACIA, one byte at a time.
        auto exchange = [&](const std::string &packet, char response) {
            const size_t before = bus.output.size();
            size_t sent = 0;
            for (unsigned step = 0; step < 1000000; ++step) {
                if (bus.input < 0 && sent < packet.size())
                    bus.input = uint8_t(packet[sent++]);
                cpu.step();
                if (sent == packet.size() && bus.input < 0 &&
                    bus.output.size() > before && bus.output.back() == response)
                    return;
            }
            throw std::runtime_error("upload exchange timed out");
        };
        exchange("C000U\r", 'K');
        exchange(std::string("W\xE0\x02\x07", 4), 'K');
        check(bus.page == 7, "upload W did not select SRAM bank");
        exchange(std::string("A\xC0\x00", 3), 'K');
        auto crc_packet = [](const std::string &data) {
            uint16_t crc = 0xffff;
            for (unsigned char value : data) {
                crc ^= uint16_t(value) << 8;
                for (int bit = 0; bit < 8; ++bit)
                    crc = uint16_t((crc << 1) ^ ((crc & 0x8000) ? 0x1021 : 0));
            }
            std::string result = "B" + data;
            result += char(crc >> 8);
            result += char(crc & 0xff);
            return result;
        };
        std::string payload(1, '\0'); // zero encodes a 256-byte block
        for (int i = 0; i < 256; ++i) payload += char(i);
        std::string bad = crc_packet(payload);
        bad.back() ^= 1;
        const auto original = std::vector<uint8_t>(bus.disk.begin() + 7 * 4096,
                                                    bus.disk.begin() + 7 * 4096 + 256);
        exchange(bad, 'C');
        check(std::equal(original.begin(), original.end(),
                         bus.disk.begin() + 7 * 4096),
              "bad CRC changed SRAM");
        exchange(crc_packet(payload), 'K');
        for (int i = 0; i < 256; ++i)
            check(bus.disk[7 * 4096 + i] == i, "256-byte upload mismatch");
        exchange(crc_packet(std::string("\x01\xA5", 2)), 'K');
        check(bus.disk[7 * 4096 + 256] == 0xa5,
              "block did not advance target by 256 bytes");
        exchange("Q", 'K');
        for (unsigned step = 0; step < 10000 && bus.output.back() != ':'; ++step)
            cpu.step();
        check(bus.output.back() == ':', "upload did not return to monitor");

        Bus key_bus(argc > 2 ? argv[2] : "../../../os/flex2/build/flex2.dsk");
        Cpu key_cpu(key_bus);
        std::copy(rom.begin(), rom.end(), key_bus.ram.begin() + 0xE000);
        key_cpu.reset();
        for (unsigned step = 0; step < 200000 &&
                 key_bus.output.find("Starting OS..") == std::string::npos; ++step)
            key_cpu.step();
        check(key_bus.output.find("Starting OS..") != std::string::npos &&
              key_bus.output.find("DATE (MM,DD,YY)") == std::string::npos,
              "startup key window did not wait through two dots");
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
        check(key_bus.output.find("Starting OS...") == std::string::npos,
              "startup key did not interrupt the countdown");
        check(key_bus.output.find("C68 BIOS v0.01",
              key_bus.output.find("C68 BIOS v0.01") + 1) == std::string::npos,
              "startup key printed the banner twice");

        Bus last_dot_bus(argc > 2 ? argv[2] : "../../../os/flex2/build/flex2.dsk");
        Cpu last_dot_cpu(last_dot_bus);
        std::copy(rom.begin(), rom.end(), last_dot_bus.ram.begin() + 0xE000);
        last_dot_cpu.reset();
        for (unsigned step = 0; step < 3000000 &&
                 last_dot_bus.output.find("Starting OS...") == std::string::npos;
             ++step)
            last_dot_cpu.step();
        check(last_dot_bus.output.find("Starting OS...") != std::string::npos &&
              last_dot_bus.output.find("DATE (MM,DD,YY)") == std::string::npos,
              "third startup dot did not leave a key window");
        last_dot_bus.input = 'x';
        bool last_dot_monitor = false;
        for (unsigned step = 0; step < 3000000; ++step) {
            last_dot_cpu.step();
            if (!last_dot_bus.output.empty() && last_dot_bus.output.back() == ':') {
                last_dot_monitor = true;
                break;
            }
        }
        check(last_dot_monitor && last_dot_bus.input < 0,
              "key after third dot did not enter the monitor");
        std::cout << "C68 BIOS boot, monitor examine, NMI, MON, and warm reset passed.\n";
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
