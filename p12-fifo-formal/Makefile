# P12 / A5: SymbiYosys formal on P2 sync_fifo
SBY      ?= sby
SBYFLAGS ?= -f
TASK     ?= bmc

.PHONY: all formal cover evidence clean versions

all: formal cover evidence
	@echo "ALL PASS"

formal: fifo_formal.sby fifo_props.v ../p2-sync-fifo/sync_fifo.v
	$(SBY) $(SBYFLAGS) fifo_formal.sby $(TASK)
	@test -f fifo_formal_$(TASK)/PASS

cover: fifo_formal.sby fifo_props.v ../p2-sync-fifo/sync_fifo.v
	$(SBY) $(SBYFLAGS) fifo_formal.sby cover
	@test -f fifo_formal_cover/PASS

evidence: formal
	@{ \
	  echo "=== tool versions ==="; \
	  echo -n "yosys: "; yosys -V | head -1; \
	  echo -n "sby:   "; sby --version 2>/dev/null || echo "SBY (YosysHQ)"; \
	  echo -n "z3:    "; z3 --version; \
	  echo; \
	  echo "=== properties ==="; \
	  echo "- assume: no wr-when-full / rd-when-empty (after reset)"; \
	  echo "- assert: !(full && empty); count<=DEPTH; empty/full <-> count"; \
	  echo "- assert: under assume, count steps exactly with wr/rd (no wrap)"; \
	  echo "- cover: reach full; reach empty after full"; \
	  echo "- DUT: ../p2-sync-fifo/sync_fifo.v (WIDTH=2 DEPTH=4 instance)"; \
	  echo "- engine: smtbmc z3; mode bmc depth 16 (+ cover depth 16)"; \
	  echo; \
	  echo "=== sby $(TASK) logfile (PASS excerpt) ==="; \
	  rg -n 'Status:|DONE|PASS|pass|engine_0|Solver' fifo_formal_$(TASK)/logfile.txt | tail -40; \
	  echo; \
	  if [ -f fifo_formal_cover/logfile.txt ]; then \
	    echo "=== sby cover logfile (PASS excerpt) ==="; \
	    rg -n 'Status:|DONE|PASS|pass|Reached cover|engine_0' fifo_formal_cover/logfile.txt | tail -40; \
	    echo; \
	  fi; \
	  echo "ALL PASS"; \
	} > PASS_EVIDENCE.txt
	@test -f fifo_formal_$(TASK)/PASS
	@rg -q 'DONE \(PASS' PASS_EVIDENCE.txt
	@echo "Wrote PASS_EVIDENCE.txt"

versions:
	@echo -n "yosys: "; yosys -V | head -1
	@echo -n "sby:   "; sby --version 2>/dev/null || echo "SBY (YosysHQ)"
	@echo -n "z3:    "; z3 --version

clean:
	rm -rf fifo_formal_bmc fifo_formal_cover PASS_EVIDENCE.txt
