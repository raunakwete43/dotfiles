#!/usr/bin/env python3
"""strix_co - Curve Optimizer setter for AMD Strix Point (Ryzen AI 9 HX 370 etc.)

Talks to the MP1 SMU mailbox through the SMN index/data pair in the root
complex's PCI config space (same transport ryzenadj uses on Strix Point).
Values are volatile: a reboot (and often suspend/resume) returns to BIOS defaults.

    sudo ./strix_co.py info
    sudo ./strix_co.py cores
    sudo ./strix_co.py set -15 --dry-run
    sudo ./strix_co.py set -15            # all-core
    sudo ./strix_co.py set -20 --core 3   # per-core (experimental)
    sudo ./strix_co.py reset
    ./strix_co.py unit -15                # print a systemd unit (does not install)

Mailbox constants/message IDs follow ryzenadj's FAM_STRIXPOINT table and the
rustinfo project's smuctl. I could not test on hardware: verify on your machine.
"""

import argparse, fcntl, glob, os, struct, sys, time

CFG = "/sys/bus/pci/devices/0000:00:00.0/config"
IDX, DAT = 0xB8, 0xBC  # SMN index/data in config space
MSG, RSP, ARG = 0x3B10928, 0x3B10978, 0x3B10998
CMD_VERSION, CMD_CO_PER, CMD_CO_ALL = 0x02, 0x4B, 0x4C
CO_LIMIT = 30  # conservative mobile Zen5 limit
LOCK = "/run/lock/strix_co.lock"
RESP = {
    0x01: "OK",
    0xFF: "Failed",
    0xFE: "UnknownCmd",
    0xFD: "RejectedPrereq",
    0xFC: "Busy",
}


def cpu_id():
    fam = mod = None
    for line in open("/proc/cpuinfo"):
        k, _, v = line.partition(":")
        k, v = k.strip(), v.strip()
        if k == "cpu family" and fam is None:
            fam = int(v)
        if k == "model" and mod is None:
            mod = int(v)
        if fam is not None and mod is not None:
            break
    return fam, mod


def check_cpu(force):
    fam, mod = cpu_id()
    # Strix Point = family 0x1A, models 0x20-0x2F. Family 0x1A also covers
    # desktop Zen5 / Strix Halo / Krackan, whose mailboxes differ.
    if (fam == 26 and 0x20 <= mod <= 0x2F) or force:
        return
    sys.exit(
        f"CPU family {fam} model 0x{mod:X} is not Strix Point (0x1A/0x20-0x2F). "
        "Refusing to poke SMN addresses. Use --force at your own risk."
    )


class Smn:
    def __init__(self):
        self.lock = open(LOCK, "w")
        fcntl.flock(self.lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        self.f = os.open(CFG, os.O_RDWR)

    def rd(self, addr):
        os.pwrite(self.f, struct.pack("<I", addr), IDX)
        return struct.unpack("<I", os.pread(self.f, 4, DAT))[0]

    def wr(self, addr, val):
        os.pwrite(self.f, struct.pack("<I", addr), IDX)
        os.pwrite(self.f, struct.pack("<I", val & 0xFFFFFFFF), DAT)

    def wait_rsp(self, timeout):
        end = time.monotonic() + timeout
        while time.monotonic() < end:
            r = self.rd(RSP)
            if r:
                return r
            time.sleep(0.0005)
        return 0

    def send(self, op, a0=0):
        if not self.wait_rsp(0.5):
            sys.exit("SMU mailbox never became idle (RSP stayed 0); aborting.")
        self.wr(RSP, 0)
        for i in range(6):
            self.wr(ARG + 4 * i, a0 if i == 0 else 0)
        self.wr(MSG, op)
        r = self.wait_rsp(1.5)
        if not r:
            sys.exit(f"SMU timed out on message 0x{op:X}.")
        return r, self.rd(ARG)


def enc_all(v, bits):
    return v & ((1 << bits) - 1)  # two's complement in N bits


def enc_per(core, v):
    return ((core & 0xF) << 20) | (v & 0xFFFF)


def apply(args):
    check_cpu(args.force)
    lim = CO_LIMIT
    if not -lim <= args.value <= lim:
        sys.exit(f"Offset {args.value} outside +/-{lim}. Refusing.")
    if args.core is None:
        op, raw = CMD_CO_ALL, enc_all(args.value, args.bits)
        what = f"all-core {args.value:+d}"
    else:
        if not 0 <= args.core <= 15:
            sys.exit("core must be 0-15 (hardware core id; see `cores`).")
        op, raw = CMD_CO_PER, enc_per(args.core, args.value)
        what = f"core {args.core} {args.value:+d}"
    print(f"{what}: msg 0x{op:02X} arg0 0x{raw:08X}")
    if args.dry_run:
        print("dry run: nothing sent.")
        return
    r, a0 = Smn().send(op, raw)
    name = RESP.get(r, f"0x{r:X}")
    print(f"SMU response: {name}   (arg0 readback 0x{a0:08X}, informational)")
    if r != 1:
        sys.exit(1)
    print("Accepted. That is not proof it took effect: validate with a stress test.")


def info(args):
    fam, mod = cpu_id()
    print(f"CPU family 0x{fam:X} model 0x{mod:X}")
    check_cpu(args.force)
    r, v = Smn().send(CMD_VERSION)
    print(
        f"GetSMUVersion -> {RESP.get(r, hex(r))}, arg0 0x{v:08X}"
        + (f" ({(v >> 16) & 255}.{(v >> 8) & 255}.{v & 255})" if r == 1 else "")
    )


def cores(_):
    seen = {}
    for p in glob.glob("/sys/devices/system/cpu/cpu[0-9]*/topology/core_id"):
        cpu = int(p.split("/")[5][3:])
        seen.setdefault(int(open(p).read()), []).append(cpu)
    for cid in sorted(seen):
        print(f"hardware core {cid:2d}: threads {sorted(seen[cid])}")


def unit(args):
    exe = os.path.abspath(__file__)
    print(f"""[Unit]
Description=Curve Optimizer {args.value:+d}
After=multi-user.target suspend.target hibernate.target
[Service]
Type=oneshot
ExecStart={exe} set {args.value}
[Install]
WantedBy=multi-user.target suspend.target hibernate.target
""")


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--force", action="store_true", help="skip CPU model check")
    s = p.add_subparsers(dest="cmd", required=True)
    s.add_parser("info").set_defaults(fn=info)
    s.add_parser("cores").set_defaults(fn=cores)
    for name in ("set", "reset"):
        q = s.add_parser(name)
        if name == "set":
            q.add_argument("value", type=int)
        q.add_argument("--core", type=int)
        q.add_argument(
            "--bits",
            type=int,
            choices=(20, 28),
            default=28,
            help="all-core encoding width (28 per rustinfo; 20 per older ryzenadj docs)",
        )
        q.add_argument("--dry-run", action="store_true")
        q.set_defaults(fn=apply, **({"value": 0} if name == "reset" else {}))
    u = s.add_parser("unit")
    u.add_argument("value", type=int)
    u.set_defaults(fn=unit)
    a = p.parse_args()
    if a.cmd not in ("unit", "cores") and os.geteuid() != 0:
        sys.exit("Run as root.")
    a.fn(a)


if __name__ == "__main__":
    main()
