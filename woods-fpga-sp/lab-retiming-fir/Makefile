IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_retiming.v fir3_combo.v fir3_pipe.v
	$(IVERILOG) $(IVFLAGS) -o sim_ret tb_retiming.v fir3_combo.v fir3_pipe.v
	$(VVP) sim_ret
python_check: check_retiming.py
	$(PYTHON) check_retiming.py
clean:
	rm -f sim_ret *.vcd
