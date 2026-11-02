# P8 / I6: tri_raster — iverilog self-check + Python golden
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all tri python_check clean

all: tri python_check
	@echo "ALL PASS"

tri: tb_tri_raster.v tri_raster.v
	$(IVERILOG) $(IVFLAGS) -o sim_tri tb_tri_raster.v tri_raster.v
	$(VVP) sim_tri

python_check: check_tri.py
	$(PYTHON) check_tri.py

clean:
	rm -f sim_tri *.vcd *.ppm
