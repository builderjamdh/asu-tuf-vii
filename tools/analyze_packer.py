#!/usr/bin/env python3
"""
Analyze wifiboost packed ELF binaries - identify decryption mechanism.
"""
import struct
import sys
import math


def analyze_file(filepath):
    with open(filepath, 'rb') as f:
        data = f.read()
    
    print(f"\n{'='*60}")
    print(f"File: {filepath} ({len(data)} bytes)")
    print(f"{'='*60}")
    
    # Parse ELF
    entry = struct.unpack('<I', data[24:28])[0]
    print(f"Entry: 0x{entry:08X}")
    
    # Find .data section
    e_shoff = struct.unpack('<I', data[32:36])[0]
    e_shnum = struct.unpack('<H', data[48:50])[0]
    e_shstrndx = struct.unpack('<H', data[50:52])[0]
    e_shentsize = struct.unpack('<H', data[46:48])[0]
    
    # Get string table
    shstrtab_off = e_shoff + e_shstrndx * e_shentsize
    shstrtab_offset = struct.unpack('<I', data[shstrtab_off+16:shstrtab_off+20])[0]
    
    data_sec = None
    text_sec = None
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        sh_name_idx = struct.unpack('<I', data[off:off+4])[0]
        sh_type = struct.unpack('<I', data[off+4:off+8])[0]
        sh_offset = struct.unpack('<I', data[off+16:off+20])[0]
        sh_size = struct.unpack('<I', data[off+20:off+24])[0]
        
        name_end = data.index(0, shstrtab_offset + sh_name_idx)
        name = data[shstrtab_offset + sh_name_idx:name_end].decode('ascii', errors='replace')
        
        if name == '.data':
            data_sec = (sh_offset, sh_size)
        if name == '.text':
            text_sec = (sh_offset, sh_size)
    
    if not data_sec:
        print("No .data section found")
        return
    
    data_off, data_size = data_sec
    payload = data[data_off:data_off + data_size]
    
    # Skip zero-initialized globals
    zero_prefix = 0
    for b in payload:
        if b != 0:
            break
        zero_prefix += 1
    
    enc = payload[zero_prefix:]
    print(f".data: {data_size} bytes, zero_prefix={zero_prefix}, encrypted={len(enc)} bytes")
    
    # Parse header: %lu %d%c = unsigned long, int, char
    if len(enc) >= 9:
        v1 = struct.unpack('<I', enc[0:4])[0]
        v2 = struct.unpack('<i', enc[4:8])[0]
        v3 = enc[8]
        print(f"Header: %lu={v1} (0x{v1:08X}), %d={v2} (0x{v2:08X}), %c=0x{v3:02X}")
    
    # .text section analysis  
    if text_sec:
        text_off, text_size = text_sec
        text = data[text_off:text_off + text_size]
        
        # Look for the decryption routine - search for patterns that reference
        # the format strings and the /proc/self/as path
        print(f"\n.text section: {text_size} bytes at 0x{text_off:06X}")
        
        # Search for references to key constants in .text
        # shc uses a key schedule based on the compile-time constant
        # Let's look at what the .text contains
        
        # The key insight: this binary reads /proc/self/as
        # The key bytes are at specific vaddr offsets in the binary's memory space
        # In shc, the decryption key is embedded in the .text as immediate values
        
        # Let's search for 4-byte patterns in .text that could be XOR keys
        # by checking if any alignment produces readable output
        
        key_offsets_found = []
        for align in [1, 2, 4]:
            for i in range(0, len(text) - 8, align):
                # Try 4, 8 byte keys from .text
                for klen in [4, 8]:
                    if i + klen > len(text):
                        continue
                    key = text[i:i+klen]
                    
                    # Skip all-zero or all-same keys
                    if len(set(key)) < 2:
                        continue
                    
                    # Quick check: decrypt first 16 bytes
                    dec16 = bytes([enc[j] ^ key[j % klen] for j in range(min(16, len(enc)))])
                    
                    # Check if starts with common shell patterns
                    prefixes = [b'#!', b'# ', b'echo', b'nvra', b'serv', b'exit', b'/bin']
                    for p in prefixes:
                        if dec16[:len(p)] == p:
                            # Found a potential key! Verify more
                            dec100 = bytes([enc[j] ^ key[j % klen] for j in range(min(500, len(enc)))])
                            printable = sum(1 for b in dec100 if 32 <= b <= 126 or b in (9, 10, 13))
                            if printable > 300:
                                key_offsets_found.append((i, klen, key, dec100, printable))
                                break
        
        if key_offsets_found:
            print(f"\n*** FOUND {len(key_offsets_found)} potential decryption keys in .text! ***")
            for i, klen, key, dec, score in key_offsets_found:
                print(f"\n  .text offset 0x{i:04X}, key_len={klen}, key={key.hex()}")
                print(f"  Readable chars: {score}/500")
                text_preview = dec.decode('ascii', errors='replace')
                print(f"  Decrypted preview:\n{text_preview[:400]}")
        else:
            print("\nNo decryption keys found via .text scanning")
            
            # Try: maybe the key is derived from the header values
            # The header might encode a seed/offset into the code
            if len(enc) >= 9:
                print("\nTrying header-derived keys...")
                # v1 and v2 might be indices into .text or offsets
                for base in [v1, v2]:
                    for klen in [4, 8, 16]:
                        if 0 <= base < len(text) - klen:
                            key = text[base:base+klen]
                            dec = bytes([enc[j] ^ key[j % klen] for j in range(min(200, len(enc)))])
                            printable = sum(1 for b in dec if 32 <= b <= 126 or b in (9, 10, 13))
                            if printable > 150:
                                print(f"  Key from .text[0x{base:X}]: len={klen}, key={key.hex()}, printable={printable}/200")
                                print(f"  Preview: {dec.decode('ascii', errors='replace')[:200]}")
    
    # Also dump first 64 bytes of payload in hex for manual inspection
    print(f"\nFirst 64 bytes of encrypted payload:")
    for i in range(0, min(64, len(enc)), 16):
        hexpart = ' '.join(f'{b:02X}' for b in enc[i:i+16])
        asciipart = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in enc[i:i+16])
        print(f"  {i:04X}: {hexpart:<48s}  {asciipart}")


def main():
    files = [
        r'C:\Users\Dahi\Documents\GitHub\rogsoft\wifiboost\wifiboost\install.sh',
        r'C:\Users\Dahi\Documents\GitHub\rogsoft\wifiboost\wifiboost\scripts\wifiboost_config.sh',
        r'C:\Users\Dahi\Documents\GitHub\rogsoft\wifiboost\wifiboost\scripts\wifiboost_status.sh',
    ]
    for f in files:
        try:
            analyze_file(f)
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()


if __name__ == '__main__':
    main()
