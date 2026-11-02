#!/usr/bin/env python3
"""Small execution stories; these are our fixtures, not CZECH test results."""
from pathlib import Path


def text(value):
    chars = []
    for character in value:
        if character == ' ':
            chars.append(0)
        elif '0' <= character <= '9':
            chars.extend((5, ord(character)-ord('0')+8))
        elif 'a' <= character <= 'z':
            chars.append(ord(character)-ord('a')+6)
        elif 'A' <= character <= 'Z':
            chars.extend((4, ord(character)-ord('A')+6))
        else:
            raise ValueError(character)
    while len(chars) % 3:
        chars.append(5)
    result = bytearray()
    for i in range(0, len(chars), 3):
        word = (chars[i]<<10) | (chars[i+1]<<5) | chars[i+2]
        if i+3 == len(chars):
            word |= 0x8000
        result.extend(word.to_bytes(2, 'big'))
    return bytes(result)


def story(code):
    header = bytearray(64)
    header[0] = 3
    header[4:8] = bytes.fromhex('00400040')
    header[14:16] = bytes.fromhex('0040')
    header[18:24] = b'000001'
    image = header + code
    if len(image) % 2:
        image.append(0)
    image[26:28] = (len(image)//2).to_bytes(2, 'big')
    image[28:30] = (sum(image[64:]) & 65535).to_bytes(2, 'big')
    return image


if __name__ == '__main__':
    root = Path('build')
    (root/'VMBOOT.DAT').write_bytes(story(b'\xb4\xb2'+text('Z68 execution smoke test')+b'\xbb\xba'))
    (root/'VMFAIL.DAT').write_bytes(story(bytes.fromhex('e0 3f 10 fe')))
    (root/'VMLIMIT.DAT').write_bytes(story(b'\xb4'*10001+b'\xba'))
