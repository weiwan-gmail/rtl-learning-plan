# Separate Verilator wrap — original nptel-vlsi-sp/lab-iir-retime Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_iir_retime
VSRC := wrap.v \
       $(ROOT)/nptel-vlsi-sp/lab-iir-retime/iir1_combo.v \
       $(ROOT)/nptel-vlsi-sp/lab-iir-retime/iir1_pipe.v
CSRC := tb.cpp
include ../common/vlt.mk
