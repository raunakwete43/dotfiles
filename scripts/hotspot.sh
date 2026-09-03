#!/usr/bin/env bash
#
# wifi-hotspot.sh
#
# Creates a wifi hotspot that runs CONCURRENTLY with an active wifi
# connection, by spinning up a second virtual interface (ap0) on the
# same physical radio and matching its channel to the main wifi
# connection's current channel.
#
# Requirements:
#   - NetworkManager using the wpa_supplicant backend (NOT iwd).
#     Confirm with: journalctl -u NetworkManager -b | grep -i backend
#   - Your wifi chipset must support AP+STA concurrency:
#       iw list | grep -A 20 "valid interface combinations"
#     Look for a combination containing both "managed" and "AP".
#   - dnsmasq installed (NetworkManager uses it for hotspot DHCP):
#       sudo pacman -S dnsmasq
#
# Usage:
#   sudo ./wifi-hotspot.sh          # start the hotspot
#   sudo ./wifi-hotspot.sh stop     # stop and clean up
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Auto-elevate: re-exec with sudo if not already root
# ---------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    exec sudo -- "$0" "$@"
fi

# ---------------------------------------------------------------------------
# Variables — edit these
# ---------------------------------------------------------------------------
HOTSPOT_SSID="MyHotspot"          # Name of the hotspot network
HOTSPOT_PASSWORD="changeme123"    # Must be at least 8 characters (WPA-PSK)
MAIN_WIFI_IFACE="wlan0"           # The interface currently connected to wifi

# Internal names — usually no need to change these
AP_IFACE="ap0"
CONN_NAME="Hotspot"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo -e "\033[1;32m[hotspot]\033[0m $*"; }
warn() { echo -e "\033[1;33m[hotspot]\033[0m $*"; }
die()  { echo -e "\033[1;31m[hotspot]\033[0m $*" >&2; exit 1; }

cleanup() {
    log "Cleaning up any existing hotspot interface/connection..."
    nmcli connection down "$CONN_NAME" >/dev/null 2>&1 || true
    nmcli connection delete "$CONN_NAME" >/dev/null 2>&1 || true
    if ip link show "$AP_IFACE" >/dev/null 2>&1; then
        ip link set "$AP_IFACE" down >/dev/null 2>&1 || true
        iw dev "$AP_IFACE" del >/dev/null 2>&1 || true
    fi
}

# ---------------------------------------------------------------------------
# Stop mode
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "stop" ]]; then
    cleanup
    log "Hotspot stopped and cleaned up."
    exit 0
fi

# ---------------------------------------------------------------------------
# Start mode
# ---------------------------------------------------------------------------
if [[ ${#HOTSPOT_PASSWORD} -lt 8 ]]; then
    die "HOTSPOT_PASSWORD must be at least 8 characters for WPA-PSK."
fi

if ! ip link show "$MAIN_WIFI_IFACE" >/dev/null 2>&1; then
    die "Interface '$MAIN_WIFI_IFACE' not found. Check MAIN_WIFI_IFACE."
fi

# Always start from a clean slate
cleanup

# --- Handle Ctrl-C / termination at any point from here on: auto cleanup ---
on_interrupt() {
    echo
    warn "Interrupt received — tearing down hotspot..."
    cleanup
    log "Hotspot stopped and cleaned up."
    exit 0
}
trap on_interrupt INT TERM

# --- Detect the current channel of the main wifi connection ---------------
log "Detecting current channel on $MAIN_WIFI_IFACE..."
ACTIVE_LINE=$(nmcli -t -f ACTIVE,SSID,CHAN,FREQ dev wifi list ifname "$MAIN_WIFI_IFACE" | awk -F: '$1=="yes"')

if [[ -z "$ACTIVE_LINE" ]]; then
    die "Could not detect an active wifi connection on $MAIN_WIFI_IFACE. Connect to wifi first."
fi

CHANNEL=$(echo "$ACTIVE_LINE" | awk -F: '{print $3}')
FREQ=$(echo "$ACTIVE_LINE" | awk -F: '{print $4}' | grep -oE '^[0-9]+')

if [[ -z "$CHANNEL" || -z "$FREQ" ]]; then
    die "Failed to parse channel/frequency from: $ACTIVE_LINE"
fi

if [[ "$FREQ" -ge 5925 ]]; then
    BAND="a"     # (6GHz shows up oddly in nmcli; treat as 'a' band arg, but note 6E hotspot support is unreliable)
    warn "Detected 6GHz connection — hotspot AP mode on 6GHz is not reliably supported on most chipsets/drivers yet."
elif [[ "$FREQ" -ge 4900 ]]; then
    BAND="a"     # 5GHz
else
    BAND="bg"    # 2.4GHz
fi

log "Main wifi is on channel $CHANNEL (${FREQ} MHz, band $BAND). Hotspot will match this."

# --- Create the virtual AP interface on the same radio ---------------------
log "Creating virtual interface $AP_IFACE on $MAIN_WIFI_IFACE's radio..."
iw dev "$MAIN_WIFI_IFACE" interface add "$AP_IFACE" type __ap
ip link set "$AP_IFACE" up

# --- Create the hotspot connection profile ---------------------------------
log "Creating NetworkManager connection '$CONN_NAME'..."
nmcli connection add \
    type wifi \
    ifname "$AP_IFACE" \
    con-name "$CONN_NAME" \
    autoconnect no \
    ssid "$HOTSPOT_SSID" \
    mode ap \
    wifi.band "$BAND" \
    wifi.channel "$CHANNEL" \
    wifi-sec.key-mgmt wpa-psk \
    wifi-sec.psk "$HOTSPOT_PASSWORD" \
    ipv4.method shared

# --- Bring it up -------------------------------------------------------------
log "Starting hotspot '$HOTSPOT_SSID'..."
nmcli connection up "$CONN_NAME"

log "Done. Status:"
nmcli device status | grep -E "DEVICE|$MAIN_WIFI_IFACE|$AP_IFACE"

log "Hotspot is running. Press Ctrl-C to stop and clean up."
log "(To stop it from another terminal instead, run: sudo $0 stop)"

# Block here so the script stays alive to catch Ctrl-C.
# 'wait' on a background sleep loop lets the trap fire immediately.
while true; do
    sleep 3600 &
    wait $!
done
