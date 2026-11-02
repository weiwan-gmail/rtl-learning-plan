IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_givens2.v givens_apply.v
	$(IVERILOG) $(IVFLAGS) -o sim_giv tb_givens2.v givens_apply.v
	$(VVP) sim_giv
python_check: check_givens2.py
	$(PYTHON) check_givens2.py
clean:
	rm -f sim_giv *.vcd
