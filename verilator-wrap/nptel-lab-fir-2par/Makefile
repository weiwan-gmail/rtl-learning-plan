# Separate Verilator wrap — original nptel-vlsi-sp/lab-fir-2par Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_fir_2par
VSRC := wrap.v \
       $(ROOT)/nptel-vlsi-sp/lab-fir-2par/fir_serial.v \
       $(ROOT)/nptel-vlsi-sp/lab-fir-2par/fir_2par.v
CSRC := tb.cpp
include ../common/vlt.mk
