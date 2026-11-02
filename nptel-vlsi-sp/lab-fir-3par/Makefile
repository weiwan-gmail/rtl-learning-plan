IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_fir_3par.v fir_serial3.v fir_3par.v
	$(IVERILOG) $(IVFLAGS) -o sim_3p tb_fir_3par.v fir_serial3.v fir_3par.v
	$(VVP) sim_3p
python_check: check_fir_3par.py
	$(PYTHON) check_fir_3par.py
clean:
	rm -f sim_3p *.vcd
