#!/bin/bash

# Discover k10temp hwmon path
for hwmon in /sys/class/hwmon/hwmon*/name; do
  if grep -q '^k10temp$' "$hwmon"; then
    export HWMON_PATH="$(dirname "$hwmon")/temp1_input"
    break
  fi
done

# Substitute env var into waybar config
envsubst < ~/.config/waybar/config_template.jsonc > ~/.config/waybar/config.jsonc

# Start waybar with the substituted config
waybar &
