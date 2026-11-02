# Separate Verilator wrap — original woods-fpga-sp/lab-arith Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_arith
VSRC := wrap.v \
       $(ROOT)/woods-fpga-sp/lab-arith/cla_add16.v \
       $(ROOT)/woods-fpga-sp/lab-arith/array_mult8.v
CSRC := tb.cpp
include ../common/vlt.mk
