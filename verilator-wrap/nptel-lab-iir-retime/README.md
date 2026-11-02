# Verilator wrap: NPTEL lab-iir-retime (combo vs pipelined IIR)

Separate **C++** testbench. DUT RTL is compiled from the original lab via relative paths — **no wholesale copy**.

| | |
|--|--|
| Original iverilog lab | [`nptel-vlsi-sp/lab-iir-retime`](../../nptel-vlsi-sp/lab-iir-retime/) — `cd nptel-vlsi-sp/lab-iir-retime && make` is unchanged |
| PASS command | `cd verilator-wrap/nptel-lab-iir-retime && make all` |
| DUT sources | `iir1_combo.v + iir1_pipe.v` |

## Run

```bash
# Linux / macOS
make all

# Windows (PC2023): withlimon layout + verilator_bin.exe — see WINDOWS.md
make all VERILATOR=verilator_bin.exe
```

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). Details: [`WINDOWS.md`](../WINDOWS.md). Linux/mac: ordinary `verilator`.

Requires Verilator 5.x and g++. Does **not** require iverilog, cocotb, or Vivado.
