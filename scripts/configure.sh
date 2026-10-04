#!/bin/sh
set -eu
source_dir="$1"
build_dir="$2"
extra=""
if [ "$(uname)" = "Darwin" ]; then
    extra="-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0"
fi
cmake -S "$source_dir/llvm" -B "$build_dir" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_TARGETS_TO_BUILD=Mips \
    -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=SuperH \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    $extra
