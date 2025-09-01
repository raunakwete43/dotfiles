#!/bin/bash

FAN_SPEED=$(sensors | awk '/cpu_fan/ { printf "%.0f\n", $2 }')
ICON=""

if [[ -n "$FAN_SPEED" ]] && [[ "$FAN_SPEED" =~ ^[0-9]+$ ]]; then
	if [ "$FAN_SPEED" -gt 3000 ]; then
		echo "%{F#FF0000}$ICON $FAN_SPEED RPM%{F-}"
	else
		echo "$ICON $FAN_SPEED RPM"
	fi
else
	echo "No fan speed data available"
fi
