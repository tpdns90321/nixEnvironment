#!/bin/sh

WLR_BACKENDS=headless
WAYLAND_DISPLAY=wayland-1
sway &
sleep 5
wayvnc 0.0.0.0
