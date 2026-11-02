IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2005 -Wall -Wno-timescale
PYTHON ?= python3
.PHONY: all rtl python_check clean
all: rtl python_check
	@echo "ALL PASS"
rtl: tb_dlms.v lms2.v dlms2.v
	$(IVERILOG) $(IVFLAGS) -o sim_dlms tb_dlms.v lms2.v dlms2.v
	$(VVP) sim_dlms
python_check: check_dlms.py
	$(PYTHON) check_dlms.py
clean:
	rm -f sim_dlms *.vcd
