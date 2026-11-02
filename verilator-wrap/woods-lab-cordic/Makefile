# Separate Verilator wrap — original woods-fpga-sp/lab-cordic Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_cordic
VSRC := wrap.v \
       $(ROOT)/woods-fpga-sp/lab-cordic/cordic_rotate.v \
       $(ROOT)/woods-fpga-sp/lab-cordic/cordic_vector.v
CSRC := tb.cpp
include ../common/vlt.mk
