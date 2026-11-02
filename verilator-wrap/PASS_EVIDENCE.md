# Verilator wrap PASS evidence

Command: `cd verilator-wrap && make all`

Recorded on Linux with distro Verilator 5.020 (Perl driver execs verilator_bin).
Windows PC2023: [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) + `verilator_bin.exe` — see WINDOWS.md.

```
==== verilator-wrap/nptel-lab-fir-transpose ====
PASS fir-transpose direct+transposed n=24 mismatches=0
METRIC SAME_BITEXACT=1 LINEAR_PHASE_H=1,2,2,1

==== verilator-wrap/nptel-lab-iir-retime ====
PASS iir-retime combo+pipe n=17 mismatches=0
METRIC LATENCY_COMBO=1 LATENCY_PIPE=2 SAME_BITEXACT=1

==== verilator-wrap/nptel-lab-dlms ====
INFO LMS  w0=3
INFO DLMS w0=3
PASS dlms LMS+DLMS plant d=3x  LMS_w0=3 DLMS_w0=3
METRIC DLMS_D=1 MUSHIFT=6 SAME_PLANT=1

==== verilator-wrap/nptel-lab-fir-2par ====
PASS fir-2par serial vs even/odd polyphase bit-exact n_serial=32
METRIC PARALLEL=2 SAME_BITEXACT=1

==== verilator-wrap/nptel-lab-fir-3par ====
PASS fir-3par vs serial golden n=30 mismatches=0
METRIC PARALLEL=3 SAME_BITEXACT=1

==== verilator-wrap/nptel-lab-biquad-fold ====
PASS biquad-fold parallel vs N=5 folded n=13
METRIC FOLDING_FACTOR=5 SAME_BITEXACT=1

==== verilator-wrap/nptel-lab-bitserial-fir ====
PASS bitserial-fir y=-3x+3x_d n=12
METRIC LSB_LATENCY=3 W=8

==== verilator-wrap/nptel-lab-baugh-wooley ====
PASS baugh-wooley8 n=327 mismatches=0
METRIC SIGNED_ARRAY=1

==== verilator-wrap/nptel-lab-csd-mul ====
PASS csd-mul *29 and *-19 n=84
METRIC CSD_29=100T01 CSD_M19=T0T01

==== verilator-wrap/nptel-lab-lookahead-iir ====
PASS lookahead-iir clustered 2-step vs integrator n=16
METRIC LOOKAHEAD=clustered LATENCY_PIPE=2 SAME_BITEXACT=1

==== verilator-wrap/woods-lab-retiming-fir ====
PASS retiming fir3 combo+pipe n=20 mismatches=0
METRIC LATENCY_COMBO=1 LATENCY_PIPE=3 SAME_BITEXACT=1

==== verilator-wrap/woods-lab-lms ====
INFO final w0=2 w1=1 (plant 2, 1)
PASS lms2 n_checked=256 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-da-fir ====
PASS da_fir4 n_checked=27 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-arith ====
PASS cla_add16+array_mult8 n=46 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-cordic ====
PASS cordic_rotate n_vec=8 mismatches=0
PASS cordic_vector n_vec=7 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-fft8 ====
PASS fft8 vectors=4 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-iir1 ====
PASS iir1 n_checked=58 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-biquad ====
PASS biquad_df1 n=26 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-da-fir-signed ====
PASS da_fir4_signed n=26 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-rcm ====
PASS rcm_const_mul n=36 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-rls1 ====
PASS rls1 n=20 final_w=3 w_q=821 p=1 mismatches=0
METRIC RMSE=0 SNR_dB=999 TARGET_W=3

==== verilator-wrap/woods-lab-div-nr ====
PASS divu16_restoring n=749 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-rns35 ====
PASS rns35 n=574 mismatches=0
METRIC RMSE=0 SNR_dB=999 M=35

==== verilator-wrap/woods-lab-sqrt16 ====
PASS sqrt16 n=92 mismatches=0
METRIC RMSE=0 SNR_dB=999

==== verilator-wrap/woods-lab-lns-mul ====
PASS lns_mul8 n=1024 mismatches=0
METRIC RMSE=0 SNR_dB=999 DOMAIN=1..32

==== verilator-wrap/woods-lab-givens2 ====
PASS givens_apply n=5 mismatches=0
METRIC RMSE=0 SNR_dB=999 NULL_DEMO=1

==== verilator-wrap/woods-lab-sgr2 ====
PASS sgr_step n=9 mismatches=0
METRIC RMSE=0 SNR_dB=999 NULL_R2=1 NO_SQRT=1

==== verilator-wrap/p3-fir-nco ====
PASS fir4 checked=104
PASS nco checked=128
PASS p3-fir-nco fir+nco bit-exact

==== verilator-wrap/p7-cic ====
PASS cic_decim bit-exact n_in=384 n_out=96 N=2 R=4 M=1

==== verilator-wrap/p11-sdr-loop ====
METRIC DC settle=288 n_out=64
PASS sdr_loop DC bit-exact A=3
METRIC DC settle=-192 n_out=32
PASS sdr_loop DC bit-exact A=-2
METRIC RMSE=0 SNR_dB=999 n_out=128
PASS sdr_loop TONE bit-exact fw=0x10000000
METRIC RMSE=0 SNR_dB=999 n_out=128
PASS sdr_loop TONE bit-exact fw=0x04000000
PASS sdr_loop all cases bit-exact

ALL VERILATOR WRAPS PASS
```

Original iverilog trees were re-run after adding these wraps (unchanged Makefiles). Spot-check of every newly wrapped Woods lab `make all` (iir1, biquad, da-fir-signed, rcm, rls1, div-nr, rns35, sqrt16, lns-mul, givens2, sgr2) → ALL PASS. PLACEHOLDER dirs stay stubs.

