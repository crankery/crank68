#!/usr/bin/env python3
"""Decode Xerox Alto .AL fonts per Sproull, Font Representations and Formats (1977), §7.1."""
from pathlib import Path
import argparse

def decode(path):
    data = Path(path).read_bytes()
    if len(data) % 2: raise ValueError('Odd file size')
    words = [int.from_bytes(data[i:i+2], 'big') for i in range(0,len(data),2)]
    height = words[0]
    prop = bool(words[1] & 0x8000)
    baseline = (words[1] >> 8) & 0x7f
    maxwidth = words[1] & 255
    if not 1 <= height <= 128 or not 1 <= maxwidth <= 128:
        raise ValueError('Implausible font header')
    glyphs=[]
    for code in range(256):
        idx=2+code
        offset=words[idx] if words[idx]<32768 else words[idx]-65536
        pos=idx+offset
        if not 0 <= pos+1 < len(words): raise ValueError(f'Bad pointer {code:02x}')
        rows=[]; seen=set(); width=0
        while True:
            if pos in seen: raise ValueError('Extension cycle')
            seen.add(pos)
            xw=words[pos]; hd=words[pos+1]>>8; xh=words[pos+1]&255
            if pos-xh < 0 or hd+xh>height: raise ValueError(f'Bad glyph {code:02x}: {hd=} {xh=}')
            bits=words[pos-xh:pos]
            columns=16 if xw%2==0 else (xw-1)//2
            if columns>16: raise ValueError('Invalid width')
            part=['.'*columns for _ in range(height)]
            for y,word in enumerate(bits,hd):
                part[y]=''.join('#' if word & (1 << (15-x)) else '.' for x in range(columns))
            rows.append(part);width+=columns
            if xw&1: break
            extension=xw//2
            if extension>=len(words)-2: raise ValueError('Bad extension code')
            pidx=2+extension
            delta=words[pidx] if words[pidx]<32768 else words[pidx]-65536
            pos=pidx+delta
        glyphs.append([''.join(p[y] for p in rows) for y in range(height)])
    return height,baseline,maxwidth,prop,glyphs

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('font');ap.add_argument('--out',default='SysFont');ap.add_argument('--patch-start',type=int,default=1,help='0-based source scanline for 8-row patch')
    a=ap.parse_args()
    height,baseline,width,prop,glyphs=decode(a.font)
    print(f'height={height} baseline={baseline} maxwidth={width} proportional={prop}')
    raw=[];patch=[]
    for code,g in enumerate(glyphs):
        # fixed 8 columns for this SysFont; extensions wider than 8 are not clipped in raw
        rows=[r.ljust(width,'.') for r in g]
        raw.append(f'@{code:02X}\n'+'\n'.join(rows))
        selected=rows[a.patch_start:a.patch_start+8]
        selected+=['.'*width]*(8-len(selected))
        if width>8: raise ValueError('8x8 patch output requires maxwidth <=8')
        patch.append(f'@{code:02X}\n'+'\n'.join(r.ljust(8,'.') for r in selected))
    Path(a.out+'.full.dump').write_text('\n\n'.join(raw)+'\n')
    Path(a.out+'.8x8.dump').write_text('\n\n'.join(patch)+'\n')
    # preserve 12 rows per glyph as direct packed bytes, MSB=leftmost
    packed=bytes(sum((1<<(7-x)) for x,ch in enumerate(row[:8]) if ch=='#') for g in glyphs for row in g)
    Path(a.out+'.full.bin').write_bytes(packed)
    print('Wrote full dump, 8x8 patch dump, and full-height binary')
if __name__=='__main__': main()
