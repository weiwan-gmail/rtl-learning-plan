# Separate Verilator wrap — original woods-fpga-sp/lab-fft8 Makefile is not included.
ROOT := $(abspath ../..)
TOP  := fft8
VSRC := $(ROOT)/woods-fpga-sp/lab-fft8/fft8.v
CSRC := tb.cpp
EXTRA_VLT_FLAGS := -Wno-UNOPTFLAT -Wno-BLKANDNBLK
include ../common/vlt.mk
