SHELL := /bin/bash

# C6800 BIOS
NAME := c68

TOOLS_DIR := ../../tools
VASM_DIR := $(TOOLS_DIR)/vasm
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin
VASM := $(TOOLS_BIN_DIR)/vasm6800_oldstyle

SRC := ${NAME}.asm
ROM := ${NAME}.rom
LST := ${NAME}.lst

.PHONY: all clean

all: $(ROM)

$(ROM): $(SRC) $(VASM)
	$(VASM) -Fbin -L $(LST) -o $@ $<

# Build vasm
$(VASM):
	$(MAKE) -C $(TOOLS_DIR)

clean:
	rm -rf $(ROM) $(LST)