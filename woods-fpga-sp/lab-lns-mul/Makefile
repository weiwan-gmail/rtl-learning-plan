IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_lns_mul.v lns_mul8.v
	$(IVERILOG) $(IVFLAGS) -o sim_lns tb_lns_mul.v lns_mul8.v
	$(VVP) sim_lns
python_check: check_lns_mul.py
	$(PYTHON) check_lns_mul.py
clean:
	rm -f sim_lns *.vcd
