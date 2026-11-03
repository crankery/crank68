#!/usr/bin/env python3
"""Read-only audit of the KiCad logical wiring used by this firmware."""
import argparse
import json
from pathlib import Path
import re


def read_sexp(path):
    tokens = iter(re.findall(r'"(?:\\.|[^"\\])*"|[()]|[^\s()]+', path.read_text()))
    def parse():
        result = []
        for token in tokens:
            if token == '(':
                result.append(parse())
            elif token == ')':
                return result
            else:
                result.append(json.loads(token) if token.startswith('"') else token)
        return result
    return parse()[0]


def children(node, name):
    return [item for item in node if isinstance(item, list) and item and item[0] == name]


def footprints(path):
    result = {}
    for fp in children(read_sexp(path), 'footprint'):
        props = {p[1]: p[2] for p in children(fp, 'property')}
        pads = {p[1]: next((n[-1] for n in children(p, 'net')), '') for p in children(fp, 'pad') if p[1]}
        result[props['Reference']] = (props['Value'], pads)
    return result


def main():
    repo = Path(__file__).resolve().parents[3]
    parser = argparse.ArgumentParser()
    parser.add_argument('--sd', type=Path, default=repo / 'SD/SD.kicad_pcb')
    parser.add_argument('--io', type=Path, default=repo / 'IO/IO.kicad_pcb')
    args = parser.parse_args()
    sd, io = footprints(args.sd), footprints(args.io)
    expected = {'2':'/PD0','3':'/PD1','4':'/PD2','5':'/PD3','6':'/PD4',
                '11':'/PD5','12':'/PD6','13':'/PD7','14':'/~{PA_OE}','15':'/PB_CLK',
                '16':'/SD_CS','17':'/MOSI','18':'/MISO','19':'/SCK',
                '23':'/CA1','24':'/CA2','25':'/CB1','26':'/CB2'}
    for pin, net in expected.items():
        if sd['U1'][1].get(pin) != net:
            raise SystemExit(f'Firmware pin mismatch: U1.{pin}, expected {net}, got {sd["U1"][1].get(pin)}')
    for bit in range(8):
        if sd['U2'][1][str(2+bit)] != f'/PA{bit}' or sd['U2'][1][str(19-bit)] != f'/PD{bit}':
            raise SystemExit('U2 latch bit order differs from firmware')
        if sd['U3'][1][str(2+bit)] != f'/PD{bit}' or sd['U3'][1][str(19-bit)] != f'/PB{bit}':
            raise SystemExit('U3 latch bit order differs from firmware')
    for ref, pin, net in [('U2','1','/~{PA_OE}'),('U2','11','/CA2'),('U3','1','GND'),('U3','11','/PB_CLK')]:
        if sd[ref][1][pin] != net:
            raise SystemExit(f'Latch control mismatch: {ref}.{pin}')
    if sd['U1'][1]['27'] != sd['D1'][1]['1'] or sd['U1'][1]['28'] != sd['D2'][1]['1']:
        raise SystemExit('Status/activity LED cathode wiring changed')
    if sd['J2'][1] != io['J2'][1]:
        raise SystemExit('SD and IO J2 logical pinouts differ')
    isp = {'1':'/MISO', '2':'+5V', '3':'/SCK', '4':'/MOSI',
           '5':'/~{RESET}', '6':'GND'}
    for pin, net in isp.items():
        if sd['J3'][1].get(pin) != net:
            raise SystemExit(f'ISP pin mismatch: J3.{pin}, expected {net}, got {sd["J3"][1].get(pin)}')
    if sd['U1'][1].get('1') != isp['5']:
        raise SystemExit('ISP RESET does not reach U1.1')
    schematic = read_sexp(args.sd.with_suffix('.kicad_sch'))
    values = {}
    for symbol in children(schematic, 'symbol'):
        props = {p[1]: p[2] for p in children(symbol, 'property')}
        values[props.get('Reference')] = props.get('Value')
    for ref in ('U2', 'U3'):
        if values.get(ref) != '74HCT574':
            raise SystemExit(f'{ref} schematic value should be 74HCT574, got {values.get(ref)}')
    print('SD U1/latch wiring, ISP J3, and IO J2 match firmware; schematic U2/U3 are HCT574.')
    print('Logical pinout audit only; back-mounted connector mating/orientation needs physical review.')


if __name__ == '__main__':
    main()
