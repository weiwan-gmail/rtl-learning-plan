# cmake-system — 系统 Verilator（无 Conan）

与 [protosim-apb](https://github.com/weiwan-gmail/protosim-apb) 相同的双树之一：这里只用**本机已安装的 Verilator**，不跑 Conan。

Does **not** change iverilog labs, `verilator-wrap/` Make, or `cocotb-wrap/` (cocotb stays Make-only).

## Matrix

CMake 编 **全部 19 个** `verilator-wrap/` lab（相对路径引用原 DUT，不复制 RTL）。添加一个 lab = [`../cmake/labs.cmake`](../cmake/labs.cmake) 里一行 `rtl_lab_define()`；`CMakeLists.txt` 保持薄封装。

| Target | Wrap | Track |
|--------|------|--------|
| `sim_fir_transpose` | `nptel-lab-fir-transpose` | NPTEL |
| `sim_iir_retime` | `nptel-lab-iir-retime` | NPTEL |
| `sim_dlms` | `nptel-lab-dlms` | NPTEL |
| `sim_fir_2par` | `nptel-lab-fir-2par` | NPTEL |
| `sim_fir_3par` | `nptel-lab-fir-3par` | NPTEL |
| `sim_biquad_fold` | `nptel-lab-biquad-fold` | NPTEL |
| `sim_bitserial_fir` | `nptel-lab-bitserial-fir` | NPTEL |
| `sim_baugh_wooley` | `nptel-lab-baugh-wooley` | NPTEL |
| `sim_csd_mul` | `nptel-lab-csd-mul` | NPTEL |
| `sim_lookahead_iir` | `nptel-lab-lookahead-iir` | NPTEL |
| `sim_retiming_fir` | `woods-lab-retiming-fir` | Woods |
| `sim_lms` | `woods-lab-lms` | Woods |
| `sim_da_fir4` | `woods-lab-da-fir` | Woods |
| `sim_woods_arith` | `woods-lab-arith` | Woods |
| `sim_cordic` | `woods-lab-cordic` | Woods |
| `sim_fft8` | `woods-lab-fft8` | Woods |
| `sim_p3_fir_nco` | `p3-fir-nco` | P3 |
| `sim_p7_cic` | `p7-cic` | P7 |
| `sim_p11_sdr_loop` | `p11-sdr-loop` | P11 |
| `sim` | 依次跑上面 19 个，全部 PASS | |
| `sim-fail` | 同一 CSD DUT，**故意写错 golden**；`ExpectFail.cmake` 仅在捕获 `FAIL` 时成功 | inject-and-catch |

Skip: Woods labs that were **never wrapped** stay iverilog-only — [`../verilator-wrap/SCOPE.md`](../verilator-wrap/SCOPE.md). cocotb stays Make-only.

Shared helpers: [`../cmake/RtlLabSim.cmake`](../cmake/RtlLabSim.cmake), [`../cmake/PreferUnixGcc.cmake`](../cmake/PreferUnixGcc.cmake), [`../cmake/labs.cmake`](../cmake/labs.cmake).

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

Copy-paste notes (worker `D:\CursorWorker`, Conan **not** required here): [`WINDOWS.md`](WINDOWS.md). PC2023 proof: [`WINDOWS_PASS_EVIDENCE.md`](WINDOWS_PASS_EVIDENCE.md).

## `sim-fail` semantics

`cmake/fail-harness/tb_intentional_fail.cpp` verilates original `csd_mul.v` and checks `y==0` for `x=1,*29` (true result is 29). A working DUT **must** print `FAIL` and exit 1. The `sim-fail` target / ctest wrapper succeeds only when that failure is caught — same idea as ProtoSim `sim-fail`.
