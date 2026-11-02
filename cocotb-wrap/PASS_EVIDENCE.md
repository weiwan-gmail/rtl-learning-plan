# Cocotb wrap PASS evidence

Command: `cd cocotb-wrap && make venv && make all`

Linux, Verilator 5.020, cocotb 1.9.2 (venv). Windows PC2023: [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) + `verilator_bin.exe` — see [`../verilator-wrap/WINDOWS.md`](../verilator-wrap/WINDOWS.md).

```
==== cocotb-wrap/woods-lab-lms ====
PASS woods-lab-lms cocotb n=256 w0=2 w1=1
** test_lms.test_lms_random_plant   PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0

==== cocotb-wrap/nptel-lab-dlms ====
PASS nptel-lab-dlms cocotb LMS_w0=3 DLMS_w0=3
** test_dlms.test_dlms_random_gain   PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0

==== cocotb-wrap/woods-lab-cordic ====
PASS woods-lab-cordic cocotb n=15
** test_cordic.test_cordic_random_angles   PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0

==== cocotb-wrap/woods-lab-da-fir ====
PASS woods-lab-da-fir cocotb n=47
** test_da_fir.test_da_random     PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0

==== cocotb-wrap/p3-fir-nco ====
PASS p3-fir-nco cocotb fir4 n=97
** test_fir4.test_fir4_random     PASS
** TESTS=1 PASS=1 FAIL=0 SKIP=0

ALL COCOTB WRAPS PASS
```
