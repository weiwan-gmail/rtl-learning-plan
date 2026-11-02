# Separate Verilator wrap — original nptel-vlsi-sp/lab-lookahead-iir Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_lookahead
VSRC := wrap.v \
       $(ROOT)/nptel-vlsi-sp/lab-lookahead-iir/iir_plain.v \
       $(ROOT)/nptel-vlsi-sp/lab-lookahead-iir/iir_lookahead.v \
       $(ROOT)/nptel-vlsi-sp/lab-lookahead-iir/iir_la_pipe.v
CSRC := tb.cpp
include ../common/vlt.mk
