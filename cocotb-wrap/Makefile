# Optional cocotb wraps. Original iverilog trees do not include this file.
.PHONY: all venv clean

WRAPS := woods-lab-lms nptel-lab-dlms woods-lab-cordic woods-lab-da-fir p3-fir-nco

venv:
	python3 -m venv .venv
	.venv/bin/pip install -U pip
	.venv/bin/pip install -r requirements.txt

export PATH := $(CURDIR)/.venv/bin:$(PATH)

all:
	@if [ ! -x .venv/bin/cocotb-config ]; then \
	  echo "Run: make venv  (in cocotb-wrap/)"; exit 1; \
	fi
	@for d in $(WRAPS); do \
	  echo "==== cocotb-wrap/$$d ===="; \
	  $(MAKE) -C $$d all || exit 1; \
	done
	@echo "ALL COCOTB WRAPS PASS"

clean:
	@for d in $(WRAPS); do $(MAKE) -C $$d clean; done
	rm -rf .venv
