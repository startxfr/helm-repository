#!/usr/bin/env python3
"""apps-waves.py <tree> <chart> : render every Application of charts/<chart>/examples/argocd and of values-app-<chart>.yaml with its valueFiles + inline values
(helm template), list the resources of each wave and check: renders, files exist, waves are disjoint, only the expected kinds per wave."""
import sys, os, subprocess, tempfile, yaml, glob, collections
tree, chart = sys.argv[1:3]
d = os.path.join(tree, "charts", chart)
def render(valuefiles, values):
    with tempfile.NamedTemporaryFile("w", suffix=".yaml", delete=False) as f:
        f.write(values or ""); tmp = f.name
    cmd = ["helm", "template", "r", d]
    for v in valuefiles:
        p = os.path.join(d, v)
        if not os.path.exists(p): return None, "valueFile missing: " + v
        cmd += ["-f", p]
    cmd += ["-f", tmp]
    r = subprocess.run(cmd, capture_output=True, text=True); os.unlink(tmp)
    if r.returncode: return None, r.stderr.strip().splitlines()[-1][:200]
    res = set()
    for doc in yaml.safe_load_all(r.stdout):
        if doc: res.add("%s/%s" % (doc.get("kind"), (doc.get("metadata") or {}).get("name")))
    return res, None
sets = collections.OrderedDict()
print("== examples/argocd")
for f in sorted(glob.glob(os.path.join(d, "examples/argocd/application-*.yaml"))):
    a = yaml.safe_load(open(f)); h = a["spec"]["source"].get("helm", {})
    res, err = render(h.get("valueFiles", []), h.get("values", ""))
    print("%-34s files=%s -> %s" % (os.path.basename(f), h.get("valueFiles"), ("%d resources" % len(res)) if res is not None else "ERROR " + err))
    if res is not None: sets[("ex", os.path.basename(f))] = res
print("== values-app-%s.yaml" % chart)
va = yaml.safe_load(open(os.path.join(tree, "charts/cluster-argocd", "values-app-%s.yaml" % chart)))
for a in va["application"]["list"]:
    h = yaml.safe_load(a["helm"]) if isinstance(a.get("helm"), str) else a.get("helm", {})
    res, err = render(h.get("valueFiles", []), h.get("values", ""))
    print("%-34s files=%s -> %s" % (a["name"], h.get("valueFiles"), ("%d resources" % len(res)) if res is not None else "ERROR " + err))
    if res is not None: sets[("va", a["name"])] = res
for grp in ("ex", "va"):
    items = [(k[1], v) for k, v in sets.items() if k[0] == grp]
    for i in range(len(items)):
        for j in range(i + 1, len(items)):
            inter = items[i][1] & items[j][1]
            if inter: print("OVERLAP %s: %s and %s share %s" % (grp, items[i][0], items[j][0], sorted(inter)[:5]))
    for n, v in items: print("  %s %-34s %s" % (grp, n, ", ".join(sorted({x.split('/')[0] for x in v}))))
