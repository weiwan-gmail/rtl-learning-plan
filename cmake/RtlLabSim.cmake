# Shared Verilator CMake helpers for rtl-learning-plan (both cmake-system/
# and cmake-conan/). Renamed from ProtoSim ApbSim.cmake.
#
# - Locate the Verilator kit; on Windows always drive verilator_bin.exe PE
#   (withlimon: https://github.com/withlimon/verilator-windows). Never the
#   extensionless Perl `verilator` (Explorer/CMD Open-with trap).
# - include(CheckCXXCompilerFlag) before verilate().
# - On MSVC, strip GCC-only -fcoroutines* flags Verilator may inject.
# - Lab matrix is cmake/labs.cmake (one rtl_lab_define() row per wrap).

include_guard(GLOBAL)

set(RTL_LAB_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(RTL_LAB_REPO_ROOT "${RTL_LAB_CMAKE_DIR}/.." ABSOLUTE)

# MSYS2 names a Perl script share/verilator/bin/verilator_bin.exe. withlimon
# and mingw64/bin ship a real PE (MZ). Only the PE may be executed on Windows.
function(rtl_lab_windows_file_is_pe filepath outvar)
  set(_ok FALSE)
  if(EXISTS "${filepath}")
    file(READ "${filepath}" _magic HEX LIMIT 2)
    string(TOUPPER "${_magic}" _magic)
    if(_magic STREQUAL "4D5A")
      set(_ok TRUE)
    endif()
  endif()
  set(${outvar} ${_ok} PARENT_SCOPE)
endfunction()

function(rtl_lab_find_windows_pe outvar)
  unset(RTL_LAB_VERILATOR_BIN CACHE)
  set(_cands "")
  # Known PE bindirs first. $VERILATOR_ROOT/bin on MSYS2 is the Perl wrapper.
  list(APPEND _cands
    "D:/verilator/bin/verilator_bin.exe"
    "C:/msys64/mingw64/bin/verilator_bin.exe")
  if(DEFINED ENV{VERILATOR_ROOT} AND NOT "$ENV{VERILATOR_ROOT}" STREQUAL "")
    list(APPEND _cands
      "$ENV{VERILATOR_ROOT}/bin/verilator_bin.exe"
      "$ENV{VERILATOR_ROOT}/../bin/verilator_bin.exe"
      "$ENV{VERILATOR_ROOT}/../../bin/verilator_bin.exe")
  endif()
  foreach(_c IN LISTS _cands)
    get_filename_component(_abs "${_c}" ABSOLUTE)
    rtl_lab_windows_file_is_pe("${_abs}" _ispe)
    if(_ispe)
      set(${outvar} "${_abs}" PARENT_SCOPE)
      return()
    endif()
  endforeach()
  find_program(_rtl_path_pe NAMES verilator_bin.exe)
  if(_rtl_path_pe)
    rtl_lab_windows_file_is_pe("${_rtl_path_pe}" _ispe)
    if(_ispe)
      set(${outvar} "${_rtl_path_pe}" PARENT_SCOPE)
      return()
    endif()
  endif()
  set(${outvar} "" PARENT_SCOPE)
endfunction()

function(rtl_lab_locate_verilator_kit)
  set(_root "")

  if(WIN32)
    rtl_lab_find_windows_pe(_pe)
    if(NOT _pe)
      message(FATAL_ERROR
        "Windows Verilator PE not found (verilator_bin.exe with MZ header).\n"
        "Install the withlimon build: https://github.com/withlimon/verilator-windows\n"
        "Extract to a short path (e.g. D:\\verilator), then:\n"
        "  VERILATOR_ROOT = D:\\verilator\n"
        "  PATH          += D:\\verilator\\bin\n"
        "Do NOT invoke the extensionless Perl `verilator` (Open-with trap).\n"
        "Do NOT invoke share/verilator/bin/verilator_bin.exe (Perl wrapper with a .exe suffix).\n"
        "PC2023 worker workspace: D:\\CursorWorker")
    endif()
    set(RTL_LAB_VERILATOR_BIN "${_pe}")
  else()
    # Do not pre-set the result variable — find_program skips the search if it
    # is already defined (even as "").
    unset(RTL_LAB_VERILATOR_BIN CACHE)
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
  # FATAL (it searches only VERILATOR_ROOT/bin with NO_CMAKE_SYSTEM_PATH), and
  # so an MSYS2 kit config does not pick share/verilator/bin's Perl wrapper.
  if(WIN32)
    rtl_lab_find_windows_pe(_pe_seed)
    if(_pe_seed)
      set(RTL_LAB_VERILATOR_BIN "${_pe_seed}" CACHE FILEPATH "RTL_LAB_VERILATOR_BIN" FORCE)
      set(VERILATOR_BIN "${_pe_seed}" CACHE FILEPATH "VERILATOR_BIN" FORCE)
    endif()
  else()
    find_program(RTL_LAB_VERILATOR_BIN NAMES verilator_bin HINTS
      "$ENV{VERILATOR_ROOT}/bin" /usr/bin /usr/local/bin)
    if(RTL_LAB_VERILATOR_BIN)
      set(VERILATOR_BIN "${RTL_LAB_VERILATOR_BIN}" CACHE FILEPATH "VERILATOR_BIN" FORCE)
    endif()
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

  # Kit configs may find_program() VERILATOR_ROOT/bin (Perl wrapper on MSYS2).
  # Re-assert the PE after that include so verilate() drives verilator_bin.exe.
  if(WIN32)
    set(VERILATOR_BIN "${RTL_LAB_VERILATOR_BIN}" CACHE FILEPATH "VERILATOR_BIN" FORCE)
    rtl_lab_windows_file_is_pe("${VERILATOR_BIN}" _bin_is_pe)
    if(NOT _bin_is_pe)
      rtl_lab_find_windows_pe(_pe_fix)
      if(NOT _pe_fix)
        message(FATAL_ERROR
          "VERILATOR_BIN is not a PE engine: ${VERILATOR_BIN}\n"
          "Do not use share/verilator/bin/verilator_bin.exe (Perl wrapper).")
      endif()
      set(RTL_LAB_VERILATOR_BIN "${_pe_fix}" CACHE FILEPATH "RTL_LAB_VERILATOR_BIN" FORCE)
      set(VERILATOR_BIN "${_pe_fix}" CACHE FILEPATH "VERILATOR_BIN" FORCE)
      message(STATUS "RtlLabSim: replaced non-PE VERILATOR_BIN with ${_pe_fix}")
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

# Register one wrap (or the fail harness). Adding a lab is one call in
# cmake/labs.cmake — not a copy of rtl_lab_add_sim + COMMAND + ctest.
#
# WRAP  verilator-wrap/<WRAP>/  — TB defaults to that dir's tb.cpp;
#       wrap.v is prepended to SOURCES when present.
# SOURCES  repo-relative DUT / extra Verilog (no wholesale RTL copies).
# FAIL  inject-and-catch target (exactly one); omitted from `sim` / PASS ctest.
function(rtl_lab_define)
  cmake_parse_arguments(D "FAIL" "NAME;TOP;WRAP;TB;PREFIX" "SOURCES;VERILATOR_ARGS" ${ARGN})
  if(NOT D_NAME OR NOT D_TOP)
    message(FATAL_ERROR "rtl_lab_define requires NAME and TOP")
  endif()
  if(NOT D_PREFIX)
    set(D_PREFIX V${D_TOP})
  endif()

  set(_srcs "")
  if(D_WRAP)
    set(_wrap_dir "${RTL_LAB_REPO_ROOT}/verilator-wrap/${D_WRAP}")
    if(NOT IS_DIRECTORY "${_wrap_dir}")
      message(FATAL_ERROR "rtl_lab_define(${D_NAME}): wrap dir not found: ${_wrap_dir}")
    endif()
    if(EXISTS "${_wrap_dir}/wrap.v")
      list(APPEND _srcs "${_wrap_dir}/wrap.v")
    endif()
    if(NOT D_TB)
      set(D_TB "${_wrap_dir}/tb.cpp")
    endif()
  endif()
  if(NOT D_TB)
    message(FATAL_ERROR "rtl_lab_define(${D_NAME}): need WRAP or TB")
  endif()
  if(NOT IS_ABSOLUTE "${D_TB}")
    set(D_TB "${RTL_LAB_REPO_ROOT}/${D_TB}")
  endif()
  if(NOT EXISTS "${D_TB}")
    message(FATAL_ERROR "rtl_lab_define(${D_NAME}): TB not found: ${D_TB}")
  endif()

  foreach(_s IN LISTS D_SOURCES)
    if(NOT IS_ABSOLUTE "${_s}")
      set(_s "${RTL_LAB_REPO_ROOT}/${_s}")
    endif()
    if(NOT EXISTS "${_s}")
      message(FATAL_ERROR "rtl_lab_define(${D_NAME}): source not found: ${_s}")
    endif()
    list(APPEND _srcs "${_s}")
  endforeach()
  if(NOT _srcs)
    message(FATAL_ERROR "rtl_lab_define(${D_NAME}): no SOURCES")
  endif()

  if(D_FAIL)
    get_property(_have_fail GLOBAL PROPERTY RTL_LAB_FAIL_NAME)
    if(_have_fail)
      message(FATAL_ERROR
        "rtl_lab_define: only one FAIL lab (already ${_have_fail})")
    endif()
    set_property(GLOBAL PROPERTY RTL_LAB_FAIL_NAME "${D_NAME}")
  else()
    set_property(GLOBAL APPEND PROPERTY RTL_LAB_PASS_NAMES "${D_NAME}")
  endif()
  set_property(GLOBAL PROPERTY RTL_LAB_${D_NAME}_TOP "${D_TOP}")
  set_property(GLOBAL PROPERTY RTL_LAB_${D_NAME}_PREFIX "${D_PREFIX}")
  set_property(GLOBAL PROPERTY RTL_LAB_${D_NAME}_TB "${D_TB}")
  set_property(GLOBAL PROPERTY RTL_LAB_${D_NAME}_SOURCES "${_srcs}")
  set_property(GLOBAL PROPERTY RTL_LAB_${D_NAME}_VERILATOR_ARGS "${D_VERILATOR_ARGS}")
endfunction()

function(rtl_lab_add_sim name)
  cmake_parse_arguments(ARG "" "TOP;PREFIX" "SOURCES;TB;VERILATOR_ARGS" ${ARGN})
  if(NOT ARG_PREFIX)
    set(ARG_PREFIX V${ARG_TOP})
  endif()
  add_executable(${name} ${ARG_TB} "${RTL_LAB_CMAKE_DIR}/sc_time_stamp.cpp")
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
      ${ARG_VERILATOR_ARGS}
  )
  rtl_lab_strip_msvc_gcc_flags(${name})
endfunction()

function(rtl_lab_emit_from_props name)
  get_property(_top GLOBAL PROPERTY RTL_LAB_${name}_TOP)
  get_property(_prefix GLOBAL PROPERTY RTL_LAB_${name}_PREFIX)
  get_property(_tb GLOBAL PROPERTY RTL_LAB_${name}_TB)
  get_property(_srcs GLOBAL PROPERTY RTL_LAB_${name}_SOURCES)
  get_property(_vargs GLOBAL PROPERTY RTL_LAB_${name}_VERILATOR_ARGS)
  rtl_lab_add_sim(${name}
    TOP ${_top}
    PREFIX ${_prefix}
    TB ${_tb}
    SOURCES ${_srcs}
    VERILATOR_ARGS ${_vargs})
endfunction()

function(rtl_lab_sim_setup)
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
  endif()
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)

  rtl_lab_find_verilator()
  include(CheckCXXCompilerFlag)

  # Data table: one rtl_lab_define() per wrap. Builds PASS targets, `sim`,
  # `sim-fail`, and ctest from that list (no per-lab COMMAND copy-paste).
  include("${RTL_LAB_CMAKE_DIR}/labs.cmake")

  get_property(_pass_tgts GLOBAL PROPERTY RTL_LAB_PASS_NAMES)
  get_property(_fail_tgt GLOBAL PROPERTY RTL_LAB_FAIL_NAME)
  if(NOT _pass_tgts)
    message(FATAL_ERROR "RtlLabSim: cmake/labs.cmake defined no PASS labs")
  endif()
  if(NOT _fail_tgt)
    message(FATAL_ERROR "RtlLabSim: cmake/labs.cmake must define one FAIL lab")
  endif()

  list(LENGTH _pass_tgts _npass)
  message(STATUS "RtlLabSim: ${_npass} PASS labs from cmake/labs.cmake + ${_fail_tgt}")

  foreach(_name IN LISTS _pass_tgts)
    rtl_lab_emit_from_props(${_name})
  endforeach()
  rtl_lab_emit_from_props(${_fail_tgt})

  set(_sim_run "")
  foreach(_t IN LISTS _pass_tgts)
    list(APPEND _sim_run COMMAND "$<TARGET_FILE:${_t}>")
  endforeach()
  add_custom_target(sim
    DEPENDS ${_pass_tgts}
    ${_sim_run}
    COMMENT "Run all verilator-wrap PASS sims (${_npass} labs)"
    VERBATIM)

  add_custom_target(sim-fail
    DEPENDS ${_fail_tgt}
    COMMAND ${CMAKE_COMMAND}
            -DEXE=$<TARGET_FILE:${_fail_tgt}>
            -P ${RTL_LAB_CMAKE_DIR}/ExpectFail.cmake
    COMMENT "Inject-and-catch: CSD checker must FAIL; runner succeeds only then"
    VERBATIM)

  foreach(_t IN LISTS _pass_tgts)
    add_test(NAME ${_t} COMMAND ${_t})
  endforeach()
  add_test(NAME sim-fail
    COMMAND ${CMAKE_COMMAND}
            -DEXE=$<TARGET_FILE:${_fail_tgt}>
            -P ${RTL_LAB_CMAKE_DIR}/ExpectFail.cmake)
endfunction()
