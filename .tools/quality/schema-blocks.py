#!/usr/bin/env python3
"""schema-blocks.py <before tree> <after tree> : every `operator` block that Helm would validate (chart values.yaml, every values file, inline values of the ArgoCD
examples and of the values-app files, each coalesced as Helm does: operator defaults < parent values.yaml < valueFiles < inline) against the operator schema
before and after. Prints the blocks that pass before and fail after, those that fail before, and the counts."""
import sys, os, glob, json, copy, yaml, warnings
warnings.filterwarnings("ignore")
import jsonschema
bt, at = sys.argv[1:3]
def merge(a, b):
    out = copy.deepcopy(a)
    for k, v in (b or {}).items():
        if v is None: out.pop(k, None)
        elif isinstance(v, dict) and isinstance(out.get(k), dict): out[k] = merge(out[k], v)
        else: out[k] = copy.deepcopy(v)
    return out
def load(p):
    try: return yaml.safe_load(open(p)) or {}
    except Exception: return None
sch = {}
for n, t in (("before", bt), ("after", at)):
    s = json.load(open(os.path.join(t, "charts/operator/values.schema.json")))
    sch[n] = jsonschema.validators.validator_for(s)(s)
opdef = load(os.path.join(bt, "charts/operator/values.yaml"))
def errs(n, block):
    return sorted("%s: %s" % ("/".join(map(str, e.path)), e.message[:70]) for e in sch[n].iter_errors(block))
total = 0; passb_failn = []; failb = []; failboth = 0; srcs = {}
def check(origin, block):
    global total, failboth
    total += 1
    full = merge(opdef, block)
    eb, ea = errs("before", full), errs("after", full)
    if not eb and ea: passb_failn.append((origin, ea))
    if eb: failb.append((origin, eb, ea))
    srcs[origin.split(":")[0].split("/")[0]] = srcs.get(origin.split(":")[0].split("/")[0], 0) + 1
dependents = {}
for f in sorted(glob.glob(os.path.join(bt, "charts/*/Chart.yaml"))):
    c = yaml.safe_load(open(f)); chart = c["name"]
    al = [(d.get("alias") or d["name"]) for d in (c.get("dependencies") or []) if d.get("name") == "operator"]
    if al: dependents[chart] = al
print("charts depending on operator:", len(dependents), "aliases:", sum(len(v) for v in dependents.values()))
for chart, aliases in dependents.items():
    d = os.path.join(bt, "charts", chart)
    base = load(os.path.join(d, "values.yaml")) or {}
    files = {os.path.basename(p): load(p) for p in sorted(glob.glob(d + "/values-*.y*ml"))}
    for al in aliases:
        check("%s:values.yaml[%s]" % (chart, al), base.get(al, {}))
        for fn, v in files.items():
            if v is None: continue
            check("%s:%s[%s]" % (chart, fn, al), merge(base, v).get(al, {}))
    def chain(valuefiles, inline):
        v = base
        for vf in valuefiles or []:
            w = files.get(vf)
            if w: v = merge(v, w)
        return merge(v, inline or {})
    for f in sorted(glob.glob(d + "/examples/argocd/application-*.yaml")):
        a = yaml.safe_load(open(f)); h = (a.get("spec", {}).get("source", {}) or {}).get("helm", {}) or {}
        inline = yaml.safe_load(h.get("values", "") or "") or {}
        v = chain(h.get("valueFiles"), inline)
        for al in aliases: check("%s:examples/%s[%s]" % (chart, os.path.basename(f), al), v.get(al, {}))
    vf = os.path.join(bt, "charts/cluster-argocd/values-app-%s.yaml" % chart)
    if os.path.exists(vf):
        for app in (load(vf) or {}).get("application", {}).get("list", []) or []:
            h = yaml.safe_load(app["helm"]) if isinstance(app.get("helm"), str) else (app.get("helm") or {})
            inline = yaml.safe_load(h.get("values", "") or "") if isinstance(h.get("values"), str) else (h.get("values") or {})
            v = chain(h.get("valueFiles"), inline)
            for al in aliases: check("values-app-%s:%s[%s]" % (chart, app.get("name"), al), v.get(al, {}))
print("blocks validated:", total, "by source kind:", {k: v for k, v in sorted(srcs.items())} if len(srcs) < 6 else "%d origins" % len(srcs))
print("PASS before and FAIL after:", len(passb_failn))
for o, e in passb_failn[:20]: print("  ", o, e[:2])
print("FAIL before:", len(failb), "(of which still failing after: %d)" % sum(1 for _, _, ea in failb if ea))
for o, eb, ea in failb[:12]: print("  ", o, "| before:", eb[:1], "| after:", ea[:1])
