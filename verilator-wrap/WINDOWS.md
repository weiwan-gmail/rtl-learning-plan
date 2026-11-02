# Windows Verilator (PC2023)

This tree is optional. Original iverilog labs do **not** read these notes.

PC2023 uses the **withlimon** native Windows build/layout — not a random unofficial drop:

- Repo / releases: [https://github.com/withlimon/verilator-windows](https://github.com/withlimon/verilator-windows)
- Latest tarball example: `verilator-windows-windows_amd64-<ver>.tar.gz` from that repo’s Releases.

## Layout to prefer

Extract to a **short path without spaces** (withlimon’s own example is `D:\verilator`):

```
<VERILATOR_ROOT>/
  bin/verilator_bin.exe     PE32+ engine  ← drive Make with this
  bin/verilator.exe         same PE, renamed copy (what verilator.bat calls)
  bin/verilator.bat         sets VERILATOR_ROOT from its folder, then verilator.exe
  bin/verilator             Perl driver, **no extension**
  include/                  (also mirrored under share/verilator/include/)
  README_WINDOWS.txt
```

Set:

```
VERILATOR_ROOT = D:\verilator          (extract root, parent of bin/)
PATH          += D:\verilator\bin
```

If the same tarball was unpacked into MSYS2 MinGW64, the PE still lives next to the Perl driver, e.g. `C:\msys64\mingw64\bin\verilator_bin.exe`. Makefiles search PATH, `VERILATOR_ROOT/bin`, `D:\verilator\bin`, then that MSYS2 path.

## Do not use the extensionless Perl `verilator`

`bin/verilator` (no `.exe`) is the Perl driver. Double-clicking it from Explorer, or invoking it from some CMD associations, pops **“Open with…”**. Wrap Makefiles therefore prefer `verilator_bin.exe`.

From cmd / Explorer-adjacent shells:

```bat
make all VERILATOR=verilator_bin.exe
```

From MSYS2 MinGW64 bash (if that `bin` is on PATH):

```bash
export VERILATOR_ROOT=/d/verilator
export PATH="$VERILATOR_ROOT/bin:$PATH"
make -C verilator-wrap all
# or: bash -lc "make -C verilator-wrap all VERILATOR=verilator_bin.exe"
```

`verilator.bat` from the withlimon package is fine for interactive CMD because it sets `VERILATOR_ROOT` and then runs `verilator.exe`. Make in this repo still targets `verilator_bin.exe` so it never hits the Perl script.

## Linux / macOS

Unchanged: `verilator` (Perl driver execs `verilator_bin` for you). Do not set `VERILATOR=verilator_bin.exe` unless that file actually exists.
