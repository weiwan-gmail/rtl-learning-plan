# cmake-system PASS evidence (Linux Cursor VM)

Recorded **2026-11-02** on this Cloud Agent Linux VM (`cursor`, Ubuntu, x86_64). Expanded wrap matrix (30 PASS + `sim-fail`): original 19 plus 11 new Woods wraps.

| Tool | Version |
|------|---------|
| CMake | 3.28.3 |
| g++ | 13.3.0 |
| Verilator | 5.020 (Debian 5.020-1), `verilator_bin` at `/bin/verilator_bin`, kit `/usr/share/verilator` |
| Conan | not used in this tree |

Windows PC2023 (withlimon `verilator_bin.exe`, worker `D:\CursorWorker`) is proven for the **original 5-lab** matrix in [`WINDOWS_PASS_EVIDENCE.md`](WINDOWS_PASS_EVIDENCE.md). Expanded 30-lab Windows re-run is a follow-up; [`WINDOWS.md`](WINDOWS.md) PE / MSVC notes still apply. cocotb is **not** in this tree — [`../cmake-cocotb/PASS_EVIDENCE.md`](../cmake-cocotb/PASS_EVIDENCE.md).

## Make paths still green (spot-check)

Original lab Makefiles were **not** edited. Each new `verilator-wrap/woods-lab-*` `make all` PASS (see [`../verilator-wrap/PASS_EVIDENCE.md`](../verilator-wrap/PASS_EVIDENCE.md)). Touched Woods iverilog labs `make all` PASS.

## cmake-system

```bash
cmake -S cmake-system -B build-system -DCMAKE_BUILD_TYPE=Release
cmake --build build-system --target sim
cmake --build build-system --target sim-fail
ctest --test-dir build-system --output-on-failure
```

Configure:

```
-- RtlLabSim: VERILATOR_BIN=/bin/verilator_bin
-- RtlLabSim: VERILATOR_ROOT=/usr/share/verilator
-- RtlLabSim: 30 PASS labs from cmake/labs.cmake + sim_fail_csd
-- Executing Verilator... (×31)
-- Configuring done
```

`--target sim` (all 30 `verilator-wrap/` labs, including the previous 19):

```
PASS fir-transpose direct+transposed n=24 mismatches=0
METRIC SAME_BITEXACT=1 LINEAR_PHASE_H=1,2,2,1
PASS iir-retime combo+pipe n=17 mismatches=0
METRIC LATENCY_COMBO=1 LATENCY_PIPE=2 SAME_BITEXACT=1
INFO LMS  w0=3
INFO DLMS w0=3
PASS dlms LMS+DLMS plant d=3x  LMS_w0=3 DLMS_w0=3
METRIC DLMS_D=1 MUSHIFT=6 SAME_PLANT=1
PASS fir-2par serial vs even/odd polyphase bit-exact n_serial=32
METRIC PARALLEL=2 SAME_BITEXACT=1
PASS fir-3par vs serial golden n=30 mismatches=0
METRIC PARALLEL=3 SAME_BITEXACT=1
PASS biquad-fold parallel vs N=5 folded n=13
METRIC FOLDING_FACTOR=5 SAME_BITEXACT=1
PASS bitserial-fir y=-3x+3x_d n=12
METRIC LSB_LATENCY=3 W=8
PASS baugh-wooley8 n=327 mismatches=0
METRIC SIGNED_ARRAY=1
PASS csd-mul *29 and *-19 n=84
METRIC CSD_29=100T01 CSD_M19=T0T01
PASS lookahead-iir clustered 2-step vs integrator n=16
METRIC LOOKAHEAD=clustered LATENCY_PIPE=2 SAME_BITEXACT=1
PASS retiming fir3 combo+pipe n=20 mismatches=0
METRIC LATENCY_COMBO=1 LATENCY_PIPE=3 SAME_BITEXACT=1
INFO final w0=2 w1=1 (plant 2, 1)
PASS lms2 n_checked=256 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS da_fir4 n_checked=27 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS cla_add16+array_mult8 n=46 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS cordic_rotate n_vec=8 mismatches=0
PASS cordic_vector n_vec=7 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS fft8 vectors=4 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS iir1 n_checked=58 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS biquad_df1 n=26 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS da_fir4_signed n=26 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS rcm_const_mul n=36 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS rls1 n=20 final_w=3 w_q=821 p=1 mismatches=0
METRIC RMSE=0 SNR_dB=999 TARGET_W=3
PASS divu16_restoring n=749 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS rns35 n=574 mismatches=0
METRIC RMSE=0 SNR_dB=999 M=35
PASS sqrt16 n=92 mismatches=0
METRIC RMSE=0 SNR_dB=999
PASS lns_mul8 n=1024 mismatches=0
METRIC RMSE=0 SNR_dB=999 DOMAIN=1..32
PASS givens_apply n=5 mismatches=0
METRIC RMSE=0 SNR_dB=999 NULL_DEMO=1
PASS sgr_step n=9 mismatches=0
METRIC RMSE=0 SNR_dB=999 NULL_R2=1 NO_SQRT=1
PASS fir4 checked=104
PASS nco checked=128
PASS p3-fir-nco fir+nco bit-exact
PASS cic_decim bit-exact n_in=384 n_out=96 N=2 R=4 M=1
METRIC DC settle=288 n_out=64
PASS sdr_loop DC bit-exact A=3
METRIC DC settle=-192 n_out=32
PASS sdr_loop DC bit-exact A=-2
METRIC RMSE=0 SNR_dB=999 n_out=128
PASS sdr_loop TONE bit-exact fw=0x10000000
METRIC RMSE=0 SNR_dB=999 n_out=128
PASS sdr_loop TONE bit-exact fw=0x04000000
PASS sdr_loop all cases bit-exact
[100%] Built target sim
```

`--target sim-fail` (inject-and-catch):

```
-- sim-fail stdout:
FAIL intentional mismatch (cmake sim-fail harness)
-- sim-fail: caught expected FAIL (exit 1)
[100%] Built target sim-fail
```

`ctest`:

```
100% tests passed, 0 tests failed out of 31
```

(30 PASS labs + `sim-fail`)
