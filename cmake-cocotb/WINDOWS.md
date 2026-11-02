# Windows cmake-cocotb (PC2023)

This tree only **invokes** `cocotb-wrap/` GNU Makefiles. It does not call `verilate()` or `RtlLabSim.cmake`.

## Rules (unchanged)

Same as [`../verilator-wrap/WINDOWS.md`](../verilator-wrap/WINDOWS.md):

- [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows), not a random unofficial drop
- Drive **`verilator_bin.exe`** (PE32+). Never the extensionless Perl `verilator` (Explorer/CMD “Open with…”)
- Worker workspace: `D:\CursorWorker`

The wrap Makefile uses [`../cocotb-wrap/common/vlt-win.mk`](../cocotb-wrap/common/vlt-win.mk) for that PE search.

Needs GNU make (`mingw32-make` / MSYS2 `make`) and `cocotb-wrap/.venv` (`make -C cocotb-wrap venv`).

## Soft-skip

If the venv, GNU make, or withlimon PE is missing, configure still succeeds; `sim` / ctest **SKIP** rather than fail. See [`README.md`](README.md).

MSVC `-fcoroutines*` stripping is in `cmake/RtlLabSim.cmake` only (Verilator C++ trees). This project is `LANGUAGES NONE`.
