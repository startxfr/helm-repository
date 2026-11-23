#!/usr/bin/env python3
"""Prototype: check each chart README against the canonical layout proposed in contribute-conventions.md."""
import os, re, sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
# (canonical heading, aliases, mandatory)
CANON = [
    ("Requirements and guidelines", [], True),
    ("What the chart renders", ["Resources rendered"], False),
    ("Deploy this helm chart on openshift", [], True),
    ("Deploy this helm chart on kubernetes", [], False),
    ("Default values", [], True),
    ("Other available values", [], True),
    ("Values dictionary", ["Values", "Values overview"], False),
    ("Values files", [], False),
    ("*feature*", [], False),
    ("Procedures", [], False),
    ("Usage examples", [], False),
    ("Deploy with ArgoCD", ["ArgoCD deployment", "Deploy this helm chart with ArgoCD", "Install with ArgoCD"], False),
    ("External secrets", [], False),
    ("History", [], True),
]
EXEMPT = {"unifai"}
alias = {}
for i, (name, al, _) in enumerate(CANON):
    alias[name] = i
    for a in al:
        alias[a] = i
FEATURE = [i for i, c in enumerate(CANON) if c[0] == "*feature*"][0]

stats = {"conform": [], "rename": [], "reorder": [], "missing": []}
for c in sorted(os.listdir(f"{ROOT}/charts")):
    p = f"{ROOT}/charts/{c}/README.md"
    if c in EXEMPT or not os.path.isfile(p):
        continue
    heads = [l[3:].strip() for l in open(p) if l.startswith("## ")]
    idx = [alias.get(h, FEATURE) for h in heads]
    renames = [h for h in heads if h in alias and h != CANON[alias[h]][0]]
    probs = []
    if idx != sorted(idx):
        probs.append("order")
    if len([i for i in idx if i == alias["Deploy with ArgoCD"]]) > 1:
        probs.append("duplicate ArgoCD section")
    mand = [n for n, _, m in CANON if m]
    if c.startswith("chaos-"):
        mand.append("Usage examples")
    if os.path.isdir(f"{ROOT}/charts/{c}/examples/argocd") or c.startswith("cluster-"):
        mand.append("Deploy with ArgoCD")
    missing = [n for n in mand if alias[n] not in idx]
    # "Values files" stands for "Default values" in the example-* family
    if "Default values" in missing and alias["Values files"] in idx:
        missing.remove("Default values")
    if missing:
        probs.append("missing: " + ", ".join(missing))
    if heads and heads[-1] != "History":
        probs.append("History not last")
    if probs:
        bucket = "missing" if missing else "reorder"
        stats[bucket].append(f"{c} ({'; '.join(probs)}{'; rename: ' + ', '.join(renames) if renames else ''})")
    elif renames:
        stats["rename"].append(f"{c} ({', '.join(renames)})")
    else:
        stats["conform"].append(c)

for k, v in stats.items():
    print(f"== {k}: {len(v)}")
    if k != "conform":
        for x in v:
            print("   ", x)
