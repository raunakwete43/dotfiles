#!/bin/bash

nm-applet &

# custom scripts
bash ~/Downloads/scripts/headphone.sh &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/bin/dunst -conf /home/manupro85/.config/dunstrc &
