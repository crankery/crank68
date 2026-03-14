SHELL := /bin/bash

TOOLS_DIR := tools
VASM_DIR := $(TOOLS_DIR)/vasm
VASM := $(VASM_DIR)/vasm6800_oldstyle

SRC := bios.asm
OUT_BIN := bios.bin

.PHONY: all clean tools

all: $(OUT_BIN)

$(OUT_BIN): $(SRC) $(VASM)
	$(VASM) -Fbin -L bios.lst -o $@ $<

# Ensure tools exist
tools: $(VASM)

# Build vasm if missing
$(VASM):
	mkdir -p $(TOOLS_DIR)
	cd $(TOOLS_DIR) && \
	if [ ! -d vasm ]; then \
		wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz && \
		tar -xf vasm.tar.gz && \
		rm -f vasm.tar.gz; \
	fi
	$(MAKE) -C $(VASM_DIR) CPU=6800 SYNTAX=oldstyle

clean:
	rm -rf $(TOOLS_DIR)