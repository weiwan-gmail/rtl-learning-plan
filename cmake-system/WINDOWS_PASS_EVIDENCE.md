# cmake-system Windows PASS evidence (PC2023)

Recorded **2026-11-02** on worker **PC2023**, checkout `D:\CursorWorker\rtl-learning-plan`, branch `cursor/cmake-dual-tree-c4c8`.

| Item | Value |
|------|--------|
| Host | PC2023 |
| CMake | 3.30.3 |
| Generator | Visual Studio 17 2022 (`C:\Program Files\Microsoft Visual Studio\2022\Community`) |
| MSVC | 19.44.35229.0 (`VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\cl.exe`) |
| Verilator engine | `C:\msys64\mingw64\bin\verilator_bin.exe` — **PE32+ MZ (`4D5A`)**, 14655015 bytes, `Verilator 5.046 2026-02-28` |
| `VERILATOR_ROOT` | `C:\msys64\mingw64\share\verilator` |
| Conan | not used in this tree |
| `D:\verilator` | not present; WINDOWS.md lists the MSYS2 unpack of the [withlimon](https://github.com/withlimon/verilator-windows) layout as the fallback |

Do **not** run:

- `C:\msys64\mingw64\bin\verilator` (extensionless Perl; Open-with)
- `C:\msys64\mingw64\share\verilator\bin\verilator_bin.exe` (684-byte Perl wrapper, first bytes `#!` / `2321`)

## Commands (WINDOWS.md + `build_sim.ps1`)

```bat
cd /d D:\CursorWorker\rtl-learning-plan
cd cmake-system
powershell -File .\build_sim.ps1
```

Equivalent CMake (what the script ran):

```bat
cmake -S cmake-system -B cmake-system\build -DCMAKE_BUILD_TYPE=Release
cmake --build cmake-system\build --config Release --target sim
cmake --build cmake-system\build --config Release --target sim-fail
ctest --test-dir cmake-system\build -C Release --output-on-failure
```

Configure selected MSVC:

```
-- Building for: Visual Studio 17 2022
-- The CXX compiler identification is MSVC 19.44.35229.0
-- RtlLabSim: VERILATOR_BIN=C:/msys64/mingw64/bin/verilator_bin.exe
-- RtlLabSim: VERILATOR_ROOT=C:\msys64\mingw64\share\verilator
```

## `--target sim` PASS

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
```

## `--target sim-fail` (inject-and-catch) PASS

```
-- sim-fail stdout:
FAIL intentional mismatch (cmake sim-fail harness)
-- sim-fail: caught expected FAIL (exit 1)
```

## `ctest` PASS

```
100% tests passed, 0 tests failed out of 6
```

(`sim_csd_mul`, `sim_da_fir4`, `sim_woods_arith`, `sim_p3_fir_nco`, `sim_p7_cic`, `sim-fail`)

Script footer: `cmake-system PASS (sim + sim-fail + ctest)`

## Fixes needed on this worker (landed in this PR)

1. **Perl wrapper `.exe`.** First configure used `share/verilator/bin/verilator_bin.exe` (`find_program` HINTS `$VERILATOR_ROOT/bin`). Process start failed (`unknown error` / not a valid Win32 application). `RtlLabSim.cmake` and both `build_sim.ps1` now MZ-check `verilator_bin.exe` and prefer `D:\verilator\bin` / `C:\msys64\mingw64\bin`.
2. **MSVC `sc_time_stamp`.** `VL_ATTR_WEAK` is empty on MSVC, so `verilated.cpp` needs a real `sc_time_stamp`. Linked `cmake/sc_time_stamp.cpp` into every CMake sim.
