SHELL := /bin/bash

NAME := mikbug2

TOOLS_DIR := ../../tools
TOOLS_BIN_DIR := ${TOOLS_DIR}/bin

VASM := vasm6800_std
VASM_BIN := $(TOOLS_BIN_DIR)/$(VASM)

SRC := $(NAME).s
LST := $(NAME).lst

TARGET := $(NAME).rom

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC) | 
	$(VASM_BIN) -Fbin -L ${LST} -o $@ $<
	cat $(@:.o=.lst)

clean:
	rm -rf $(TARGET) ${LST} $(OUT) $(LST)