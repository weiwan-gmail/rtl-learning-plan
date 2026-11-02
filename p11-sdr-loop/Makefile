# P11 / Track B: sdr_loop — NCO → FIR → CIC teaching loopback
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

NCO_V    := ../p3-fir-nco/nco.v
FIR_V    := ../p3-fir-nco/fir4.v
CIC_V    := ../p7-cic/cic_decim.v

.PHONY: all loop python_check clean

all: loop python_check
	@echo "ALL PASS"

loop: tb_sdr_loop.v sdr_loop.v $(NCO_V) $(FIR_V) $(CIC_V)
	$(IVERILOG) $(IVFLAGS) -o sim_sdr_loop tb_sdr_loop.v sdr_loop.v $(NCO_V) $(FIR_V) $(CIC_V)
	$(VVP) sim_sdr_loop

python_check: check_sdr_loop.py
	$(PYTHON) check_sdr_loop.py

clean:
	rm -f sim_sdr_loop *.vcd
