import struct, sys, os, hashlib
from fdt_parse import parse_fdt
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes

KEY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..",
                   "release", "src-rt-5.04behnd.4916",
                   "targets", "keys", "demo", "GEN3", "Krot-fld.pem")


def walk_props(data, off_struct, off_strings):
    """Yield (path, propname, value_offset, value_len). Mirrors fdt_parse.py logic."""
    pos = off_struct
    strings = data[off_strings:]
    names = []

    def get_string(off):
        end = strings.index(b"\x00", off)
        return strings[off:end].decode("utf-8", "replace")

    def path():
        return "/" + "/".join(names)

    while True:
        tok = struct.unpack(">I", data[pos:pos + 4])[0]
        pos += 4
        if tok == 1:
            nend = data.index(b"\x00", pos)
            name = data[pos:nend].decode("utf-8", "replace")
            pos = (nend + 4) & ~3
            names.append(name)
        elif tok == 3:
            plen, poff = struct.unpack(">II", data[pos:pos + 8])
            pos += 8
            pname = get_string(poff)
            yield (path(), pname, pos, plen)
            pos = (pos + plen + 3) & ~3
        elif tok == 2 or tok == 9:
            if not names:
                return
            names.pop()
        elif tok == 4:
            continue
        else:
            raise ValueError("bad token %d" % tok)


def load_payloads(fit_path):
    data = bytearray(open(fit_path, "rb").read())
    ts = struct.unpack(">I", data[4:8])[0]
    tree = parse_fdt(data)
    imgs = tree["children"]["images"]["children"]
    info = {}
    for name, node in imgs.items():
        pr = node["props"]
        pos = struct.unpack(">I", pr["data-position"])[0]
        size = struct.unpack(">I", pr["data-size"])[0]
        info[name] = (pos, size, data[pos:pos + size])
    return data, ts, info


def build_data(base_data, replacements, resign=True, quiet=False, key_path=KEY):
    """Rebuild a bootfs FIT in memory: patch data-position/data-size, recompute
    all hash-1 values, re-sign. Returns bytes."""
    data = bytearray(base_data)
    ts = struct.unpack(">I", data[4:8])[0]
    tree = parse_fdt(data)
    imgs = tree["children"]["images"]["children"]
    info = {}
    for name, node in imgs.items():
        pr = node["props"]
        pos = struct.unpack(">I", pr["data-position"])[0]
        size = struct.unpack(">I", pr["data-size"])[0]
        info[name] = (pos, size, data[pos:pos + size])
    assert data[ts:ts + 4] == b"STIF"
    ordered = sorted(info.items(), key=lambda kv: kv[1][0])
    cur = 0x299c
    for name, (pos, size, _) in ordered:
        assert pos >= cur, (name, hex(pos), hex(cur))
        cur = pos + size
    # compute new layout
    new_payload = {}
    new_positions = {}
    cur = 0x299c
    for name, (pos, size, payload) in ordered:
        payload = replacements.get(name, payload)
        new_positions[name] = cur
        new_payload[cur] = payload
        cur = (cur + len(payload) + 3) & ~3
    # patch DTB props
    off_struct = struct.unpack(">I", data[8:12])[0]
    off_strings = struct.unpack(">I", data[12:16])[0]
    patch = {}
    hash_patch = {}
    for path, pname, voff, plen in walk_props(data, off_struct, off_strings):
        img = path.rsplit("/", 1)[-1]
        if "/images/" in path and pname in ("data-position", "data-size"):
            patch.setdefault(img, {})[pname] = voff
        if pname == "value" and path.endswith("/hash-1") and "/images/" in path:
            img = path.split("/")[-2]
            assert plen == 32, (path, plen)
            hash_patch[img] = voff
    for name, np in new_positions.items():
        opos, osize, _ = info[name]
        if np != opos:
            assert patch[name]["data-position"] is not None
            struct.pack_into(">I", data, patch[name]["data-position"], np)
        nsize = len(replacements.get(name, info[name][2]))
        if nsize != osize:
            struct.pack_into(">I", data, patch[name]["data-size"], nsize)
    # recompute hash-1 values (bootm verifies per-image hashes, CONFIG_FIT_SIGNATURE)
    for name, voff in hash_patch.items():
        payload = new_payload[new_positions[name]]
        dig = hashlib.sha256(payload).digest()
        assert len(dig) == 32
        struct.pack_into("32s", data, voff, dig)
        if not quiet:
            print("  hash-1[%s] = %s" % (name, dig.hex()))
    # rebuild payload region: header (incl STIF sig) up to 0x299c + payloads
    out = bytearray(data[:ts])
    if resign:
        sig = sign(out, key_path)
        out += b"STIF" + sig
        out += b"\x00" * (0x299c - len(out))
        assert len(out) == 0x299c
    else:
        out = bytearray(data[:0x299c])
    # write payloads
    for p in sorted(new_payload):
        b = new_payload[p]
        assert len(out) == p or len(out) < p
        if len(out) < p:
            out += b"\x00" * (p - len(out))
        out += b
    return bytes(out)


def build(base_path, out_path, replacements, resign=True, quiet=False, key_path=KEY):
    """Rebuild bootfs FIT from a file, write result to out_path."""
    data = open(base_path, "rb").read()
    result = build_data(data, replacements, resign=resign, quiet=quiet,
                        key_path=key_path)
    open(out_path, "wb").write(result)
    print("built", out_path, "size", hex(len(result)))


def sign(header, key_path):
    key = load_pem_private_key(open(key_path, "rb").read(), None)
    return key.sign(bytes(header), padding.PSS(mgf=padding.MGF1(hashes.SHA256()),
                  salt_length=padding.PSS.MAX_LENGTH), hashes.SHA256())
