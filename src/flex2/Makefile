SHELL := /bin/bash

TOOLS_BIN_DIR := ../tools/bin
VASM_BIN := $(TOOLS_BIN_DIR)/vasm6800_oldstyle
VASM_STD_BIN := $(TOOLS_BIN_DIR)/vasm6800_std
Z68_SRC_DIR := ../z68
STORY_INPUTS := $(wildcard ../z68/stories ../z68/stories/*.[dD][aA][tT] ../z68/stories/*.[zZ]3)
Z68_SRCS := $(wildcard $(Z68_SRC_DIR)/*.s $(Z68_SRC_DIR)/*/*.s)
VASM_FLAGS := -maxerrors=0 -Fbin -ast -i
PYTHON := python3
CXX := c++
CC := cc
INFORM_SRC_DIR := ../tools/inform6
INFORM_SRCS := $(wildcard $(INFORM_SRC_DIR)/*.c $(INFORM_SRC_DIR)/*.h)
EMU_DIR := ../emu
BASIC_SRC := ../roms/basic680/c68basic.s
EMU_SRCS := $(wildcard $(EMU_DIR)/src/cpu/*.cpp $(EMU_DIR)/src/gen/*.g.cpp) $(addprefix $(EMU_DIR)/src/util/,symbols.cpp logging.cpp logBuffer.cpp)
EMU_HEADERS := $(wildcard $(EMU_DIR)/src/cpu/*.h $(EMU_DIR)/src/gen/*.g.h $(EMU_DIR)/src/util/*.h)

.PHONY: all clean image z68 rebuild-image verify-flex21 verify-image verify-opcodes test
all: verify-flex21 verify-opcodes verify-image

verify-opcodes:
	$(PYTHON) $(Z68_SRC_DIR)/tools/make-opcodes.py --check

build/flex21.asm: 6800Flex/FLEX21.ASM tools/prepare-flex21.py
	$(PYTHON) tools/prepare-flex21.py

build/flex21.bin: build/flex21.asm Makefile
	$(VASM_BIN) $(VASM_FLAGS) -L build/flex21.lst -o $@ $<

verify-flex21: build/flex21.bin 6800Flex/FLEX21.LST tools/verify-flex21.py
	$(PYTHON) tools/verify-flex21.py

build/c68flex.asm: build/flex21.asm tools/prepare-c68.py platform/console.asm platform/ramdisk.asm
	$(PYTHON) tools/prepare-c68.py

build/c68flex.bin: build/c68flex.asm Makefile
	$(VASM_BIN) $(VASM_FLAGS) -L build/c68flex.lst -o $@ $<

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

z68: image

build/flex2.dsk: build/c68flex.bin build/msbasic.bin build/boot.bin build/z68.bin build/CZECH.DAT build/VMBOOT.DAT build/VMFAIL.DAT build/VMLIMIT.DAT tools/mkimage.py tools/stories.py $(STORY_INPUTS) tools/disk_layout.py tools/source-disk.py 6800Flex/6800FLEX.DSK 6800Flex/6800UTL1.DSK 6800Flex/6800UTL2.DSK 6800Flex/GAMES_5.DSK 6800Flex/MYGAMES.DSK 6800Flex/XBASIC_1.DSK
	$(PYTHON) tools/mkimage.py

# Explicitly discard generated disk contents even if an emulator saved a newer file.
rebuild-image: build/c68flex.bin build/msbasic.bin build/boot.bin build/z68.bin build/CZECH.DAT build/VMBOOT.DAT build/VMFAIL.DAT build/VMLIMIT.DAT
	$(PYTHON) tools/mkimage.py
	$(PYTHON) tools/verify-image.py

# Regenerate co-produced files together if a standalone artifact was removed.
image: build/flex2.dsk
	@test -f build/FLEX2.SYS -a -f build/MSBASIC.CMD -a -f build/image.json || $(PYTHON) tools/mkimage.py

verify-image: image tools/verify-image.py
	$(PYTHON) tools/verify-image.py

build/smoke: tests/smoke.cpp tests/flex_harness.h tests/z68.h tests/random.h $(EMU_SRCS) $(EMU_HEADERS)
	@mkdir -p build
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/smoke.cpp $(EMU_SRCS) -o $@

build/acceptance: tests/acceptance.cpp tests/flex_harness.h $(EMU_SRCS) $(EMU_HEADERS)
	@mkdir -p build
	$(CXX) -std=c++17 -O2 -I$(EMU_DIR)/src tests/acceptance.cpp $(EMU_SRCS) -o $@

.PHONY: acceptance czech
acceptance: all build/acceptance
	./build/acceptance

# Deliberately red until the actual upstream suite completes successfully.
czech: acceptance
	$(PYTHON) $(Z68_SRC_DIR)/tests/check-czech.py build/acceptance.json

test: all build/smoke build/acceptance
	./build/smoke
	./build/acceptance
	$(PYTHON) tools/verify-image.py build/smoke.dsk

clean:
	rm -rf build
