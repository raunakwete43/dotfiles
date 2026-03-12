#!/usr/bin/env bash

freq="$1"
path="/sys/class/drm/card1/device"

if [ -z "$freq" ]; then
    echo "Usage: $0 <freq>"
    exit 1
fi

current=$(cat $path/power_dpm_force_performance_level)

echo "Current performance level: $current"

if [ "$current" = "auto" ]; then
    echo manual | sudo tee $path/power_dpm_force_performance_level > /dev/null
elif [ "$current" = "high" ]; then
    echo low | sudo tee $path/power_dpm_force_performance_level > /dev/null
    echo manual | sudo tee $path/power_dpm_force_performance_level > /dev/null
fi

echo "Setting frequency to $freq"

echo "s 1 $freq" | sudo tee $path/pp_od_clk_voltage > /dev/null
echo "c" | sudo tee $path/pp_od_clk_voltage > /dev/null
