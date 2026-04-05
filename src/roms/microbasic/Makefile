SHELL := /bin/bash

# TSC MICRO BASIC PLUS
NAME := microbas

TOOLS_DIR := ../../tools
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin

VASM := vasm6800_std
VASM_BIN := $(TOOLS_BIN_DIR)/$(VASM)

PYTHON := python3
TRANSLATE := translate.py

ORIG := microbas.asm
SRC := microbas.s
OUT := $(SRC:%.s=%.o)
LST := $(SRC:%.s=%.lst)

TARGET := microbas.o

.PHONY: all clean

all: $(TARGET)

$(SRC): $(TRANSLATE) $(ORIG)
	$(PYTHON) $(TRANSLATE) $(ORIG) > $(SRC)

%.o: %.s | 
	$(VASM_BIN) -Fvobj -L $(@:.o=.lst) -o $@ $<
	cat $(@:.o=.lst)

clean:
	rm -rf $(TARGET) $(LST) $(OUT) $(SRC)