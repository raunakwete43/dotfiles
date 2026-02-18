#!/bin/bash

choice=$(printf "Performance\nBalanced\nPower Saver" | rofi -dmenu -p "Power Profile")

case "$choice" in
  25W)
    sudo ryzenadj \
      -a 25000 -b 25000 -c 25000 \
      -d 1000 -e 1000 -f 70 \
      --apu-slow-limit=25000 \
      --power-saving
    ;;

  15W)
    sudo ryzenadj \
      -a 15000 -b 15000 -c 15000 \
      -d 1000 -e 1000 -f 60 \
      --apu-slow-limit=15000 \
      --power-saving
    ;;

  Power\ Saver)
    sudo ryzenadj \
      -a 8000 -b 8000 -c 8000 \
      -d 1000 -e 1000 -f 50 \
      --apu-slow-limit=8000 \
      --power-saving
    ;;
esac




