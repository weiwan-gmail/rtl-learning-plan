IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_lookahead.v iir_plain.v iir_lookahead.v iir_la_pipe.v
	$(IVERILOG) $(IVFLAGS) -o sim_la tb_lookahead.v iir_plain.v iir_lookahead.v iir_la_pipe.v
	$(VVP) sim_la
python_check: check_lookahead.py
	$(PYTHON) check_lookahead.py
clean:
	rm -f sim_la *.vcd
