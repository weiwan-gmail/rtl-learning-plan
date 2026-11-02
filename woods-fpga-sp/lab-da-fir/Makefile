IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all da python_check clean

all: da python_check
	@echo "ALL PASS"

da: tb_da_fir4.v da_fir4.v
	$(IVERILOG) $(IVFLAGS) -o sim_da tb_da_fir4.v da_fir4.v
	$(VVP) sim_da

python_check: check_da_fir4.py
	$(PYTHON) check_da_fir4.py

clean:
	rm -f sim_da *.vcd
