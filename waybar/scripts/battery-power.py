#!/usr/bin/env python3

import json
import sys
import os


def get_battery_power():
    """Calculate battery power in watts from current and voltage"""
    try:
        # Read current (microamps) and voltage (microvolts)
        with open("/sys/class/power_supply/BAT1/current_now", "r") as f:
            current_ua = int(f.read().strip())

        with open("/sys/class/power_supply/BAT1/voltage_now", "r") as f:
            voltage_uv = int(f.read().strip())

        with open("/sys/class/power_supply/BAT1/status", "r") as f:
            status = f.read().strip()

        # Convert to watts (current in A * voltage in V)
        power_watts = (current_ua / 1_000_000) * (voltage_uv / 1_000_000)

        # Determine if charging or discharging
        if status == "Charging":
            sign = "+"
        elif status == "Discharging":
            sign = "-"
        else:
            sign = ""
        
        # Use lightning bolt icon always
        icon = "󱐋"

        # Format output with 2 decimal places
        text = f"{icon} {sign}{power_watts:.2f}W"

        # Waybar JSON output
        output = {
            "text": text,
            "tooltip": f"Battery Power: {sign}{power_watts:.2f}W\nStatus: {status}",
            "class": status.lower(),
        }

        print(json.dumps(output))

    except Exception as e:
        # Fallback output if there's an error
        output = {
            "text": "⚠ N/A",
            "tooltip": f"Error reading battery power: {e}",
            "class": "error",
        }
        print(json.dumps(output))


if __name__ == "__main__":
    get_battery_power()

