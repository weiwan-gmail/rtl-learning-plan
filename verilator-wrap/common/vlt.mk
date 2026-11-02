# Shared Verilator rules for verilator-wrap/* (not used by original iverilog labs).
#
# Windows (Wei PC2023) uses the prebuilt layout from
#   https://github.com/withlimon/verilator-windows
# (not a random unofficial drop). After extract, e.g. D:\verilator:
#   <root>/bin/verilator_bin.exe   PE32+ engine  ← prefer this
#   <root>/bin/verilator.exe       same PE, renamed copy
#   <root>/bin/verilator.bat       sets VERILATOR_ROOT, then calls verilator.exe
#   <root>/bin/verilator           Perl driver, NO extension — Explorer/CMD
#                                  may pop “Open with…”. Do not invoke it.
# Set VERILATOR_ROOT=<extract root> and PATH+=<root>/bin.
# Override: make VERILATOR=verilator_bin.exe
# Linux / macOS: leave VERILATOR unset → `verilator`.

COMMON_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT  := $(abspath $(COMMON_DIR)/../..)

UNAME_S := $(shell uname -s 2>/dev/null || echo unknown)

# .exe suffix on Windows / MSYS2 / MinGW
EXE :=
ifneq ($(OS),)
  ifeq ($(OS),Windows_NT)
    EXE := .exe
  endif
endif
ifneq ($(findstring MINGW,$(UNAME_S)),)
  EXE := .exe
endif
ifneq ($(findstring MSYS,$(UNAME_S)),)
  EXE := .exe
endif
ifneq ($(findstring CYGWIN,$(UNAME_S)),)
  EXE := .exe
endif

# If the user exported VERILATOR_ROOT, put its bin dir first (MSYS2 share/verilator).
ifneq ($(VERILATOR_ROOT),)
  export PATH := $(VERILATOR_ROOT)/bin:$(PATH)
endif

ifndef VERILATOR
  # Prefer withlimon verilator_bin.exe; never the extensionless Perl `verilator`.
  VB_PATH := $(shell command -v verilator_bin.exe 2>/dev/null)
  VB_ROOT := $(wildcard $(VERILATOR_ROOT)/bin/verilator_bin.exe)
  VB_LIMON := $(wildcard D:/verilator/bin/verilator_bin.exe)
  VB_LIMON_MSYS := $(wildcard /d/verilator/bin/verilator_bin.exe)
  # If the withlimon tarball was unpacked into MSYS2 MinGW64 (PC2023 note):
  VB_MSYS := $(wildcard /c/msys64/mingw64/bin/verilator_bin.exe)
  VB_MSYS2 := $(wildcard C:/msys64/mingw64/bin/verilator_bin.exe)
  ifneq ($(VB_PATH),)
    VERILATOR := $(VB_PATH)
  else ifneq ($(VB_ROOT),)
    VERILATOR := $(VB_ROOT)
  else ifneq ($(VB_LIMON),)
    VERILATOR := $(VB_LIMON)
  else ifneq ($(VB_LIMON_MSYS),)
    VERILATOR := $(VB_LIMON_MSYS)
  else ifneq ($(VB_MSYS),)
    VERILATOR := $(VB_MSYS)
  else ifneq ($(VB_MSYS2),)
    VERILATOR := $(VB_MSYS2)
  else
    VERILATOR := verilator
  endif
endif

# -j 1: Verilator 5.020 can abort with "destroy locked Thread Pool" on -j 0.
VLT_FLAGS ?= --cc --exe --build -j 1 -Wall --Wno-fatal -Wno-DECLFILENAME --timescale 1ns/1ps
VLT_FLAGS += $(EXTRA_VLT_FLAGS)
CXXFLAGS_V ?= -I$(COMMON_DIR) -std=c++17 -O2

.PHONY: all build run clean
all: run

build:
	@echo "VERILATOR=$(VERILATOR)"
	$(VERILATOR) $(VLT_FLAGS) \
		-CFLAGS "$(CXXFLAGS_V)" \
		--top-module $(TOP) \
		--Mdir obj_dir \
		-o sim \
		$(VSRC) $(CSRC)

run: build
	./obj_dir/sim$(EXE)

clean:
	rm -rf obj_dir
