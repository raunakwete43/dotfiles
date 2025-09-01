import subprocess
import argparse
import os

parser = argparse.ArgumentParser()

parser.add_argument("name")
parser.add_argument("--type", choices=["minimal", "notebook"], default="minimal")

args = parser.parse_args()

env_name = args.name
env_type = args.type
env_path = os.getcwd()

command = f"python -m venv {env_name}"
print(command)
result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

if result.returncode == 0:
    print("Command ran successfully")
else:
    print(f"Command falied with error {result.stderr}")

activate_env = os.path.join(env_path, env_name, "bin", "activate")
activate_cmd = f"source {activate_env}"

print(activate_cmd)

activate_result = subprocess.run(activate_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

if activate_result.returncode == 0:
    print(f"Successfully activated {env_name}")
else:
    print(f"Command falied with error {result.stderr}")
    exit(1)

modules_to_install = ["numpy"]  # Add more modules as needed
install_cmd = f"pip install {' '.join(modules_to_install)}"

install_result = subprocess.run(install_cmd, shell=True)

if install_result.returncode == 0:
    print(f"Successfully installed modules in {env_name}")
else:
    print(f"Command failed with error {install_result.stderr}")
    exit(1)
