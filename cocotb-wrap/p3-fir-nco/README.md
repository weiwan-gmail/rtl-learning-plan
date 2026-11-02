# Cocotb wrap: P3 fir4

Random stream + saturation corners vs Python FIR golden. Original: [`p3-fir-nco`](../../p3-fir-nco/).

```bash
cd p3-fir-nco && make
```

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). See [../../verilator-wrap/WINDOWS.md](../../verilator-wrap/WINDOWS.md). Linux/mac: ordinary `verilator`.
