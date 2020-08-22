#!/bin/bash
set -e
set -x

BUILD_TYPE=RelWithDebInfo

# WebRTC build

pushd ../Libraries/tg_owt
cmake \
        "-DCMAKE_BUILD_TYPE=${BUILD_TYPE}" \
        "-DCMAKE_INSTALL_PREFIX=/app" \
        -G Ninja -S . -B "out/${BUILD_TYPE}"
ninja -C "out/${BUILD_TYPE}" -j${FLATPAK_BUILDER_N_JOBS}
popd

# Telegram build

cmake \
        "-DCMAKE_BUILD_TYPE=${BUILD_TYPE}" \
        "-DCMAKE_INSTALL_PREFIX=/app" \
        "-DDESKTOP_APP_USE_PACKAGED:BOOL=ON" \
        "-DDESKTOP_APP_USE_PACKAGED_LAZY:BOOL=ON" \
        "-DDESKTOP_APP_USE_PACKAGED_LAZY_PLATFORMTHEMES:BOOL=OFF" \
        "-DDESKTOP_APP_USE_PACKAGED_FONTS:BOOL=OFF" \
        "-DTDESKTOP_LAUNCHER_BASENAME=org.telegram.desktop" \
        "-DTDESKTOP_API_ID=611335" \
        "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c" \
        -G Ninja -S . -B build
ninja -C build -j${FLATPAK_BUILDER_N_JOBS}
ninja -C build install
