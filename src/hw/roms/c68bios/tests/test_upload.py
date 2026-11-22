"""Host-side packet and retry checks for the BIOS uploader."""

import importlib.util
import io
import unittest
from contextlib import redirect_stdout
from pathlib import Path


SPEC = importlib.util.spec_from_file_location(
    "c68upload", Path(__file__).resolve().parents[1] / "tools" / "upload.py")
upload = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(upload)


class FakeSocket:
    def __init__(self, replies):
        self.replies = bytearray(replies)
        self.writes = []

    def sendall(self, data):
        self.writes.append(data)

    def recv(self, count):
        if not self.replies:
            return b""
        return bytes([self.replies.pop(0)])


class UploadTest(unittest.TestCase):
    def test_crc_vector_and_full_block_retry(self):
        self.assertEqual(upload.crc16(b"123456789"), 0x29b1)
        stream = FakeSocket(b"CK")
        link = upload.Link(stream, True)
        data = bytes(range(256))
        link.block(data, 1)
        payload = b"\0" + data
        packet = b"B" + payload + upload.crc16(payload).to_bytes(2, "big")
        self.assertEqual(stream.writes, [packet, packet])

    def test_commands(self):
        stream = FakeSocket(b"K" * 3)
        link = upload.Link(stream, True)
        link.set_address(0xc000)
        link.poke(0xe002, 7)
        link.quit()
        self.assertEqual(stream.writes,
                         [b"A\xc0\0", b"W\xe0\x02\x07", b"Q"])

    def test_sram_image_pages_and_resume(self):
        class RecordingLink:
            def __init__(self):
                self.calls = []

            def poke(self, address, value):
                self.calls.append(("poke", address, value))

            def set_address(self, address):
                self.calls.append(("address", address))

            def block(self, data, retries):
                self.calls.append(("block", len(data), data[0], retries))

        image = b"".join(bytes([page]) * upload.PAGE_BYTES
                         for page in range(256))
        link = RecordingLink()
        with redirect_stdout(io.StringIO()):
            upload.upload_sram(link, image, 126, 2, 256, 2)
        for pair in (126, 127):
            first = (pair - 126) * 36
            self.assertEqual(link.calls[first:first + 3],
                             [("poke", 0xe002, 2 * pair),
                              ("poke", 0xe003, 2 * pair + 1),
                              ("address", 0xc000)])
            self.assertEqual(link.calls[first + 3:first + 19],
                             [("block", 256, 2 * pair, 2)] * 16)
            self.assertEqual(link.calls[first + 19], ("address", 0xd000))
            self.assertEqual(link.calls[first + 20:first + 36],
                             [("block", 256, 2 * pair + 1, 2)] * 16)
        self.assertEqual(len(link.calls), 72)


if __name__ == "__main__":
    unittest.main()
