"""SRAM partition geometry and initial file placement."""
DRIVES = 4
TRACKS = 256 // DRIVES
SECTORS_PER_TRACK = 16
SECTORS = TRACKS * SECTORS_PER_TRACK
DRIVE_BYTES = SECTORS * 256
LABELS = ('C68SYS', 'C68BASIC', 'C68GAMES', 'C68FILES')
BASIC_FILES = {'MSBASIC.CMD', 'BASIC.CMD', 'XBASIC.CMD', 'RENUMX.CMD',
               'RENUMBER.CMD', 'CONVERT.BAS'}


def file_drive(name):
    if name in BASIC_FILES:
        return 1
    if name.endswith('.BAS'):
        return 2
    return 0
