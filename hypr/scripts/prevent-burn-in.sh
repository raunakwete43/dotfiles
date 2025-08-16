#!/bin/bash

# Call me every now and then using cron

notify-send "Shifting pixels..."
sleep 1

# Render overlay over bar (swap each call)
hyproled -s -a 0:0:2880:48

# More precoutions in addition to hyproled

# Change gaps to prevent the borders burning in
in=3;
out=3;
if [ "$(hyprshade current)" == "hyproled_shader" ]; then
    in=1;
    out=1;
fi

hyprctl --instance 0 keyword general:gaps_in $in;
hyprctl --instance 0 keyword general:gaps_out $out;
