export WLR_BACKENDS=headless
export WAYLAND_DISPLAY=wayland-1
sway &
sleep 5
wayvnc 0.0.0.0
