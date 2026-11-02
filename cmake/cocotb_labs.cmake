# Cocotb wrap matrix. Consumed ONLY by cmake-cocotb/ via CocotbWrap.cmake.
# Do not include this file from cmake-system/, cmake-conan/, or RtlLabSim.cmake.
#
# NAME  → custom target + ctest name
# WRAP  → cocotb-wrap/<WRAP>/ (same Make the existing tree already runs)
#
# Adding a wrap is one cocotb_lab_define() row. Keep this list in the same
# order as cocotb-wrap/Makefile WRAPS.

include_guard(GLOBAL)

cocotb_lab_define(NAME cocotb_lms WRAP woods-lab-lms)
cocotb_lab_define(NAME cocotb_dlms WRAP nptel-lab-dlms)
cocotb_lab_define(NAME cocotb_cordic WRAP woods-lab-cordic)
cocotb_lab_define(NAME cocotb_da_fir WRAP woods-lab-da-fir)
cocotb_lab_define(NAME cocotb_p3_fir WRAP p3-fir-nco)
