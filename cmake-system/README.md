# cmake-system — 系统 Verilator（无 Conan）

与 [protosim-apb](https://github.com/weiwan-gmail/protosim-apb) 相同的双树之一：这里只用**本机已安装的 Verilator**，不跑 Conan。

Does **not** change iverilog labs, `verilator-wrap/` Make, or `cocotb-wrap/` (cocotb stays Make-only).

## 代表矩阵 / representative matrix

CMake 只编一组 wrap（相对路径引用原 DUT，不复制 RTL）：

| Target | Wrap / lab | Track |
|--------|------------|--------|
| `sim_csd_mul` | `verilator-wrap/nptel-lab-csd-mul` → `nptel-vlsi-sp/lab-csd-mul` | NPTEL |
| `sim_da_fir4` | `verilator-wrap/woods-lab-da-fir` | Woods |
| `sim_woods_arith` | `verilator-wrap/woods-lab-arith` | Woods |
| `sim_p3_fir_nco` | `verilator-wrap/p3-fir-nco` | P3 |
| `sim_p7_cic` | `verilator-wrap/p7-cic` | P7 |
| `sim` | 依次跑上面五个，全部 PASS | |
| `sim-fail` | 同一 CSD DUT，**故意写错 golden**；`ExpectFail.cmake` 仅在捕获 `FAIL` 时成功 | inject-and-catch |

Shared helpers: [`../cmake/RtlLabSim.cmake`](../cmake/RtlLabSim.cmake), [`../cmake/PreferUnixGcc.cmake`](../cmake/PreferUnixGcc.cmake).

## Linux

```bash
cmake -S cmake-system -B build-system -DCMAKE_BUILD_TYPE=Release
cmake --build build-system --target sim
cmake --build build-system --target sim-fail
ctest --test-dir build-system --output-on-failure
```

Unix 上 `PreferUnixGcc.cmake` 在 `project()` 前优先选 `g++`/`gcc`。

Linux VM evidence: [`PASS_EVIDENCE.md`](PASS_EVIDENCE.md).

## Windows (PC2023)

[withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) + **`verilator_bin.exe`**. Never the extensionless Perl `verilator`.

```powershell
cd cmake-system
.\build_sim.ps1
```

Copy-paste notes (worker `D:\CursorWorker`, Conan **not** required here): [`WINDOWS.md`](WINDOWS.md).

## `sim-fail` semantics

`cmake/fail-harness/tb_intentional_fail.cpp` verilates original `csd_mul.v` and checks `y==0` for `x=1,*29` (true result is 29). A working DUT **must** print `FAIL` and exit 1. The `sim-fail` target / ctest wrapper succeeds only when that failure is caught — same idea as ProtoSim `sim-fail`.
