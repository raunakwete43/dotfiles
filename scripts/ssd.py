#!/usr/bin/env python3
import csv
import re
import subprocess
from datetime import datetime
from pathlib import Path
import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    stream=sys.stdout,
)

logging.info("Starting SSD SMART data collection script.")

# Path to output CSV log file
LOG_FILE = Path("/home/manu/.nvme_smart_log.csv")

# Device to monitor
DEVICE = "/dev/nvme0n1"

# SMART attributes to extract
FIELDS = {
    "Power Cycles": r"Power Cycles:\s+([\d,]+)",
    "Power On Hours": r"Power On Hours:\s+([\d,]+)",
    "Unsafe Shutdowns": r"Unsafe Shutdowns:\s+([\d,]+)",
    "Data Units Read": r"Data Units Read:\s+([\d,]+)",
    "Data Units Written": r"Data Units Written:\s+([\d,]+)",
    "Percentage Used": r"Percentage Used:\s+(\d+)%",
    "Available Spare": r"Available Spare:\s+(\d+)%",
    "Controller Busy Time": r"Controller Busy Time:\s+([\d,]+)",
    "Media and Data Integrity Errors": r"Media and Data Integrity Errors:\s+([\d,]+)",
    "Error Information Log Entries": r"Error Information Log Entries:\s+([\d,]+)",
}


def run_smartctl(device: str) -> str:
    """Run smartctl and return output as string."""
    result = subprocess.run(
        ["smartctl", "-a", device],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"smartctl failed: {result.stderr.strip()}")
    return result.stdout


def parse_output(output: str) -> dict:
    """Extract values based on regex patterns."""
    data = {"Timestamp": datetime.now().isoformat(timespec="seconds")}
    for field, pattern in FIELDS.items():
        match = re.search(pattern, output)
        if match:
            value = match.group(1).replace(",", "")
            data[field] = value
        else:
            data[field] = None
    return data


def append_to_csv(file: Path, data: dict):
    """Append SMART data to CSV file."""
    file_exists = file.exists()
    with open(file, "a", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=["Timestamp"] + list(FIELDS.keys()))
        if not file_exists:
            writer.writeheader()
        writer.writerow(data)


def main():
    try:
        output = run_smartctl(DEVICE)
        data = parse_output(output)
        append_to_csv(LOG_FILE, data)
    except Exception as e:
        logging.error(f"An error occurred while collecting SMART data. {e}")
        # print(f"Error: {e}")
    logging.info("SMART data collection completed.")


if __name__ == "__main__":
    main()
