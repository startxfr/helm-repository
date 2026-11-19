#!/usr/bin/env python3
"""Align the internal dependency pins on the current local version of the released charts.

Usage (from anywhere): .tools/bump-pins.py [--apply] [--released a,b,c]

For every charts/*/Chart.yaml, each `dependencies[]` item whose name is a chart of this repository, named in
--released (default: every chart reported by `./sx-helm changed-charts`) and pinned on a 21.3.x version, gets its
`version` set to the CURRENT local version of that chart. Other dependencies (external charts, other branches) and
all other lines of the file are left byte for byte untouched, whatever the key order or quoting of the item.
Chart.lock files are not used (generated artifacts): `helm dependency update` runs at release time.

Output: one line per pin changed, then `DEPENDENT <chart>` for every chart modified (or to modify without --apply),
so the release tool can add these charts to the release. Dry run unless --apply is given."""
import argparse
import glob
import os
import re
import subprocess
import sys

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
os.chdir(ROOT)

p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
p.add_argument('--apply', action='store_true')
p.add_argument('--released', help='comma separated chart names (default: ./sx-helm changed-charts)')
a = p.parse_args()

local = {}
for f in glob.glob('charts/*/Chart.yaml'):
    y = yaml.safe_load(open(f))
    local[y['name']] = str(y['version'])

if a.released:
    released = {c.strip() for c in a.released.split(',') if c.strip()}
else:
    out = subprocess.run(['./sx-helm', 'changed-charts'], capture_output=True, text=True, check=True).stdout
    released = {os.path.basename(l.strip()) for l in out.splitlines() if l.strip().startswith('./') or l.strip() in local}
unknown = sorted(released - set(local))
if unknown:
    sys.exit('unknown chart(s): ' + ', '.join(unknown))

changes, dependents = [], []
for f in sorted(glob.glob('charts/*/Chart.yaml')):
    text = open(f).read()
    lines = text.split('\n')
    chart = yaml.safe_load(text)['name']
    i = next((k for k, l in enumerate(lines) if l.startswith('dependencies:')), None)
    if i is None:
        continue
    items, cur = [], None
    for k in range(i + 1, len(lines)):
        l = lines[k]
        if l and not l.startswith((' ', '-')):
            break  # next top level key
        if re.match(r'^\s*- ', l):
            cur = {}
            items.append(cur)
        m = re.match(r'^\s*(?:- )?(name|version):\s*"?([^"\s#]+)"?', l)
        if m and cur is not None:
            cur[m.group(1)] = m.group(2)
            cur[m.group(1) + '_line'] = k
    touched = False
    for it in items:
        n, v = it.get('name'), it.get('version')
        if n in released and v and v != local[n] and v.startswith('21.3.'):
            changes.append((chart, n, v, local[n]))
            touched = True
            k = it['version_line']
            lines[k] = re.sub(r'(version:\s*)(["\']?)[^"\'\s#]+\2', lambda m: m.group(1) + m.group(2) + local[n] + m.group(2), lines[k], count=1)
    if touched:
        dependents.append(chart)
        if a.apply:
            open(f, 'w').write('\n'.join(lines))
for c in changes:
    print('%s: %s %s -> %s' % c)
for c in dependents:
    print('DEPENDENT', c)
print(len(changes), 'pin(s) in', len(dependents), 'chart(s)', 'updated' if a.apply else '(dry run, use --apply)', file=sys.stderr)
