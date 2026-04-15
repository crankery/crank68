NAME := c68basic

SHELL := /bin/bash

TOOLS_DIR := ../../tools
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin

VASM := vasm6800_oldstyle
VASM_BIN := $(TOOLS_BIN_DIR)/$(VASM)

BASE := basic680.asm
PATCH := c68basic.diff
SRC := $(NAME).asm
LST := $(NAME).lst

ORIG_SREC := mits_raw_bin.srec
ORIG_BIN := mits_raw.bin

TARGET := $(NAME).rom

.PHONY: all clean

all: $(TARGET) $(ORIG_BIN)

$(SRC): $(BASE) $(PATCH)
	rm -f $(SRC)
	cp $(BASE) $(SRC)
	patch -p0 $(SRC) < $(PATCH)

$(TARGET): $(SRC) | 
	$(VASM_BIN) -maxerrors=0 -Fbin -L $(LST) -o $@ $<
	dd if=/dev/zero of=$@ bs=1 seek=$$(stat -f%z mits_raw.bin) count=0
	# cat $(LST)

$(ORIG_BIN): $(ORIG_SREC)
	srec_cat $(ORIG_SREC) -Motorola -offset 0x0000 -o $(ORIG_BIN) -binary

clean:
	rm -rf $(TARGET) $(LST) $(SRC)