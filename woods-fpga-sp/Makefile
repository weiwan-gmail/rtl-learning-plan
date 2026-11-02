.PHONY: all clean

LABS := lab-cordic lab-iir1 lab-da-fir lab-fft8 lab-lms

all:
	@for d in $(LABS); do \
	  echo "==== $$d ===="; \
	  $(MAKE) -C $$d all || exit 1; \
	done
	@echo "ALL WOODS LABS PASS"

clean:
	@for d in $(LABS); do $(MAKE) -C $$d clean; done
