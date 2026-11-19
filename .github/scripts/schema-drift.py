#!/usr/bin/env python3
"""List the keys of charts/<chart>/values.yaml that are missing from values.schema.json `properties`.

Checked: the top level keys and the second level keys of the mappings that the schema describes as objects with
`properties`. Skipped: charts whose schema is hand written and open (unifai) and the free-form `spec` blocks.
Informational by default (exit 0); with --strict the exit code is 1 when something is missing.
Usage: schema-drift.py [--strict] [--root DIR] [chart ...]"""
import argparse
import glob
import json
import os
import sys

import yaml

OPEN_SCHEMAS = {'unifai'}
FREE_FORM = {'spec'}

p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
p.add_argument('charts', nargs='*')
p.add_argument('--strict', action='store_true')
p.add_argument('--root', default=os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
a = p.parse_args()

res = {}
for d in sorted(glob.glob(os.path.join(a.root, 'charts', '*'))):
    c = os.path.basename(d)
    if (a.charts and c not in a.charts) or c in OPEN_SCHEMAS:
        continue
    vp, sp = os.path.join(d, 'values.yaml'), os.path.join(d, 'values.schema.json')
    if not (os.path.isfile(vp) and os.path.isfile(sp)):
        continue
    values = yaml.safe_load(open(vp)) or {}
    props = json.load(open(sp)).get('properties', {})
    miss = []
    for k, v in values.items():
        if k in FREE_FORM:
            continue
        if k not in props:
            miss.append(k)
            continue
        sub = props[k]
        if isinstance(v, dict) and sub.get('type') == 'object' and 'properties' in sub:
            miss += [f'{k}.{k2}' for k2 in v if k2 not in sub['properties'] and k2 not in FREE_FORM]
    if miss:
        res[c] = miss

for c, m in sorted(res.items(), key=lambda x: (len(x[1]), x[0])):
    print(f'{len(m):3d} {c}: {" ".join(m)}')
print(f'schema drift: {sum(map(len, res.values()))} key(s) missing in {len(res)} chart(s)')
sys.exit(1 if (a.strict and res) else 0)
