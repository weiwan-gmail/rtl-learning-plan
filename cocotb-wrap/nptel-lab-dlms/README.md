# Cocotb wrap: NPTEL lab-dlms

Random `d=3x` plant; LMS and delayed-LMS both converge. Original: [`nptel-vlsi-sp/lab-dlms`](../../nptel-vlsi-sp/lab-dlms/).

```bash
cd nptel-lab-dlms && make
```

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). See [../../verilator-wrap/WINDOWS.md](../../verilator-wrap/WINDOWS.md). Linux/mac: ordinary `verilator`.
