PYTHON ?= python3
OUT := build
EX := $(OUT)/extract
MAP := $(OUT)/mapped
BASE := $(OUT)/base
ROLL := $(OUT)/rolled
BANK := $(OUT)/bank
ROM_ROW_ADDRESS_XOR := 3

FONTS := pet-ascii-graphics ega-8x8 spectrum atari osborne-8x8 \
         reserved reserved reserved \
         reserved reserved reserved reserved \
         reserved reserved reserved reserved
EXTRACTS := $(addprefix $(EX)/,$(addsuffix .bin,vt100 pet-graphics pet-business spectrum atari ega ega-8x8 alto osborne))
MAPPED := $(addprefix $(MAP)/,$(addsuffix .bin,vt100 pet-graphics pet-business pet-ascii pet-ascii-graphics spectrum atari ega ega-8x8 alto osborne osborne-8x8))
BASES := $(BASE)/atari.bin $(BASE)/osborne-8x8.bin $(BASE)/vt100.bin
ROLLED := $(ROLL)/vt100.bin
BANKS := $(addprefix $(BANK)/,$(addsuffix .bin,$(FONTS)))
SHEETS := $(EXTRACTS:.bin=.png) $(MAPPED:.bin=.png) \
          $(BASES:.bin=.png) $(ROLLED:.bin=.png) $(sort $(BANKS:.bin=.png))

.PHONY: all check clean
all: $(OUT)/fonts-28c256.bin $(OUT)/fonts-28c256.png $(SHEETS)

$(EX) $(MAP) $(BASE) $(ROLL) $(BANK):
	mkdir -p $@

$(EX)/vt100.bin: resources/vt100-23-018E2.bin tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py vt100 $< $@
$(EX)/pet-graphics.bin $(EX)/pet-business.bin: $(EX)/pet-%.bin: resources/cbm-pet.901447-08.bin tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py pet-$* $< $@
$(EX)/spectrum.bin: resources/sinclair-spectrum-48.rom tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py spectrum $< $@
$(EX)/atari.bin: resources/ATARIOSB.ROM tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py atari $< $@
$(EX)/ega.bin: resources/IBM-EGA.bin tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py ega $< $@
$(EX)/ega-8x8.bin: resources/IBM-EGA.bin tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py ega-8x8 $< $@
$(EX)/alto.bin: resources/SysFont.Al. tools/extract.py tools/decode_al_font.py | $(EX)
	$(PYTHON) tools/extract.py alto $< $@
$(EX)/osborne.bin: resources/OCC1_char.BIN tools/extract.py | $(EX)
	$(PYTHON) tools/extract.py osborne $< $@

$(EX)/vt100.png $(EX)/ega.png $(EX)/alto.png $(EX)/osborne.png: $(EX)/%.png: $(EX)/%.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height $(if $(filter vt100,$*),16,$(if $(filter ega,$*),14,$(if $(filter alto,$*),12,10))) -o $@
$(EX)/pet-graphics.png $(EX)/pet-business.png $(EX)/spectrum.png $(EX)/atari.png $(EX)/ega-8x8.png: $(EX)/%.png: $(EX)/%.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 8 -o $@

$(ROLL)/vt100.bin: $(EX)/vt100.bin tools/roll.py | $(ROLL)
	$(PYTHON) tools/roll.py $< $@ --height 16 --rows 2
$(BASE)/vt100.bin: $(ROLL)/vt100.bin patches/vt100.fontedit tools/fontedit.py | $(BASE)
	$(PYTHON) tools/fontedit.py build $< patches/vt100.fontedit --height 16 -o $@
$(MAP)/vt100.bin: $(BASE)/vt100.bin tools/shift.py | $(MAP)
	$(PYTHON) tools/shift.py $< $@ --height 16 --rows 2 --repeat-top
$(MAP)/ega.bin $(MAP)/ega-8x8.bin $(MAP)/osborne.bin: $(MAP)/%.bin: $(EX)/%.bin | $(MAP)
	cp $< $@
$(BASE)/osborne-8x8.bin: $(MAP)/osborne.bin tools/osborne8.py | $(BASE)
	$(PYTHON) tools/osborne8.py $< $@
$(MAP)/osborne-8x8.bin: $(BASE)/osborne-8x8.bin patches/osborne-8x8.fontedit tools/fontedit.py | $(MAP)
	$(PYTHON) tools/fontedit.py build $< patches/osborne-8x8.fontedit --height 8 -o $@
$(MAP)/pet-graphics.bin $(MAP)/pet-business.bin $(MAP)/spectrum.bin $(MAP)/alto.bin: $(MAP)/%.bin: $(EX)/%.bin tools/remap.py | $(MAP)
	$(PYTHON) tools/remap.py $* $< $@
$(BASE)/atari.bin: $(EX)/atari.bin tools/remap.py | $(BASE)
	$(PYTHON) tools/remap.py atari $< $@
$(MAP)/atari.bin: $(BASE)/atari.bin patches/atari.fontedit tools/fontedit.py | $(MAP)
	$(PYTHON) tools/fontedit.py build $< patches/atari.fontedit --height 8 -o $@
$(MAP)/pet-ascii.bin: $(MAP)/pet-business.bin patches/pet-ascii.fontedit tools/fontedit.py | $(MAP)
	$(PYTHON) tools/fontedit.py build $< patches/pet-ascii.fontedit --height 8 -o $@
$(MAP)/pet-ascii-graphics.bin: $(MAP)/pet-ascii.bin $(MAP)/pet-graphics.bin tools/combine.py | $(MAP)
	$(PYTHON) tools/combine.py $(MAP)/pet-ascii.bin $(MAP)/pet-graphics.bin $@
$(MAP)/vt100.png $(MAP)/ega.png $(MAP)/alto.png $(MAP)/osborne.png: $(MAP)/%.png: $(MAP)/%.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height $(if $(filter vt100,$*),16,$(if $(filter ega,$*),14,$(if $(filter alto,$*),12,10))) -o $@
$(MAP)/pet-graphics.png $(MAP)/pet-business.png $(MAP)/pet-ascii.png $(MAP)/pet-ascii-graphics.png $(MAP)/spectrum.png $(MAP)/atari.png $(MAP)/ega-8x8.png $(MAP)/osborne-8x8.png: $(MAP)/%.png: $(MAP)/%.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 8 -o $@
$(BASE)/atari.png $(BASE)/osborne-8x8.png: $(BASE)/%.png: $(BASE)/%.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 8 -o $@
$(BASE)/vt100.png: $(BASE)/vt100.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 16 -o $@
$(ROLL)/vt100.png: $(ROLL)/vt100.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 16 -o $@

$(BANK)/pet-ascii-graphics.bin $(BANK)/ega-8x8.bin $(BANK)/spectrum.bin $(BANK)/atari.bin $(BANK)/osborne-8x8.bin: $(BANK)/%.bin: $(MAP)/%.bin tools/bank.py | $(BANK)
	$(PYTHON) tools/bank.py $< $@ --height 8 --rows 8
$(BANK)/reserved.bin: Makefile | $(BANK)
	$(PYTHON) -c 'from pathlib import Path; Path("$@").write_bytes(bytes(2048))'
$(BANK)/%.png: $(BANK)/%.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 8 -o $@

$(OUT)/fonts-28c256.bin: $(BANKS) tools/assemble.py Makefile
	$(PYTHON) tools/assemble.py --row-address-xor $(ROM_ROW_ADDRESS_XOR) --glyph-height 8 $@ $(BANKS)
$(OUT)/fonts-28c256.png: $(OUT)/fonts-28c256.bin tools/fontview.py
	$(PYTHON) tools/fontview.py $< --height 8 --row-address-xor $(ROM_ROW_ADDRESS_XOR) -o $@

check: all
	$(PYTHON) tools/check.py --row-address-xor $(ROM_ROW_ADDRESS_XOR) $(OUT)/fonts-28c256.bin $(BANKS)

clean:
	rm -rf $(OUT)
