#!/usr/bin/env python3
"""Pin the internal dependencies of the charts on a version that is already published (ADR-0006).

Usage (from anywhere):
  .tools/bump-pins.py [--apply] [--only chart] [--below X.Y.Z]   resolve the pins against the published index
  .tools/bump-pins.py --check-offline [--only chart]              pin < chart version, no network (CI)
  .tools/bump-pins.py --check [--only chart]                      offline checks + the pinned version is published
  .tools/bump-pins.py --lagging [--only chart]                    report the dependents that must be released again to take a published dependency
  .tools/bump-pins.py --levels                                    list the charts by depth in the internal dependency graph (no network)

An internal dependency is a `dependencies[]` item whose `repository` is served by this repository bucket
(HELM_REPO_BASEURL of .tools/config; upstream charts and other registries are never touched). The rule:

  the pin of an internal dependency is the HIGHEST version of that chart published in the index of its repository
  (<repository>/index.yaml), of the same MAJOR.MINOR as the chart that carries the pin, strictly LOWER than the
  version of that chart (or than --below, the version a release is about to give to it).

A pin never equals the version of its own chart: such a chart cannot be rebuilt before its dependency is published.
A dependency that has no published version below the target is an error: publish it first, in a release of its own.
When the index cannot be downloaded the tool stops (exit 2): it never falls back to the versions of the local tree.

Dependencies written in flow style (`- {name: ...}`) are refused: rewrite them in block style. With --apply nothing is written
unless every chart resolves (all or nothing). The index is validated strictly: an unreadable entry or a version that is not a canonical
MAJOR.MINOR.PATCH without leading zeros is never used (an unreadable index exits 2).

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
    m = re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', v if isinstance(v, str) else '')
    return tuple(int(x) for x in m.groups()) if m else None


def vstr(t):
    return '.'.join(str(x) for x in t)


p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
p.add_argument('--apply', action='store_true', help='write the resolved pins')
p.add_argument('--only', help='restrict to this single chart')
p.add_argument('--below', help='version a chart is about to get (default: its current version)')
p.add_argument('--check-offline', action='store_true', help='pin < chart version, no network')
p.add_argument('--check', action='store_true', help='offline checks + the pinned version is in the published index')
p.add_argument('--lagging', action='store_true', help='report the pins below the highest published version of the dependency (same MAJOR.MINOR); a dependency whose highest published version is the chart own version is not listed (after a full release every dependent lags by one by construction); no change')
p.add_argument('--levels', action='store_true', help='list the charts by depth in the internal dependency graph (no network)')
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
    """{chart name: {(X, Y, Z): version string as published}} of the index of a repository, downloaded once (retries, no fallback)."""
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
        doc = yaml.load(raw, Loader=Loader)
        entries = doc.get('entries') if isinstance(doc, dict) else None
        if not isinstance(entries, dict):
            raise ValueError('no `entries` mapping')
        out = {}
        for name, versions in entries.items():
            if not isinstance(name, str) or not isinstance(versions, list) or not all(isinstance(v, dict) for v in versions):
                raise ValueError(f'entry {name!r} is not a list of chart versions: fix {repo}/index.yaml (helm repo index regenerates it)')
            found = {}
            for v in versions:
                s = v.get('version')
                if not isinstance(s, str):
                    raise ValueError(f'entry {name!r} has the version {s!r} that is not a string (an unquoted legacy version such as 18.11?): quote it in {repo}/index.yaml, or regenerate the index with helm repo index')
                if vtuple(s):  # a version that is not a canonical X.Y.Z is never selected
                    found[vtuple(s)] = s
            out[name] = found
    except Exception as e:
        sys.stderr.write(f'bump-pins: the index of {repo} is unreachable or unreadable ({e}): nothing changed, '
                         'the pins are never taken from the local tree\n')
        sys.exit(2)
    _cache[repo] = out
    return out


def dependency_items(lines):
    """The items of the `dependencies:` list: dicts with name / version / repository and the line of each."""
    i = next((k for k, l in enumerate(lines) if l.startswith('dependencies:')), None)
    if i is None:
        return [], False
    flow = bool(re.match(r'^dependencies:\s*[\[{]\s*[^\]}\s]', lines[i]))
    items, cur = [], None
    for k in range(i + 1, len(lines)):
        l = lines[k]
        if l and not l.startswith((' ', '-')):
            break  # next top level key
        if re.match(r'^\s*-\s*[\[{]', l):
            flow = True
        if re.match(r'^\s*- ', l):
            cur = {}
            items.append(cur)
        m = re.match(r'^\s*(?:- )?(name|version|repository|alias):\s*"?([^"\s#]+)"?', l)
        if m and cur is not None:
            cur[m.group(1)] = m.group(2)
            cur[m.group(1) + '_line'] = k
    return items, flow


def internal(y):
    """Internal dependencies (served by this bucket) of a parsed Chart.yaml."""
    return [d for d in (y.get('dependencies') or []) if str(d.get('repository', '')).rstrip('/').startswith(BASE + '/')]


if a.levels:
    docs, names = {}, set()
    for f in glob.glob('charts/*/Chart.yaml'):
        names.add(yaml.safe_load(open(f))['name'])
    for f in glob.glob('charts/*/Chart.yaml'):
        y = yaml.safe_load(open(f))
        docs[y['name']] = {d['name'] for d in internal(y) if d['name'] in names and d['name'] != y['name']}
    level = {}
    while len(level) < len(docs):
        ready = [c for c in docs if c not in level and docs[c] <= set(level)]
        if not ready:
            sys.exit('dependency cycle between: ' + ', '.join(sorted(set(docs) - set(level))))
        for c in ready:
            level[c] = 1 + max((level[d] for d in docs[c]), default=-1)
    for n in range(max(level.values()) + 1):
        print('level %d (%d): %s' % (n, sum(1 for v in level.values() if v == n), ' '.join(sorted(c for c, v in level.items() if v == n))))
    sys.exit(0)


changes, errors, lagging, writes, warnings = [], [], [], {}, []
for f in sorted(glob.glob('charts/*/Chart.yaml')):
    text = open(f).read()
    lines = text.split('\n')
    chart = yaml.safe_load(text)['name']
    if a.only and chart != a.only:
        continue
    own = vtuple(yaml.safe_load(text).get('version'))
    target = below or own
    touched = False
    items, flow = dependency_items(lines)
    if flow:
        errors.append(f'{chart}: the dependencies are written in flow style, which this tool cannot rewrite: use the block style (- name: ...)')
        continue
    for it in items:
        name, pin, repo = it.get('name'), it.get('version'), (it.get('repository') or '').rstrip('/')
        label = name if not it.get('alias') or it['alias'] == name else f"{name} ({it['alias']})"
        if not repo.startswith(BASE + '/'):
            continue  # upstream chart or other registry
        pt = vtuple(pin)
        if a.lagging:
            # the highest published version of the same MAJOR.MINOR, whatever the chart version: the chart must be released
            # at a version ABOVE it to take it (the pin is always strictly below the version being released)
            latest = max((t for t in published(repo).get(name, {}) if own and t[:2] == own[:2]), default=None)
            if pt and latest and latest > pt and latest != own:
                lagging.append(f'{chart}: {label} pins {pin}, {vstr(latest)} is published: release {chart} at a version above {vstr(latest)}')
            continue
        if a.check_offline or a.check:
            if pt is None:
                errors.append(f'{chart}: {label} is pinned on "{pin}", an exact X.Y.Z version is required')
            elif own is None or pt >= own:
                errors.append(f'{chart} {vstr(own) if own else "?"}: {label} is pinned on {pin}, not lower than the chart version')
            elif a.check and pt not in published(repo).get(name, {}):
                errors.append(f'{chart}: {name} {pin} is not published in {repo}/index.yaml')
            continue
        if target is None:
            errors.append(f'{chart}: the chart version is not an exact X.Y.Z version')
            continue
        pub = published(repo).get(name, {})
        candidates = [t for t in pub if t[:2] == target[:2] and t < target]
        if not candidates:
            errors.append(f'{chart}: {name} has no version below {vstr(target)} published in {repo}: publish {name} first, '
                          'in a release of its own')
            continue
        newer = [t for t in pub if t[:2] == target[:2] and t >= target]
        if newer:  # published, but not below the version being released: the pin cannot take it
            warnings.append(f'{chart}: {label} {pub[max(newer)]} is published and cannot be pinned by a release at {vstr(target)}: '
                            f'release {chart} at a version above {vstr(max(newer))} to take it')
        new = pub[max(candidates)]  # the version string as published
        if pin != new:
            changes.append((chart, label, pin, new))
            touched = True
            k = it['version_line']
            lines[k] = re.sub(r'(version:\s*)(["\']?)[^"\'\s#]+\2', lambda m: m.group(1) + m.group(2) + new + m.group(2), lines[k], count=1)
    if touched:
        writes[f] = '\n'.join(lines)

if a.only and not any(True for f in glob.glob(f'charts/{a.only}/Chart.yaml')):
    sys.exit('unknown chart: ' + a.only)
if a.apply and writes and not errors:  # all or nothing
    for f, content in writes.items():
        open(f, 'w').write(content)
for c in changes:
    print('%s: %s %s -> %s' % c)
for l in lagging:
    print(l)
for w in warnings:
    sys.stderr.write('WARNING ' + w + '\n')
for e in errors:
    sys.stderr.write('FAIL ' + e + '\n')
if a.lagging:
    sys.stderr.write('%d dependent(s) to release again to take a published dependency\n' % len(lagging))
elif a.check or a.check_offline:
    sys.stderr.write('%d wrong pin(s)\n' % len(errors) if errors else 'ok: every internal pin is lower than its chart version%s\n'
                     % (' and published' if a.check else ''))
else:
    state = 'to update (dry run, use --apply)' if not a.apply else ('NOT written: nothing is written while a chart fails' if errors else 'updated')
    sys.stderr.write('%d pin(s) %s, %d error(s)\n' % (len(changes), state, len(errors)))
sys.exit(1 if errors else 0)
