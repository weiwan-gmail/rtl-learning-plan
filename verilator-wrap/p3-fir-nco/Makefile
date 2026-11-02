# Separate Verilator wrap — original p3-fir-nco Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_p3_fir_nco
VSRC := wrap.v \
       $(ROOT)/p3-fir-nco/fir4.v \
       $(ROOT)/p3-fir-nco/nco.v
CSRC := tb.cpp
include ../common/vlt.mk
