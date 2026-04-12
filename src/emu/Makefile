BUILD_DIR = build
GENERATOR = cpu_codegen.py

# todo: build the bios header
# xxd -i ../roms/c68bios/bios.rom bios.h

# Compiler
CXX = g++

# Python
PYTHON = python3

# Compiler flags
CXXFLAGS = -std=c++17 -Wall -O2 -Imame -g

# Target executable
TARGET = $(BUILD_DIR)/emu

# Default target
all: $(TARGET)

GEN_TEMPLATES = $(wildcard *.in)
GEN_INPUTS = cpu_operations.csv
GEN_OUTS_CPP = cpu_defs.g.cpp cpu_dispatch.g.cpp
GEN_OUTS_H = cpu_defs.g.h cpu_operations.g.h
GEN_OUTS = $(GEN_OUTS_CPP) $(GEN_OUTS_H)
$(GEN_OUTS): $(GENERATOR) ${GEN_TEMPLATES} ${GEN_INPUTS}
	$(PYTHON) $(GENERATOR)

$(GEN_OUTS_CPP:.cpp=.o): $(GEN_OUTS)

# Source files (all .cpp in current directory)
SRCS = $(wildcard *.cpp)
DOT_HS = $(wildcard *.h)

# Object files
OBJS = $(SRCS:%.cpp=$(BUILD_DIR)/%.o)

# Linker
$(TARGET): $(OBJS) $(DOT_HS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

# Compile
${BUILD_DIR}/%.o: %.cpp | $(BUILD_DIR) $(GEN_OUTS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -rf $(BUILD_DIR) $(GEN_OUTS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

generated: ${GEN_OUTS}

regen:
	rm -f $(CPU_DEFS_H) $(CPU_DEFS_CPP)
	$(MAKE) generated

.PHONY: all clean generated
