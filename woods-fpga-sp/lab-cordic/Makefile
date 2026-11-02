IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  := -g2005 -Wall -Wno-timescale
PYTHON   ?= python3

.PHONY: all cordic vector python_check clean

all: cordic vector python_check
	@echo "ALL PASS"

cordic: tb_cordic_rotate.v cordic_rotate.v
	$(IVERILOG) $(IVFLAGS) -o sim_cordic tb_cordic_rotate.v cordic_rotate.v
	$(VVP) sim_cordic

vector: tb_cordic_vector.v cordic_vector.v
	$(IVERILOG) $(IVFLAGS) -o sim_cordic_vec tb_cordic_vector.v cordic_vector.v
	$(VVP) sim_cordic_vec

python_check: check_cordic.py
	$(PYTHON) check_cordic.py

clean:
	rm -f sim_cordic sim_cordic_vec *.vcd
