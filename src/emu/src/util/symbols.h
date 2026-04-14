#pragma once

#include <cstdint>
#include <fstream>
#include <optional>
#include <regex>
#include <string>
#include <unordered_map>
#include <vector>

struct Symbol
{
    std::string name;
    char kind;
    uint16_t value;
};

class Symbols
{
public:
    bool load(std::string_view filename);
    const std::vector<Symbol> *lookup(uint16_t value) const;

private:
    std::unordered_map<std::string, Symbol> by_name_;
    std::unordered_map<uint16_t, std::vector<Symbol>> by_value_;
};