#!/usr/bin/env python3
"""Rendered-manifest safety net for chart refactorings. Read-only on the repository: works on temporary copies.

Usage:
  .tools/render-golden.py snapshot <dir> [chart ...]   render every chart into <dir>/<chart>/<case>.yaml
  .tools/render-golden.py compare <dirA> <dirB>        list the cases that differ between two snapshots (exit 1)
  .tools/render-golden.py toggles [chart ...]          every `<key>.enabled` switched on alone must render (exit 1)

Cases rendered for a chart: the default values, every values-*.yaml of the chart, and every top level key of
values.yaml that is a mapping with `enabled: false`, switched on alone (`--set <key>.enabled=true`).
Every case is rendered twice: the lines that change between two renders (generated certificates, random
passwords) are replaced by `<key>: <generated>`. A case that fails to render is stored as a single line `ERROR: <first line of the helm error>`, so a snapshot also
records which cases are broken. The version labels are dropped: a version bump is not a difference.

Typical refactoring session (the snapshot directory must be outside the repository):
  .tools/render-golden.py snapshot /tmp/before cluster-grafana
  ... edit the templates ...
  .tools/render-golden.py snapshot /tmp/after cluster-grafana && .tools/render-golden.py compare /tmp/before /tmp/after

Dependencies: the charts/<chart>/charts/*.tgz already present are used when they match the pins of Chart.yaml,
otherwise `helm dependency update` runs in the temporary copy. Environment: JOBS (default 8).
"""
import concurrent.futures
import filecmp
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile

import yaml

ROOT = os.environ.get('GOLDEN_ROOT') or os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))  # GOLDEN_ROOT: another tree (tests)
CHARTS = os.path.join(ROOT, 'charts')
JOBS = int(os.environ.get('JOBS', '8'))
IGNORE = re.compile(r'^\s+(app\.startx\.fr/version|app\.kubernetes\.io/version|helm\.sh/chart|startx\.fr/generated-by|'
                    r'startx\.fr/generator-cmd)\b')

# (chart, key): switching the key on alone is refused on purpose by the chart (a validation, not a bug).
# Add an entry only with the reason.
TOGGLE_NEEDS_VALUES = {
    ('chaos-litmus', 'litmus'): 'no default password: needs litmus.existingSecret or adminConfig.ADMIN_PASSWORD, and litmus.mongodb.auth',
    ('cluster-gitlab', 'gitlab'): 'the upstream chart requires certmanager-issuer.email',
    ('cluster-loki', 'storageSecret'): 'needs storageSecret.data or storageSecret.externalSecret',
    ('cluster-quay', 'oidc'): 'oidc.enabled requires quay.config.enabled',
}

# (chart, key): known bugs, reported but not failing until they are fixed (harmonization plan, lot 1). Must end empty.
TOGGLE_KNOWN_BUGS = {
    ('cluster-kubecost', 'project'): 'project.additionalLabels is a map, the project chart expects a string',
    ('cluster-machine', 'machineSet'): 'taints of the default machineSet render invalid YAML',
}


def all_charts():
    return sorted(c for c in os.listdir(CHARTS) if os.path.isfile(os.path.join(CHARTS, c, 'Chart.yaml')))


def prepare(chart, tmp):
    """Copy the chart in tmp and make sure its dependencies are there. Returns (dir, error or None)."""
    dst = os.path.join(tmp, chart)
    shutil.copytree(os.path.join(CHARTS, chart), dst, symlinks=True)
    lock = os.path.join(dst, 'Chart.lock')
    if os.path.exists(lock):
        os.remove(lock)
    meta = yaml.safe_load(open(os.path.join(dst, 'Chart.yaml')))
    deps = meta.get('dependencies') or []
    if not deps:
        return dst, None
    have = {os.path.basename(p) for p in glob.glob(os.path.join(dst, 'charts', '*.tgz'))}
    if all(f"{d['name']}-{d['version']}.tgz" in have for d in deps):
        # drop anything else (older packages, unpacked leftovers) so only the pinned versions are loaded
        for p in glob.glob(os.path.join(dst, 'charts', '*')):
            if os.path.basename(p) not in {f"{d['name']}-{d['version']}.tgz" for d in deps}:
                shutil.rmtree(p) if os.path.isdir(p) else os.remove(p)
        return dst, None
    shutil.rmtree(os.path.join(dst, 'charts'), ignore_errors=True)
    for _ in range(2):
        r = subprocess.run(['helm', 'dependency', 'update', dst], capture_output=True, text=True)
        if r.returncode == 0:
            return dst, None
    return dst, (r.stderr.strip().splitlines() or ['helm dependency update failed'])[-1]


def cases(chart_dir):
    """[(case name, helm args)]"""
    res = [('default', [])]
    for f in sorted(glob.glob(os.path.join(chart_dir, 'values-*.yaml'))):
        res.append(('file.' + os.path.basename(f)[:-len('.yaml')], ['-f', f]))
    try:
        values = yaml.safe_load(open(os.path.join(chart_dir, 'values.yaml'))) or {}
    except yaml.YAMLError:
        values = {}
    for k, v in values.items():
        if isinstance(v, dict) and v.get('enabled') is False:
            res.append(('toggle.' + k, ['--set', f'{k}.enabled=true']))
    return res


def render(chart_dir, args):
    r = subprocess.run(['helm', 'template', 'golden', chart_dir, '--namespace', 'golden'] + args,
                       capture_output=True, text=True)
    if r.returncode != 0:
        err = [l for l in r.stderr.strip().splitlines() if l.strip()]
        return None, (err[0] if err else 'helm template failed')
    return ''.join(l for l in r.stdout.splitlines(True) if not IGNORE.match(l)), None


def do_chart(chart, out, only_toggles=False):
    """Returns the list of (case, error) of the chart."""
    tmp = tempfile.mkdtemp(prefix='golden-')
    try:
        d, err = prepare(chart, tmp)
        if err:
            return [('dependencies', err)]
        res = []
        for name, args in cases(d):
            if only_toggles and not name.startswith('toggle.'):
                continue
            text, err = render(d, args)
            if err is None:
                # generated material (certificates, random passwords): render twice and mask the lines that move
                again, _ = render(d, args)
                if again is not None and again != text:
                    x, y = text.splitlines(True), again.splitlines(True)
                    if len(x) == len(y):
                        text = ''.join(l if l == m else l.split(':', 1)[0] + ': <generated>\n' for l, m in zip(x, y))
                    else:
                        text = 'UNSTABLE: the number of lines changes between two renders\n'
            # the temporary path must not leak in the snapshot
            if err:
                err = err.replace(tmp + '/', '')
            if out:
                os.makedirs(os.path.join(out, chart), exist_ok=True)
                open(os.path.join(out, chart, name + '.yaml'), 'w').write(text if err is None else f'ERROR: {err}\n')
            res.append((name, err))
        return res
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def run(charts, out, only_toggles=False):
    with concurrent.futures.ThreadPoolExecutor(JOBS) as ex:
        return dict(zip(charts, ex.map(lambda c: do_chart(c, out, only_toggles), charts)))


def main():
    a = sys.argv[1:]
    if not a or a[0] in ('-h', '--help'):
        print(__doc__)
        return 0
    cmd, rest = a[0], a[1:]
    if cmd == 'snapshot' and rest:
        out = os.path.abspath(rest[0])
        if os.path.commonpath([out, ROOT]) == ROOT:
            sys.exit('the snapshot directory must be outside the repository')
        charts = rest[1:] or all_charts()
        for c in charts:
            shutil.rmtree(os.path.join(out, c), ignore_errors=True)
        res = run(charts, out)
        n = sum(len(v) for v in res.values())
        bad = [(c, k, e) for c, v in res.items() for k, e in v if e]
        for c, k, e in bad:
            print(f'error {c} [{k}]: {e}')
        print(f'snapshot of {len(charts)} chart(s), {n} case(s), {len(bad)} in error, in {out}')
        return 0
    if cmd == 'compare' and len(rest) == 2:
        x, y = (os.path.abspath(p) for p in rest)
        fx = {os.path.relpath(p, x) for p in glob.glob(os.path.join(x, '*', '*.yaml'))}
        fy = {os.path.relpath(p, y) for p in glob.glob(os.path.join(y, '*', '*.yaml'))}
        diffs = 0
        for f in sorted(fx | fy):
            if f not in fy:
                print(f'ONLY-A {f}'); diffs += 1
            elif f not in fx:
                print(f'ONLY-B {f}'); diffs += 1
            elif not filecmp.cmp(os.path.join(x, f), os.path.join(y, f), shallow=False):
                r = subprocess.run(['diff', os.path.join(x, f), os.path.join(y, f)], capture_output=True, text=True)
                print(f"DIFF   {f} ({sum(1 for l in r.stdout.splitlines() if l[:1] in '<>')} line(s))"); diffs += 1
        print(f'{len(fx | fy)} case(s) compared, {diffs} difference(s)')
        return 1 if diffs else 0
    if cmd == 'toggles':
        charts = rest or all_charts()
        res = run(charts, None, only_toggles=True)
        n = bad = 0
        for c in charts:
            for k, e in res[c]:
                n += 1
                key = k[len('toggle.'):]
                if e and (c, key) in TOGGLE_NEEDS_VALUES:
                    print(f'ok   {c}: {key}.enabled=true needs more values ({TOGGLE_NEEDS_VALUES[(c, key)]})')
                elif e and (c, key) in TOGGLE_KNOWN_BUGS:
                    print(f'BUG  {c}: {key}.enabled=true does not render, known: {TOGGLE_KNOWN_BUGS[(c, key)]}')
                elif e:
                    print(f'FAIL {c}: {key}.enabled=true does not render: {e}'); bad += 1
        print(f'toggles: {n} switch(es) in {len(charts)} chart(s), {bad} failure(s)')
        return 1 if bad else 0
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
