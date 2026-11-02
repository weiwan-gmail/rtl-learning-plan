# cmake-cocotb: third CMake tree — cocotb-wrap labs only.
# Analogous to cmake-system (thin project()) but does NOT include
# RtlLabSim.cmake / labs.cmake and does not verilate C++ TBs.
cmake_minimum_required(VERSION 3.24)
cmake_policy(SET CMP0074 NEW)
if(POLICY CMP0144)
  cmake_policy(SET CMP0144 NEW)
endif()
# LANGUAGES NONE: this tree only invokes existing GNU Make recipes.
project(rtl_lab_cocotb LANGUAGES NONE)
enable_testing()
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/CocotbWrap.cmake")
cocotb_wrap_setup()
