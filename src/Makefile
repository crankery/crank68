PYTHON ?= python3
DRIVE_LAYOUT ?= sram-first
SOUND_BOARD_REV ?= 1
SD_VOLUME ?= $(if $(filter sd-first,$(DRIVE_LAYOUT)),0,1)
SRAM_SESSION := $(if $(filter sd-first,$(DRIVE_LAYOUT)),build/session-sram-sd-first.dsk,build/session.dsk)
GALASM := tools/GALasm/src/galasm
GALASM_SOURCES := $(wildcard tools/GALasm/src/*.c tools/GALasm/src/*.h tools/GALasm/src/Makefile)
GAL_SOURCES := $(wildcard hw/pld/*.gal)
GAL_JEDECS := $(patsubst hw/pld/%.gal,build/pld/%.jed,$(GAL_SOURCES))
GAL_FUSE_MAPS := $(patsubst hw/pld/%.gal,build/pld/%.fus,$(GAL_SOURCES))
GAL_PIN_REPORTS := $(patsubst hw/pld/%.gal,build/pld/%.pin,$(GAL_SOURCES))

.PHONY: all system pld fonts test run run-c68bios session program-avr program-avr-dry-run
all: system

$(GALASM): $(GALASM_SOURCES)
	$(MAKE) -C tools/GALasm/src galasm

# GALasm writes outputs beside its input. Assemble a copy under build/ so
# generated JEDEC, fuse and pin files never appear among the source files.
build/pld/%.jed build/pld/%.fus build/pld/%.pin: hw/pld/%.gal $(GALASM)
	@mkdir -p build/pld
	cp $< build/pld/$*.gal
	$(GALASM) build/pld/$*.gal

pld: $(GAL_JEDECS) $(GAL_FUSE_MAPS) $(GAL_PIN_REPORTS)

fonts:
	$(MAKE) -C hw/video/fonts all PYTHON=$(PYTHON)

# Keep the nested builds in order: FLEX builds the matching MIKBUG ROM.
system: pld fonts
	$(MAKE) -C os/flex2 all DRIVE_LAYOUT=$(DRIVE_LAYOUT) SOUND_BOARD_REV=$(SOUND_BOARD_REV)
	$(MAKE) -C hw/sd check
	$(MAKE) -C emu all
	$(PYTHON) tools/package-system.py --sd-volume $(SD_VOLUME) --drive-layout $(DRIVE_LAYOUT)

test: system
ifeq ($(DRIVE_LAYOUT),sd-first)
	$(MAKE) -C os/flex2 test-sd DRIVE_LAYOUT=$(DRIVE_LAYOUT) SOUND_BOARD_REV=$(SOUND_BOARD_REV)
else
	$(MAKE) -C hw/roms/mikbug2 test SOUND_BOARD_REV=$(SOUND_BOARD_REV)
	$(MAKE) -C os/flex2 test DRIVE_LAYOUT=$(DRIVE_LAYOUT) SOUND_BOARD_REV=$(SOUND_BOARD_REV)
endif
	$(PYTHON) tools/test-sd-emu.py --drive-layout $(DRIVE_LAYOUT)
	$(MAKE) -C emu test

session: system
	$(PYTHON) tools/prepare-session.py --drive-layout $(DRIVE_LAYOUT)

run: session
	build/system/emu --load build/system/mikbug2.rom@E000 --sram-image $(SRAM_SESSION) --sd-image build/session-sd-$(DRIVE_LAYOUT).dsk $(if $(TCP_PORT),--tcp-console $(TCP_PORT)) $(if $(filter 1,$(TRACE)),--trace) $(if $(filter 1,$(THROTTLE)),--throttle)

# Try the new C68 BIOS without changing the packaged MIKBUG default.
run-c68bios: session
	$(MAKE) -C hw/roms/c68bios all
	build/system/emu --load hw/roms/c68bios/c68.rom@E000 --sram-image $(SRAM_SESSION) --sd-image build/session-sd-$(DRIVE_LAYOUT).dsk $(if $(TCP_PORT),--tcp-console $(TCP_PORT)) $(if $(filter 1,$(TRACE)),--trace) $(if $(filter 1,$(THROTTLE)),--throttle)

# Only these explicit targets contact (or display commands for) the programmer.
program-avr: system
	$(PYTHON) hw/sd/tools/program_avr.py --fuses build/system/avr-fuses.conf build/system/instore_sd.hex

program-avr-dry-run: system
	$(PYTHON) hw/sd/tools/program_avr.py --dry-run --fuses build/system/avr-fuses.conf build/system/instore_sd.hex
