# Separate Verilator wrap — original nptel-vlsi-sp/lab-fir-transpose Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_fir_transpose
VSRC := wrap.v \
       $(ROOT)/nptel-vlsi-sp/lab-fir-transpose/fir_direct.v \
       $(ROOT)/nptel-vlsi-sp/lab-fir-transpose/fir_transpose.v
CSRC := tb.cpp
include ../common/vlt.mk
