# cmake-cocotb — third tree (cocotb-wrap only)

Sibling of [`../cmake-system/`](../cmake-system/) and [`../cmake-conan/`](../cmake-conan/), but **not** the Verilator C++ dual-tree.

| Tree | What it builds | Shared CMake |
|------|----------------|--------------|
| `cmake-system/` | `verilator-wrap/` C++ sims (system Verilator) | [`../cmake/RtlLabSim.cmake`](../cmake/RtlLabSim.cmake) + [`../cmake/labs.cmake`](../cmake/labs.cmake) |
| `cmake-conan/` | same C++ sims (Conan 2 Verilator recipe) | same `RtlLabSim` / `labs.cmake` |
| `cmake-cocotb/` | [`../cocotb-wrap/`](../cocotb-wrap/) Python TBs | [`../cmake/CocotbWrap.cmake`](../cmake/CocotbWrap.cmake) + [`../cmake/cocotb_labs.cmake`](../cmake/cocotb_labs.cmake) |

`cmake-system` / `cmake-conan` / `labs.cmake` stay **Verilator-only**. This project does **not** `include(RtlLabSim.cmake)`.

Does **not** change `cocotb-wrap/` Makefiles. CMake targets invoke the same `make -C cocotb-wrap/<lab> all` the Make path already uses.

## Matrix

Adding a lab = one `cocotb_lab_define()` row in [`../cmake/cocotb_labs.cmake`](../cmake/cocotb_labs.cmake) (same five wraps as `cocotb-wrap/Makefile`).

| Target | Wrap |
|--------|------|
| `cocotb_lms` | `woods-lab-lms` |
| `cocotb_dlms` | `nptel-lab-dlms` |
| `cocotb_cordic` | `woods-lab-cordic` |
| `cocotb_da_fir` | `woods-lab-da-fir` |
| `cocotb_p3_fir` | `p3-fir-nco` |
| `sim` | all five, in that order |
| `venv` | `make -C cocotb-wrap venv` (does not auto-run) |

## Linux

The Make path **requires** `cocotb-wrap/.venv` (`cocotb>=1.8,<2`). Simulator is Verilator (not iverilog).

```bash
# once per checkout
make -C cocotb-wrap venv
# or: cmake --build build-cocotb --target venv

cmake -S cmake-cocotb -B build-cocotb
cmake --build build-cocotb --target sim
ctest --test-dir build-cocotb --output-on-failure
```

Make-only (unchanged):

```bash
cd cocotb-wrap && make venv && make all
```

## Soft-skip

Configure **succeeds** even when the Make path cannot run. `sim` prints `SKIP: …` and ctest marks the five tests skipped (`SKIP_REGULAR_EXPRESSION`) when any of:

- GNU make missing
- `cocotb-wrap/.venv` missing (run `make -C cocotb-wrap venv`; a system `cocotb` install is not enough — the existing Makefiles look at that venv)
- Verilator missing (`verilator` / `verilator_bin` on Unix; **`verilator_bin.exe` PE** on Windows)

This tree does **not** use iverilog. iverilog is only for original Woods/NPTEL `make all`.

## Windows (PC2023)

Same withlimon / **`verilator_bin.exe`** rule as [`../verilator-wrap/WINDOWS.md`](../verilator-wrap/WINDOWS.md). CMake does not drive the Perl `verilator`; it calls the wrap Makefile, which uses [`../cocotb-wrap/common/vlt-win.mk`](../cocotb-wrap/common/vlt-win.mk). Needs GNU make (MSYS2 / MinGW `mingw32-make`). If the venv or PE is missing, tests skip rather than fail.

MSVC `-fcoroutines*` stripping lives in `RtlLabSim.cmake` and does **not** apply here (no `verilate()`, `LANGUAGES NONE`).

## Evidence

Linux: [`PASS_EVIDENCE.md`](PASS_EVIDENCE.md).
