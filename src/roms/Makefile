SHELL := /bin/bash

VASM_DIR := vasm
TOOLS_DIR := ../tools/bin
VASM := $(TOOLS_DIR)/vasm6800_oldstyle
VASM_MOT := $(TOOLS_DIR)/vasm6800_mot

BIOS_SRC := bios/bios.asm
BIOS_OUT_BIN := bios/bios.bin
BIOS_OUT_LST := bios/bios.lst

.PHONY: all clean

all: $(BIOS_OUT_BIN)

$(BIOS_OUT_LST): $(BIOS_OUT_BIN)

$(BIOS_OUT_BIN): $(BIOS_SRC) $(VASM)
	$(VASM) -Fbin -L bios.lst -o $@ $<

# Ensure tools exist
tools: $(VASM)

# Build vasm if missing
$(VASM):
	$(MAKE) -C $(TOOLS_DIR)

clean:
	rm -rf $(BIOS_OUT_BIN) $(BIOS_OUT_LST)