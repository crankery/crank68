SRC_DIR := src

BUILD_DIR := build

OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin

GEN_DIR := $(SRC_DIR)/gen
GENERATOR := $(GEN_DIR)/cpu_codegen.py

# Compiler
CXX := g++

# Python
PYTHON := python3

# Compiler flags
CXXFLAGS := -std=c++17 -Wall -O2 -Imame -g -I$(SRC_DIR) -MMD -MP

# Target executable
TARGET := $(BIN_DIR)/emu

# Default target
all: $(TARGET)

GEN_TEMPLATES = $(wildcard $(GEN_DIR)/*.in)
GEN_INPUTS = $(GEN_DIR)/cpu_operations.csv
GEN_OUTS_CPP = $(GEN_DIR)/cpu_defs.g.cpp $(GEN_DIR)/cpu_dispatch.g.cpp
GEN_OUTS_H = $(GEN_DIR)/cpu_defs.g.h $(GEN_DIR)/cpu_operations.g.h
GEN_OUTS = $(GEN_OUTS_CPP) $(GEN_OUTS_H)

$(GEN_OUTS): $(GENERATOR) ${GEN_TEMPLATES} ${GEN_INPUTS}
	$(PYTHON) $(GENERATOR)

$(GEN_OUTS_CPP:.cpp=.o): $(GEN_OUTS)

# Source files
SRCS = $(shell find src -name '*.cpp' ! -path '$(GEN_DIR)/*') $(GEN_OUTS_CPP)

# Header files
DOT_HS = $(shell find src -name '*.h')

# Object files
OBJS = $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

# Linker
$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

# Compile
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp $(GEN_OUTS_H)
	@mkdir -p $(dir $@)
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

DEPS := $(OBJS:.o=.d)

-include $(DEPS)

.PHONY: all clean generated
