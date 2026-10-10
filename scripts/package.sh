#!/bin/sh
set -eu
build_dir="$1"
source_dir="$2"
name="$3"
output_dir="$4"
staging="$output_dir/$name"
rm -rf "$staging"
mkdir -p "$staging/bin" "$staging/lib"
for tool in clang lld llvm-ar llvm-rc llvm-objcopy llvm-objdump llvm-readobj llvm-nm llvm-size llvm-symbolizer llvm-mc; do
    cp "$build_dir/bin/$tool" "$staging/bin/$tool"
done
link() {
    ln -s "$1" "$staging/bin/$2"
}
link clang clang++
link lld ld.lld
link llvm-ar llvm-ranlib
link llvm-objcopy llvm-strip
link llvm-readobj llvm-readelf
link llvm-symbolizer llvm-addr2line
cp -R "$build_dir/lib/clang" "$staging/lib/clang"
mkdir -p "$staging/include/c++" "$staging/share/libcxx"
cp -R "$source_dir/libcxx/include" "$staging/include/c++/v1"
find "$staging/include/c++/v1" \( -name "*.in" -o -name CMakeLists.txt \) -delete
cp -R "$source_dir/libcxx/src" "$staging/share/libcxx/src"
cp "$source_dir/libcxx/LICENSE.TXT" "$staging/share/libcxx/LICENSE.TXT"
cp "$source_dir/llvm/LICENSE.TXT" "$staging/LICENSE.TXT"
commit="$(git -C "$source_dir" rev-parse HEAD)"
cat > "$staging/README.txt" <<README
LLVM with the SuperH (SH-3, Windows CE), ARM (Windows CE) and MIPS targets,
for velo-toolchain and jornada-72x-tools.

Built from https://github.com/Gadgetoid/llvm-project
commit $commit

Tools: clang, ld.lld, llvm-ar, llvm-ranlib, llvm-rc, llvm-objcopy,
llvm-strip, llvm-objdump, llvm-readobj, llvm-readelf, llvm-nm, llvm-size,
llvm-symbolizer, llvm-addr2line, llvm-mc.

libc++'s headers are in include/c++/v1 and its sources in share/libcxx/src, without a
__config_site: jornada-72x-tools supplies its own and builds the parts it uses.

LLVM is under the Apache License v2.0 with LLVM Exceptions; see LICENSE.TXT.
README
for tool in "$staging"/bin/*; do
    test -x "$tool"
done
printf '#include <stdarg.h>\nint pick(int count, ...) { va_list list; va_start(list, count); int value = va_arg(list, int); va_end(list); return value; }\n' > "$output_dir/check.c"
"$staging/bin/clang" --target=sh3el-unknown-none-wince -ffreestanding -c "$output_dir/check.c" -o "$output_dir/check.o"
"$staging/bin/llvm-readelf" -h "$output_dir/check.o" | grep -q "Hitachi SH"
"$staging/bin/clang" --target=armv4-unknown-none-wince -mcpu=strongarm -ffreestanding -c "$output_dir/check.c" -o "$output_dir/check.o"
"$staging/bin/llvm-readelf" -h "$output_dir/check.o" | grep -q "ARM"
"$staging/bin/ld.lld" --version > /dev/null
test -f "$staging/include/c++/v1/__config"
test -f "$staging/share/libcxx/src/string.cpp"
rm -f "$output_dir/check.c" "$output_dir/check.o"
tar -C "$output_dir" -cJf "$output_dir/$name.tar.xz" "$name"
echo "$output_dir/$name.tar.xz"
