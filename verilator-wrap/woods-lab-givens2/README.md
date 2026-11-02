# Verilator wrap: Woods lab-givens2 (2x2 Givens apply)

Separate **C++** testbench. DUT RTL is compiled from the original lab via relative paths — **no wholesale copy**.

| | |
|--|--|
| Original iverilog lab | [`woods-fpga-sp/lab-givens2`](../../woods-fpga-sp/lab-givens2/) — `cd woods-fpga-sp/lab-givens2 && make` is unchanged |
| PASS command | `cd verilator-wrap/woods-lab-givens2 && make all` |
| DUT sources | `givens_apply.v` |

## Run

```bash
# Linux / macOS
make all

# Windows (PC2023): withlimon layout + verilator_bin.exe — see WINDOWS.md
make all VERILATOR=verilator_bin.exe
```

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`**. Do not invoke the extensionless Perl `verilator` (Explorer/CMD “Open with…”). Details: [`WINDOWS.md`](../WINDOWS.md). Linux/mac: ordinary `verilator`.

Requires Verilator 5.x and g++. Does **not** require iverilog, cocotb, or Vivado.
