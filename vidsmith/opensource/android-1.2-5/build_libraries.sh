#!/usr/bin/env bash
# 构建 MOV 重封装所需的最小 LGPL 动态库。
set -euo pipefail

ndk="$1"
build="$2"
version=6.1.6
archive="ffmpeg-$version.tar.xz"
sha256=d4fcb164028dd3beee5d92c0ac72e46aac6973c75ea12dc14de07bf8f407370a
mkdir -p "$build"
cd "$build"
build="$PWD"
rm -rf "ffmpeg-$version" objects include libs
if [[ ! -f "$archive" ]]; then
    trap 'rm -f "$archive.part"' EXIT
    curl --fail --location --retry 3 --silent --show-error -o "$archive.part" "https://ffmpeg.org/releases/$archive"
    mv "$archive.part" "$archive"
fi
printf '%s  %s\n' "$sha256" "$archive" | shasum -a 256 -c
tar -xf "$archive"

case "$(uname -s)" in
    Darwin) host=darwin-x86_64 ;;
    Linux) host=linux-x86_64 ;;
    *) echo "FFmpeg Android build requires macOS or Linux." >&2; exit 2 ;;
esac
bin="$ndk/toolchains/llvm/prebuilt/$host/bin"

for abi in arm64-v8a armeabi-v7a x86_64; do
    case "$abi" in
        arm64-v8a) arch=aarch64; triple=aarch64-linux-android ;;
        armeabi-v7a) arch=arm; triple=armv7a-linux-androideabi ;;
        x86_64) arch=x86_64; triple=x86_64-linux-android ;;
    esac
    mkdir -p "objects/$abi" "libs/$abi" include
    (
        cd "objects/$abi"
        "$build/ffmpeg-$version/configure" --target-os=android --arch="$arch" --enable-cross-compile \
            --cc="$bin/${triple}29-clang" --ar="$bin/llvm-ar" --nm="$bin/llvm-nm" \
            --ranlib="$bin/llvm-ranlib" --strip="$bin/llvm-strip" --extra-ldflags=-Wl,-z,max-page-size=16384 \
            --disable-static --enable-shared --enable-pic --disable-everything --disable-autodetect \
            --disable-programs --disable-doc --disable-debug --disable-asm --disable-avdevice \
            --disable-avfilter --disable-swresample --disable-swscale --disable-postproc \
            --enable-demuxer=mov --enable-muxer=mov --enable-protocol=file --enable-small
        make -j8
        for library in avformat avcodec avutil; do
            cp "lib$library/lib$library.so" "$build/libs/$abi/"
        done
        make install-headers DESTDIR="$PWD/headers"
        mv headers/usr/local/include "$build/include/$abi"
    )
done
