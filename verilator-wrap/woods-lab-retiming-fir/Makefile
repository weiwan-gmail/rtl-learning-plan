# Separate Verilator wrap — original woods-fpga-sp/lab-retiming-fir Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_retiming_fir
VSRC := wrap.v \
       $(ROOT)/woods-fpga-sp/lab-retiming-fir/fir3_combo.v \
       $(ROOT)/woods-fpga-sp/lab-retiming-fir/fir3_pipe.v
CSRC := tb.cpp
include ../common/vlt.mk
