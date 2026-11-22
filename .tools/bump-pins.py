#!/usr/bin/env python3
"""Pin the internal dependencies of the charts on a version that is already published (ADR-0006).

Usage (from anywhere):
  .tools/bump-pins.py [--apply] [--only chart] [--below X.Y.Z]   resolve the pins against the published index
  .tools/bump-pins.py --check-offline [--only chart]              pin < chart version, no network (CI)
  .tools/bump-pins.py --check [--only chart]                      offline checks + the pinned version is published
  .tools/bump-pins.py --lagging [--only chart]                    report the pins older than the latest published version

An internal dependency is a `dependencies[]` item whose `repository` is served by this repository bucket
(HELM_REPO_BASEURL of .tools/config; upstream charts and other registries are never touched). The rule:

  the pin of an internal dependency is the HIGHEST version of that chart published in the index of its repository
  (<repository>/index.yaml), of the same MAJOR.MINOR as the chart that carries the pin, strictly LOWER than the
  version of that chart (or than --below, the version a release is about to give to it).

A pin never equals the version of its own chart: such a chart cannot be rebuilt before its dependency is published.
A dependency that has no published version below the target is an error: publish it first, in a release of its own.
When the index cannot be downloaded the tool stops (exit 2): it never falls back to the versions of the local tree.

Only the `version:` line of the item is rewritten; every other byte of Chart.yaml is left untouched, whatever the key
order or quoting of the item. Dry run unless --apply is given. Chart.lock files are generated artifacts (ADR-0005):
`helm dependency update` runs at release time.

BUMP_PINS_SLEEP=<seconds> sets the pause between the 3 download attempts (default 2). --index <repository url>=<index file> replaces the download of that index (tests, offline review) ; repeatable.
Output: one line `<chart>: <dependency> <old> -> <new>` per pin to change (or changed), errors on stderr.
Exit codes: 0 ok, 1 a pin is wrong or cannot be resolved, 2 an index is unreachable or unreadable."""
import argparse
import glob
import os
import re
import sys
import time
import urllib.request

import yaml

try:
    from yaml import CSafeLoader as Loader
except ImportError:  # pragma: no cover
    from yaml import SafeLoader as Loader

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
os.chdir(ROOT)


def base_url():
    if os.environ.get('BASE'):
        return os.environ['BASE'].rstrip('/')
    cfg = open('.tools/config').read()
    bucket = re.search(r'^HELM_REPO_AWSBUCKET="([^"]+)"', cfg, re.M).group(1)
    dc = re.search(r'^HELM_REPO_AWSDC="([^"]+)"', cfg, re.M).group(1)
    return f'https://{bucket}.s3.{dc}.amazonaws.com'


def vtuple(v):
    m = re.fullmatch(r'(\d+)\.(\d+)\.(\d+)', str(v or ''))
    return tuple(int(x) for x in m.groups()) if m else None


def vstr(t):
    return '.'.join(str(x) for x in t)


p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
p.add_argument('--apply', action='store_true', help='write the resolved pins')
p.add_argument('--only', help='restrict to this single chart')
p.add_argument('--below', help='version a chart is about to get (default: its current version)')
p.add_argument('--check-offline', action='store_true', help='pin < chart version, no network')
p.add_argument('--check', action='store_true', help='offline checks + the pinned version is in the published index')
p.add_argument('--lagging', action='store_true', help='report the pins older than the latest published version (no change)')
p.add_argument('--index', action='append', default=[], metavar='URL=FILE', help='local copy of an index.yaml')
a = p.parse_args()

BASE = base_url()
local_index = {}
for item in a.index:
    url, _, path = item.partition('=')
    if not path:
        sys.exit('--index expects <repository url>=<index file>')
    local_index[url.rstrip('/')] = path
below = vtuple(a.below) if a.below else None
if a.below and below is None:
    sys.exit('--below expects a version X.Y.Z')

_cache = {}


def published(repo):
    """{chart name: set of (X, Y, Z)} of the index of a repository, downloaded once (retries, no fallback)."""
    repo = repo.rstrip('/')
    if repo in _cache:
        return _cache[repo]
    try:
        if repo in local_index:
            raw = open(local_index[repo], 'rb').read()
        else:
            err = None
            for attempt in range(3):
                try:
                    raw = urllib.request.urlopen(repo + '/index.yaml', timeout=60).read()
                    break
                except Exception as e:  # network, DNS, HTTP error
                    err = e
                    time.sleep(float(os.environ.get('BUMP_PINS_SLEEP', '2')) * (attempt + 1))
            else:
                raise err
        entries = (yaml.load(raw, Loader=Loader) or {}).get('entries') or {}
    except Exception as e:
        sys.stderr.write(f'bump-pins: the index of {repo} is unreachable or unreadable ({e}): nothing changed, '
                         'the pins are never taken from the local tree\n')
        sys.exit(2)
    out = {}
    for name, versions in entries.items():
        out[name] = {t for t in (vtuple(v.get('version')) for v in versions) if t}
    _cache[repo] = out
    return out


def dependency_items(lines):
    """The items of the `dependencies:` list: dicts with name / version / repository and the line of each."""
    i = next((k for k, l in enumerate(lines) if l.startswith('dependencies:')), None)
    if i is None:
        return []
    items, cur = [], None
    for k in range(i + 1, len(lines)):
        l = lines[k]
        if l and not l.startswith((' ', '-')):
            break  # next top level key
        if re.match(r'^\s*- ', l):
            cur = {}
            items.append(cur)
        m = re.match(r'^\s*(?:- )?(name|version|repository|alias):\s*"?([^"\s#]+)"?', l)
        if m and cur is not None:
            cur[m.group(1)] = m.group(2)
            cur[m.group(1) + '_line'] = k
    return items


changes, errors, lagging = [], [], []
for f in sorted(glob.glob('charts/*/Chart.yaml')):
    text = open(f).read()
    lines = text.split('\n')
    chart = yaml.safe_load(text)['name']
    if a.only and chart != a.only:
        continue
    own = vtuple(yaml.safe_load(text).get('version'))
    target = below or own
    touched = False
    for it in dependency_items(lines):
        name, pin, repo = it.get('name'), it.get('version'), (it.get('repository') or '').rstrip('/')
        label = name if not it.get('alias') or it['alias'] == name else f"{name} ({it['alias']})"
        if not repo.startswith(BASE + '/'):
            continue  # upstream chart or other registry
        pt = vtuple(pin)
        if a.lagging:
            latest = max((t for t in published(repo).get(name, set()) if own and t[:2] == own[:2]), default=None)
            if pt and latest and latest > pt:
                lagging.append(f'{chart}: {label} pinned on {pin}, {vstr(latest)} is published')
            continue
        if a.check_offline or a.check:
            if pt is None:
                errors.append(f'{chart}: {label} is pinned on "{pin}", an exact X.Y.Z version is required')
            elif own is None or pt >= own:
                errors.append(f'{chart} {vstr(own) if own else "?"}: {label} is pinned on {pin}, not lower than the chart version')
            elif a.check and pt not in published(repo).get(name, set()):
                errors.append(f'{chart}: {name} {pin} is not published in {repo}/index.yaml')
            continue
        if target is None:
            errors.append(f'{chart}: the chart version is not an exact X.Y.Z version')
            continue
        candidates = [t for t in published(repo).get(name, set()) if t[:2] == target[:2] and t < target]
        if not candidates:
            errors.append(f'{chart}: {name} has no version below {vstr(target)} published in {repo}: publish {name} first, '
                          'in a release of its own')
            continue
        new = vstr(max(candidates))
        if pin != new:
            changes.append((chart, label, pin, new))
            touched = True
            k = it['version_line']
            lines[k] = re.sub(r'(version:\s*)(["\']?)[^"\'\s#]+\2', lambda m: m.group(1) + m.group(2) + new + m.group(2), lines[k], count=1)
    if touched and a.apply and not any(e.startswith(chart + ':') or e.startswith(chart + ' ') for e in errors):
        open(f, 'w').write('\n'.join(lines))

if a.only and not any(True for f in glob.glob(f'charts/{a.only}/Chart.yaml')):
    sys.exit('unknown chart: ' + a.only)
for c in changes:
    print('%s: %s %s -> %s' % c)
for l in lagging:
    print(l)
for e in errors:
    sys.stderr.write('FAIL ' + e + '\n')
if a.lagging:
    sys.stderr.write('%d pin(s) older than the latest published version\n' % len(lagging))
elif a.check or a.check_offline:
    sys.stderr.write('%d wrong pin(s)\n' % len(errors) if errors else 'ok: every internal pin is lower than its chart version%s\n'
                     % (' and published' if a.check else ''))
else:
    sys.stderr.write('%d pin(s) %s, %d error(s)\n' % (len(changes), 'updated' if a.apply else 'to update (dry run, use --apply)', len(errors)))
sys.exit(1 if errors else 0)
