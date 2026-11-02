# Shared helpers for cmake-cocotb/ only. Not used by cmake-system/,
# cmake-conan/, or RtlLabSim.cmake (those stay Verilator C++ wraps).
#
# Invokes the existing cocotb-wrap/<lab> Makefiles (same sim as
# `cd cocotb-wrap && make all`). Soft-skips configure/ctest/sim when the
# Make path cannot run: missing GNU make, missing cocotb-wrap/.venv
# (`make -C cocotb-wrap venv`), or missing Verilator.
#
# Windows: the invoked Makefile uses cocotb-wrap/common/vlt-win.mk —
# withlimon verilator_bin.exe PE, never the extensionless Perl `verilator`.

include_guard(GLOBAL)

set(COCOTB_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(COCOTB_REPO_ROOT "${COCOTB_CMAKE_DIR}/.." ABSOLUTE)
set(COCOTB_WRAP_ROOT "${COCOTB_REPO_ROOT}/cocotb-wrap")

function(cocotb_windows_file_is_pe filepath outvar)
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

function(cocotb_lab_define)
  cmake_parse_arguments(D "" "NAME;WRAP" "" ${ARGN})
  if(NOT D_NAME OR NOT D_WRAP)
    message(FATAL_ERROR "cocotb_lab_define requires NAME and WRAP")
  endif()
  set(_dir "${COCOTB_WRAP_ROOT}/${D_WRAP}")
  if(NOT IS_DIRECTORY "${_dir}")
    message(FATAL_ERROR "cocotb_lab_define(${D_NAME}): wrap dir not found: ${_dir}")
  endif()
  if(NOT EXISTS "${_dir}/Makefile")
    message(FATAL_ERROR "cocotb_lab_define(${D_NAME}): Makefile not found: ${_dir}/Makefile")
  endif()
  set_property(GLOBAL APPEND PROPERTY COCOTB_LAB_NAMES "${D_NAME}")
  set_property(GLOBAL PROPERTY COCOTB_LAB_${D_NAME}_WRAP "${D_WRAP}")
  set_property(GLOBAL PROPERTY COCOTB_LAB_${D_NAME}_DIR "${_dir}")
endfunction()

function(cocotb_wrap_detect)
  set(_ok TRUE)
  set(_why "")

  find_program(COCOTB_GNUMAKE NAMES gmake mingw32-make make)
  if(NOT COCOTB_GNUMAKE)
    set(_ok FALSE)
    set(_why "GNU make not found (need gmake / mingw32-make / make)")
  endif()

  if(WIN32)
    set(_venv_cfg "${COCOTB_WRAP_ROOT}/.venv/Scripts/cocotb-config.exe")
    set(_venv_bin "${COCOTB_WRAP_ROOT}/.venv/Scripts")
  else()
    set(_venv_cfg "${COCOTB_WRAP_ROOT}/.venv/bin/cocotb-config")
    set(_venv_bin "${COCOTB_WRAP_ROOT}/.venv/bin")
  endif()
  if(NOT EXISTS "${_venv_cfg}")
    set(_ok FALSE)
    if(_why)
      string(APPEND _why "; ")
    endif()
    string(APPEND _why
      "cocotb-wrap/.venv missing (run: make -C cocotb-wrap venv). "
      "Make path requires that venv; system cocotb is not enough")
  endif()

  # Do not pre-set the find_program result — CMake skips the search if the
  # variable is already defined (even as "").
  unset(_vlt)
  if(WIN32)
    set(_cands "")
    list(APPEND _cands
      "D:/verilator/bin/verilator_bin.exe"
      "C:/msys64/mingw64/bin/verilator_bin.exe")
    if(DEFINED ENV{VERILATOR_ROOT} AND NOT "$ENV{VERILATOR_ROOT}" STREQUAL "")
      list(APPEND _cands "$ENV{VERILATOR_ROOT}/bin/verilator_bin.exe")
    endif()
    foreach(_c IN LISTS _cands)
      get_filename_component(_abs "${_c}" ABSOLUTE)
      cocotb_windows_file_is_pe("${_abs}" _ispe)
      if(_ispe)
        set(_vlt "${_abs}")
        break()
      endif()
    endforeach()
    if(NOT _vlt)
      unset(_pe CACHE)
      find_program(_pe NAMES verilator_bin.exe)
      if(_pe)
        cocotb_windows_file_is_pe("${_pe}" _ispe)
        if(_ispe)
          set(_vlt "${_pe}")
        endif()
      endif()
    endif()
    if(NOT _vlt)
      set(_ok FALSE)
      if(_why)
        string(APPEND _why "; ")
      endif()
      string(APPEND _why
        "Windows Verilator PE not found (verilator_bin.exe with MZ header). "
        "Install withlimon: https://github.com/withlimon/verilator-windows")
    endif()
  else()
    unset(COCOTB_VERILATOR_BIN CACHE)
    find_program(COCOTB_VERILATOR_BIN NAMES verilator verilator_bin HINTS
      "$ENV{VERILATOR_ROOT}/bin" /usr/bin /usr/local/bin)
    set(_vlt "${COCOTB_VERILATOR_BIN}")
    if(NOT _vlt)
      set(_ok FALSE)
      if(_why)
        string(APPEND _why "; ")
      endif()
      string(APPEND _why "verilator not found (apt install verilator)")
    endif()
  endif()

  set(COCOTB_WRAP_AVAILABLE ${_ok} PARENT_SCOPE)
  set(COCOTB_WRAP_SKIP_WHY "${_why}" PARENT_SCOPE)
  set(COCOTB_GNUMAKE "${COCOTB_GNUMAKE}" PARENT_SCOPE)
  set(COCOTB_VENV_BIN "${_venv_bin}" PARENT_SCOPE)
  set(COCOTB_VERILATOR "${_vlt}" PARENT_SCOPE)
endfunction()

function(cocotb_add_skip_test name)
  add_test(NAME ${name}
    COMMAND ${CMAKE_COMMAND} -E echo "SKIP: ${COCOTB_WRAP_SKIP_WHY}")
  set_tests_properties(${name} PROPERTIES SKIP_REGULAR_EXPRESSION "^SKIP:")
endfunction()

function(cocotb_wrap_setup)
  cocotb_wrap_detect()
  include("${COCOTB_CMAKE_DIR}/cocotb_labs.cmake")

  get_property(_names GLOBAL PROPERTY COCOTB_LAB_NAMES)
  if(NOT _names)
    message(FATAL_ERROR "CocotbWrap: cmake/cocotb_labs.cmake defined no labs")
  endif()
  list(LENGTH _names _n)
  message(STATUS "CocotbWrap: ${_n} labs from cmake/cocotb_labs.cmake")

  # venv target is always offered when GNU make is present (creates the
  # Make-required cocotb-wrap/.venv). Does not auto-run on `sim`.
  if(COCOTB_GNUMAKE)
    add_custom_target(venv
      COMMAND "${COCOTB_GNUMAKE}" venv
      WORKING_DIRECTORY "${COCOTB_WRAP_ROOT}"
      USES_TERMINAL
      VERBATIM
      COMMENT "Create cocotb-wrap/.venv (pip install -r requirements.txt)")
  endif()

  if(COCOTB_WRAP_AVAILABLE)
    message(STATUS "CocotbWrap: GNUMAKE=${COCOTB_GNUMAKE}")
    message(STATUS "CocotbWrap: VENV_BIN=${COCOTB_VENV_BIN}")
    message(STATUS "CocotbWrap: VERILATOR=${COCOTB_VERILATOR}")

    if(WIN32)
      set(_pathsep ";")
    else()
      set(_pathsep ":")
    endif()
    set(_path "${COCOTB_VENV_BIN}${_pathsep}$ENV{PATH}")

    set(_sim_deps "")
    foreach(_name IN LISTS _names)
      get_property(_dir GLOBAL PROPERTY COCOTB_LAB_${_name}_DIR)
      get_property(_wrap GLOBAL PROPERTY COCOTB_LAB_${_name}_WRAP)
      add_custom_target(${_name}
        COMMAND "${CMAKE_COMMAND}" -E env "PATH=${_path}"
                "${COCOTB_GNUMAKE}" all
        WORKING_DIRECTORY "${_dir}"
        USES_TERMINAL
        VERBATIM
        COMMENT "cocotb-wrap/${_wrap} (existing Makefile)")
      add_test(NAME ${_name}
        COMMAND "${CMAKE_COMMAND}" -E env "PATH=${_path}"
                "${COCOTB_GNUMAKE}" all
        WORKING_DIRECTORY "${_dir}")
      list(APPEND _sim_deps ${_name})
    endforeach()

    add_custom_target(sim
      DEPENDS ${_sim_deps}
      COMMENT "Run all cocotb-wrap labs (${_n}) via their Makefiles"
      VERBATIM)
  else()
    message(STATUS "CocotbWrap: SKIP (${COCOTB_WRAP_SKIP_WHY})")
    foreach(_name IN LISTS _names)
      add_custom_target(${_name}
        COMMAND "${CMAKE_COMMAND}" -E echo
                "SKIP ${_name}: ${COCOTB_WRAP_SKIP_WHY}"
        VERBATIM)
      cocotb_add_skip_test(${_name})
    endforeach()
    add_custom_target(sim
      COMMAND "${CMAKE_COMMAND}" -E echo "SKIP sim: ${COCOTB_WRAP_SKIP_WHY}"
      COMMENT "Soft-skip: cocotb Make path not available on this host"
      VERBATIM)
  endif()
endfunction()
