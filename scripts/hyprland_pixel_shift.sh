#!/bin/bash

INTERVAL=1
SHIFT_AMOUNT=1

while true; do
    winid=$(hyprctl activewindow -j | jq -r '.address')
    if [ "$winid" != "0x0" ]; then
        x=$(( (RANDOM % (2 * SHIFT_AMOUNT + 1)) - SHIFT_AMOUNT ))
        y=$(( (RANDOM % (2 * SHIFT_AMOUNT + 1)) - SHIFT_AMOUNT ))
        hyprctl dispatch movewindowpixel "$x" "$y"
    fi
    sleep $INTERVAL
done
