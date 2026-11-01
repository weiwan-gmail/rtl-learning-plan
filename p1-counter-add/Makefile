# P1: counter8 + add32 — iverilog/vvp self-check
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale

.PHONY: all counter add clean

all: counter add
	@echo "ALL PASS"

counter: tb_counter8.v counter8.v
	$(IVERILOG) $(IVFLAGS) -o sim_counter8 tb_counter8.v counter8.v
	$(VVP) sim_counter8

add: tb_add32.v add32.v
	$(IVERILOG) $(IVFLAGS) -o sim_add32 tb_add32.v add32.v
	$(VVP) sim_add32

clean:
	rm -f sim_counter8 sim_add32 *.vcd
