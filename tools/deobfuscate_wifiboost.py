#!/usr/bin/env python3
"""
Deobfuscation tool for koolshare/wifiboost compiled shell scripts.

These scripts are shell scripts compiled into ARM ELF binaries using a custom
packer that encrypts the shell script payload with a key derived from the
binary's own code/data sections.

The packer mechanism:
1. Shell script is encrypted (likely RC4 or similar stream cipher)
2. Encrypted payload is stored in the .data section of a small ARM ELF stub
3. The stub links to libc, opens /proc/self/as, reads key material, 
   decrypts the payload, and exec's it via busybox sh
4. Anti-debugging via ptrace prevents dynamic analysis

Usage:
    python deobfuscate_wifiboost.py <elf_file> [--output-dir <dir>]
"""

import struct
import sys
import os
import argparse
from pathlib import Path


def parse_elf32(data):
    """Parse ELF32 header and return program/section headers."""
    if data[:4] != b'\x7fELF':
        raise ValueError("Not an ELF file")
    
    ei_class = data[4]
    if ei_class != 1:
        raise ValueError(f"Expected ELF32 (class=1), got class={ei_class}")
    
    ei_data = data[5]  # 1 = little-endian
    
    e_entry = struct.unpack('<I', data[24:28])[0]
    e_phoff = struct.unpack('<I', data[28:32])[0]
    e_shoff = struct.unpack('<I', data[32:36])[0]
    e_ehsize = struct.unpack('<H', data[40:42])[0]
    e_phentsize = struct.unpack('<H', data[42:44])[0]
    e_phnum = struct.unpack('<H', data[44:46])[0]
    e_shentsize = struct.unpack('<H', data[46:48])[0]
    e_shnum = struct.unpack('<H', data[48:50])[0]
    e_shstrndx = struct.unpack('<H', data[50:52])[0]
    
    # Parse program headers
    phdrs = []
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type = struct.unpack('<I', data[off:off+4])[0]
        p_offset = struct.unpack('<I', data[off+4:off+8])[0]
        p_vaddr = struct.unpack('<I', data[off+8:off+12])[0]
        p_filesz = struct.unpack('<I', data[off+16:off+20])[0]
        p_memsz = struct.unpack('<I', data[off+20:off+24])[0]
        p_flags = struct.unpack('<I', data[off+24:off+28])[0]
        phdrs.append({
            'type': p_type, 'offset': p_offset, 'vaddr': p_vaddr,
            'filesz': p_filesz, 'memsz': p_memsz, 'flags': p_flags
        })
    
    # Parse section headers
    shdrs = []
    if e_shnum > 0 and e_shoff > 0:
        # Get section name string table
        shstrtab_off = e_shoff + e_shstrndx * e_shentsize
        shstrtab_offset = struct.unpack('<I', data[shstrtab_off+16:shstrtab_off+20])[0]
        shstrtab_size = struct.unpack('<I', data[shstrtab_off+20:shstrtab_off+24])[0]
        shstrtab = data[shstrtab_offset:shstrtab_offset+shstrtab_size]
        
        for i in range(e_shnum):
            off = e_shoff + i * e_shentsize
            sh_name_idx = struct.unpack('<I', data[off:off+4])[0]
            sh_type = struct.unpack('<I', data[off+4:off+8])[0]
            sh_offset = struct.unpack('<I', data[off+16:off+20])[0]
            sh_size = struct.unpack('<I', data[off+20:off+24])[0]
            
            name_end = shstrtab.index(0, sh_name_idx) if sh_name_idx < len(shstrtab) else sh_name_idx
            name = shstrtab[sh_name_idx:name_end].decode('ascii', errors='replace')
            
            shdrs.append({
                'name': name, 'type': sh_type, 'offset': sh_offset, 'size': sh_size
            })
    
    return {
        'entry': e_entry, 'phdrs': phdrs, 'sections': shdrs,
        'e_shoff': e_shoff, 'e_shnum': e_shnum
    }


def extract_strings(data, min_len=4):
    """Extract printable ASCII strings from binary data."""
    strings = []
    current = []
    start = 0
    for i, b in enumerate(data):
        if 0x20 <= b <= 0x7E:
            if not current:
                start = i
            current.append(chr(b))
        else:
            if len(current) >= min_len:
                strings.append((start, ''.join(current)))
            current = []
    if len(current) >= min_len:
        strings.append((start, ''.join(current)))
    return strings


def try_xor_decrypt(data, max_key_len=32, verbose=False):
    """Try single-byte and short multi-byte XOR keys targeting #!/bin/sh header."""
    results = []
    targets = [b'#!/bin/sh', b'#!/bin/bash', b'#!/bin/ash', b'#!/usr/bin/env sh']
    
    for target in targets:
        for key_len in range(1, max_key_len + 1):
            # Derive key from first key_len bytes
            key = bytes([data[i] ^ target[i % key_len] for i in range(key_len)])
            
            # Validate: decrypt a larger portion and check for readable text
            decrypted = bytes([data[i] ^ key[i % key_len] for i in range(min(256, len(data)))])
            
            # Check if it looks like a shell script
            score = 0
            for c in decrypted:
                if 0x20 <= c <= 0x7E or c in (0x09, 0x0A, 0x0D):
                    score += 1
                elif c == 0:
                    break
                else:
                    score -= 2
            
            ratio = score / min(256, len(data))
            if ratio > 0.85 and decrypted[:len(target)] == target:
                # Verify further - check for common shell keywords
                text = decrypted.decode('ascii', errors='replace')
                keywords = ['echo', 'if', 'then', 'fi', '/bin/sh', 'exit', 'return',
                           'nvram', 'service', '/tmp/', '/jffs/', 'busybox']
                found = sum(1 for kw in keywords if kw in text[:500])
                if found >= 2:
                    results.append({
                        'key': key, 'key_len': key_len,
                        'score': ratio, 'preview': text[:300],
                        'keyword_hits': found,
                        'target': target.decode()
                    })
    
    return results


def try_rc4_decrypt(data, key_material_source, verbose=False):
    """Try RC4 decryption with various key sources."""
    results = []
    
    # RC4 key scheduling
    def rc4_init(key):
        S = list(range(256))
        j = 0
        for i in range(256):
            j = (j + S[i] + key[i % len(key)]) % 256
            S[i], S[j] = S[j], S[i]
        return S
    
    def rc4_crypt(S, data):
        result = bytearray(len(data))
        i = j = 0
        for k in range(len(data)):
            i = (i + 1) % 256
            j = (j + S[i]) % 256
            S[i], S[j] = S[j], S[i]
            result[k] = data[k] ^ S[(S[i] + S[j]) % 256]
        return bytes(result)
    
    # Try various key sources
    keys_to_try = []
    
    # Try format strings as key material
    keys_to_try.append(b'/proc/%d/as')
    keys_to_try.append(b'busybox')
    keys_to_try.append(b'sh')
    keys_to_try.append(b'%lu %d%c')
    keys_to_try.append(b'%lx')
    keys_to_try.append(b'=%lu %d')
    keys_to_try.append(b'E: neither argv[0] nor $_ works.')
    
    # Try concatenations
    keys_to_try.append(b'/proc/%d/asbusybox')
    keys_to_try.append(b'busyboxsh')
    keys_to_try.append(b'%lu %d%cbusybox')
    
    # Try with different numeric prefixes (the %lu %d%c header values)
    for v1 in [0, 1, 2, 3, 4, 8, 12, 16, 100, 256, 1024, 4096]:
        for v2 in [0, 1, 2, 3, 4, 8]:
            header = struct.pack('<II', v1, v2)
            keys_to_try.append(header)
            keys_to_try.append(header + b'busybox')
    
    for key in keys_to_try:
        S = rc4_init(key)
        decrypted = rc4_crypt(S[:], data[:min(512, len(data))])
        
        # Check for shell script
        if decrypted[:2] == b'#!':
            text = decrypted.decode('ascii', errors='replace')
            keywords = ['echo', 'if', 'then', 'fi', '/bin/sh', 'exit', 'return',
                       'nvram', 'service', '/tmp/', '/jffs/', 'busybox']
            found = sum(1 for kw in keywords if kw in text[:500])
            if found >= 2:
                # Full decryption
                full_decrypted = rc4_crypt(rc4_init(key), data)
                results.append({
                    'cipher': 'RC4',
                    'key': key,
                    'key_hex': key.hex(),
                    'preview': text[:300],
                    'keyword_hits': found
                })
    
    return results


def try_block_xor(data, block_sizes=[4, 8, 16], verbose=False):
    """Try XOR with repeating block key, testing all possible key values for first block."""
    results = []
    
    for bs in block_sizes:
        # For each possible first-block key, check if result looks like shell script
        first_block = data[:bs]
        
        # If target is #!/bin/sh padded with known chars
        targets = [
            b'#!/bin/sh\x00'[:bs],
            b'#!/bin/sh\n'[:bs],
        ]
        
        for target in targets:
            if len(target) < bs:
                continue
            key = bytes([first_block[i] ^ target[i] for i in range(bs)])
            
            decrypted = bytes([data[i] ^ key[i % bs] for i in range(min(512, len(data)))])
            
            # Score the result
            text = decrypted.decode('ascii', errors='replace')
            null_pos = text.find('\x00')
            if null_pos > 0 and null_pos < 3:
                continue  # Too early null = wrong key
            
            keywords = ['echo', 'if', 'then', 'fi', 'exit', 'return',
                       'nvram', 'service', '/tmp/', 'busybox', 'case', 'esac',
                       'while', 'do', 'done', 'for', 'in', 'eval']
            found = sum(1 for kw in keywords if kw in text[:1000])
            if found >= 3:
                full_decrypted = bytes([data[i] ^ key[i % bs] for i in range(len(data))])
                results.append({
                    'cipher': f'Block XOR (block={bs})',
                    'key': key,
                    'key_hex': key.hex(),
                    'preview': full_decrypted[:500].decode('ascii', errors='replace'),
                    'keyword_hits': found
                })
    
    return results


def analyze_elf(filepath, verbose=False):
    """Full analysis of an ELF binary for script deobfuscation."""
    with open(filepath, 'rb') as f:
        data = f.read()
    
    print(f"{'='*60}")
    print(f"Analyzing: {filepath}")
    print(f"File size: {len(data)} bytes")
    print(f"{'='*60}")
    
    elf = parse_elf32(data)
    
    print(f"\nELF32 ARM, Entry: 0x{elf['entry']:08X}")
    
    # Print program headers
    print("\nProgram Headers:")
    type_names = {0: 'PT_NULL', 1: 'PT_LOAD', 2: 'PT_DYNAMIC', 3: 'PT_INTERP',
                  4: 'PT_NOTE', 6: 'PT_PHDR', 0x6474E551: 'PT_GNU_STACK',
                  0x70000001: 'PT_ARM_EXIDX'}
    for i, ph in enumerate(elf['phdrs']):
        tn = type_names.get(ph['type'], f"0x{ph['type']:X}")
        print(f"  [{i}] {tn:20s} offset=0x{ph['offset']:06X} vaddr=0x{ph['vaddr']:08X} "
              f"filesz=0x{ph['filesz']:06X} memsz=0x{ph['memsz']:06X} flags=0x{ph['flags']:X}")
    
    # Print section headers
    if elf['sections']:
        print("\nSection Headers:")
        for i, sh in enumerate(elf['sections']):
            print(f"  [{i:2d}] {sh['name']:20s} offset=0x{sh['offset']:06X} size=0x{sh['size']:06X}")
    
    # Find .rodata strings
    print("\nReadable Strings (.rodata):")
    for sh in elf['sections']:
        if sh['name'] == '.rodata':
            rodata = data[sh['offset']:sh['offset']+sh['size']]
            for off, s in extract_strings(rodata, 4):
                print(f"  0x{sh['offset']+off:06X}: {s}")
    
    # Find .data section
    data_section = None
    text_section = None
    for sh in elf['sections']:
        if sh['name'] == '.data':
            data_section = sh
        if sh['name'] == '.text':
            text_section = sh
    
    if not data_section:
        print("\nNo .data section found!")
        return
    
    payload = data[data_section['offset']:data_section['offset']+data_section['size']]
    print(f"\n.data section: {len(payload)} bytes at offset 0x{data_section['offset']:06X}")
    
    # Check for zero-initialized prefix
    zero_prefix = 0
    for b in payload:
        if b != 0:
            break
        zero_prefix += 1
    if zero_prefix > 0:
        print(f"  Zero-initialized prefix: {zero_prefix} bytes")
    
    enc_data = payload[zero_prefix:]
    
    # Calculate entropy
    import math
    freq = [0] * 256
    for b in enc_data:
        freq[b] += 1
    entropy = 0
    for f in freq:
        if f > 0:
            p = f / len(enc_data)
            entropy -= p * math.log2(p)
    print(f"  Encrypted payload: {len(enc_data)} bytes, entropy: {entropy:.2f} bits/byte")
    
    # Extract all strings in the binary for key material analysis
    all_strings = extract_strings(data, 4)
    print(f"\nKey Material Strings in Binary:")
    for off, s in all_strings:
        print(f"  0x{off:06X}: {s}")
    
    # Decryption attempts
    print(f"\n{'='*60}")
    print("Decryption Attempts")
    print(f"{'='*60}")
    
    # 1. XOR brute force
    print("\n[1] XOR with shebang-derived keys...")
    results = try_xor_decrypt(enc_data, max_key_len=16, verbose=verbose)
    if results:
        for r in results:
            print(f"  MATCH! Key length={r['key_len']}, target={r['target']}")
            print(f"  Key (hex): {r['key'].hex()}")
            print(f"  Preview:\n{r['preview']}")
            print()
    else:
        print("  No simple XOR key found")
    
    # 2. Block XOR
    print("\n[2] Block XOR...")
    results = try_block_xor(enc_data, verbose=verbose)
    if results:
        for r in results:
            print(f"  MATCH! {r['cipher']}")
            print(f"  Key (hex): {r['key_hex']}")
            print(f"  Preview:\n{r['preview']}")
            print()
    else:
        print("  No block XOR key found")
    
    # 3. RC4
    print("\n[3] RC4 decryption...")
    results = try_rc4_decrypt(enc_data, all_strings, verbose=verbose)
    if results:
        for r in results:
            print(f"  MATCH! {r['cipher']}")
            print(f"  Key (hex): {r['key_hex']}")
            print(f"  Preview:\n{r['preview']}")
            print()
    else:
        print("  No RC4 key found")
    
    # 4. Extract raw data for manual analysis
    print("\n[4] Raw payload dumps:")
    return {
        'filepath': filepath,
        'payload': enc_data,
        'data_section': data_section,
        'all_strings': all_strings,
        'elf': elf,
        'binary_data': data
    }


def main():
    parser = argparse.ArgumentParser(description='Deobfuscate koolshare compiled shell scripts')
    parser.add_argument('files', nargs='+', help='ELF binary files to analyze')
    parser.add_argument('--output-dir', '-o', default='.', help='Output directory for extracted scripts')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    parser.add_argument('--dump-payload', action='store_true', help='Dump raw encrypted payload')
    args = parser.parse_args()
    
    os.makedirs(args.output_dir, exist_ok=True)
    
    for filepath in args.files:
        try:
            result = analyze_elf(filepath, verbose=args.verbose)
            
            if result and args.dump_payload:
                outpath = os.path.join(args.output_dir, 
                    os.path.basename(filepath) + '.enc_payload.bin')
                with open(outpath, 'wb') as f:
                    f.write(result['payload'])
                print(f"\nRaw payload dumped to: {outpath}")
                
                # Also dump the strings map
                outpath2 = os.path.join(args.output_dir,
                    os.path.basename(filepath) + '.strings.txt')
                with open(outpath2, 'w') as f:
                    for off, s in result['all_strings']:
                        f.write(f"0x{off:06X}: {s}\n")
                print(f"Strings map dumped to: {outpath2}")
                
        except Exception as e:
            print(f"Error analyzing {filepath}: {e}", file=sys.stderr)
            import traceback
            traceback.print_exc()
    
    print(f"\n{'='*60}")
    print("NOTE: These binaries use a custom ARM ELF packer with anti-debug (ptrace).")
    print("If automated decryption fails, try running on an ARM system or emulator")
    print("with ptrace disabled, and intercept the exec call to capture the")
    print("decrypted script before execution.")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
