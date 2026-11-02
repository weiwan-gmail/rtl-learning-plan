# Woods leftovers (not wrapped)

All **17** `woods-fpga-sp/lab-*` RTL trees now have Verilator C++ wraps (relative DUT paths, no RTL copies). They are in [`../cmake/labs.cmake`](../cmake/labs.cmake) and `verilator-wrap/Makefile`.

PLACEHOLDER dirs stay stubs — not wrapable as pure RTL + self-check TB (Vivado / HLS / vendor / system-level):

| Path | Why skipped |
|------|-------------|
| `ch05-vendor-fpga` | Vendor FPGA primitives / datasheets, not portable RTL |
| `ch07-hls-vivado` | Vivado HLS / OpenCL / commercial HLS |
| `ch10-model-based` | MADF / model-based synthesis toolchains |
| `ch11-beamformer-qr` | Full QR-RLS beamformer array; building blocks are wrapped (`lab-givens2`, `lab-sgr2`, `lab-rls1`) |
| `ch12-bigdata-softproc` | Soft-core / system-level, not a single-module sim |

See [`../woods-fpga-sp/PLACEHOLDERS.md`](../woods-fpga-sp/PLACEHOLDERS.md). No Vivado.

## CMake layout (three trees)

| Tree | Scope |
|------|--------|
| `cmake-system/` + `cmake-conan/` | Verilator **C++** wraps. Table: [`../cmake/labs.cmake`](../cmake/labs.cmake). **Not** cocotb. |
| `cmake-cocotb/` | [`../cocotb-wrap/`](../cocotb-wrap/) only. Table: [`../cmake/cocotb_labs.cmake`](../cmake/cocotb_labs.cmake). Invokes existing Makefiles. Does **not** include `RtlLabSim.cmake`. |

`cmake-system/` and `cmake-conan/` verilate **every wrap in this tree** (30 PASS + `sim-fail`).
