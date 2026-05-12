#!/usr/bin/env bash

# usage:
# ./pp.sh 0   → quiet
# ./pp.sh 1   → balanced
# ./pp.sh 2   → performance

set -e

[ "$#" -ne 1 ] && { echo "Provide mode 0-2"; exit 1; }

case "$1" in
  0) prof="quiet" ;;
  1) prof="balanced" ;;
  2) prof="performance" ;;
  *) echo "Invalid value"; exit 1 ;;
esac

path="/sys/firmware/acpi/platform_profile"

[ ! -f "$path" ] && { echo "Not supported"; exit 1; }

if echo "$prof" | sudo tee "$path" > /dev/null 2>/dev/null; then
  echo "platform -> $prof"
else
  echo "write failed"
fi
