SHELL := /bin/bash

# Motorola mikbug2
NAME := mikbug2

TOOLS_DIR := ../../tools
VASM_DIR := $(TOOLS_DIR)/vasm
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
VASM := $(TOOLS_BIN_DIR)/vasm6800_std

SRC := $(NAME).asm
BIN := $(NAME).bin
ROM := $(NAME).rom
LST := $(NAME).lst

all: $(ROM)

# asemble the source
$(BIN): $(SRC) $(VASM)
	$(VASM) -Fbin -L $(LST) -o $@ $<

# rip the last 2KB of the output of assembly out as the .ROM
$(ROM): $(BIN)
	dd if=$(BIN) of=$(ROM) bs=1024 skip=22 count=2

# build vasm
$(VASM):
	$(MAKE) -C $(TOOLS_DIR)

clean:
	rm -rf $(ROM) $(LST) $(BIN)

.PHONY: all clean
