#!/usr/bin/env bash

# usage:
# disable threads: ./cpu_ctl.sh 4-11 16-23
# enable  threads: ./cpu_ctl.sh -e 4-11 16-23
# disable cores  : ./cpu_ctl.sh -c 0-3
# enable  cores  : ./cpu_ctl.sh -e -c 0-3

set -e

mode="disable"
core_mode=0

while [[ "$1" == -* ]]; do
  case "$1" in
    -e|--enable) mode="enable"; shift ;;
    -c|--core)   core_mode=1; shift ;;
    *) echo "Unknown flag $1"; exit 1 ;;
  esac
done

[ "$#" -eq 0 ] && { echo "Provide ranges like: 4-11 16-23"; exit 1; }

value=0
[ "$mode" = "enable" ] && value=1

# apply function
apply_cpu() {
  local cpu=$1
  local path="/sys/devices/system/cpu/cpu${cpu}/online"

  if [ -f "$path" ]; then
    echo "$value" | sudo tee "$path" > /dev/null
    echo "$mode cpu${cpu}"
  else
    echo "cpu${cpu} skip"
  fi
}

for range in "$@"; do
  IFS='-' read -r start end <<< "$range"

  for ((i=start; i<=end; i++)); do
    if [ "$core_mode" -eq 1 ]; then
      # 12 cores → sibling offset 12
      apply_cpu "$i"
      apply_cpu "$((i + 12))"
    else
      apply_cpu "$i"
    fi
  done
done
