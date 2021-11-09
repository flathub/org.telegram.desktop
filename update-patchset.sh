#!/bin/sh
set -e

pushd desktop-app-patches > /dev/null
git fetch
git checkout origin/master
popd > /dev/null

QT=6_2_0
find desktop-app-patches -maxdepth 1 -name '*'_${QT} -type d -exec ./gen-patchset.py {} \;
