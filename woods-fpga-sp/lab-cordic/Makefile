IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all cordic python_check clean

all: cordic python_check
	@echo "ALL PASS"

cordic: tb_cordic_rotate.v cordic_rotate.v
	$(IVERILOG) $(IVFLAGS) -o sim_cordic tb_cordic_rotate.v cordic_rotate.v
	$(VVP) sim_cordic

python_check: check_cordic.py
	$(PYTHON) check_cordic.py

clean:
	rm -f sim_cordic *.vcd
