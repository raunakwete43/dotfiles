from pathlib import Path
from archinstall import disk

fs_type = disk.FilesystemType("ext4")
device_path = Path("/dev/sda")

device = disk.device_handler.get_device(device_path)
print(device)
