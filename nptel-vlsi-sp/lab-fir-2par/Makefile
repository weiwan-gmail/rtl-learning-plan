IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_fir_2par.v fir_serial.v fir_2par.v
	$(IVERILOG) $(IVFLAGS) -o sim_2p tb_fir_2par.v fir_serial.v fir_2par.v
	$(VVP) sim_2p
python_check: check_fir_2par.py
	$(PYTHON) check_fir_2par.py
clean:
	rm -f sim_2p *.vcd
