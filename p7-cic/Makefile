# P7 / N6: cic_decim — iverilog/vvp self-check + Python golden sanity
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all cic python_check clean

all: cic python_check
	@echo "ALL PASS"

cic: tb_cic_decim.v cic_decim.v
	$(IVERILOG) $(IVFLAGS) -o sim_cic tb_cic_decim.v cic_decim.v
	$(VVP) sim_cic

python_check: check_cic.py
	$(PYTHON) check_cic.py

clean:
	rm -f sim_cic *.vcd
