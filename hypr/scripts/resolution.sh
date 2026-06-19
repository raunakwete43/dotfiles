#!/usr/bin/env bash
set -euo pipefail

MONITOR="eDP-1"

CURRENT_SCALE="$(hyprctl monitors "$MONITOR" \
    | awk '/scale:/ {print $2}')"

if [[ "$CURRENT_SCALE" == "1.50" ]]; then
    TARGET_SCALE="1"
else
    TARGET_SCALE="1.5"
fi

hyprctl eval "
hl.monitor({
    output = \"$MONITOR\",
    mode = \"2880x1800@120\",
    position = \"0x0\",
    bitdepth = 10,
    scale = $TARGET_SCALE
})
"

notify-send "Display Scale" "$MONITOR → $TARGET_SCALE"
