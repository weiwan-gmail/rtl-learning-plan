# Shared Verilator CMake helpers for rtl-learning-plan (both cmake-system/
# and cmake-conan/). Renamed from ProtoSim ApbSim.cmake.
#
# - Locate the Verilator kit; on Windows always drive verilator_bin.exe PE
#   (withlimon: https://github.com/withlimon/verilator-windows). Never the
#   extensionless Perl `verilator` (Explorer/CMD Open-with trap).
# - include(CheckCXXCompilerFlag) before verilate().
# - On MSVC, strip GCC-only -fcoroutines* flags Verilator may inject.

include_guard(GLOBAL)

set(RTL_LAB_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(RTL_LAB_REPO_ROOT "${RTL_LAB_CMAKE_DIR}/.." ABSOLUTE)

function(rtl_lab_locate_verilator_kit)
  set(_root "")

  if(WIN32)
    # Always the PE engine. Never NAMES verilator (no extension).
    # Do not pre-set the result variable — find_program skips the search if it
    # is already defined (even as "").
    find_program(RTL_LAB_VERILATOR_BIN NAMES verilator_bin.exe HINTS
      "$ENV{VERILATOR_ROOT}/bin"
      "D:/verilator/bin"
      "C:/msys64/mingw64/bin")
    if(NOT RTL_LAB_VERILATOR_BIN)
      message(FATAL_ERROR
        "Windows Verilator PE not found (verilator_bin.exe).\n"
        "Install the withlimon build: https://github.com/withlimon/verilator-windows\n"
        "Extract to a short path (e.g. D:\\verilator), then:\n"
        "  VERILATOR_ROOT = D:\\verilator\n"
        "  PATH          += D:\\verilator\\bin\n"
        "Do NOT invoke the extensionless Perl `verilator` (Open-with trap).\n"
        "PC2023 worker workspace: D:\\CursorWorker")
    endif()
  else()
    find_program(RTL_LAB_VERILATOR_BIN NAMES verilator_bin HINTS
      "$ENV{VERILATOR_ROOT}/bin"
      /usr/bin
      /usr/local/bin)
    if(NOT RTL_LAB_VERILATOR_BIN)
      message(FATAL_ERROR
        "verilator_bin not found. Install Verilator 5.x (e.g. apt install verilator).")
    endif()
  endif()
  set(_pe "${RTL_LAB_VERILATOR_BIN}")

  get_filename_component(_bin "${_pe}" DIRECTORY)
  get_filename_component(_parent "${_bin}" DIRECTORY)
  foreach(_c
      "$ENV{VERILATOR_ROOT}"
      "${_parent}"
      "${_parent}/share/verilator"
      "/usr/share/verilator"
      "/usr/local/share/verilator"
      "D:/verilator"
      "C:/msys64/mingw64/share/verilator")
    if(_c AND EXISTS "${_c}/include/verilated.h")
      set(_root "${_c}")
      break()
    endif()
  endforeach()

  if(NOT _root)
    message(FATAL_ERROR
      "VERILATOR_ROOT kit not found (need include/verilated.h). PE was ${_pe}")
  endif()

  message(STATUS "RtlLabSim: VERILATOR_BIN=${_pe}")
  message(STATUS "RtlLabSim: VERILATOR_ROOT=${_root}")
  set(RTL_LAB_VERILATOR_BIN "${_pe}" PARENT_SCOPE)
  set(RTL_LAB_VERILATOR_ROOT "${_root}" PARENT_SCOPE)
endfunction()

function(rtl_lab_find_verilator)
  # Pre-seed VERILATOR_BIN so a Debian/Ubuntu verilator-config.cmake does not
  # FATAL (it searches only VERILATOR_ROOT/bin with NO_CMAKE_SYSTEM_PATH).
  if(WIN32)
    find_program(RTL_LAB_VERILATOR_BIN NAMES verilator_bin.exe HINTS
      "$ENV{VERILATOR_ROOT}/bin" "D:/verilator/bin" "C:/msys64/mingw64/bin")
  else()
    find_program(RTL_LAB_VERILATOR_BIN NAMES verilator_bin HINTS
      "$ENV{VERILATOR_ROOT}/bin" /usr/bin /usr/local/bin)
  endif()
  if(RTL_LAB_VERILATOR_BIN)
    set(VERILATOR_BIN "${RTL_LAB_VERILATOR_BIN}" CACHE FILEPATH "VERILATOR_BIN" FORCE)
  endif()

  # First find_package() triggers cmake-conan if the provider is registered.
  find_package(verilator QUIET)

  foreach(_pkg_var
      verilator_PACKAGE_FOLDER_RELEASE
      verilator_PACKAGE_FOLDER_RELWITHDEBINFO
      verilator_PACKAGE_FOLDER_DEBUG
      verilator_PACKAGE_FOLDER)
    if(DEFINED ${_pkg_var} AND EXISTS "${${_pkg_var}}/include/verilated.h")
      set(ENV{VERILATOR_ROOT} "${${_pkg_var}}")
      # Prefer the packaged PE (withlimon on Windows) over a stale PATH hit.
      unset(RTL_LAB_VERILATOR_BIN CACHE)
      message(STATUS "RtlLabSim: Conan package folder ${${_pkg_var}}")
      break()
    endif()
  endforeach()

  rtl_lab_locate_verilator_kit()
  set(VERILATOR_ROOT "${RTL_LAB_VERILATOR_ROOT}" CACHE PATH "VERILATOR_ROOT" FORCE)
  set(verilator_ROOT "${RTL_LAB_VERILATOR_ROOT}" CACHE PATH "verilator_ROOT" FORCE)
  set(VERILATOR_BIN "${RTL_LAB_VERILATOR_BIN}" CACHE FILEPATH "VERILATOR_BIN" FORCE)
  set(ENV{VERILATOR_ROOT} "${RTL_LAB_VERILATOR_ROOT}")

  if(NOT COMMAND verilate)
    if(EXISTS "${RTL_LAB_VERILATOR_ROOT}/verilator-config.cmake")
      include("${RTL_LAB_VERILATOR_ROOT}/verilator-config.cmake")
    else()
      message(STATUS
        "RtlLabSim: kit has no verilator-config.cmake (typical of withlimon); "
        "using bundled cmake/verilator-config.fallback.cmake")
      include("${RTL_LAB_CMAKE_DIR}/verilator-config.fallback.cmake")
    endif()
  endif()

  if(NOT COMMAND verilate)
    message(FATAL_ERROR "verilate() missing after Verilator package load")
  endif()
endfunction()

function(rtl_lab_strip_msvc_gcc_flags target)
  if(NOT MSVC)
    return()
  endif()
  foreach(_prop COMPILE_OPTIONS INTERFACE_COMPILE_OPTIONS)
    get_target_property(_opts ${target} ${_prop})
    if(_opts)
      list(FILTER _opts EXCLUDE REGEX "fcoroutines")
      set_property(TARGET ${target} PROPERTY ${_prop} "${_opts}")
    endif()
  endforeach()
endfunction()

function(rtl_lab_add_sim name)
  cmake_parse_arguments(ARG "" "TOP;PREFIX" "SOURCES;TB" ${ARGN})
  if(NOT ARG_PREFIX)
    set(ARG_PREFIX V${ARG_TOP})
  endif()
  add_executable(${name} ${ARG_TB})
  target_include_directories(${name} PRIVATE
    "${RTL_LAB_REPO_ROOT}/verilator-wrap/common")
  target_compile_features(${name} PRIVATE cxx_std_17)

  # Verilator's verilate() calls check_cxx_compiler_flag() (coroutines /
  # TIMING path). Include the module first; MSVC then gets flag stripping.
  include(CheckCXXCompilerFlag)

  verilate(${name}
    PREFIX ${ARG_PREFIX}
    TOP_MODULE ${ARG_TOP}
    SOURCES ${ARG_SOURCES}
    VERILATOR_ARGS
      -Wall --Wno-fatal -Wno-DECLFILENAME --timescale 1ns/1ps
  )
  rtl_lab_strip_msvc_gcc_flags(${name})
endfunction()

function(rtl_lab_sim_setup)
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
  endif()
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)

  rtl_lab_find_verilator()
  include(CheckCXXCompilerFlag)

  set(_R "${RTL_LAB_REPO_ROOT}")
  set(_W "${_R}/verilator-wrap")

  # Representative matrix (not every wrap): ≥1 NPTEL, ≥1 Woods, P3 and P7.
  # DUT paths are the original labs / existing wraps — no wholesale RTL copies.

  rtl_lab_add_sim(sim_csd_mul
    TOP csd_mul PREFIX Vcsd_mul
    TB ${_W}/nptel-lab-csd-mul/tb.cpp
    SOURCES ${_R}/nptel-vlsi-sp/lab-csd-mul/csd_mul.v)

  rtl_lab_add_sim(sim_da_fir4
    TOP da_fir4 PREFIX Vda_fir4
    TB ${_W}/woods-lab-da-fir/tb.cpp
    SOURCES ${_R}/woods-fpga-sp/lab-da-fir/da_fir4.v)

  rtl_lab_add_sim(sim_woods_arith
    TOP wrap_arith PREFIX Vwrap_arith
    TB ${_W}/woods-lab-arith/tb.cpp
    SOURCES
      ${_W}/woods-lab-arith/wrap.v
      ${_R}/woods-fpga-sp/lab-arith/cla_add16.v
      ${_R}/woods-fpga-sp/lab-arith/array_mult8.v)

  rtl_lab_add_sim(sim_p3_fir_nco
    TOP wrap_p3_fir_nco PREFIX Vwrap_p3_fir_nco
    TB ${_W}/p3-fir-nco/tb.cpp
    SOURCES
      ${_W}/p3-fir-nco/wrap.v
      ${_R}/p3-fir-nco/fir4.v
      ${_R}/p3-fir-nco/nco.v)

  rtl_lab_add_sim(sim_p7_cic
    TOP cic_decim PREFIX Vcic_decim
    TB ${_W}/p7-cic/tb.cpp
    SOURCES ${_R}/p7-cic/cic_decim.v)

  rtl_lab_add_sim(sim_fail_csd
    TOP csd_mul PREFIX Vcsd_mul
    TB ${RTL_LAB_CMAKE_DIR}/fail-harness/tb_intentional_fail.cpp
    SOURCES ${_R}/nptel-vlsi-sp/lab-csd-mul/csd_mul.v)

  set(_pass_tgts sim_csd_mul sim_da_fir4 sim_woods_arith sim_p3_fir_nco sim_p7_cic)

  add_custom_target(sim
    DEPENDS ${_pass_tgts}
    COMMAND $<TARGET_FILE:sim_csd_mul>
    COMMAND $<TARGET_FILE:sim_da_fir4>
    COMMAND $<TARGET_FILE:sim_woods_arith>
    COMMAND $<TARGET_FILE:sim_p3_fir_nco>
    COMMAND $<TARGET_FILE:sim_p7_cic>
    COMMENT "Run representative Verilator PASS sims (NPTEL CSD, Woods DA+arith, P3, P7)"
    VERBATIM)

  add_custom_target(sim-fail
    DEPENDS sim_fail_csd
    COMMAND ${CMAKE_COMMAND}
            -DEXE=$<TARGET_FILE:sim_fail_csd>
            -P ${RTL_LAB_CMAKE_DIR}/ExpectFail.cmake
    COMMENT "Inject-and-catch: CSD checker must FAIL; runner succeeds only then"
    VERBATIM)

  foreach(_t ${_pass_tgts})
    add_test(NAME ${_t} COMMAND ${_t})
  endforeach()
  add_test(NAME sim-fail
    COMMAND ${CMAKE_COMMAND}
            -DEXE=$<TARGET_FILE:sim_fail_csd>
            -P ${RTL_LAB_CMAKE_DIR}/ExpectFail.cmake)
endfunction()
