# Build the FLEX command and package it in the C68 SRAM disk image.
# Keep all generated artifacts in the FLEX build directory.
.PHONY: all test acceptance czech zork clean
all:
	$(MAKE) -C ../../os/flex2 z68

test:
	$(MAKE) -C ../../os/flex2 test

acceptance:
	$(MAKE) -C ../../os/flex2 acceptance

czech:
	$(MAKE) -C ../../os/flex2 czech

zork:
	$(MAKE) -C ../../os/flex2 zork

clean:
	$(RM) ../../os/flex2/build/z68.bin ../../os/flex2/build/z68.lst ../../os/flex2/build/Z68.CMD
