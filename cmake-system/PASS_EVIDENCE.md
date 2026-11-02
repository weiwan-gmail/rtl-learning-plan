# cmake-system PASS evidence (Linux Cursor VM)

Recorded **2026-11-02** on this Cloud Agent Linux VM (`cursor`, Ubuntu, x86_64).

| Tool | Version |
|------|---------|
| CMake | 3.28.3 |
| g++ | 13.3.0 |
| Verilator | 5.020 (Debian 5.020-1), `verilator_bin` at `/bin/verilator_bin`, kit `/usr/share/verilator` |
| Conan | not used in this tree |

Windows PC2023 (withlimon `verilator_bin.exe`, worker `D:\CursorWorker`) is a follow-up; see [`WINDOWS.md`](WINDOWS.md).

## Make paths still green (spot-check; full iverilog/wrap `make all` not re-run)

Original lab Makefiles were **not** edited.

```
# p1-counter-add (iverilog)
PASS tb_counter8 cycles=264 errors=0
PASS tb_add32 directed=10 random=2000 errors=0
ALL PASS

# p3-fir-nco (iverilog)
PASS nco
PASS numpy impulse y=[1000, 2000, 2000, 1000, 0]
METRIC bit-exact=YES checked=520 RMSE=0.0 SNR_dB=inf
ALL PASS

# woods-fpga-sp/lab-da-fir (iverilog)
PASS da_fir4 n_checked=27 mismatches=0
ALL PASS

# verilator-wrap/nptel-lab-csd-mul
PASS csd-mul *29 and *-19 n=84

# verilator-wrap/woods-lab-da-fir
PASS da_fir4 n_checked=27 mismatches=0
```

`verilator-wrap && make all` (19 wraps) was **not** fully re-run here (time); CMake matrix covers NPTEL CSD, Woods DA+arith, P3, P7.

## cmake-system

```bash
cmake -S cmake-system -B build-system -DCMAKE_BUILD_TYPE=Release
cmake --build build-system --target sim
cmake --build build-system --target sim-fail
ctest --test-dir build-system --output-on-failure
```

`--target sim`:

```
PASS csd-mul *29 and *-19 n=84
METRIC CSD_29=100T01 CSD_M19=T0T01
PASS da_fir4 n_checked=27 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS cla_add16+array_mult8 n=46 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS fir4 checked=104
PASS nco checked=128
PASS p3-fir-nco fir+nco bit-exact
PASS cic_decim bit-exact n_in=384 n_out=96 N=2 R=4 M=1
[100%] Built target sim
```

`--target sim-fail` (inject-and-catch):

```
-- sim-fail stdout:
FAIL intentional mismatch (cmake sim-fail harness)
-- sim-fail: caught expected FAIL (exit 1)
[100%] Built target sim-fail
```

`ctest`:

```
100% tests passed, 0 tests failed out of 6
```

(`sim_csd_mul`, `sim_da_fir4`, `sim_woods_arith`, `sim_p3_fir_nco`, `sim_p7_cic`, `sim-fail`)
