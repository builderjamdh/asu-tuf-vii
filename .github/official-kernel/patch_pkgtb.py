#!/usr/bin/env python3
"""Replace the kernel inside a pkgtb's bootfs with an official kernel payload.

Usage:
    python patch_pkgtb.py --pkgtb in.pkgtb --out out.pkgtb
                         --kernel official_kernel.lzo [--key Krot-fld.pem]

The bootfs FIT is rebuilt (data-position/data-size patched, all hash-1 values
recomputed, re-signed with the demo key) and the pkgtb structure block is
patched (bootfs data-size + hash-1, rootfs data-offset).
"""
import argparse
import struct
import hashlib
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fdt_parse import parse_fdt
from fit_build import build_data, walk_props, sign

DEFAULT_KEY = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "..",
    "release", "src-rt-5.04behnd.4916",
    "targets", "keys", "demo", "GEN3", "Krot-fld.pem")


def patch_pkgtb(pkgtb_path, out_path, kernel_payload, key_path):
    data = bytearray(open(pkgtb_path, "rb").read())
    ts = struct.unpack(">I", data[4:8])[0]
    base = (ts + 3) & ~3
    tree = parse_fdt(data)
    imgs = tree["children"]["images"]["children"]
    payloads = {}
    for name, node in imgs.items():
        pr = node["props"]
        off = struct.unpack(">I", pr["data-offset"])[0]
        size = struct.unpack(">I", pr["data-size"])[0]
        payloads[name] = (base + off, size, data[base + off:base + off + size])
    boot_name = [n for n in payloads if "bootfs" in n]
    assert len(boot_name) == 1, boot_name
    boot_name = boot_name[0]
    bf_off, bf_size, bf = payloads[boot_name]
    print(f"bootfs  @ {bf_off:#x} size {bf_size:#x} ({bf_size})")

    new_bf = build_data(bf, {"kernel": kernel_payload}, resign=True,
                        key_path=key_path)
    print(f"new bootfs size {len(new_bf):#x} ({len(new_bf)})")

    # patch pkgtb structure block in place
    off_struct = struct.unpack(">I", data[8:12])[0]
    off_strings = struct.unpack(">I", data[12:16])[0]
    patched = []
    for path, pname, voff, plen in walk_props(data, off_struct, off_strings):
        if pname == "data-size" and path == "//images/%s" % boot_name:
            struct.pack_into(">I", data, voff, len(new_bf))
            patched.append((path, pname, hex(len(new_bf))))
        elif pname == "value" and path == "//images/%s/hash-1" % boot_name:
            assert plen == 32
            dig = hashlib.sha256(new_bf).digest()
            struct.pack_into("32s", data, voff, dig)
            patched.append((path, pname, dig.hex()))
        elif pname == "data-offset" and path == "//images/nand_squashfs":
            struct.pack_into(">I", data, voff, len(new_bf))
            patched.append((path, pname, hex(len(new_bf))))
    for p in patched:
        print("  patched", p)

    # reassemble: structure block + new bootfs + rootfs (rootfs unchanged)
    rootfs = None
    for name, (off, size, payload) in payloads.items():
        if "squashfs" in name or "rootfs" in name:
            rootfs = payload
    assert rootfs is not None
    out = bytes(data[:base]) + new_bf + rootfs
    open(out_path, "wb").write(out)
    print("wrote", out_path, "size", hex(len(out)), f"({len(out)})")
    return out


def verify(pkgtb_path, key_path):
    data = open(pkgtb_path, "rb").read()
    ts = struct.unpack(">I", data[4:8])[0]
    base = (ts + 3) & ~3
    tree = parse_fdt(data)
    ok = True
    for name, node in tree["children"]["images"]["children"].items():
        pr = node["props"]
        off = struct.unpack(">I", pr["data-offset"])[0]
        size = struct.unpack(">I", pr["data-size"])[0]
        payload = data[base + off:base + off + size]
        hv = node["children"]["hash-1"]["props"]["value"].hex()
        m = hashlib.sha256(payload).hexdigest() == hv
        ok &= m
        print(f"  pkgtb {name:16s} size {size:#x} hash-1 match: {m}")
        if "bootfs" in name:
            ts2 = struct.unpack(">I", payload[4:8])[0]
            assert payload[ts2:ts2 + 4] == b"STIF"
            sig = payload[ts2 + 4:ts2 + 260]
            from cryptography.hazmat.primitives.serialization import load_pem_private_key
            from cryptography.hazmat.primitives.asymmetric import padding
            from cryptography.hazmat.primitives import hashes as h
            pub = load_pem_private_key(open(key_path, "rb").read(), None).public_key()
            try:
                pub.verify(sig, payload[:ts2],
                           padding.PSS(mgf=padding.MGF1(h.SHA256()),
                                       salt_length=padding.PSS.MAX_LENGTH),
                           h.SHA256())
                print("  bootfs FIT signature: OK (Krot-fld.pem)")
            except Exception as ex:
                ok = False
                print("  bootfs FIT signature: FAIL", ex)
            from fit_build import build_data as _bd  # noqa
    return ok


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--pkgtb", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--kernel", required=True,
                    help="official kernel payload (lzop-compressed)")
    ap.add_argument("--key", default=DEFAULT_KEY)
    ap.add_argument("--verify", action="store_true")
    a = ap.parse_args()
    kernel = open(a.kernel, "rb").read()
    out = patch_pkgtb(a.pkgtb, a.out, kernel, a.key)
    if a.verify:
        print("== verify ==")
        ok = verify(a.out, a.key)
        print("RESULT:", "ALL OK" if ok else "MISMATCH")
        sys.exit(0 if ok else 1)
