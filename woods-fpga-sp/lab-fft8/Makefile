IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all fft python_check clean

all: fft python_check
	@echo "ALL PASS"

fft: tb_fft8.v fft8.v
	$(IVERILOG) $(IVFLAGS) -o sim_fft8 tb_fft8.v fft8.v
	$(VVP) sim_fft8

python_check: check_fft8.py
	$(PYTHON) check_fft8.py

clean:
	rm -f sim_fft8 *.vcd
