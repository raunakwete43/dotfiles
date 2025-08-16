#!/bin/bash

# Ensure environment variables are set
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export HYPRLAND_INSTANCE_SIGNATURE=${HYPRLAND_INSTANCE_SIGNATURE:-$(ls "$XDG_RUNTIME_DIR/hypr/" | grep -oP '^[^.]+' | head -n 1)}

# Function to handle events
handle() {
  if [[ "$1" == "fullscreen>>1" ]]; then
    hyproled off
    echo "OFF"
  else
    # Only activate if not already active
    if [ "$(hyprshade current)" != "hyproled_shader" ]; then
      hyproled -a 0:0:2880:50
      echo "ON"
    fi
  fi
}

# Listen to Hyprland events and process them
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
while read -r line; do 
  handle "$line"
done
