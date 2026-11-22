SHELL := /bin/bash

TOOLS_BIN_DIR := ../../tools/bin
VASM_BIN := $(TOOLS_BIN_DIR)/vasm6800_oldstyle
VASM_STD_BIN := $(TOOLS_BIN_DIR)/vasm6800_std
Z68_SRC_DIR := ../../apps/z68
VERA_SRC_DIR := ../../_deprecated/vera
STORY_INPUTS := $(wildcard ../../apps/z68/stories ../../apps/z68/stories/*.[dD][aA][tT] ../../apps/z68/stories/*.[zZ]3)
Z68_SRCS := $(wildcard $(Z68_SRC_DIR)/*.s $(Z68_SRC_DIR)/*/*.s)
VASM_FLAGS := -maxerrors=0 -Fbin -ast -i
PYTHON := python3
DRIVE_LAYOUT ?= sram-first
SOUND_BOARD_REV ?= 1
ifneq ($(filter $(SOUND_BOARD_REV),1 2),$(SOUND_BOARD_REV))
$(error SOUND_BOARD_REV must be 1 or 2)
endif
SD_TEST_VOLUME := $(if $(filter sd-first,$(DRIVE_LAYOUT)),0,1)
CXX := c++
CC := cc
INFORM_SRC_DIR := ../../tools/inform6
INFORM_SRCS := $(wildcard $(INFORM_SRC_DIR)/*.c $(INFORM_SRC_DIR)/*.h)
EMU_DIR := ../../emu
BASIC_SRC := ../../apps/basic680/c68basic.s
EMU_SRCS := $(wildcard $(EMU_DIR)/src/cpu/*.cpp $(EMU_DIR)/src/gen/*.g.cpp) $(addprefix $(EMU_DIR)/src/util/,symbols.cpp logging.cpp logBuffer.cpp)
EMU_HEADERS := $(wildcard $(EMU_DIR)/src/cpu/*.h $(EMU_DIR)/src/gen/*.g.h $(EMU_DIR)/src/util/*.h)

.PHONY: all clean image z68 rebuild-image verify-flex21 verify-image verify-opcodes test
all: rom verify-flex21 verify-opcodes verify-image

.PHONY: rom
rom:
	$(MAKE) -C ../../hw/roms/mikbug2 SOUND_BOARD_REV=$(SOUND_BOARD_REV)

verify-opcodes:
	$(PYTHON) $(Z68_SRC_DIR)/tools/make-opcodes.py --check

build/flex21.asm: 6800Flex/FLEX21.ASM tools/prepare-flex21.py
	$(PYTHON) tools/prepare-flex21.py

build/flex21.bin: build/flex21.asm Makefile
	$(VASM_BIN) $(VASM_FLAGS) -L build/flex21.lst -o $@ $<

verify-flex21: build/flex21.bin 6800Flex/FLEX21.LST tools/verify-flex21.py
	$(PYTHON) tools/verify-flex21.py

.PHONY: force-drive-config
force-drive-config:

build/drive-config.asm: force-drive-config tools/drive_config.py
	$(PYTHON) tools/drive_config.py $(DRIVE_LAYOUT)

build/drive-config.h: build/drive-config.asm
	@test -f $@ || $(PYTHON) tools/drive_config.py $(DRIVE_LAYOUT)

build/c68flex.asm: build/flex21.asm tools/prepare-c68.py platform/console.asm platform/sound.asm platform/rtc.asm platform/ramdisk.asm platform/sdcard.asm platform/cmdcase.asm build/drive-config.asm
	$(PYTHON) tools/prepare-c68.py

build/c68flex.bin: build/c68flex.asm build/sound-board.cfg Makefile
	$(VASM_BIN) $(VASM_FLAGS) -DSOUND_BOARD_REV=$(SOUND_BOARD_REV) -L build/c68flex.lst -o $@ $<

.PHONY: force-sound-board
force-sound-board:

build/sound-board.cfg: force-sound-board
	@mkdir -p build
	@printf '%s\n' $(SOUND_BOARD_REV) > $@.tmp
	@cmp -s $@.tmp $@ || mv $@.tmp $@
	@rm -f $@.tmp

build/msbasic.asm: $(BASIC_SRC) tools/prepare-msbasic.py
	@mkdir -p build
	$(PYTHON) tools/prepare-msbasic.py $(BASIC_SRC)

build/msbasic.bin: build/msbasic.asm Makefile
	$(VASM_BIN) -Fbin -maxerrors=0 -L build/msbasic.lst -o $@ $<

build/boot.bin: platform/boot.asm Makefile
	@mkdir -p build
	$(VASM_BIN) $(VASM_FLAGS) -L build/boot.lst -o $@ $<

build/inform6: $(INFORM_SRCS)
	@mkdir -p build
	$(CC) -O2 -o $@ $(wildcard $(INFORM_SRC_DIR)/*.c)

build/CZECH.DAT: $(Z68_SRC_DIR)/tests/czech/czech.inf build/inform6
	./build/inform6 -v3 $< $@

build/VMBOOT.DAT: $(Z68_SRC_DIR)/tests/make-vm-fixtures.py
	@mkdir -p build
	$(PYTHON) $<

build/VMFAIL.DAT build/VMLIMIT.DAT: build/VMBOOT.DAT
	@test -f $@ || $(PYTHON) $(Z68_SRC_DIR)/tests/make-vm-fixtures.py

build/z68.bin: $(Z68_SRCS) Makefile
	@mkdir -p build
	$(VASM_STD_BIN) -I$(Z68_SRC_DIR)/hardware -I$(Z68_SRC_DIR)/app -I$(Z68_SRC_DIR)/z -Fbin -L build/z68.lst -o $@ $(Z68_SRC_DIR)/z68.s

.PHONY: vera
vera: image

.PHONY: video-demo
video-demo: build/video_demo.bin

$(VERA_SRC_DIR)/font.bin: $(VERA_SRC_DIR)/make-font.py ../../_deprecated/terminal/picodvi/software/assets/font_8x8.h
	$(PYTHON) $(VERA_SRC_DIR)/make-font.py

build/vera.bin: $(VERA_SRC_DIR)/terminal.s $(VERA_SRC_DIR)/keyboard.s $(VERA_SRC_DIR)/font.bin Makefile
	@mkdir -p build
	$(VASM_STD_BIN) -I$(VERA_SRC_DIR) -Fbin -L build/vera.lst -o $@ $(VERA_SRC_DIR)/terminal.s

build/boop.bin: platform/boop.s Makefile
	@mkdir -p build
	$(VASM_STD_BIN) -Fbin -L build/boop.lst -o $@ $<

build/rogue.bin: ../../apps/rogue/rogue.s Makefile
	@mkdir -p build
	$(VASM_STD_BIN) -Fbin -L build/rogue.lst -o $@ $<

../../apps/ladder/flex/easy_street.inc: ../../apps/ladder/tools/make_levels.py ../../apps/ladder/Ladder/src/ladicons.pas
	$(PYTHON) ../../apps/ladder/tools/make_levels.py

build/ladder.bin: ../../apps/ladder/flex/ladder.s ../../apps/ladder/flex/menu.inc ../../apps/ladder/flex/highscore.inc ../../apps/ladder/flex/rocks.inc $(addprefix ../../apps/ladder/,$(LEVEL_INCS)) Makefile
	@mkdir -p build
	$(VASM_STD_BIN) -I../../apps/ladder/flex -Fbin -L build/ladder.lst -o $@ $<

build/video_demo.bin: platform/video_demo.s Makefile
	@mkdir -p build
	$(VASM_STD_BIN) -Fbin -L build/video_demo.lst -o $@ $<

z68: image

build/flex2.dsk: build/c68flex.bin build/msbasic.bin build/boot.bin build/z68.bin build/vera.bin build/boop.bin build/rogue.bin build/ladder.bin build/CZECH.DAT build/VMBOOT.DAT build/VMFAIL.DAT build/VMLIMIT.DAT tools/mkimage.py ../../apps/rogue/generate_floors.py tools/stories.py $(STORY_INPUTS) tools/disk_layout.py tools/source-disk.py 6800Flex/6800FLEX.DSK 6800Flex/6800UTL1.DSK 6800Flex/6800UTL2.DSK 6800Flex/GAMES_5.DSK 6800Flex/MYGAMES.DSK 6800Flex/XBASIC_1.DSK
	$(PYTHON) tools/mkimage.py

# Explicitly discard generated disk contents even if an emulator saved a newer file.
rebuild-image: build/c68flex.bin build/msbasic.bin build/boot.bin build/z68.bin build/vera.bin build/boop.bin build/rogue.bin build/ladder.bin build/CZECH.DAT build/VMBOOT.DAT build/VMFAIL.DAT build/VMLIMIT.DAT
	$(PYTHON) tools/mkimage.py
	$(PYTHON) tools/verify-image.py

# Regenerate co-produced files together if a standalone artifact was removed.
image: build/flex2.dsk
	@test -f build/FLEX2.SYS -a -f build/MSBASIC.CMD -a -f build/image.json || $(PYTHON) tools/mkimage.py

verify-image: image tools/verify-image.py
	$(PYTHON) tools/verify-image.py

build/smoke: tests/smoke.cpp tests/flex_harness.h tests/z68.h tests/random.h tests/vars.h tests/input.h tests/status.h tests/dict.h tests/wrap.h tests/memory.h $(EMU_SRCS) $(EMU_HEADERS)
	@mkdir -p build
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/smoke.cpp $(EMU_SRCS) -o $@

build/story-runner: tests/story-runner.cpp tests/flex_harness.h $(EMU_SRCS) $(EMU_HEADERS)
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/story-runner.cpp $(EMU_SRCS) -o $@

build/rogue-test: tests/rogue.cpp tests/flex_harness.h $(EMU_SRCS) $(EMU_HEADERS)
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/rogue.cpp $(EMU_SRCS) -o $@

build/ladder-test: tests/ladder.cpp tests/flex_harness.h $(EMU_SRCS) $(EMU_HEADERS)
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/ladder.cpp $(EMU_SRCS) -o $@

.PHONY: ladder-test
ladder-test: image build/ladder-test
	./build/ladder-test build/ladder.bin build/ladder.lst

.PHONY: rogue-test
rogue-test: image build/rogue-test
	./build/rogue-test

.PHONY: zork
zork: all build/story-runner
	./build/story-runner ZORK1 --expect-prompt

build/acceptance: tests/acceptance.cpp tests/flex_harness.h $(EMU_SRCS) $(EMU_HEADERS)
	@mkdir -p build
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/acceptance.cpp $(EMU_SRCS) -o $@

.PHONY: acceptance czech
acceptance: all build/acceptance
	./build/acceptance

# Require the complete upstream automatic-test count after acceptance.
czech: acceptance
	$(PYTHON) $(Z68_SRC_DIR)/tests/check-czech.py build/acceptance.json

build/sd-driver: tests/sd-driver.cpp tests/flex_harness.h ../../hw/sd/firmware/instore_sd/src/protocol.h ../../hw/sd/firmware/instore_sd/src/direct_link.h build/drive-config.h $(EMU_SRCS) $(EMU_HEADERS)
	@mkdir -p build
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/sd-driver.cpp $(EMU_SRCS) -o $@

build/sd-test.dsk: build/flex2.dsk build/drive-config.asm ../../hw/sd/tools/extract_image.py
	$(PYTHON) ../../hw/sd/tools/extract_image.py --source build/flex2.dsk --drive $(SD_TEST_VOLUME) --output $@ --force

.PHONY: test-sd
test-sd: all build/sd-driver build/sd-test.dsk
	./build/sd-driver

test: all build/smoke build/acceptance build/sd-driver build/sd-test.dsk build/rogue-test build/ladder-test
	./build/sd-driver
	./build/smoke
	./build/acceptance
	./build/rogue-test
	./build/ladder-test build/ladder.bin build/ladder.lst
	$(PYTHON) tools/verify-image.py build/smoke.dsk

clean:
	rm -rf build
