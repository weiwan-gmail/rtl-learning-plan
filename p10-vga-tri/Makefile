# P10: wire P8 tri_raster FB into P4 VGA timing (NN scale 64x48 -> 640x480)
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale

VGA_TIMING := ../p4-vga/vga_timing.v
TRI_RASTER := ../p8-tri-raster/tri_raster.v

.PHONY: all vga_tri clean

all: vga_tri
	@echo "ALL PASS"

vga_tri: tb_vga_tri.v vga_tri.v $(VGA_TIMING) $(TRI_RASTER)
	$(IVERILOG) $(IVFLAGS) -o sim_vga_tri tb_vga_tri.v vga_tri.v $(VGA_TIMING) $(TRI_RASTER)
	$(VVP) sim_vga_tri

clean:
	rm -f sim_vga_tri *.vcd frame.ppm
