#!/bin/bash
set -e
set -x

# WebRTC build

patches_dir=$FLATPAK_BUILDER_BUILDDIR/patches

pushd ../Libraries/webrtc
#cp $patches_dir/webrtc/.gclient ./
#export PATH=$PATH:$FLATPAK_BUILDER_BUILDDIR/depot_tools
#git clone https://github.com/open-webrtc-toolkit/owt-deps-webrtc src
#gclient sync
touch src/build/config/gclient_args.gni

git apply --directory=src                     $patches_dir/webrtc/src.diff
git apply --directory=src/build               $patches_dir/webrtc/build.diff
git apply --directory=src/third_party         $patches_dir/webrtc/third_party.diff
git apply --directory=src/third_party/libsrtp $patches_dir/webrtc/libsrtp.diff

pushd src
#$patches_dir/webrtc/configure.sh
GN_ARGS=(
    "target_os=\"linux\""
    "treat_warnings_as_errors=false"
    "is_component_build=false"
    "is_debug=false"
    "is_clang=false"
    "symbol_level=2"
    "proprietary_codecs=true"
    "use_custom_libcxx=false"
#    "use_system_libjpeg=true"
#    "system_libjpeg_root=\"/usr/include\""
#    "system_libjpeg_libs=[\"jpeg\"]"
    "use_rtti=true"
    "use_gold=false"
    "use_sysroot=false"
    "linux_use_bundled_binutils=false"
    "enable_dsyms=true"
    "rtc_include_tests=false"
    "rtc_build_examples=false"
    "rtc_build_tools=false"
    "rtc_build_opus=false"
    "rtc_build_ssl=false"
    "rtc_ssl_root=\"/usr/include\""
    "rtc_ssl_libs=[\"ssl\",\"crypto\"]"
    "rtc_builtin_ssl_root_certificates=false"
    "rtc_build_ffmpeg=false"
    "rtc_ffmpeg_root=\"/usr/include\""
    "rtc_ffmpeg_libs=[\"avcodec\",\"swscale\",\"swresample\",\"avutil\"]"
    "rtc_opus_root=\"/usr/include/opus\""
    "rtc_enable_protobuf=false"
)
gn gen out --args="${GN_ARGS[*]}"
ninja -C out webrtc
popd

popd

# Telegram build

CMAKE_ARGS=(
    "-DCMAKE_INSTALL_PREFIX=/app"
    "-DDESKTOP_APP_USE_PACKAGED:BOOL=ON"
    "-DDESKTOP_APP_USE_PACKAGED_LAZY:BOOL=ON"
    "-DDESKTOP_APP_USE_PACKAGED_LAZY_PLATFORMTHEMES:BOOL=OFF"
    "-DDESKTOP_APP_USE_PACKAGED_FONTS:BOOL=OFF"
    "-DTDESKTOP_LAUNCHER_BASENAME=org.telegram.desktop"
    "-DTDESKTOP_API_ID=611335"
    "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
)
mkdir build
pushd build
cmake -G Ninja "${CMAKE_ARGS[@]}" ..
popd
ninja -C build
ninja -C build install
