#!/bin/bash

# Set the touchpad device name
touchpad_device="ELAN1301:00 04F3:30EF Touchpad"

# Get the current status of the touchpad
status=$(xinput list-props "$touchpad_device" | grep "Device Enabled" | awk '{print $4}')

# Toggle the touchpad status
if [ "$status" -eq 1 ]; then
    xinput disable "$touchpad_device"
    notify-send  "Touchpad disabled"
else
    xinput enable "$touchpad_device"
    notify-send  "Touchpad enabled"
fi
