import socket


def scan_ports(target, start_port, end_port):
    open_ports = []

    for port in range(start_port, end_port + 1):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)

        result = sock.connect_ex((target, port))
        if result == 0:
            open_ports.append(port)
        sock.close()

    return open_ports


target_ip = "192.168.1.1"  # Replace with your target IP
start_port = 1
end_port = 1024  # You can adjust the range of ports to scan

open_ports = scan_ports(target_ip, start_port, end_port)
if open_ports:
    print(f"Open ports on {target_ip}: {open_ports}")
else:
    print("No open ports found.")
