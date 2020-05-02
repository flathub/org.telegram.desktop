#!/bin/bash

if [ "${XDG_CURRENT_DESKTOP,,}" == "gnome" ] || [ "${XDG_SESSION_DESKTOP,,}" == "gnome" ]; then
    if [ -z "$QT_QPA_PLATFORM" ]; then
        export QT_QPA_PLATFORM=xcb
    fi
fi

exec telegram-desktop.bin "$@"
