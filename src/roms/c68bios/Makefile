SHELL := /bin/bash

# C6800 BIOS
NAME := c68

TOOLS_DIR := ../../tools
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

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OUTS) $(LINKER_SCRIPT)
	$(VLINK_BIN) -b rawbin -T $(LINKER_SCRIPT) -M$(NAME).map -o $(TARGET) $(OUTS)

%.o: %.s | 
	$(VASM_BIN) -Fvobj -L $(@:.o=.lst) -o $@ $<
	cat $(@:.o=.lst)

$(VLINK_BIN) $(VASM_BIN):
	$(MAKE) -C $(TOOLS_DIR)

clean:
	rm -rf $(TARGET) $(LSTS) $(OUTS)