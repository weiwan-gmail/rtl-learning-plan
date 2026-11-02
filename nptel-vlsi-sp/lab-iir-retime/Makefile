IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_iir_retime.v iir1_combo.v iir1_pipe.v
	$(IVERILOG) $(IVFLAGS) -o sim_iir tb_iir_retime.v iir1_combo.v iir1_pipe.v
	$(VVP) sim_iir
python_check: check_iir_retime.py
	$(PYTHON) check_iir_retime.py
clean:
	rm -f sim_iir *.vcd
