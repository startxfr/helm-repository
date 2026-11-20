#!/usr/bin/env python3
"""Print the charts to release: the given charts plus every internal chart that depends on them, directly or not
(a dependent takes the new version of its dependencies, see ADR-0001 and ADR-0005). One name per line, sorted.
Usage: release-closure.py a,b,c      closure over dependents
       release-closure.py --deps-of c  internal dependencies of one chart
(run from anywhere; reads charts/*/Chart.yaml next to .tools/)"""
import glob, os, sys
import yaml

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
deps = {}
for f in glob.glob(os.path.join(root, 'charts', '*', 'Chart.yaml')):
    y = yaml.safe_load(open(f)) or {}
    deps[y.get('name', os.path.basename(os.path.dirname(f)))] = [d.get('name') for d in (y.get('dependencies') or [])]
if len(sys.argv) > 2 and sys.argv[1] == '--deps-of':
    # internal charts the given chart depends on, one per line
    print('\n'.join(d for d in deps.get(sys.argv[2], []) if d in deps))
    sys.exit(0)
selected = {n for n in (sys.argv[1].split(',') if len(sys.argv) > 1 else []) if n}
unknown = sorted(n for n in selected if n not in deps)
if unknown:
    sys.exit('release-closure: unknown chart(s): ' + ', '.join(unknown))
changed = True
while changed:
    changed = False
    for chart, ds in deps.items():
        if chart not in selected and any(d in selected for d in ds):
            selected.add(chart)
            changed = True
print('\n'.join(sorted(selected)))
