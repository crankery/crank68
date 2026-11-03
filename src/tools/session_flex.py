"""Refresh FLEX2.SYS inside a saved disk without replacing its other files."""
from hashlib import sha256
import os
from pathlib import Path
import tempfile


def sector_offset(image, link, sectors_per_track):
    track, sector = link
    tracks = len(image) // (sectors_per_track * 256)
    if track >= tracks or not 1 <= sector <= sectors_per_track:
        raise ValueError(f'Invalid FLEX sector link: {track},{sector}')
    return (track * sectors_per_track + sector - 1) * 256


def flex_sectors(image, sectors_per_track):
    directory = bytes((0, 5))
    visited = set()
    entry = None
    while directory != b'\0\0':
        offset = sector_offset(image, directory, sectors_per_track)
        if offset in visited:
            raise ValueError('FLEX directory contains a loop')
        visited.add(offset)
        block = image[offset:offset + 256]
        for at in range(16, 256, 24):
            candidate = block[at:at + 24]
            if (candidate[:8].rstrip(b'\0') == b'FLEX2' and
                    candidate[8:11].rstrip(b'\0') == b'SYS'):
                entry = candidate
                break
        if entry is not None:
            break
        directory = block[:2]
    if entry is None:
        return None

    count = int.from_bytes(entry[17:19], 'big')
    link = entry[13:15]
    sectors = []
    visited.clear()
    while link != b'\0\0':
        offset = sector_offset(image, link, sectors_per_track)
        if offset in visited or len(sectors) >= count:
            raise ValueError('FLEX2.SYS sector chain is invalid')
        visited.add(offset)
        block = image[offset:offset + 256]
        if int.from_bytes(block[2:4], 'big') != len(sectors) + 1:
            raise ValueError('FLEX2.SYS sector sequence is invalid')
        sectors.append(offset)
        link = block[:2]
    if len(sectors) != count:
        raise ValueError('FLEX2.SYS sector count is invalid')
    return sectors


def sync_flex(factory_path, session_path, session_sectors_per_track):
    factory = factory_path.read_bytes()[:512 * 1024]
    session = bytearray(session_path.read_bytes())
    source = flex_sectors(factory, 16)
    target = flex_sectors(session, session_sectors_per_track)
    if source is None or target is None:
        raise ValueError(f'FLEX2.SYS is missing from {factory_path} or {session_path}')
    if len(source) != len(target):
        raise ValueError(f'FLEX2.SYS changed sector count in {session_path}; manual migration needed')

    old = bytes(session)
    changed = False
    for src, dst in zip(source, target):
        payload = factory[src + 4:src + 256]
        if session[dst + 4:dst + 256] != payload:
            session[dst + 4:dst + 256] = payload
            changed = True
    if not changed:
        return

    backup = session_path.with_name(session_path.name + '.pre-flex-' + sha256(old).hexdigest()[:12])
    try:
        with backup.open('xb') as saved:
            saved.write(old)
    except FileExistsError:
        pass

    with tempfile.NamedTemporaryFile(dir=session_path.parent,
                                     prefix=session_path.name + '.updating-',
                                     delete=False) as updated:
        updated.write(session)
        temporary = Path(updated.name)
    os.replace(temporary, session_path)
    print(f'Updated FLEX2.SYS in {session_path.name}; backup: {backup.name}')
