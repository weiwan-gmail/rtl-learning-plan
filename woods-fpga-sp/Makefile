.PHONY: all clean

LABS := lab-cordic lab-iir1 lab-da-fir lab-fft8 lab-lms \
        lab-arith lab-rcm lab-biquad lab-da-fir-signed lab-retiming-fir lab-givens2 \
        lab-rls1 lab-div-nr lab-rns35 \
        lab-sqrt16 lab-lns-mul lab-sgr2

all:
	@for d in $(LABS); do \
	  echo "==== $$d ===="; \
	  $(MAKE) -C $$d all || exit 1; \
	done
	@echo "ALL WOODS LABS PASS"

clean:
	@for d in $(LABS); do $(MAKE) -C $$d clean; done
