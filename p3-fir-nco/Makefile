# P3: fir4 (+ optional nco) — iverilog/vvp self-check, bit-exact vs integer golden
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all fir nco numpy_check clean

all: fir nco numpy_check
	@echo "ALL PASS"

fir: tb_fir4.v fir4.v
	$(IVERILOG) $(IVFLAGS) -o sim_fir4 tb_fir4.v fir4.v
	$(VVP) sim_fir4

nco: tb_nco.v nco.v
	$(IVERILOG) $(IVFLAGS) -o sim_nco tb_nco.v nco.v
	$(VVP) sim_nco

# Independent NumPy golden vs pure-Python model of fir4 (sanity of coeffs/sat)
numpy_check: check_fir4.py
	$(PYTHON) check_fir4.py

clean:
	rm -f sim_fir4 sim_nco *.vcd
