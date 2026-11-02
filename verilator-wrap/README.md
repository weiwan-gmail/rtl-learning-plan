# Verilator wraps (separate from iverilog labs)

Optional **C++** testbenches that compile original DUT RTL with Verilator. Original lab Makefiles are **not** included and must keep working with iverilog only:

```bash
cd nptel-vlsi-sp && make all    # unchanged
cd woods-fpga-sp && make all    # unchanged
cd p3-fir-nco && make all       # unchanged
```

DUT sources are referenced by relative path (plus a thin `wrap.v` glue module where two architectures share one C++ TB). No Vivado.

## Run

```bash
# all wraps
cd verilator-wrap && make all

# one lab
cd verilator-wrap/nptel-lab-csd-mul && make all
```

PASS command per wrap is `make all` in that directory. Logs: [`PASS_EVIDENCE.md`](PASS_EVIDENCE.md).

Requires Verilator 5.x and g++.

## Windows (PC2023)

Use the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). Details: [`WINDOWS.md`](WINDOWS.md). Linux/mac: ordinary `verilator`.

## Scope

| Wrap | Original lab | Why this one |
|------|----------------|--------------|
| `nptel-lab-*` (10) | all RTL labs under `nptel-vlsi-sp/lab-*` | full NPTEL RTL set (not `assign-w*`) |
| `woods-lab-retiming-fir` | Woods retiming FIR | FIR / retiming |
| `woods-lab-lms` | Woods 2-tap LMS | adaptive |
| `woods-lab-da-fir` | Woods unsigned DA FIR | distributed arithmetic |
| `woods-lab-arith` | CLA-16 + array mult | arithmetic |
| `woods-lab-cordic` | rotate + vector | CORDIC |
| `woods-lab-fft8` | 8-pt FFT | transform |
| `p3-fir-nco` | P3 | FIR + NCO (quick) |
| `p7-cic` | P7 | CIC (quick) |
| `p11-sdr-loop` | P11 | NCO→FIR→CIC (quick) |

Woods labs **not** wrapped, and why: [`SCOPE.md`](SCOPE.md).

Cocotb (randomized Python goldens) lives in a **separate** tree: [`../cocotb-wrap/`](../cocotb-wrap/).
