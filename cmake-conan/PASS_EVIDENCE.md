# cmake-conan PASS evidence (Linux Cursor VM)

Recorded **2026-11-02** on this Cloud Agent Linux VM (`cursor`, Ubuntu, x86_64).

| Tool | Version |
|------|---------|
| CMake | 3.28.3 |
| g++ | 13.3.0 (PreferUnixGcc; `conan profile detect` guessed clang, provider used **auto-cmake → gcc 13**) |
| Verilator | local recipe `verilator/5.052` **packaged the system 5.020 kit** (did not rebuild from source) |
| Conan | **2.34.0** (`pip install --user conan`) — same major/minor as PC2023 |

Windows PC2023 (Conan 2.34 + withlimon `verilator_bin.exe`, worker `D:\CursorWorker`) is a follow-up; see [`../cmake-system/WINDOWS.md`](../cmake-system/WINDOWS.md).

## Configure

```bash
export PATH="$HOME/.local/bin:$PATH"
conan profile detect --force
cmake -S cmake-conan -B build-conan -DCMAKE_BUILD_TYPE=Release
```

Conan install used in-tree `recipes/verilator` (`tool_requires("verilator/5.052")`). Package folder supplied `VERILATOR_ROOT` / `include/verilated.h`; `verilate()` came from the packaged kit cmake + RtlLabSim.

```
======== Installing packages ========
-------- Installing package verilator/5.052 ...
Calling package()
package(): Packaged 1 '.cmake' file: verilator-config.cmake
...
Install finished successfully
-- RtlLabSim: Conan package folder /home/ubuntu/.conan2/p/b/veril.../p
-- Executing Verilator... (×6)
-- Configuring done
```

## sim / sim-fail / ctest

```bash
cmake --build build-conan --target sim
cmake --build build-conan --target sim-fail
ctest --test-dir build-conan --output-on-failure
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

`--target sim-fail`:

```
-- sim-fail stdout:
FAIL intentional mismatch (cmake sim-fail harness)
-- sim-fail: caught expected FAIL (exit 1)
[100%] Built target sim-fail
```

`ctest`: **100% tests passed, 0 tests failed out of 6**.
