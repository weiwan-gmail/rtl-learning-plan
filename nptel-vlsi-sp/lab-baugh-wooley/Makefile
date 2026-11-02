IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_baugh_wooley.v baugh_wooley8.v
	$(IVERILOG) $(IVFLAGS) -o sim_bw tb_baugh_wooley.v baugh_wooley8.v
	$(VVP) sim_bw
python_check: check_bw.py
	$(PYTHON) check_bw.py
clean:
	rm -f sim_bw *.vcd
