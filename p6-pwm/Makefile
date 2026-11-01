# P6: pwm — iverilog/vvp self-check (period / duty / edges)
IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale

.PHONY: all pwm clean

all: pwm
	@echo "ALL PASS"

pwm: tb_pwm.v pwm.v
	$(IVERILOG) $(IVFLAGS) -o sim_pwm tb_pwm.v pwm.v
	$(VVP) sim_pwm

clean:
	rm -f sim_pwm *.vcd
