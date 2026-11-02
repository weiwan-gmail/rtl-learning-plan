IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_sgr2.v sgr_step.v
	$(IVERILOG) $(IVFLAGS) -o sim_sgr tb_sgr2.v sgr_step.v
	$(VVP) sim_sgr
python_check: check_sgr2.py
	$(PYTHON) check_sgr2.py
clean:
	rm -f sim_sgr *.vcd
