#!/usr/bin/env python3
"""Profile of the values-*.yaml files of a chart: enabled blocks, list sizes, identical files. Read only.
   vf-profile.py <chart dir> [--all]"""
import sys, pathlib, hashlib, subprocess, json, re
d = pathlib.Path(sys.argv[1])
try:
    import yaml
except ImportError:
    yaml = None
def load(p):
    if yaml:
        return yaml.safe_load(p.read_text()) or {}
    return json.loads(subprocess.run(["yq", "e", "-o=json", ".", str(p)], capture_output=True, text=True).stdout or "{}")
def prof(v):
    out = []
    if not isinstance(v, dict): return ""
    for k, x in v.items():
        if k == "context": continue
        if isinstance(x, dict):
            en = x.get("enabled")
            lst = x.get("list")
            if en is True:
                out.append(k + (("[%d]" % len(lst)) if isinstance(lst, list) and lst else ""))
    return ",".join(out) or "(nothing enabled)"
groups = {}
for p in sorted(d.glob("values-*.y*ml")):
    t = re.sub(r"\s+", " ", p.read_text()).strip()
    ctx = load(p).get("context", {}) if isinstance(load(p), dict) else {}
    groups.setdefault(hashlib.sha1(t.encode()).hexdigest()[:8], []).append(p.name)
    if "--all" in sys.argv:
        print("%-46s %-28s %s" % (p.name, str(ctx.get("cluster", "")) + "/" + str(ctx.get("environment", "")), prof(load(p))[:110]))
print("identical groups:", [g for g in groups.values() if len(g) > 1])
