# cmake-system: system Verilator, no Conan.
# Same dual-tree shape as weiwan-gmail/protosim-apb `cmake-system/`.
cmake_minimum_required(VERSION 3.24)
cmake_policy(SET CMP0074 NEW)
if(POLICY CMP0144)
  cmake_policy(SET CMP0144 NEW)
endif()
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/PreferUnixGcc.cmake")
project(rtl_lab_sim_system LANGUAGES CXX)
enable_testing()
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/RtlLabSim.cmake")
rtl_lab_sim_setup()
