# cmake-conan Windows PASS evidence (PC2023)

Recorded **2026-11-02** on worker **PC2023**, checkout `D:\CursorWorker\rtl-learning-plan`, branch `cursor/cmake-dual-tree-c4c8`. Same MSVC + withlimon-layout PE as [`../cmake-system/WINDOWS_PASS_EVIDENCE.md`](../cmake-system/WINDOWS_PASS_EVIDENCE.md).

This run is the original **5-lab** representative matrix. The expanded 30-lab wrap matrix is Linux-proven; a PC2023 re-run of `build_sim.ps1` is a follow-up. cocotb is `cmake-cocotb/`, not this tree.

| Item | Value |
|------|--------|
| Host | PC2023 |
| CMake | 3.30.3 |
| Generator | Visual Studio 17 2022 |
| MSVC | 19.44.35229.0 (auto-cmake `compiler.version=194`) |
| Conan | **2.34.0** (`C:\Python\Python315\Scripts\conan.exe`) |
| Recipe | local `verilator/5.052` (does **not** Autotools-build; packages the PE kit) |
| Packaged kit | `C:\msys64\mingw64` → `C:\Users\a\.conan2\p\b\veril0c69ac0a7ea47\p` |
| Packaged PE | `...\p\bin\verilator_bin.exe` — **MZ `4D5A`**, 14655015 bytes (copy of withlimon-layout MSYS2 engine 5.046) |
| `VERILATOR_BIN` (driven) | `C:/msys64/mingw64/bin/verilator_bin.exe` (same PE) |
| `VERILATOR_ROOT` | Conan package folder (headers + kit `verilator-config.cmake`) |

## Commands (WINDOWS.md + `build_sim.ps1`)

```bat
cd /d D:\CursorWorker\rtl-learning-plan\cmake-conan
conan profile detect --force
powershell -File .\build_sim.ps1
```

`conan profile detect --force` guessed **msvc 18 / compiler.version=195** (VS Community 2026 is installed). The cmake-conan provider used **auto-cmake → MSVC 19.44 / compiler.version=194** (Visual Studio 17 2022), which is what actually compiled.

Provider `conan install` (Release, then Debug; same package id because `package_id` is cleared):

```
conan install cmake-conan -of=cmake-conan/build/conan
  --profile:host=cmake-conan/build/conan_host_profile
  --profile:build=cmake-conan/build/conan_host_profile
  -s build_type=Release --build=missing --no-remote
```

## Packaging (protosim-apb pattern) PASS

```
Build requirements
    verilator/5.052#2ca60c144396e930fa426bddb5d8ba64 - Cache
...
Packaging local withlimon kit at C:\msys64\mingw64
package(): Packaged 1 '.cmake' file: verilator-config.cmake
package(): Packaged 1 '.exe' file: verilator_bin.exe
...
Install finished successfully
-- RtlLabSim: Conan package folder C:/Users/a/.conan2/p/b/veril0c69ac0a7ea47/p
-- RtlLabSim: VERILATOR_BIN=C:/msys64/mingw64/bin/verilator_bin.exe
-- RtlLabSim: VERILATOR_ROOT=C:/Users/a/.conan2/p/b/veril0c69ac0a7ea47/p
```

No Autotools. Engine is the packaged withlimon-layout PE (5.046), not a from-source 5.052 rebuild.

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

## `--target sim-fail` PASS

```
-- sim-fail stdout:
FAIL intentional mismatch (cmake sim-fail harness)
-- sim-fail: caught expected FAIL (exit 1)
```

## `ctest` PASS

```
100% tests passed, 0 tests failed out of 6
```

Script footer: `cmake-conan PASS (sim + sim-fail + ctest)`

## Blockers hit, then unblocked

### 1. Extra Conan remote password prompt (exact error)

First `conan install` **without** `--no-remote` (recipe already in cache):

```
Connecting to remote 'conancenter' anonymously
Connecting to remote 'conan-local' with user 'user01'
Remote 'conan-local' needs authentication, obtaining credentials
Remote 'conan-local' username: ERROR: EOF when reading a line. [Remote: conan-local]
Conan install failed='1'
```

`conan-local` is `http://artifactory.dev.link123.com/artifactory/api/conan/conan-local`. Fix: `CONAN_INSTALL_ARGS=--build=missing;--no-remote` (CMakeLists + `build_sim.ps1`). Graph is the local recipe only.

### 2. `--make cmake` vs engine 5.046 (exact error)

After packaging, the 5.020 fallback config passed `--make cmake`:

```
Verilator command: "C:/msys64/mingw64/bin/verilator_bin.exe ... --make cmake ..."
%Error: Unknown --make system specified: 'cmake'
```

5.046 wants `--make json` (same as the MSYS2 kit `verilator-config.cmake`). Recipe now copies that kit cmake into the package **after** `bin/verilator_bin.exe` is the PE; fallback probes json vs cmake.

### 3. Same PE / `sc_time_stamp` fixes as cmake-system

MZ-check so `VERILATOR_ROOT=share/verilator` does not package or execute the Perl wrapper `.exe`. MSVC stub `cmake/sc_time_stamp.cpp`.
