#!/usr/bin/env bash

# Default interface (you can change this or pass it as an argument)
INTERFACE=${1:-wlan0}

# Check if macchanger is installed
if ! command -v macchanger &> /dev/null; then
    echo "macchanger is not installed. Installing..."
    sudo pacman -S --noconfirm macchanger || exit 1
fi

# Bring interface down
echo "[*] Bringing down interface $INTERFACE..."
sudo ip link set $INTERFACE down

# Randomize MAC address
echo "[*] Changing MAC address of $INTERFACE to random..."
sudo macchanger -r $INTERFACE

# Bring interface back up
echo "[*] Bringing up interface $INTERFACE..."
sudo ip link set $INTERFACE up

# Show new MAC
echo "[*] New MAC address:"
ip link show $INTERFACE | grep ether
