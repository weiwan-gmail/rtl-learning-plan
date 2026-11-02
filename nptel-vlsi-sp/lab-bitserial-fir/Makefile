IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_bitserial_fir.v bitserial_fir.v
	$(IVERILOG) $(IVFLAGS) -o sim_bs tb_bitserial_fir.v bitserial_fir.v
	$(VVP) sim_bs
python_check: check_bitserial.py
	$(PYTHON) check_bitserial.py
clean:
	rm -f sim_bs *.vcd
