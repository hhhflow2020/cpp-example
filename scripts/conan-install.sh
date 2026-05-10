#!/usr/bin/env bash
set -Eeuo pipefail

BUILD_TYPE="${BUILD_TYPE:-Release}"

echo "==> Conan install"
echo "BUILD_TYPE=${BUILD_TYPE}"

if ! command -v conan >/dev/null 2>&1; then
  echo "error: conan not found" >&2
  exit 1
fi

if ! conan profile path default >/dev/null 2>&1; then
  echo "error: not have default conan profile"
  exit 1
fi

CONAN_ARGS=(
  install .
  --build=missing
  -s "build_type=${BUILD_TYPE}"
)

if [[ -f conan.lock ]]; then
  echo "==> Using conan.lock"
  CONAN_ARGS+=(--lockfile=conan.lock)
fi

conan "${CONAN_ARGS[@]}"

TOOLCHAIN_FILE="build/${BUILD_TYPE}/generators/conan_toolchain.cmake"

if [[ ! -f "${TOOLCHAIN_FILE}" ]]; then
  echo "error: Conan toolchain file not found: ${TOOLCHAIN_FILE}" >&2
  exit 1
fi

echo "==> Conan install completed"