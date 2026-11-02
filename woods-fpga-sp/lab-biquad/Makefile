IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_biquad.v biquad_df1.v
	$(IVERILOG) $(IVFLAGS) -o sim_biquad tb_biquad.v biquad_df1.v
	$(VVP) sim_biquad
python_check: check_biquad.py
	$(PYTHON) check_biquad.py
clean:
	rm -f sim_biquad *.vcd
