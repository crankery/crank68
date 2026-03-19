BUILD_DIR = build
M6800_DEFS_H = m6800_defs.h
M6800_DEFS_CPP = m6800_defs.cpp
M6800_OPS_CSV = m6800_ops.csv
GENERATOR = m6800_defs_gen.py

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
all: $(M6800_DEFS) $(TARGET)

$(M6800_DEFS_H) $(M6800_DEFS_CPP): $(GENERATOR) $(M6800_OPS_CSV)
	$(PYTHON) $(GENERATOR) $(M6800_OPS_CSV) $(M6800_DEFS_H) $(M6800_DEFS_CPP)

$(M6800_DEFS_CPP:.cpp=.o): $(M6800_DEFS_CPP) $(M6800_DEFS_H)

# Source files (all .cpp in current directory)
SRCS = $(wildcard *.cpp)

# Object files
OBJS = $(SRCS:%.cpp=$(BUILD_DIR)/%.o)

# Links
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

# Compile
${BUILD_DIR}/%.o: %.cpp | ${BUILD_DIR}
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -rf $(BUILD_DIR) $(M6800_DEFS_H) $(M6800_DEFS_CPP)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

generated: $(M6800_DEFS_H) $(M6800_DEFS_CPP)

regen:
	rm -f $(M6800_DEFS_H) $(M6800_DEFS_CPP)
	$(MAKE) generated

.PHONY: all clean generated
