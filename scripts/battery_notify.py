#!/usr/bin/env python3
from pydbus import SystemBus
from gi.repository import GLib
import subprocess

LOW_THRESHOLD = 41
FULL_THRESHOLD = 78

NOTIFY_LOW_SENT = False
NOTIFY_FULL_SENT = False

bus = SystemBus()
loop = GLib.MainLoop()

# Find battery device
upower = bus.get(".UPower")
devices = upower.EnumerateDevices()
battery = None
for dev in devices:
    if "battery" in dev:
        battery = bus.get(".UPower", dev)
        break

if not battery:
    print("No battery found.")
    exit(1)


def notify(summary, body, urgency="normal"):
    subprocess.run(["notify-send", "-u", urgency, summary, body])


def on_properties_changed(interface, changed, invalidated):
    global NOTIFY_LOW_SENT, NOTIFY_FULL_SENT

    percent = battery.Percentage
    state = battery.State  # 1=charging, 2=discharging, 4=fully charged

    if percent <= LOW_THRESHOLD and state == 2:  # Discharging
        if not NOTIFY_LOW_SENT:
            notify(
                "Battery Low",
                f"Battery is at {int(percent)}%. Plug in the charger.",
                "critical",
            )
            NOTIFY_LOW_SENT = True
            NOTIFY_FULL_SENT = False
    elif percent >= FULL_THRESHOLD and state == 1:  # Charging
        if not NOTIFY_FULL_SENT:
            notify(
                "Battery Full",
                f"Battery is at {int(percent)}%. Unplug the charger.",
                "normal",
            )
            NOTIFY_FULL_SENT = True
            NOTIFY_LOW_SENT = False


battery.onPropertiesChanged = on_properties_changed

print("Battery monitoring started...")
loop.run()
