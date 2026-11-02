IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all iir python_check clean

all: iir python_check
	@echo "ALL PASS"

iir: tb_iir1.v iir1.v
	$(IVERILOG) $(IVFLAGS) -o sim_iir1 tb_iir1.v iir1.v
	$(VVP) sim_iir1

python_check: check_iir1.py
	$(PYTHON) check_iir1.py

clean:
	rm -f sim_iir1 *.vcd
