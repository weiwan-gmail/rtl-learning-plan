# Verilator wrap: P11 SDR loopback (NCO→FIR→CIC)

Separate **C++** testbench. DUT RTL is compiled from the original lab via relative paths — **no wholesale copy**.

| | |
|--|--|
| Original iverilog lab | [`p11-sdr-loop`](../../p11-sdr-loop/) — `cd p11-sdr-loop && make` is unchanged |
| PASS command | `cd verilator-wrap/p11-sdr-loop && make all` |
| DUT sources | `sdr_loop.v + p3 nco/fir4 + p7 cic_decim (relative, no copy)` |

## Run

```bash
# Linux / macOS
make all

# Windows (PC2023): withlimon layout + verilator_bin.exe — see WINDOWS.md
make all VERILATOR=verilator_bin.exe
```

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). Details: [`WINDOWS.md`](../WINDOWS.md). Linux/mac: ordinary `verilator`.

Requires Verilator 5.x and g++. Does **not** require iverilog, cocotb, or Vivado.
