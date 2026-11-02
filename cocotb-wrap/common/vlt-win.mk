# Windows Verilator binary selection (same policy as verilator-wrap/common/vlt.mk).
# Original iverilog labs do not include this file.
#
# PC2023 uses https://github.com/withlimon/verilator-windows (not a random
# unofficial drop). Extract layout: <root>/bin/verilator_bin.exe. The
# extensionless `verilator` file is a Perl driver — Explorer/CMD may pop
# “Open with…”. Prefer verilator_bin.exe. Linux/mac: `verilator`.

UNAME_S := $(shell uname -s 2>/dev/null || echo unknown)

ifneq ($(VERILATOR_ROOT),)
  export PATH := $(VERILATOR_ROOT)/bin:$(PATH)
endif

ifndef VERILATOR
  VB_PATH := $(shell command -v verilator_bin.exe 2>/dev/null)
  VB_ROOT := $(wildcard $(VERILATOR_ROOT)/bin/verilator_bin.exe)
  VB_LIMON := $(wildcard D:/verilator/bin/verilator_bin.exe)
  VB_LIMON_MSYS := $(wildcard /d/verilator/bin/verilator_bin.exe)
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

export VERILATOR
# The Perl driver re-execs $VERILATOR_BIN. Never set that to the
# extensionless `verilator` script (fork loop / Windows “Open with…”).
ifneq ($(findstring verilator_bin,$(VERILATOR)),)
  export VERILATOR_BIN := $(VERILATOR)
endif
