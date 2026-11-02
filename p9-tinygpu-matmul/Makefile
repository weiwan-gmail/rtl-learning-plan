# P9 / I7: tiny-gpu 2x2 matmul (reuses p5-tiny-gpu/tiny-gpu submodule)
.PHONY: all matmul clean

all: matmul
	@echo "ALL PASS"

matmul:
	./run_matmul.sh

clean:
	rm -f sim_matmul.log results.xml
	# build/ and .venv live in the shared submodule; leave them unless you clean P5 too
