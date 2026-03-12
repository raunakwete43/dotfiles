#!/usr/bin/env bash

# ASUS fan profile controller (ACPI WMNB)

METHOD="\_SB.ATKD.WMNB 0x00 0x4C4E4146"

usage() {
echo "Usage: $0 {quiet|balanced|performance|turbo|0|1|2|3}"
exit 1
}

case "$1" in
quiet|0)
MODE=0x00
NAME="Quiet"
;;
balanced|1)
MODE=0x01
NAME="Balanced"
;;
performance|2)
MODE=0x02
NAME="Performance"
;;
turbo|3)
MODE=0x03
NAME="Turbo"
;;
*)
usage
;;
esac

BUFFER="{${MODE},0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}"

echo "${METHOD} ${BUFFER}" | sudo tee /proc/acpi/call >/dev/null

echo "Fan profile set to: $NAME"
