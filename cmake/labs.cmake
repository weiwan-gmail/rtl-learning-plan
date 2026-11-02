# CMake PASS/FAIL sim matrix. Adding a wrap is one rtl_lab_define() row.
# Consumed by rtl_lab_sim_setup() in RtlLabSim.cmake.
#
# WRAP  → verilator-wrap/<WRAP>/tb.cpp
#         + wrap.v prepended when that file exists
# SOURCES are repo-relative original DUT paths (no RTL copies).
# Extra VERILATOR_ARGS match verilator-wrap/<WRAP>/Makefile EXTRA_VLT_FLAGS.
# PREFIX defaults to V<TOP> (matches the wrap tb.cpp include).
#
# Leftovers (not in this table): Woods labs that were never wrapped —
# see verilator-wrap/SCOPE.md. cocotb stays Make-only.

include_guard(GLOBAL)

# --- NPTEL (10) ---
rtl_lab_define(
  NAME sim_fir_transpose TOP wrap_fir_transpose WRAP nptel-lab-fir-transpose
  SOURCES
    nptel-vlsi-sp/lab-fir-transpose/fir_direct.v
    nptel-vlsi-sp/lab-fir-transpose/fir_transpose.v)

rtl_lab_define(
  NAME sim_iir_retime TOP wrap_iir_retime WRAP nptel-lab-iir-retime
  SOURCES
    nptel-vlsi-sp/lab-iir-retime/iir1_combo.v
    nptel-vlsi-sp/lab-iir-retime/iir1_pipe.v)

rtl_lab_define(
  NAME sim_dlms TOP wrap_dlms WRAP nptel-lab-dlms
  SOURCES
    nptel-vlsi-sp/lab-dlms/lms2.v
    nptel-vlsi-sp/lab-dlms/dlms2.v)

rtl_lab_define(
  NAME sim_fir_2par TOP wrap_fir_2par WRAP nptel-lab-fir-2par
  SOURCES
    nptel-vlsi-sp/lab-fir-2par/fir_serial.v
    nptel-vlsi-sp/lab-fir-2par/fir_2par.v)

rtl_lab_define(
  NAME sim_fir_3par TOP wrap_fir_3par WRAP nptel-lab-fir-3par
  SOURCES nptel-vlsi-sp/lab-fir-3par/fir_3par.v)

rtl_lab_define(
  NAME sim_biquad_fold TOP wrap_biquad_fold WRAP nptel-lab-biquad-fold
  SOURCES
    nptel-vlsi-sp/lab-biquad-fold/biquad_par.v
    nptel-vlsi-sp/lab-biquad-fold/biquad_fold.v)

rtl_lab_define(
  NAME sim_bitserial_fir TOP bitserial_fir WRAP nptel-lab-bitserial-fir
  VERILATOR_ARGS -Wno-UNOPTFLAT
  SOURCES nptel-vlsi-sp/lab-bitserial-fir/bitserial_fir.v)

rtl_lab_define(
  NAME sim_baugh_wooley TOP baugh_wooley8 WRAP nptel-lab-baugh-wooley
  SOURCES nptel-vlsi-sp/lab-baugh-wooley/baugh_wooley8.v)

rtl_lab_define(
  NAME sim_csd_mul TOP csd_mul WRAP nptel-lab-csd-mul
  SOURCES nptel-vlsi-sp/lab-csd-mul/csd_mul.v)

rtl_lab_define(
  NAME sim_lookahead_iir TOP wrap_lookahead WRAP nptel-lab-lookahead-iir
  SOURCES
    nptel-vlsi-sp/lab-lookahead-iir/iir_plain.v
    nptel-vlsi-sp/lab-lookahead-iir/iir_lookahead.v
    nptel-vlsi-sp/lab-lookahead-iir/iir_la_pipe.v)

# --- Woods (6 wrapped labs) ---
rtl_lab_define(
  NAME sim_retiming_fir TOP wrap_retiming_fir WRAP woods-lab-retiming-fir
  SOURCES
    woods-fpga-sp/lab-retiming-fir/fir3_combo.v
    woods-fpga-sp/lab-retiming-fir/fir3_pipe.v)

rtl_lab_define(
  NAME sim_lms TOP lms2 WRAP woods-lab-lms
  SOURCES woods-fpga-sp/lab-lms/lms2.v)

rtl_lab_define(
  NAME sim_da_fir4 TOP da_fir4 WRAP woods-lab-da-fir
  SOURCES woods-fpga-sp/lab-da-fir/da_fir4.v)

rtl_lab_define(
  NAME sim_woods_arith TOP wrap_arith WRAP woods-lab-arith
  SOURCES
    woods-fpga-sp/lab-arith/cla_add16.v
    woods-fpga-sp/lab-arith/array_mult8.v)

rtl_lab_define(
  NAME sim_cordic TOP wrap_cordic WRAP woods-lab-cordic
  SOURCES
    woods-fpga-sp/lab-cordic/cordic_rotate.v
    woods-fpga-sp/lab-cordic/cordic_vector.v)

rtl_lab_define(
  NAME sim_fft8 TOP fft8 WRAP woods-lab-fft8
  VERILATOR_ARGS -Wno-UNOPTFLAT -Wno-BLKANDNBLK
  SOURCES woods-fpga-sp/lab-fft8/fft8.v)

# --- P3 / P7 / P11 ---
rtl_lab_define(
  NAME sim_p3_fir_nco TOP wrap_p3_fir_nco WRAP p3-fir-nco
  SOURCES
    p3-fir-nco/fir4.v
    p3-fir-nco/nco.v)

rtl_lab_define(
  NAME sim_p7_cic TOP cic_decim WRAP p7-cic
  SOURCES p7-cic/cic_decim.v)

rtl_lab_define(
  NAME sim_p11_sdr_loop TOP sdr_loop WRAP p11-sdr-loop
  SOURCES
    p11-sdr-loop/sdr_loop.v
    p3-fir-nco/nco.v
    p3-fir-nco/fir4.v
    p7-cic/cic_decim.v)

# Intentional FAIL harness (same CSD DUT; golden forced wrong).
rtl_lab_define(
  NAME sim_fail_csd TOP csd_mul FAIL
  TB cmake/fail-harness/tb_intentional_fail.cpp
  SOURCES nptel-vlsi-sp/lab-csd-mul/csd_mul.v)
