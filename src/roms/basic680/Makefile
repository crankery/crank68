NAME := c68basic

SHELL := /bin/bash

TOOLS_DIR := ../../tools
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin

VASM := vasm6800_oldstyle
VASM_BIN := $(TOOLS_BIN_DIR)/$(VASM)

ORIG_NAME := basic680
ORIG := $(ORIG_NAME).asm

# changes to the ORIG disassembly for syntax changes only
SYNTAX_EDIT := $(ORIG_NAME).s
SYNTAX_DIFF := $(ORIG_NAME).diff
SYNTAX_SRC := $(ORIG_NAME)_syntax.asm
SYNTAX_BIN := $(ORIG_NAME)_syntax.bin
SYNTAX_LST := $(ORIG_NAME)_syntax.lst

# changes to the ORIG disassembly for syntax changes and other edits
C68_EDIT := $(NAME).s
C68_DIFF := $(NAME).diff
C68_ROM := $(NAME).rom
C68_SRC := $(NAME).asm
C68_LST := $(NAME).lst

# source binaries
ORIG_SREC := mits_raw_bin.srec
ORIG_BIN := mits_raw.bin

.PHONY: all clean diff verify-syntax

all: verify-syntax $(ORIG_BIN) $(DIFF) $(SYNTAX_SRC) $(SYNTAX_DIFF) $(C68_SRC) $(C68_DIFF) $(C68_ROM) $(SYNTAX_BIN)

verify-syntax: basic680_syntax.bin mits_raw.bin
	cmp basic680_syntax.bin mits_raw.bin

# apply the syntax edits to the original disassembly and create a new source
# file with the syntax changes only, then diff that against the original to create a patch file for the syntax
$(SYNTAX_DIFF): $(SYNTAX_EDIT) $(ORIG)
	-diff -u $(ORIG) $(SYNTAX_EDIT) > $(SYNTAX_DIFF)

$(SYNTAX_SRC): $(ORIG) $(SYNTAX_DIFF)
	rm -f $(SYNTAX_SRC)
	cp $(ORIG) $(SYNTAX_SRC)
	patch -p0 $(SYNTAX_SRC) < $(SYNTAX_DIFF)

# apply the C68 edits to the updated syntax source and create a new source file with the C68 edits
# then diff that against the syntax source to create a patch file for the C68 edits
$(C68_DIFF): $(C68_EDIT) $(SYNTAX_SRC)
	-diff -u $(SYNTAX_SRC) $(C68_EDIT) > $(C68_DIFF)

$(C68_SRC): $(SYNTAX_SRC) $(C68_DIFF)
	rm -f $(C68_SRC)
	cp $(SYNTAX_SRC) $(C68_SRC)
	patch -p0 $(C68_SRC) < $(C68_DIFF)

$(ORIG_BIN): $(ORIG_SREC)
	srec_cat $(ORIG_SREC) -Motorola -offset 0x0000 -o $(ORIG_BIN) -binary
	dd if=/dev/zero of=$@ bs=1 seek=$$(stat -f%z mits_raw.bin) count=0

$(C68_ROM): $(C68_SRC) | 
	$(VASM_BIN) -maxerrors=0 -Fbin -L $(C68_LST) -o $@ $<

$(SYNTAX_BIN): $(SYNTAX_SRC) |
	$(VASM_BIN) -maxerrors=0 -Fbin -L $(SYNTAX_LST) -o $@ $<

clean:
	rm -rf $(ORIG_BIN)
	rm -rf $(C68_SRC) $(C68_DIFF) $(C68_LST) $(C68_ROM)
	rm -rf $(SYNTAX_SRC) $(SYNTAX_DIFF) $(SYNTAX_LST) $(SYNTAX_BIN)