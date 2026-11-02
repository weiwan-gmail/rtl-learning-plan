IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_rns35.v rns35.v
	$(IVERILOG) $(IVFLAGS) -o sim_rns tb_rns35.v rns35.v
	$(VVP) sim_rns
python_check: check_rns35.py
	$(PYTHON) check_rns35.py
clean:
	rm -f sim_rns *.vcd
