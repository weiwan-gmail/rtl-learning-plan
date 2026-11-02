# cmake-conan — Conan 2 + 本地 Verilator recipe

与 [protosim-apb](https://github.com/weiwan-gmail/protosim-apb) 相同的双树之二。CMakeLists 与 `cmake-system/` 共用 [`../cmake/RtlLabSim.cmake`](../cmake/RtlLabSim.cmake)；依赖通过 Conan 2 提供。

Does **not** change iverilog labs, `verilator-wrap/` Make, or `cocotb-wrap/` (cocotb stays Make-only).

## Layout

| Path | Role |
|------|------|
| `CMakeLists.txt` | `PreferUnixGcc` → export local recipe → `conan_provider.cmake` → `RtlLabSim` |
| `conanfile.py` | `tool_requires("verilator/5.052")` + CMakeDeps build context |
| `conan_provider.cmake` | Vendored [conan-io/cmake-conan](https://github.com/conan-io/cmake-conan) develop2 |
| `recipes/verilator/` | Local recipe: **withlimon** tarball / `D:\verilator` on Windows; system kit on Linux |
| `profiles/linux-gcc` | Linux GCC 13 |
| `profiles/windows-msvc` | VS2022 / MSVC 193 (PC2023 CMake path) |
| `build_sim.ps1` | PC2023 helper |

Targets are the same as cmake-system: all 19 `verilator-wrap/` PASS labs plus `sim-fail` (inject-and-catch). Table: [`../cmake/labs.cmake`](../cmake/labs.cmake). See [`../cmake-system/README.md`](../cmake-system/README.md).

## Linux

Needs Conan 2 (`pip install conan`; this VM proved **2.34.0**) and a system Verilator kit (`apt install verilator`). The local recipe **packages the system kit** (does not rebuild Verilator from source).

```bash
export PATH="$HOME/.local/bin:$PATH"   # if pip --user
conan profile detect --force
cmake -S cmake-conan -B build-conan -DCMAKE_BUILD_TYPE=Release
cmake --build build-conan --target sim
cmake --build build-conan --target sim-fail
ctest --test-dir build-conan --output-on-failure
```

If Conan is missing, use `cmake-system/` instead; this tree still ships.

Linux VM evidence (Conan **2.34.0**): [`PASS_EVIDENCE.md`](PASS_EVIDENCE.md).

## Windows (PC2023)

| Item | Value |
|------|--------|
| Worker | `D:\CursorWorker` |
| Conan | **2.34** |
| Verilator | [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) **`verilator_bin.exe`** |

```powershell
cd cmake-conan
.\build_sim.ps1
```

Full copy-paste: [`../cmake-system/WINDOWS.md`](../cmake-system/WINDOWS.md). The recipe prefers `D:\verilator` if present, otherwise the MSYS2 prefix / withlimon **5.052** tarball. Always the PE `verilator_bin.exe` — never extensionless Perl `verilator`. PC2023 proof: [`WINDOWS_PASS_EVIDENCE.md`](WINDOWS_PASS_EVIDENCE.md). `conan install` uses `--no-remote` so extra remotes cannot prompt for a password.

MSVC: `CheckCXXCompilerFlag` before `verilate()`, then strip `-fcoroutines*`.
