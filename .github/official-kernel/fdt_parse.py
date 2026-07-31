#!/usr/bin/env python3
"""Pure-python Flattened Device Tree (DTB) parser + pkgtb/FIT extractor."""
import struct, sys, os, json

FDT_BEGIN_NODE = 1
FDT_END_NODE = 2
FDT_PROP = 3
FDT_NOP = 4
FDT_END = 9


def parse_fdt(data, name="root"):
    assert len(data) >= 40, "too short for DTB header"
    assert data[:4] == b"\xd0\x0d\xfe\xed", "not a DTB (bad magic %s)" % data[:4].hex()
    totalsize = struct.unpack(">I", data[4:8])[0]
    off_dt_struct = struct.unpack(">I", data[8:12])[0]
    off_dt_strings = struct.unpack(">I", data[12:16])[0]
    strings_blob = data[off_dt_strings:]

    def get_string(off):
        end = strings_blob.index(b"\x00", off)
        return strings_blob[off:end].decode("utf-8", "replace")

    pos = off_dt_struct

    def parse_node_body(pos, nname):
        props = {}
        children = {}
        while True:
            tok = struct.unpack(">I", data[pos:pos + 4])[0]
            pos += 4
            if tok == FDT_BEGIN_NODE:
                nend = data.index(b"\x00", pos)
                cname = data[pos:nend].decode("utf-8", "replace")
                pos = (nend + 4) & ~3
                child, pos = parse_node_body(pos, cname)
                children[cname] = child
            elif tok == FDT_PROP:
                plen, poff = struct.unpack(">II", data[pos:pos + 8])
                pos += 8
                pname = get_string(poff)
                pval = data[pos:pos + plen]
                pos = (pos + plen + 3) & ~3
                props[pname] = pval
            elif tok == FDT_END_NODE or tok == FDT_END:
                return {"name": nname, "props": props, "children": children}, pos
            elif tok == FDT_NOP:
                continue
            else:
                raise ValueError("bad token %d at %d" % (tok, pos - 4))

    tok = struct.unpack(">I", data[pos:pos + 4])[0]
    assert tok == FDT_BEGIN_NODE
    pos += 4
    nend = data.index(b"\x00", pos)
    root_name = data[pos:nend].decode("utf-8", "replace")
    pos = (nend + 4) & ~3
    tree, _ = parse_node_body(pos, root_name)
    return tree


def prop_str(v):
    if v is None:
        return None
    if v == b"":
        return "<empty>"
    try:
        return v.decode("utf-8")
    except UnicodeDecodeError:
        return v.hex()


def fmt_props(props):
    out = {}
    for k, v in props.items():
        if len(v) <= 64:
            out[k] = prop_str(v)
        else:
            out[k] = "<%d bytes: %s...>" % (len(v), v[:32].hex())
    return out


def dump_tree(tree, indent=0, max_depth=6, out=None):
    p = indent * "  "
    n = tree["name"]
    line = "%s[%s]" % (p, n)
    pr = fmt_props(tree["props"])
    if pr:
        line += " props=" + json.dumps(pr, ensure_ascii=False)
    print(line)
    if indent < max_depth * 2:
        for c in tree["children"].values():
            dump_tree(c, indent + 1, max_depth, out)


def extract_images(fit_data, outdir, prefix=""):
    """Extract images from a pkgtb/FIT: uses /images subnode data-offset/data-size."""
    tree = parse_fdt(fit_data)
    images = tree["children"].get("images", {})
    if not images:
        print("no /images node")
        return {}
    if "children" in images:
        imgs = images["children"]
    else:
        imgs = {}
    os.makedirs(outdir, exist_ok=True)
    result = {}
    base = (struct.unpack(">I", fit_data[4:8])[0] + 3) & ~3
    for name, node in imgs.items():
        pr = node["props"]
        doff = struct.unpack(">I", pr["data-offset"])[0]
        dsize = struct.unpack(">I", pr["data-size"])[0]
        desc = prop_str(pr.get("description", b"")) or name
        payload = fit_data[base + doff:base + doff + dsize]
        fn = os.path.join(outdir, "%s%s.bin" % (prefix, name))
        with open(fn, "wb") as f:
            f.write(payload)
        result[name] = (fn, len(payload), desc)
        print("  extracted %-12s %8d bytes  (%s)" % (name, len(payload), desc))
    return result


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "dump":
        data = open(sys.argv[2], "rb").read()
        tree = parse_fdt(data)
        dump_tree(tree)
    elif cmd == "extract":
        data = open(sys.argv[2], "rb").read()
        tree = parse_fdt(data)
        dump_tree(tree, max_depth=3)
        extract_images(data, sys.argv[3], sys.argv[4] if len(sys.argv) > 4 else "")
