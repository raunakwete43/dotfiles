#!/usr/bin/env bash

# usage:
# ./gov.sh 0        → performance all
# ./gov.sh 1 0-11   → powersave cpus 0-11

set -e

[ "$#" -lt 1 ] && { echo "Provide mode 0/1"; exit 1; }

num="$1"
shift

case "$num" in
  0) gov="performance" ;;
  1) gov="powersave" ;;
  *) echo "Invalid value"; exit 1 ;;
esac

is_online() {
  cpu=$1
  p="/sys/devices/system/cpu/cpu${cpu}/online"
  [ ! -f "$p" ] && return 0
  [ "$(cat "$p")" = "1" ]
}

apply_gov() {
  cpu=$1
  path="/sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor"

  is_online "$cpu" || { echo "cpu${cpu} offline"; return; }
  [ ! -f "$path" ] && { echo "cpu${cpu} skip"; return; }

  if echo "$gov" | sudo tee "$path" > /dev/null 2>/dev/null; then
    echo "cpu${cpu} -> $gov"
  else
    echo "cpu${cpu} busy"
  fi
}

max_cpu=$(nproc --all)

if [ "$#" -eq 0 ]; then
  for ((cpu=0; cpu<max_cpu; cpu++)); do
    apply_gov "$cpu"
  done
  exit 0
fi

for range in "$@"; do
  IFS='-' read -r start end <<< "$range"
  for ((i=start; i<=end; i++)); do
    apply_gov "$i"
  done
done
