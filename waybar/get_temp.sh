#!/bin/bash
HWMON_CACHE="${XDG_RUNTIME_DIR:-/tmp}/.k10temp_hwmon"

if [ ! -f "$HWMON_CACHE" ]; then
  for hwmon in /sys/class/hwmon/hwmon*/name; do
    if grep -q '^k10temp$' "$hwmon"; then
      dirname "$hwmon" > "$HWMON_CACHE"
      break
    fi
  done
fi

cat "$(cat "$HWMON_CACHE")/temp1_input"
