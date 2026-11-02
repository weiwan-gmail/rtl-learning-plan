# Separate Verilator wrap — original nptel-vlsi-sp/lab-dlms Makefile is not included.
ROOT := $(abspath ../..)
TOP  := wrap_dlms
VSRC := wrap.v \
       $(ROOT)/nptel-vlsi-sp/lab-dlms/lms2.v \
       $(ROOT)/nptel-vlsi-sp/lab-dlms/dlms2.v
CSRC := tb.cpp
include ../common/vlt.mk
