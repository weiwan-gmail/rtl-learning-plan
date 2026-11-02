# Woods leftovers (not wrapped)

Representative Verilator wraps cover FIR/retiming, LMS, DA, arith, CORDIC, and FFT. The other `woods-fpga-sp/lab-*` trees stay iverilog-only for now.

| Lab | Why skipped |
|-----|-------------|
| `lab-iir1` | Same 1st-order IIR idea as `nptel-lab-iir-retime` |
| `lab-biquad` | DF-I already compared (parallel vs fold) in `nptel-lab-biquad-fold` |
| `lab-da-fir-signed` | Signed DA variant of wrapped `woods-lab-da-fir` |
| `lab-rcm` | Constant-mul / shift-add, covered in spirit by `nptel-lab-csd-mul` |
| `lab-rls1` | Adaptive; LMS wraps (`woods-lab-lms`, `nptel-lab-dlms`) represent the class |
| `lab-div-nr` | Extra arith (restoring divide); CLA + array mul already wrapped |
| `lab-rns35` | Extra arith (RNS); not needed for the diverse set |
| `lab-sqrt16` | Extra arith (digit sqrt) |
| `lab-lns-mul` | Extra arith (LNS) |
| `lab-givens2` | QR building block; FFT/CORDIC already cover “structured DSP arith” |
| `lab-sgr2` | Unnormalized Givens; same bucket as givens2 |

PLACEHOLDER dirs (`ch05-vendor-fpga`, `ch07-hls-vivado`, …) stay stubs — no Vivado.
