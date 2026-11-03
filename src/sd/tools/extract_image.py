#!/usr/bin/env python3
"""Extract and expand a 512 KiB SRAM volume into a 1 MiB SD volume."""
import argparse
from pathlib import Path

VOLUME_BYTES = 128 * 16 * 256
SD_VOLUME_BYTES = 128 * 32 * 256


def expand(volume):
    if len(volume) != VOLUME_BYTES or volume[550:552] != bytes((127, 16)):
        raise ValueError('Expected a 128-track, 16-sector SRAM volume')
    image = bytearray(SD_VOLUME_BYTES)
    for track in range(128):
        image[track*8192:track*8192+4096] = volume[track*4096:(track+1)*4096]

    def offset(link):
        track, sector = link
        if track >= 128 or not 1 <= sector <= 16:
            raise ValueError('Invalid source free-chain address')
        return (track * 32 + sector - 1) * 256

    # Validate the old free chain before attaching the newly available sectors.
    sir = 2 * 256
    link = bytes(image[sir+29:sir+31])
    seen = set()
    tail = bytes(2)
    while link != bytes(2):
        at = offset(link)
        if at in seen or at < 4096:
            raise ValueError('Invalid or cyclic source free chain')
        seen.add(at)
        tail = link
        link = bytes(image[at:at+2])
    count = int.from_bytes(image[sir+33:sir+35], 'big')
    if count != len(seen) or tail != image[sir+31:sir+33]:
        raise ValueError('Source free-chain metadata differs')

    added = [bytes((track, sector)) for track in range(128) for sector in range(17, 33)]
    for i, address in enumerate(added):
        at = (address[0] * 32 + address[1] - 1) * 256
        image[at:at+2] = added[i+1] if i+1 < len(added) else bytes(2)
    if seen:
        at = offset(tail)
        image[at:at+2] = added[0]
    else:
        image[sir+29:sir+31] = added[0]
    image[sir+31:sir+33] = added[-1]
    image[sir+33:sir+35] = (count + len(added)).to_bytes(2, 'big')
    image[sir+38:sir+40] = bytes((127, 32))
    return bytes(image)


def extract(source, drive):
    data = source.read_bytes()
    if len(data) != 2 * VOLUME_BYTES:
        raise ValueError('Expected the current two-volume, 1 MiB SRAM image')
    if drive not in (0, 1):
        raise ValueError('SRAM volume must be 0 or 1')
    volume = data[drive * VOLUME_BYTES:(drive + 1) * VOLUME_BYTES]
    if volume[2 * 256 + 38:2 * 256 + 40] != bytes((127, 16)):
        raise ValueError('Volume SIR geometry is not 128 tracks by 16 sectors')
    return volume


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, default=Path('../flex2/build/flex2.dsk'))
    parser.add_argument('--drive', type=int, choices=(0, 1), default=1)
    parser.add_argument('--output', type=Path, default=Path('build/FLEX.DSK'))
    parser.add_argument('--force', action='store_true')
    args = parser.parse_args()
    if args.source.resolve() == args.output.resolve():
        parser.error('Output must differ from source')
    try:
        volume = expand(extract(args.source, args.drive))
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open('wb' if args.force else 'xb') as target:
            target.write(volume)
    except (OSError, ValueError) as error:
        parser.exit(1, str(error) + '\n')
    print(f'{args.output}: {len(volume):,} bytes from SRAM drive {args.drive}')


if __name__ == '__main__':
    main()
