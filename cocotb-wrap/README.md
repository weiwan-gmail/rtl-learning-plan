# Cocotb wraps (optional, separate from iverilog labs)

Python testbenches **only** where a golden / randomized plant adds coverage the C++ Verilator wrap does not: LMS, delayed-LMS, CORDIC, DA FIR, P3 FIR. Original lab Makefiles are not included.

```bash
cd cocotb-wrap && make venv
cd cocotb-wrap && make all          # all five
cd cocotb-wrap/woods-lab-lms && make
```

DUT RTL is compiled from the original lab path (no copy). Simulator is Verilator.

## Windows (PC2023)

Same rule as [`../verilator-wrap/WINDOWS.md`](../verilator-wrap/WINDOWS.md): use the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). Linux/mac: ordinary `verilator`.

```bash
make VERILATOR=verilator_bin.exe
```

## Why these five (not every lab)

| Wrap | Adds |
|------|------|
| `woods-lab-lms` | random plant, bit-exact vs Python LMS |
| `nptel-lab-dlms` | random `d=k·x` plant, LMS vs DLMS both converge |
| `woods-lab-cordic` | random angles vs integer CORDIC golden |
| `woods-lab-da-fir` | random unsigned samples vs MAC golden |
| `p3-fir-nco` | random FIR stream + sat corners vs Python FIR |

CSD mul, Baugh–Wooley, parallel FIR, etc. already have exhaustive/grid C++ TBs in `verilator-wrap/`.
