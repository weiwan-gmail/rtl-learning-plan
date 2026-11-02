# Cocotb + Verilator without relying on GNU make $(shell) seeing PATH.
# Original iverilog labs do not include this file.
#
# Windows (PC2023): https://github.com/withlimon/verilator-windows
# Uses $(VERILATOR) from vlt-win.mk → verilator_bin.exe, not the Perl `verilator`.

COCOTB_WRAP_COMMON := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COCOTB_WRAP_ROOT := $(abspath $(COCOTB_WRAP_COMMON)/..)
VENV_BIN := $(COCOTB_WRAP_ROOT)/.venv/bin
COCOTB_CONFIG := $(VENV_BIN)/cocotb-config

ifeq ($(wildcard $(COCOTB_CONFIG)),)
  $(error Run `make venv` in cocotb-wrap/ first (missing $(COCOTB_CONFIG)))
endif

include $(COCOTB_WRAP_COMMON)vlt-win.mk

SIM ?= verilator
TOPLEVEL_LANG ?= verilog
MODULE ?= test
COCOTB_REDUCED_LOG_FMT ?= 1
export COCOTB_REDUCED_LOG_FMT
SHELL := bash

COCOTB_PY_DIR := $(shell $(COCOTB_CONFIG) --prefix)
COCOTB_SHARE_DIR := $(COCOTB_PY_DIR)/cocotb/share
PYTHON_BIN := $(shell $(COCOTB_CONFIG) --python-bin)
LIBPYTHON_LOC := $(shell $(COCOTB_CONFIG) --libpython)
export LIBPYTHON_LOC
LIB_DIR := $(COCOTB_PY_DIR)/cocotb/libs

SIM_BUILD ?= sim_build
export SIM_BUILD
COCOTB_RESULTS_FILE ?= results.xml
export COCOTB_RESULTS_FILE
COCOTB_HDL_TIMEUNIT ?= 1ns
COCOTB_HDL_TIMEPRECISION ?= 1ps

CMD := $(VERILATOR)
COMPILE_ARGS += --timescale $(COCOTB_HDL_TIMEUNIT)/$(COCOTB_HDL_TIMEPRECISION)
COMPILE_ARGS += --vpi --public-flat-rw --prefix Vtop -o Vtop
COMPILE_ARGS += -LDFLAGS "-Wl,-rpath,$(shell $(COCOTB_CONFIG) --lib-dir) -L$(shell $(COCOTB_CONFIG) --lib-dir) -lcocotbvpi_verilator"
EXTRA_ARGS += --Wno-fatal

.PHONY: all sim clean
all: sim

sim:
	$(RM) $(COCOTB_RESULTS_FILE)
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(COCOTB_RESULTS_FILE)

$(SIM_BUILD):
	mkdir -p $@

$(SIM_BUILD)/Vtop.mk: $(VERILOG_SOURCES) $(COCOTB_SHARE_DIR)/lib/verilator/verilator.cpp | $(SIM_BUILD)
	$(CMD) -cc --exe -Mdir $(SIM_BUILD) -DCOCOTB_SIM=1 --top-module $(TOPLEVEL) \
	  $(COMPILE_ARGS) $(EXTRA_ARGS) $(VERILOG_SOURCES) \
	  $(COCOTB_SHARE_DIR)/lib/verilator/verilator.cpp

$(SIM_BUILD)/Vtop: $(SIM_BUILD)/Vtop.mk
	$(MAKE) -C $(SIM_BUILD) -f Vtop.mk

$(COCOTB_RESULTS_FILE): $(SIM_BUILD)/Vtop
	$(RM) $(COCOTB_RESULTS_FILE)
	MODULE=$(MODULE) TESTCASE=$(TESTCASE) TOPLEVEL=$(TOPLEVEL) TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
	  PATH="$(VENV_BIN):$(PATH)" $(SIM_BUILD)/Vtop $(SIM_ARGS) $(PLUSARGS)
	@test -f $(COCOTB_RESULTS_FILE) || (echo "ERROR: $(COCOTB_RESULTS_FILE) missing" >&2; exit 1)
	@if grep -q '<failure' $(COCOTB_RESULTS_FILE); then echo "FAIL: see $(COCOTB_RESULTS_FILE)"; exit 1; fi

clean:
	$(RM) -r $(SIM_BUILD) $(COCOTB_RESULTS_FILE)
