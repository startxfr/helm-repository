#!/usr/bin/env python3
"""Keep the dependency blocks of every values.schema.json generated from the schema of the dependency itself.

Usage:
  .tools/schema-sync.py [chart ...]           rewrite charts/<chart>/values.schema.json in place (default: all)
  .tools/schema-sync.py --check [chart ...]   write nothing, exit 1 when a schema is not up to date (CI)
  .tools/schema-sync.py --inline ...          copy the definitions in place instead of using `$ref` (bigger files; for
                                              tools that do not resolve local references)
  .tools/schema-sync.py --root DIR ...        work on DIR/charts instead of this repository (tests)

What it generates, in the schema of every chart that has internal dependencies (charts of this repository, whatever
their alias):
  - `$defs.<dependency chart>`: the schema of the dependency (its own values.schema.json, itself synchronized first),
    without `$schema` and without any `required` list: Helm already validates the values of an enabled dependency with
    the schema packaged in the dependency, and a `required` copied in the parent fails when the dependency is disabled.
    Objects stay open (Helm injects `global` in every dependency block).
  - `properties.<alias or name>`: `{"$ref": "#/$defs/<dependency chart>"}` (title/description of the previous block
    are kept next to the reference).
  - `$defs.context` and `properties.context`: one definition of the deployment context for the whole repository
    (taken from charts/project), the `required` list of the chart is kept next to the reference.
Why a copy and not a reference to the dependency file: Helm does not resolve a relative `$ref`, an https `$ref` breaks
offline, and the OpenShift console only reads the schema of the parent chart.

Not touched: the properties of the chart itself, the upstream (external) dependencies, the hand written schema of the
charts listed in SKIP. The dependency keys found in the schema that match no dependency of Chart.yaml are reported
(`stale`), never removed.
"""
import argparse
import copy
import json
import os
import re
import sys

import yaml

SKIP = {'unifai'}  # hand written, closed schema (draft-07)
CONTEXT_FROM = 'project'  # chart whose `context` block is the reference
OUR_REPO = 'sx-helm-repository'  # substring of the repository URL of the internal dependencies

p = argparse.ArgumentParser(description=__doc__.split('\n')[0])
p.add_argument('charts', nargs='*')
p.add_argument('--check', action='store_true')
p.add_argument('--inline', action='store_true')
p.add_argument('--root', default=os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
a = p.parse_args()
CHARTS = os.path.join(a.root, 'charts')


def load_schema(chart):
    text = open(os.path.join(CHARTS, chart, 'values.schema.json')).read()
    return text, json.loads(text)


def internal_deps(chart):
    """[(key in the parent values, dependency chart)]"""
    meta = yaml.safe_load(open(os.path.join(CHARTS, chart, 'Chart.yaml')))
    res = []
    for d in meta.get('dependencies') or []:
        if OUR_REPO in str(d.get('repository', '')) and os.path.isfile(os.path.join(CHARTS, d['name'], 'values.schema.json')):
            res.append((d.get('alias') or d['name'], d['name']))
    return res


def strip_required(node):
    """Remove the `required` keyword of every schema node (not a property that would be named required)."""
    if isinstance(node, dict):
        node.pop('required', None) if isinstance(node.get('required'), list) else None
        for kw in ('properties', '$defs', 'definitions', 'patternProperties'):
            for sub in (node.get(kw) or {}).values():
                strip_required(sub)
        for kw in ('items', 'additionalProperties', 'not', 'if', 'then', 'else'):
            strip_required(node.get(kw))
        for kw in ('allOf', 'anyOf', 'oneOf'):
            for sub in node.get(kw) or []:
                strip_required(sub)
    elif isinstance(node, list):
        for sub in node:
            strip_required(sub)
    return node


def resolve(node, defs):
    """Inline the local `#/$defs/x` references (--inline)."""
    if isinstance(node, dict):
        ref = node.get('$ref')
        if isinstance(ref, str) and ref.startswith('#/$defs/') and ref[len('#/$defs/'):] in defs:
            target = resolve(copy.deepcopy(defs[ref[len('#/$defs/'):]]), defs)
            rest = {k: resolve(v, defs) for k, v in node.items() if k != '$ref'}
            target.update(rest)
            return target
        return {k: resolve(v, defs) for k, v in node.items()}
    if isinstance(node, list):
        return [resolve(v, defs) for v in node]
    return node


_context = None


def context_def():
    global _context
    if _context is None:
        ref = load_schema(CONTEXT_FROM)[1]
        ctx = ref['properties']['context']
        if '$ref' in ctx:  # already synchronized: the definition is in $defs
            ctx = ref['$defs']['context']
        _context = strip_required(copy.deepcopy(ctx))
    return copy.deepcopy(_context)


_cache = {}


def synced(chart, stack=()):
    """Schema of the chart after synchronization (memoized)."""
    if chart in _cache:
        return _cache[chart]
    if chart in stack:
        sys.exit('dependency cycle: ' + ' -> '.join(stack + (chart,)))
    _, schema = load_schema(chart)
    if chart in SKIP:
        _cache[chart] = schema
        return schema
    schema = copy.deepcopy(schema)
    props = schema.setdefault('properties', {})
    defs = schema.pop('$defs', {}) or {}
    for name in [n for n in defs if n == 'context' or os.path.isdir(os.path.join(CHARTS, n))]:
        del defs[name]  # generated entries are rebuilt
    # context
    if 'context' in props:
        req = props['context'].get('required')
        props['context'] = {'$ref': '#/$defs/context'}
        if isinstance(req, list):
            props['context']['required'] = req
        defs['context'] = context_def()
    # dependencies
    for key, dep in internal_deps(chart):
        sub = copy.deepcopy(synced(dep, stack + (chart,)))
        sub.pop('$schema', None)
        for n, d in (sub.pop('$defs', {}) or {}).items():
            if n in defs and defs[n] != strip_required(copy.deepcopy(d)):
                sys.exit(f'{chart}: two different definitions named {n} (through {dep})')
            defs[n] = strip_required(copy.deepcopy(d))
        legacy = sub.pop('definitions', None)
        if legacy:  # hand written local definitions of the dependency: keep them reachable
            schema.setdefault('definitions', {}).update({k: v for k, v in legacy.items() if k not in schema.get('definitions', {})})
        defs[dep] = strip_required(sub)
        old = props.get(key) if isinstance(props.get(key), dict) else {}
        new = {'$ref': f'#/$defs/{dep}'}
        for kw in ('title', 'description'):
            if kw in old:
                new[kw] = old[kw]
        props[key] = new
    if defs:
        schema['$defs'] = {k: defs[k] for k in sorted(defs)}
    if a.inline and '$defs' in schema:
        d = schema.pop('$defs')
        schema = resolve(schema, d)
    _cache[chart] = schema
    return schema


def stale_blocks(chart, schema):
    """Schema properties that look like a dependency block but match no dependency key nor values.yaml key."""
    keys = {k for k, _ in internal_deps(chart)}
    try:
        values = yaml.safe_load(open(os.path.join(CHARTS, chart, 'values.yaml'))) or {}
    except Exception:
        values = {}
    res = []
    for k, v in (schema.get('properties') or {}).items():
        if k in keys or k in values or not isinstance(v, dict):
            continue
        sub = v.get('properties') or {}
        if 'context' in sub and ({'project', 'subscription', 'operatorGroup'} & set(sub)):
            res.append(k)
    return res


def dump(schema, old_text):
    m = re.search(r'\n([ \t]+)"', old_text)
    indent = len(m.group(1)) if m else 4
    return json.dumps(schema, indent=indent, ensure_ascii=False) + '\n'


def main():
    charts = a.charts or sorted(c for c in os.listdir(CHARTS) if os.path.isfile(os.path.join(CHARTS, c, 'values.schema.json')))
    changed = 0
    for c in charts:
        old_text, _ = load_schema(c)
        schema = synced(c)
        if c in SKIP:
            print(f'skip    {c} (hand written schema)')
            continue
        new_text = dump(schema, old_text)
        for k in stale_blocks(c, schema):
            print(f'stale   {c}: properties.{k} looks like a dependency block but Chart.yaml has no such dependency')
        if new_text != old_text:
            changed += 1
            if a.check:
                print(f'OUTDATED {c}: run .tools/schema-sync.py {c}')
            else:
                open(os.path.join(CHARTS, c, 'values.schema.json'), 'w').write(new_text)
                print(f'write   {c} ({len(old_text)} -> {len(new_text)} bytes)')
    print(f'{len(charts)} chart(s), {changed} {"outdated" if a.check else "rewritten"}')
    return 1 if (a.check and changed) else 0


if __name__ == '__main__':
    sys.exit(main())
