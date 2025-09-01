#!/bin/bash

# initial=0
# flag=0

while true; do
    
    headphone="$(pactl list sinks | grep 'Headphones' | awk '/availability/{print $12}' | sed 's/)//')"
    auto_mute="$(amixer -c 1 | grep -e "Item0" | awk '/Item0/{print $2}' | tr -d "'")"

    if [ "$headphone" == "unknown" ]; then
        h_status=true
    else
        h_status=false
    fi

    if [ "$auto_mute" == "Enabled" ]; then
        a_status=true
    else
        a_status=false
    fi

    if [ "$h_status" == "true" -a "$a_status" == "false" ]; then
        amixer -c 1 sset "Auto-Mute Mode" Enabled
        notify-send "Automute Enabled" --icon="/home/manupro85/Pictures/Icons/headphone.png"
    fi

    sleep 2
done

