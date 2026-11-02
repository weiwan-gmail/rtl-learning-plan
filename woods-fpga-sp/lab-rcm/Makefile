IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_rcm.v rcm_const_mul.v
	$(IVERILOG) $(IVFLAGS) -o sim_rcm tb_rcm.v rcm_const_mul.v
	$(VVP) sim_rcm
python_check: check_rcm.py
	$(PYTHON) check_rcm.py
clean:
	rm -f sim_rcm *.vcd
