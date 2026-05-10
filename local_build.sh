#!/usr/bin/env bash
set -euo pipefail

build_type=Release

conan install . --build=missing -s build_type=${build_type}
conan lock create conanfile.py
cmake -S . -B build/${build_type} \
    -G "Ninja" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_TOOLCHAIN_FILE=build/${build_type}/generators/conan_toolchain.cmake \
    -DCMAKE_BUILD_TYPE=${build_type}
cmake --build build/${build_type} -j$(nproc)
ctest --test-dir build/${build_type} --output-on-failure
cmake --install build/${build_type} --prefix ./build/${build_type}/out
# cpack --config build/${build_type}/CPackConfig.cmake
