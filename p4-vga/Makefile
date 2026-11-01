# P4: vga_timing + color bars — iverilog/vvp self-check (h/vsync + RGB)
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale

.PHONY: all vga clean

all: vga
	@echo "ALL PASS"

vga: tb_vga.v vga_timing.v vga_bars.v
	$(IVERILOG) $(IVFLAGS) -o sim_vga tb_vga.v vga_timing.v vga_bars.v
	$(VVP) sim_vga

clean:
	rm -f sim_vga *.vcd
