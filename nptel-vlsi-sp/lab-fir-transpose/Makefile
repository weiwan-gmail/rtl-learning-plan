IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_fir_transpose.v fir_direct.v fir_transpose.v
	$(IVERILOG) $(IVFLAGS) -o sim_ft tb_fir_transpose.v fir_direct.v fir_transpose.v
	$(VVP) sim_ft
python_check: check_fir_transpose.py
	$(PYTHON) check_fir_transpose.py
clean:
	rm -f sim_ft *.vcd
