#!/usr/bin/env python3
"""Generate charts/cluster-argocd/values-app-<chart>.yaml from charts/<chart>/examples/argocd/*.yaml.

The generated file follows the pattern documented in CLAUDE.md ("cluster-argocd values-app pattern"):
  - one AppProject named <prefix>-<name> (infra- for cluster-*, chaos- for chaos-*, app- for example-*, the chart name
    for the other charts), built from the example appproject.yaml;
  - one Application per examples/argocd/application-<suffix>.yaml, named <project>-<suffix>, with the sync-wave of the
    example, a finalizer on every Application except the -project one (a namespace can be slow to terminate), the
    `repo` and `rev: stable` source keys, the helm values of the example and, in these values, every top level
    `<flag>.enabled` of the chart values.yaml that the example does not mention set explicitly to false (an omitted
    flag causes SharedResourceWarning and secrets leaking across waves);
  - the syncPolicy and the ignoreDifferences of the example;
  - destinationNamespace when the example deploys in another namespace than openshift-gitops.

Usage:
  .tools/generate-values-app.py [chart ...]            generate in --out (default charts/cluster-argocd) every chart
                                                       that has an examples/argocd/appproject.yaml
  .tools/generate-values-app.py --out DIR [chart ...]  write the files in DIR instead
  .tools/generate-values-app.py --diff [chart ...]     do not write: compare with the existing files and list the
                                                       differences (the existing hand tuned files are never replaced)
Existing files are not overwritten unless --force is given. Hand tuned variants (values-app-<chart>-<variant>.yaml)
are never touched.
"""
import argparse
import glob
import os
import sys

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
CHARTS = os.path.join(ROOT, 'charts')
REPO = 'https://gitlab.com/startx1/helm.git'


def project_name(chart):
    if chart.startswith('cluster-'):
        return 'infra-' + chart[len('cluster-'):]
    if chart.startswith('example-'):
        return 'app-' + chart[len('example-'):]
    return chart  # chaos-*, chaos, operator, project, sxapi, unifai


def flags_of(chart):
    """Top level keys of values.yaml that are a mapping with a boolean `enabled`."""
    path = os.path.join(CHARTS, chart, 'values.yaml')
    values = yaml.safe_load(open(path)) or {}
    return [k for k, v in values.items() if isinstance(v, dict) and isinstance(v.get('enabled'), bool)]


def block(text, indent):
    pad = ' ' * indent
    return ''.join(pad + line if line.strip() else line for line in text.splitlines(True))


def dump(data):
    return yaml.safe_dump(data, default_flow_style=False, sort_keys=False, width=120)


def application_entry(chart, project, example_path, flags):
    suffix = os.path.basename(example_path)[len('application-'):-len('.yaml')]
    app = yaml.safe_load(open(example_path))
    spec = app['spec']
    helm = spec['source'].get('helm', {}) or {}
    values = yaml.safe_load(helm.get('values', '') or '') or {}
    explicit = []
    for flag in flags:
        if flag not in values:
            values[flag] = {'enabled': False}
            explicit.append(flag)
    wave = (app['metadata'].get('annotations') or {}).get('argocd.argoproj.io/sync-wave', '10')
    lines = [
        f"    - name: '{project}-{suffix}'",
        "      namespace: 'openshift-gitops'",
        f"      finalizer: {'false' if suffix == 'project' else 'true'}",
        f'      wave: "{wave}"',
        "      server: 'https://kubernetes.default.svc'",
    ]
    dest = (spec.get('destination') or {}).get('namespace')
    if dest and dest != 'openshift-gitops':
        # namespace the Application deploys into (cluster-argocd application.list[].destinationNamespace)
        lines.append(f"      destinationNamespace: '{dest}'")
    lines += [
        f"      project: '{project}'",
        '      source:',
        f"        path: 'charts/{chart}'",
        f"        repo: '{REPO}'",
        "        rev: 'stable'",
        '      helm: |',
    ]
    helm_text = 'valueFiles:\n' + ''.join(f'  - {v}\n' for v in helm.get('valueFiles', ['values.yaml']))
    helm_text += 'values: |\n' + block(dump(values), 2)
    out = '\n'.join(lines) + '\n' + block(helm_text, 8)
    if spec.get('syncPolicy'):
        out += '      syncPolicy: |\n' + block(dump(spec['syncPolicy']), 8)
    if spec.get('ignoreDifferences'):
        out += '      ignoreDifferences: |\n' + block(dump(spec['ignoreDifferences']), 8)
    return out, explicit


def generate(chart):
    ex = os.path.join(CHARTS, chart, 'examples', 'argocd')
    proj_file = os.path.join(ex, 'appproject.yaml')
    if not os.path.isfile(proj_file):
        return None, []
    project = project_name(chart)
    ap = yaml.safe_load(open(proj_file))['spec']
    dests = []
    for d in ap.get('destinations', []):
        ns = d.get('namespace')
        if ns and ns != '*' and ns not in dests:
            dests.append(ns)
    if 'openshift-gitops' not in dests:
        dests.append('openshift-gitops')
    out = [f"# Generated by .tools/generate-values-app.py from charts/{chart}/examples/argocd/ (do not edit by hand:",
           f"# hand tuned variants go in values-app-{chart}-<variant>.yaml)", '',
           'argocd_project:', '  enabled: true', '  list:', f"    - name: '{project}'",
           "      namespace: 'openshift-gitops'", '      wave: "-10"', '      sourceRepos:', f"        - '{REPO}'", '      destinations:']
    for ns in dests:
        out += [f"        - namespace: '{ns}'", "          server: 'https://kubernetes.default.svc'"]
    wl = ap.get('clusterResourceWhitelist')
    out += ['      clusterResourceWhitelist:']
    if wl:
        for r in wl:
            out += [f"        - group: '{r.get('group', '')}'", f"          kind: '{r.get('kind', '*')}'"]
    else:
        out += ["        - group: '*'", "          kind: '*'"]
    out += ['      roles:', '      - name: admin', '        description: All privileges to group admin in project',
            '        policies:', f'        - p, proj:{project}:admin, *, *, */*, allow', '        - g, system:cluster-admins, role:admin',
            '        groups:', '        - system:cluster-admins', '        - admin', '', '# Applications', 'application:', '  enabled: true', '  list:']
    flags = flags_of(chart)
    order = {'app': 1, 'operator': 2, 'project': 3}
    files = sorted(glob.glob(os.path.join(ex, 'application-*.yaml')),
                   key=lambda p: (order.get(os.path.basename(p)[len('application-'):-len('.yaml')], 0), p))
    explicit_all = []
    text = '\n'.join(out) + '\n'
    for f in files:
        entry, explicit = application_entry(chart, project, f, flags)
        text += entry
        explicit_all += [(os.path.basename(f), x) for x in explicit]
    text += '\nargocd_repocreds:\n  enabled: true\n  list: []\n'
    yaml.safe_load(text)  # must stay valid YAML
    return text, explicit_all


def summarize(chart, text, existing_path):
    """Short list of the differences between the generated and the existing file (parsed YAML)."""
    if not os.path.isfile(existing_path):
        return ['no existing file']
    new, old = yaml.safe_load(text), yaml.safe_load(open(existing_path))
    diffs = []
    pn, po = new['argocd_project']['list'][0], old['argocd_project']['list'][0]
    if pn['name'] != po['name']:
        diffs.append(f"project name {po['name']} -> {pn['name']}")
    an = {a['name']: a for a in new['application']['list']}
    ao = {a['name']: a for a in old['application']['list']}
    if sorted(an) != sorted(ao):
        diffs.append('applications %s -> %s' % (sorted(ao), sorted(an)))
    keys = [k for k in ('repoURL', 'targetRevision') if any(k in a['source'] for a in ao.values())]
    if keys:
        diffs.append('source keys %s (aliases) -> repo/rev' % '/'.join(keys))
    for n in sorted(set(an) & set(ao)):
        if an[n].get('wave') != ao[n].get('wave'):
            diffs.append(f"{n}: wave {ao[n].get('wave')} -> {an[n].get('wave')}")
        if bool(an[n].get('finalizer')) != bool(ao[n].get('finalizer')):
            diffs.append(f"{n}: finalizer {ao[n].get('finalizer')} -> {an[n].get('finalizer')}")
        if (an[n].get('ignoreDifferences') or '').strip() != (ao[n].get('ignoreDifferences') or '').strip():
            diffs.append(f'{n}: ignoreDifferences differ')
        if (an[n].get('helm') or '').strip() != (ao[n].get('helm') or '').strip():
            diffs.append(f'{n}: helm values differ')
    return diffs


def main():
    p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    p.add_argument('charts', nargs='*')
    p.add_argument('--out', default=os.path.join(CHARTS, 'cluster-argocd'))
    p.add_argument('--diff', action='store_true')
    p.add_argument('--force', action='store_true')
    a = p.parse_args()
    charts = a.charts or sorted(os.listdir(CHARTS))
    done = skipped = 0
    for chart in charts:
        text, explicit = generate(chart)
        if text is None:
            skipped += 1
            continue
        target = os.path.join(a.out, f'values-app-{chart}.yaml')
        existing = os.path.join(CHARTS, 'cluster-argocd', f'values-app-{chart}.yaml')
        if a.diff:
            d = summarize(chart, text, existing)
            print(f"{chart}: {'identical structure' if not d else '; '.join(d)}" + (f" | explicit false flags added: {len(explicit)}" if explicit else ''))
            done += 1
            continue
        if os.path.exists(target) and not a.force and os.path.abspath(target) == os.path.abspath(existing):
            print(f'keep   {target} (exists, use --force)')
            continue
        os.makedirs(a.out, exist_ok=True)
        open(target, 'w').write(text)
        print(f'write  {target}')
        done += 1
    print(f'{done} chart(s) processed, {skipped} without examples/argocd/appproject.yaml')


if __name__ == '__main__':
    sys.exit(main())
