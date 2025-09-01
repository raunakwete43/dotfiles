#!/bin/bash

# Fade the screen and wait. Needs brightnessctl.
# When receiving SIGHUP, stop fading and set backlight to original brightness.
# When receiving SIGTERM, wait a bit, and set backlight to original brightness
# (this prevents the screen from flashing before it is turned completely off
# by DPMS in the locker command).

min_brightness=30
fade_time=2000
fade_steps=70

# Function to restore the original brightness level
restore_brightness() {
    brightnessctl s 35%
    exit 0
}

# Set up traps to restore brightness on exit, SIGHUP, and SIGTERM
trap restore_brightness EXIT
trap restore_brightness HUP
trap 'sleep 1s; restore_brightness' TERM

# Start fading the brightness to the minimum level
brightnessctl s 10% &

wait
sleep infinity & # No, sleeping in the foreground does not work
wait

