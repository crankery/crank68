SHELL := /bin/bash

NAME := mikbug2
ROM_VERSION ?= 1
SOUND_BOARD_REV ?= 1
ifneq ($(filter $(SOUND_BOARD_REV),1 2),$(SOUND_BOARD_REV))
$(error SOUND_BOARD_REV must be 1 or 2)
endif

TOOLS_DIR := ../../tools
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin

VASM := vasm6800_std
VASM_BIN := $(TOOLS_BIN_DIR)/$(VASM)

SRC := $(NAME).s
LST := $(NAME).lst

TARGET := $(NAME).rom

.PHONY: all clean test

all: $(TARGET)

test: $(TARGET)
	python3 tests/boot.py

$(TARGET): $(SRC) sdcard.s sound.s help.s build/sound-board.cfg build/rom-id.s
	$(VASM_BIN) -DSOUND_BOARD_REV=$(SOUND_BOARD_REV) -Fbin -L $(LST) -o $@ $<
	cat $(LST)

.PHONY: force-rom-id force-sound-board
force-rom-id:

build/rom-id.s: force-rom-id tools/rom_id.py
	python3 tools/rom_id.py --output $@ --version "$(ROM_VERSION)" --sound-rev "$(SOUND_BOARD_REV)"

force-sound-board:

build/sound-board.cfg: force-sound-board
	@mkdir -p build
	@printf '%s\n' $(SOUND_BOARD_REV) > $@.tmp
	@cmp -s $@.tmp $@ || mv $@.tmp $@
	@rm -f $@.tmp

clean:
	rm -rf $(TARGET) $(LST)
