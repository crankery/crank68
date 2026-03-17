SHELL := /bin/bash

VASM_DIR := vasm
TOOLS_DIR := ../bin
VASM := $(VASM_DIR)/${TOOLS_DIR}/vasm6800_oldstyle
VASM_MOT := $(VASM_DIR)/${TOOLS_DIR}/vasm6800_mot

BIOS_SRC := bios.asm
BIOS_OUT_BIN := bios.bin

.PHONY: all clean tools

all: $(OUT_BIN)

$(OUT_BIN): $(SRC) $(VASM)
	$(VASM) -Fbin -L bios.lst -o $@ $<

# Ensure tools exist
tools: $(VASM)

# Build vasm if missing
$(VASM):
	$(MAKE) -C $(VASM_DIR) CPU=6800 SYNTAX=oldstyle

clean:
	rm -rf $(TOOLS_DIR)