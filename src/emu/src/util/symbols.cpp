#include "symbols.h"
#include "machine/machine.h"

bool Symbols::load(std::string_view filename)
{
    int count = 0;
    std::ifstream in(std::string(filename).c_str());
    if (!in)
    {
        return false;
    }

    std::string line;
    bool in_by_name = false;

    std::regex re(R"(^(\S+)\s+([AS]):([0-9A-Fa-f]{4})\s*$)");

    while (std::getline(in, line))
    {
        if (line == "Symbols by name:")
        {
            in_by_name = true;
            continue;
        }

        if (line == "Symbols by value:")
        {
            break;
        }

        if (!in_by_name)
        {
            continue;
        }

        std::smatch m;
        if (!std::regex_match(line, m, re))
        {
            continue;
        }

        Symbol sym;
        sym.name = m[1].str();
        sym.kind = m[2].str()[0];
        sym.value = static_cast<uint16_t>(std::stoul(m[3].str(), nullptr, 16));

        by_name_[sym.name] = sym;
        by_value_[sym.value].push_back(sym);

        count++;
    }

    char buffer[256];
    snprintf(buffer, sizeof(buffer), "loaded %d symbols from %s\r\n", count, std::string(filename).c_str());
    Machine::instance().logging_.log(buffer);

    return true;
}

const std::vector<Symbol> *Symbols::lookup(uint16_t value) const
{
    auto it = by_value_.find(value);
    if (it == by_value_.end())
    {
        return nullptr;
    }

    return &it->second;
}
