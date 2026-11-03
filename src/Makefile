PYTHON ?= python3
DRIVE_LAYOUT ?= sram-first
SD_VOLUME ?= $(if $(filter sd-first,$(DRIVE_LAYOUT)),0,1)
SRAM_SESSION := $(if $(filter sd-first,$(DRIVE_LAYOUT)),build/session-sram-sd-first.dsk,build/session.dsk)

.PHONY: all system test run session program-avr program-avr-dry-run program-avr-isp program-avr-isp-dry-run
all: system

# Keep the nested builds in order: FLEX builds the matching MIKBUG ROM.
system:
	$(MAKE) -C flex2 all DRIVE_LAYOUT=$(DRIVE_LAYOUT)
	$(MAKE) -C sd check
	$(MAKE) -C emu all
	$(PYTHON) tools/package-system.py --sd-volume $(SD_VOLUME) --drive-layout $(DRIVE_LAYOUT)

test: system
ifeq ($(DRIVE_LAYOUT),sd-first)
	$(MAKE) -C flex2 test-sd DRIVE_LAYOUT=$(DRIVE_LAYOUT)
else
	$(MAKE) -C roms/mikbug2 test
	$(MAKE) -C flex2 test DRIVE_LAYOUT=$(DRIVE_LAYOUT)
endif
	$(PYTHON) tools/test-sd-emu.py --drive-layout $(DRIVE_LAYOUT)
	$(MAKE) -C emu test

session: system
	$(PYTHON) tools/prepare-session.py --drive-layout $(DRIVE_LAYOUT)

run: session
	build/system/emu --load build/system/mikbug2.rom@E000 --sram-image $(SRAM_SESSION) --sd-image build/session-sd-$(DRIVE_LAYOUT).dsk $(if $(TCP_PORT),--tcp-console $(TCP_PORT)) $(if $(filter 1,$(TRACE)),--trace) $(if $(filter 1,$(THROTTLE)),--throttle)

# Only these explicit targets contact (or display commands for) the programmer.
program-avr: system
	$(PYTHON) sd/tools/program_avr.py --fuses build/system/avr-fuses.conf build/system/sd_bridge.hex

program-avr-dry-run: system
	$(PYTHON) sd/tools/program_avr.py --dry-run --fuses build/system/avr-fuses.conf build/system/sd_bridge.hex

program-avr-isp: system
	$(PYTHON) sd/tools/program_avr.py --icsp --fuses build/system/avr-fuses.conf build/system/sd_bridge.hex

program-avr-isp-dry-run: system
	$(PYTHON) sd/tools/program_avr.py --dry-run --icsp --fuses build/system/avr-fuses.conf build/system/sd_bridge.hex
