IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_da_fir4_signed.v da_fir4_signed.v
	$(IVERILOG) $(IVFLAGS) -o sim_da_s tb_da_fir4_signed.v da_fir4_signed.v
	$(VVP) sim_da_s
python_check: check_da_fir_signed.py
	$(PYTHON) check_da_fir_signed.py
clean:
	rm -f sim_da_s *.vcd
