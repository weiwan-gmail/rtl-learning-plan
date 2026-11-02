IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_divu16.v divu16_nr.v
	$(IVERILOG) $(IVFLAGS) -o sim_div tb_divu16.v divu16_nr.v
	$(VVP) sim_div
python_check: check_div.py
	$(PYTHON) check_div.py
clean:
	rm -f sim_div *.vcd
