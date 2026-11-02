IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all lms python_check clean

all: lms python_check
	@echo "ALL PASS"

lms: tb_lms2.v lms2.v
	$(IVERILOG) $(IVFLAGS) -o sim_lms2 tb_lms2.v lms2.v
	$(VVP) sim_lms2

python_check: check_lms2.py
	$(PYTHON) check_lms2.py

clean:
	rm -f sim_lms2 *.vcd
