#!/usr/bin/env bash
# cool-run.sh — run any command with NVMe thermal throttling

THERMAL_TARGET=78
NVME_DEV="/dev/nvme0n1"
POLL_INTERVAL=5
COOLDOWN=15

if [ $# -eq 0 ]; then
  echo "Usage: ssd_throttle.sh <command> [args...]"
  exit 1
fi

echo "Running: $*"


# -p 'CPUQuota=200%' \

systemd-run --user --scope \
  -p "IOReadBandwidthMax=${NVME_DEV} 80M" \
  -p "IOWriteBandwidthMax=${NVME_DEV} 80M" \
  -p 'IOWeight=10' \
  ionice -c 3 nice -n 19 \
  taskset -c 0,1 \
  "$@" &

PID=$!

while kill -0 $PID 2>/dev/null; do
  TEMP=$(cat /sys/class/nvme/nvme0/hwmon*/temp1_input 2>/dev/null | head -1)
  TEMP_C=$((TEMP / 1000))

  if [ "$TEMP_C" -gt "$THERMAL_TARGET" ]; then
    echo "Temp ${TEMP_C}°C > ${THERMAL_TARGET}°C — pausing for ${COOLDOWN}s..."
    kill -STOP $PID
    sleep $COOLDOWN
    kill -CONT $PID
    echo "Resuming..."
  fi
  sleep $POLL_INTERVAL
done

wait $PID
echo "Done (exit code: $?)."
