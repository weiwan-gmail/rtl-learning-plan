.PHONY: all clean

LABS := lab-fir-transpose lab-iir-retime lab-dlms lab-fir-2par lab-fir-3par \
        lab-biquad-fold lab-bitserial-fir lab-baugh-wooley lab-csd-mul lab-lookahead-iir

ASSIGNS := assign-w1 assign-w2 assign-w3 assign-w4 assign-w5 assign-w6 assign-w7 assign-w8

all:
	@for d in $(LABS) $(ASSIGNS); do \
	  echo "==== $$d ===="; \
	  $(MAKE) -C $$d all || exit 1; \
	done
	@echo "ALL NPTEL-VLSI-SP LABS+ASSIGNS PASS"

clean:
	@for d in $(LABS) $(ASSIGNS); do $(MAKE) -C $$d clean; done
