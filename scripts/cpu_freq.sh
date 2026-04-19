#!/usr/bin/env bash

# usage:
# sudo ./set_cpu_freq.sh <max_GHz> [min_GHz]

if [[ -z "$1" ]]; then
  echo "Provide max GHz"
  exit 1
fi

MAX_GHZ="$1"
MIN_GHZ="$2"

# convert GHz → kHz
MAX_KHZ=$(awk "BEGIN {printf \"%d\", $MAX_GHZ * 1000000}")

# only compute MIN if provided
if [[ -n "$MIN_GHZ" ]]; then
  MIN_KHZ=$(awk "BEGIN {printf \"%d\", $MIN_GHZ * 1000000}")
fi

for CPU in /sys/devices/system/cpu/cpu[0-9]*; do
  echo "$MAX_KHZ" | sudo tee "$CPU/cpufreq/scaling_max_freq" > /dev/null

  if [[ -n "$MIN_KHZ" ]]; then
    echo "$MIN_KHZ" | sudo tee "$CPU/cpufreq/scaling_min_freq" > /dev/null
  fi
done

echo "Max set: $MAX_GHZ GHz"

if [[ -n "$MIN_GHZ" ]]; then
  echo "Min set: $MIN_GHZ GHz"
else
  echo "Min unchanged"
fi
