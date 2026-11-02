# Run every Verilator wrap. Not invoked by original iverilog trees.
.PHONY: all clean

WRAPS := \
  nptel-lab-fir-transpose nptel-lab-iir-retime nptel-lab-dlms \
  nptel-lab-fir-2par nptel-lab-fir-3par nptel-lab-biquad-fold \
  nptel-lab-bitserial-fir nptel-lab-baugh-wooley nptel-lab-csd-mul \
  nptel-lab-lookahead-iir \
  woods-lab-retiming-fir woods-lab-lms woods-lab-da-fir \
  woods-lab-arith woods-lab-cordic woods-lab-fft8 \
  p3-fir-nco p7-cic p11-sdr-loop

all:
	@for d in $(WRAPS); do \
	  echo "==== verilator-wrap/$$d ===="; \
	  $(MAKE) -C $$d all || exit 1; \
	done
	@echo "ALL VERILATOR WRAPS PASS"

clean:
	@for d in $(WRAPS); do $(MAKE) -C $$d clean; done
