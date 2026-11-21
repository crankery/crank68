import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('extract_image', Path(__file__).resolve().parents[1] / 'tools/extract_image.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ImageTest(unittest.TestCase):
    def test_expand_preserves_data_and_extends_free_chain(self):
        volume = bytearray(module.VOLUME_BYTES)
        # One allocated sector with recognizable data, followed by free space.
        volume[4096:4352] = bytes(range(256))
        free = [bytes((track, sector)) for track in range(1, 128)
                for sector in range(1, 17) if (track, sector) != (1, 1)]
        for i, address in enumerate(free):
            at = (address[0]*16 + address[1]-1)*256
            volume[at:at+2] = free[i+1] if i+1 < len(free) else bytes(2)
        volume[541:543] = free[0]
        volume[543:545] = free[-1]
        volume[545:547] = len(free).to_bytes(2, 'big')
        volume[550:552] = bytes((127, 16))
        original = bytes(volume)
        expanded = module.expand(volume)
        self.assertEqual(volume, original)
        self.assertEqual(len(expanded), 1024*1024)
        self.assertEqual(expanded[550:552], bytes((127, 32)))
        for track in range(128):
            for sector in range(1, 17):
                if (track, sector) in ((0, 3), (127, 16)):
                    continue  # SIR and the old free-chain tail are updated.
                old = (track*16 + sector-1)*256
                new = (track*32 + sector-1)*256
                self.assertEqual(expanded[new:new+256], original[old:old+256])
        seen = set()
        link = expanded[541:543]
        while link != bytes(2):
            track, sector = link
            self.assertLess(track, 128)
            self.assertTrue(1 <= sector <= 32)
            self.assertNotIn(link, seen)
            seen.add(link)
            at = (track*32 + sector-1)*256
            tail = link
            link = expanded[at:at+2]
        self.assertEqual(len(seen), len(free) + 2048)
        self.assertEqual(len(seen), int.from_bytes(expanded[545:547], 'big'))
        self.assertEqual(tail, expanded[543:545])
        volume[545:547] = bytes(2)
        with self.assertRaises(ValueError):
            module.expand(volume)

    def test_expand_full_source(self):
        volume = bytearray(module.VOLUME_BYTES)
        volume[550:552] = bytes((127, 16))
        expanded = module.expand(volume)
        self.assertEqual(expanded[541:543], bytes((0, 17)))
        self.assertEqual(int.from_bytes(expanded[545:547], 'big'), 2048)

    def test_extract_and_reject(self):
        size = module.VOLUME_BYTES
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'sram.dsk'
            data = bytearray([0x11] * size + [0x22] * size)
            for at in (0, size):
                data[at+2*256+38:at+2*256+40] = bytes((127, 16))
            source.write_bytes(data)
            self.assertEqual(module.extract(source, 0), bytes(data[:size]))
            self.assertEqual(module.extract(source, 1), bytes(data[size:]))
            with self.assertRaises(ValueError):
                module.extract(source, 2)
            source.write_bytes(data[:-1])
            with self.assertRaises(ValueError):
                module.extract(source, 1)
            source.write_bytes(bytes(2*size))
            with self.assertRaises(ValueError):
                module.extract(source, 0)


if __name__ == '__main__':
    unittest.main()
