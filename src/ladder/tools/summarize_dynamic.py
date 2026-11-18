"""Summarize iz-cpm's selective LADDER.COM call log.

Example: python3 tools/summarize_dynamic.py calls.csv RUNTIME_CALLS.csv --out /tmp/ladder
Writes <out>-sites.csv and <out>-targets.csv. Raw events are retained separately.
"""

import argparse
import csv
from collections import Counter
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('events', type=Path)
    parser.add_argument('static_inventory', type=Path)
    parser.add_argument('--out', type=Path, required=True,
                        help='output filename prefix')
    args = parser.parse_args()

    with args.static_inventory.open(newline='') as source:
        static = {
            (row['source'][1:], row['kind'], row['target'][1:]): row['trace']
            for row in csv.DictReader(source)
        }
    sites = {}
    with args.events.open(newline='') as source:
        for row in csv.DictReader(source):
            key = (row['source'], row['kind'], row['target'])
            if key not in sites:
                sites[key] = {
                    'source': row['source'], 'kind': row['kind'],
                    'target': row['target'], 'count': 0,
                    'first_seq': row['seq'], 'last_seq': row['seq'],
                    'static_status': static.get(key, 'not_in_static_scan'),
                    'first_af': row['af'], 'first_bc': row['bc'],
                    'first_de': row['de'], 'first_hl': row['hl'],
                    'first_sp': row['sp'],
                }
            sites[key]['count'] += 1
            sites[key]['last_seq'] = row['seq']

    site_rows = sorted(sites.values(), key=lambda row: int(row['source'], 16))
    site_path = args.out.with_name(args.out.name + '-sites.csv')
    with site_path.open('w', newline='') as dest:
        writer = csv.DictWriter(dest, fieldnames=list(site_rows[0]))
        writer.writeheader()
        writer.writerows(site_rows)

    target_counts = Counter()
    target_sites = Counter()
    for row in site_rows:
        target_counts[row['target']] += row['count']
        target_sites[row['target']] += 1
    target_rows = [
        {'target': target, 'executions': count, 'distinct_sites': target_sites[target]}
        for target, count in target_counts.most_common()
    ]
    target_path = args.out.with_name(args.out.name + '-targets.csv')
    with target_path.open('w', newline='') as dest:
        writer = csv.DictWriter(dest, fieldnames=list(target_rows[0]))
        writer.writeheader()
        writer.writerows(target_rows)

    total = sum(target_counts.values())
    statuses = Counter(row['static_status'] for row in site_rows)
    print(f'{total} executed transfers; {len(site_rows)} sites; '
          f'{len(target_rows)} targets')
    print('sites by static status:', dict(statuses))
    print('top targets:', [(r['target'], r['executions']) for r in target_rows[:12]])
    print('wrote', site_path, target_path)


if __name__ == '__main__':
    main()
