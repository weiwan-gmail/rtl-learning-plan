IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_sqrt16.v sqrt16.v
	$(IVERILOG) $(IVFLAGS) -o sim_sqrt tb_sqrt16.v sqrt16.v
	$(VVP) sim_sqrt
python_check: check_sqrt16.py
	$(PYTHON) check_sqrt16.py
clean:
	rm -f sim_sqrt *.vcd
