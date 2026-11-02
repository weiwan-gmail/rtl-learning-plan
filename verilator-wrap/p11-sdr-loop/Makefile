# Separate Verilator wrap — original p11-sdr-loop Makefile is not included.
ROOT := $(abspath ../..)
TOP  := sdr_loop
VSRC := $(ROOT)/p11-sdr-loop/sdr_loop.v \
       $(ROOT)/p3-fir-nco/nco.v \
       $(ROOT)/p3-fir-nco/fir4.v \
       $(ROOT)/p7-cic/cic_decim.v
CSRC := tb.cpp
EXTRA_VLT_FLAGS := -Wno-fatal
include ../common/vlt.mk
