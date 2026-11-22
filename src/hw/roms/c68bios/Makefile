SHELL := /bin/bash
PYTHON ?= python3

# C6800 BIOS
NAME := c68

TOOLS_DIR := ../../../tools
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin

VASM := vasm6800_std
VASM_BIN := $(TOOLS_BIN_DIR)/$(VASM)

VLINK := vlink
VLINK_BIN := $(TOOLS_BIN_DIR)/$(VLINK)

SRCS := $(filter-out defs.s, $(wildcard *.s))
OUTS := $(SRCS:%.s=%.o)
LSTS := $(SRCS:%.s=%.lst)

TARGET := $(NAME).rom
LINKER_SCRIPT = ${NAME}.ln
BUILD_SOURCES := $(wildcard *.s) $(LINKER_SCRIPT)

.PHONY: all clean test

all: $(TARGET)

EMU_DIR := ../../../emu/src
EMU_SRCS := $(wildcard $(EMU_DIR)/cpu/*.cpp) $(EMU_DIR)/gen/cpu_defs.g.cpp $(EMU_DIR)/gen/cpu_dispatch.g.cpp $(EMU_DIR)/util/symbols.cpp $(EMU_DIR)/util/logging.cpp $(EMU_DIR)/util/logBuffer.cpp

tests/boot: tests/boot.cpp $(EMU_SRCS)
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR) -o $@ $^

test: $(TARGET) tests/boot
	$(MAKE) -C ../../../os/flex2 image
	./tests/boot
	$(PYTHON) -m unittest discover -s tests -p 'test_upload.py'

$(TARGET): $(OUTS) $(LINKER_SCRIPT)
	$(VLINK_BIN) -b rawbin -T $(LINKER_SCRIPT) -M$(NAME).map -o $(TARGET) $(OUTS)

build_tag.inc: $(BUILD_SOURCES) tools/build_tag.py
	$(PYTHON) tools/build_tag.py $@ $(BUILD_SOURCES)

data.o: build_tag.inc

%.o: %.s | 
	$(VASM_BIN) -Fvobj -L $(@:.o=.lst) -o $@ $<
	cat $(@:.o=.lst)

$(VLINK_BIN) $(VASM_BIN):
	$(MAKE) -C $(TOOLS_DIR)

clean:
	rm -rf $(TARGET) $(LSTS) $(OUTS) tests/boot build_tag.inc
