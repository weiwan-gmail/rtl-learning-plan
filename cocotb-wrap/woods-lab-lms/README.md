# Cocotb wrap: Woods lab-lms

Randomized 2-tap LMS vs Python golden. Original: [`woods-fpga-sp/lab-lms`](../../woods-fpga-sp/lab-lms/).

```bash
# from cocotb-wrap/ after `make venv`
cd woods-lab-lms && make
```

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). See [../../verilator-wrap/WINDOWS.md](../../verilator-wrap/WINDOWS.md). Linux/mac: ordinary `verilator`.
