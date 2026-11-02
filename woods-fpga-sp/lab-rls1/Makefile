IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_rls1.v rls1.v
	$(IVERILOG) $(IVFLAGS) -o sim_rls1 tb_rls1.v rls1.v
	$(VVP) sim_rls1
python_check: check_rls1.py
	$(PYTHON) check_rls1.py
clean:
	rm -f sim_rls1 *.vcd
