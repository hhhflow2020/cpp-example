#!/usr/bin/env bash
set -Eeuo pipefail

BUILD_TYPE="${BUILD_TYPE:-Release}"
BUILD_DIR="${BUILD_DIR:-build/${BUILD_TYPE}}"
INSTALL_PREFIX="${INSTALL_PREFIX:-package}"

TOOLCHAIN_FILE="${BUILD_DIR}/generators/conan_toolchain.cmake"

echo "==> CMake build"
echo "BUILD_TYPE=${BUILD_TYPE}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "INSTALL_PREFIX=${INSTALL_PREFIX}"
echo "TOOLCHAIN_FILE=${TOOLCHAIN_FILE}"

if ! command -v cmake >/dev/null 2>&1; then
  echo "error: cmake not found" >&2
  exit 1
fi

if ! command -v ctest >/dev/null 2>&1; then
  echo "error: ctest not found" >&2
  exit 1
fi

if [[ ! -f "${TOOLCHAIN_FILE}" ]]; then
  echo "error: Conan toolchain file not found: ${TOOLCHAIN_FILE}" >&2
  echo "hint: run scripts/conan-install.sh before scripts/cmake-build.sh" >&2
  exit 1
fi

cmake -S . -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}"

cmake --build "${BUILD_DIR}" \
  --config "${BUILD_TYPE}" \
  -j"$(nproc)"

ctest --test-dir "${BUILD_DIR}" \
  -C "${BUILD_TYPE}" \
  --output-on-failure

cmake --install "${BUILD_DIR}" \
  --config "${BUILD_TYPE}" \
  --prefix "${INSTALL_PREFIX}"

echo "==> CMake build completed"