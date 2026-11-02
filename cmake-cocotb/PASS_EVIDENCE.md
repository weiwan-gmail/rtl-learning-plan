# cmake-cocotb PASS evidence (Linux Cursor VM)

Recorded **2026-11-02** on this Cloud Agent Linux VM (`cursor`, Ubuntu, x86_64). Third CMake tree: invokes existing `cocotb-wrap/` Makefiles. Does **not** include `RtlLabSim.cmake` / `labs.cmake`.

| Tool | Version |
|------|---------|
| CMake | 3.28.3 |
| GNU make | `/usr/bin/gmake` |
| Verilator | 5.020 (Debian 5.020-1), `/bin/verilator` |
| Python | 3.12.3 |
| cocotb | 1.9.2 in `cocotb-wrap/.venv` |

Original `cd cocotb-wrap && make all` was **not** edited and stayed green after `make venv`.

## Soft-skip (no venv)

```bash
cmake -S cmake-cocotb -B build-cocotb
ctest --test-dir build-cocotb --output-on-failure
cmake --build build-cocotb --target sim
```

Configure (Verilator present, venv absent):

```
-- CocotbWrap: 5 labs from cmake/cocotb_labs.cmake
-- CocotbWrap: SKIP (cocotb-wrap/.venv missing (run: make -C cocotb-wrap venv). Make path requires that venv; system cocotb is not enough)
```

ctest: 5/5 **Skipped**, 0 failed. `--target sim` prints the same SKIP line and succeeds.

## Green path (venv + Verilator)

```bash
make -C cocotb-wrap venv
cmake -S cmake-cocotb -B build-cocotb
cmake --build build-cocotb --target sim
ctest --test-dir build-cocotb --output-on-failure
```

Configure:

```
-- CocotbWrap: 5 labs from cmake/cocotb_labs.cmake
-- CocotbWrap: GNUMAKE=/usr/bin/gmake
-- CocotbWrap: VENV_BIN=/workspace/cocotb-wrap/.venv/bin
-- CocotbWrap: VERILATOR=/bin/verilator
```

`--target sim`:

```
PASS woods-lab-lms cocotb n=256 w0=2 w1=1
** test_lms.test_lms_random_plant   PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0
PASS nptel-lab-dlms cocotb LMS_w0=3 DLMS_w0=3
** test_dlms.test_dlms_random_gain   PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0
PASS woods-lab-cordic cocotb n=15
** test_cordic.test_cordic_random_angles   PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0
PASS woods-lab-da-fir cocotb n=47
** test_da_fir.test_da_random     PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0
PASS p3-fir-nco cocotb fir4 n=97
** test_fir4.test_fir4_random     PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0
[100%] Built target sim
```

ctest:

```
100% tests passed, 0 tests failed out of 5
```

Make-only (same five wraps): `cd cocotb-wrap && make all` → `ALL COCOTB WRAPS PASS`.
