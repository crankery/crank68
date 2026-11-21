#!/usr/bin/env python3
"""Generate the FLEX physical-drive mapping for one of two layouts."""
import argparse
from pathlib import Path

LAYOUTS = {
    'sram-first': (0, 1, 2),
    'sd-first': (1, 2, 0),
}


def write_if_changed(path, data):
    if not path.is_file() or path.read_text() != data:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(data)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('layout', choices=LAYOUTS)
    args = parser.parse_args()
    sram0, sram1, sd = LAYOUTS[args.layout]
    write_if_changed(Path('build/drive-config.asm'),
                     f'; {args.layout}: logical FLEX drive numbers\n'
                     f'C68SRAM0 EQU {sram0}\nC68SRAM1 EQU {sram1}\nC68SDDRIVE EQU {sd}\n')
    write_if_changed(Path('build/drive-config.h'),
                     f'// {args.layout}: logical FLEX drive numbers\n'
                     f'constexpr unsigned Sram0Drive = {sram0};\n'
                     f'constexpr unsigned Sram1Drive = {sram1};\n'
                     f'constexpr unsigned SdDrive = {sd};\n')
    print(f'{args.layout}: SRAM0={sram0}, SRAM1={sram1}, SD={sd}')


if __name__ == '__main__':
    main()
