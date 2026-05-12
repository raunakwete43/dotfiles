#!/usr/bin/env bash

set -e

[ "$#" -lt 1 ] && { echo "Provide EPP number 0-4"; exit 1; }

num="$1"
shift

case "$num" in
  0) epp="default" ;;
  1) epp="performance" ;;
  2) epp="balance_performance" ;;
  3) epp="balance_power" ;;
  4) epp="power" ;;
  *) echo "Invalid value"; exit 1 ;;
esac

is_online() {
  cpu=$1
  online_path="/sys/devices/system/cpu/cpu${cpu}/online"

  [ ! -f "$online_path" ] && return 0
  [ "$(cat "$online_path")" = "1" ]
}

apply_epp() {
  cpu=$1
  path="/sys/devices/system/cpu/cpu${cpu}/cpufreq/energy_performance_preference"

  is_online "$cpu" || { echo "cpu${cpu} offline"; return; }
  [ ! -f "$path" ] && { echo "cpu${cpu} skip"; return; }

  if echo "$epp" | sudo tee "$path" > /dev/null 2>/dev/null; then
    echo "cpu${cpu} -> $epp"
  else
    echo "cpu${cpu} busy"
  fi
}

max_cpu=$(nproc --all)

if [ "$#" -eq 0 ]; then
  for ((cpu=0; cpu<max_cpu; cpu++)); do
    apply_epp "$cpu"
  done
  exit 0
fi

for range in "$@"; do
  IFS='-' read -r start end <<< "$range"
  for ((i=start; i<=end; i++)); do
    apply_epp "$i"
  done
done
