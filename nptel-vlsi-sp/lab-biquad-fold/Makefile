IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_biquad_fold.v biquad_par.v biquad_fold.v
	$(IVERILOG) $(IVFLAGS) -o sim_bq tb_biquad_fold.v biquad_par.v biquad_fold.v
	$(VVP) sim_bq
python_check: check_biquad_fold.py
	$(PYTHON) check_biquad_fold.py
clean:
	rm -f sim_bq *.vcd
