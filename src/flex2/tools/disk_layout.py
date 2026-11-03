"""SRAM partition geometry and initial file placement."""
DRIVES = 2
TRACKS = 256 // DRIVES
SECTORS_PER_TRACK = 16
SECTORS = TRACKS * SECTORS_PER_TRACK
DRIVE_BYTES = SECTORS * 256
LABELS = ('C68SYS', 'C68DATA')
BASIC_FILES = {'MSBASIC.CMD', 'BASIC.CMD', 'XBASIC.CMD', 'RENUMX.CMD',
               'RENUMBER.CMD', 'CONVERT.BAS'}


def file_drive(name):
    if name in BASIC_FILES:
        return 0
    if name.endswith(('.BAS', '.DAT')):
        return 1
    return 0
