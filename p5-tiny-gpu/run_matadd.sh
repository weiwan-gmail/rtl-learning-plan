#!/usr/bin/env bash
# P5 helper: init/use tiny-gpu submodule, local venv + LIBPYTHON, then make test_matadd
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
UPSTREAM="${ROOT}/tiny-gpu"

if [[ ! -f "${UPSTREAM}/Makefile" ]]; then
  echo "missing submodule at ${UPSTREAM}" >&2
  echo "run from repo root: git submodule update --init" >&2
  exit 1
fi

cd "$UPSTREAM"

export PATH="${HOME}/bin:${UPSTREAM}/.venv/bin:${PATH}"
export VIRTUAL_ENV="${UPSTREAM}/.venv"

if [[ ! -x "${UPSTREAM}/.venv/bin/cocotb-config" ]]; then
  echo "creating .venv with cocotb<2 in ${UPSTREAM} ..."
  python3 -m venv .venv
  .venv/bin/pip install -q 'cocotb<2'
fi

if ! command -v sv2v >/dev/null; then
  echo "sv2v not in PATH (expected ~/bin/sv2v from zachjs/sv2v release)" >&2
  exit 1
fi
if ! command -v iverilog >/dev/null; then
  echo "iverilog not found" >&2
  exit 1
fi

if [[ -z "${LIBPYTHON_LOC:-}" ]]; then
  for cand in \
    /usr/lib/x86_64-linux-gnu/libpython3.13.so.1.0 \
    /usr/lib/x86_64-linux-gnu/libpython3.13.so \
    /usr/lib/x86_64-linux-gnu/libpython3.so
  do
    if [[ -f "$cand" ]]; then
      export LIBPYTHON_LOC="$cand"
      break
    fi
  done
fi
if [[ -z "${LIBPYTHON_LOC:-}" ]]; then
  echo "LIBPYTHON_LOC unset and no libpython3*.so found (apt install libpython3.13)" >&2
  exit 1
fi

mkdir -p build
exec make test_matadd
