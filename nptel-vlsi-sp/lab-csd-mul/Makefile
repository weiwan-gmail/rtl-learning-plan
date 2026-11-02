IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_csd_mul.v csd_mul.v
	$(IVERILOG) $(IVFLAGS) -o sim_csd tb_csd_mul.v csd_mul.v
	$(VVP) sim_csd
python_check: check_csd.py
	$(PYTHON) check_csd.py
clean:
	rm -f sim_csd *.vcd
