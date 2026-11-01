# P2: sync_fifo — iverilog/vvp self-check
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale

.PHONY: all fifo clean

all: fifo
	@echo "ALL PASS"

fifo: tb_sync_fifo.v sync_fifo.v
	$(IVERILOG) $(IVFLAGS) -o sim_fifo tb_sync_fifo.v sync_fifo.v
	$(VVP) sim_fifo

clean:
	rm -f sim_fifo *.vcd
