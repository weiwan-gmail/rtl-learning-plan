# Separate Verilator wrap — original nptel-vlsi-sp/lab-biquad-fold Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_biquad_fold
VSRC := wrap.v \
       $(ROOT)/nptel-vlsi-sp/lab-biquad-fold/biquad_par.v \
       $(ROOT)/nptel-vlsi-sp/lab-biquad-fold/biquad_fold.v
CSRC := tb.cpp
include ../common/vlt.mk
