#!/bin/sh
set -eu
build_dir="$1"
cmake --build "$build_dir" --target clang lld llvm-ar llvm-rc llvm-objcopy llvm-objdump llvm-readobj llvm-nm llvm-size llvm-symbolizer llvm-mc clang-resource-headers
