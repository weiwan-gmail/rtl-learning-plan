IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_arith.v cla_add16.v array_mult8.v
	$(IVERILOG) $(IVFLAGS) -o sim_arith tb_arith.v cla_add16.v array_mult8.v
	$(VVP) sim_arith
python_check: check_arith.py
	$(PYTHON) check_arith.py
clean:
	rm -f sim_arith *.vcd
