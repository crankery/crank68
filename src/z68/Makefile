# Build the FLEX command and package it in the C68 SRAM disk image.
# Keep all generated artifacts in the FLEX build directory.
.PHONY: all test acceptance czech clean
all:
	$(MAKE) -C ../flex2 z68

test:
	$(MAKE) -C ../flex2 test

acceptance:
	$(MAKE) -C ../flex2 acceptance

czech:
	$(MAKE) -C ../flex2 czech

clean:
	$(RM) ../flex2/build/z68.bin ../flex2/build/z68.lst ../flex2/build/Z68.CMD
