#!/usr/bin/env python3
"""README conventions of the charts (docs/contribute-conventions.md, section 5.2). Report only.

  readme-conventions.py [chart ...]

Checks, for charts/<name>/README.md:
  title      a title that must not be used any more (ArgoCD deployment, Other available values, Values ...)
  duplicate  the same `##` title twice
  order      the known `##` sections are not in the order of the conventions
  missing    a mandatory section is absent (Requirements and guidelines, Deploy this helm chart on openshift,
             Default values (or values.yaml described in Values files), Values files, History; Deploy with ArgoCD for cluster-* charts and charts with
             examples/argocd/; Usage examples for chaos-*) or `## History` is not the last section
  coverage   a values-*.yaml file of the chart is neither named in `## Values files` nor matched by a glob written there

Prints one `WARN <chart>: <rule>: <detail>` line per finding and a summary. Exit code 0, or 1 with
CI_CONVENTIONS_STRICT=true when something was found. Charts listed in EXEMPT_LAYOUT skip the order and missing rules.
"""
import fnmatch, os, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parents[2]

# canonical order of the known `##` titles; chart-specific sections are free and ignored by the order rule
RANK = {
    "Requirements and guidelines": 1, "What the chart renders": 2,
    "Deploy this helm chart on openshift": 3, "Deploy this helm chart on kubernetes": 4,
    "Default values": 5, "Values files": 6, "Values dictionary": 7,
    "Procedures": 9, "Usage examples": 10, "Deploy with ArgoCD": 11, "External secrets": 12, "History": 13,
}
# deprecated title -> replacement
DEPRECATED = {
    "ArgoCD deployment": "Deploy with ArgoCD", "Deploy this helm chart with ArgoCD": "Deploy with ArgoCD",
    "Install with ArgoCD": "Deploy with ArgoCD", "Deploy via ArgoCD": "Deploy with ArgoCD",
    "Values": "Values dictionary", "Values overview": "Values dictionary",
    "Resources rendered": "What the chart renders",
    "Other available values": "Values files", "Others values availables": "Values files",
}
MANDATORY = ["Requirements and guidelines", "Deploy this helm chart on openshift", "Default values", "Values files", "History"]
# standalone documentation: only the title, duplicate, Values files and History rules apply (see Exceptions)
EXEMPT_LAYOUT = {"unifai"}


def headings(text):
    """[(title, body_lines)] of the `## ` sections; headings inside code fences are ignored"""
    secs, cur, fence, comment = [], None, None, False
    for line in text.split("\n"):
        # an HTML comment hides everything up to the line holding `-->`, code fences included (they may close with `-->`)
        if comment:
            comment = "-->" not in line
            if cur is not None:
                cur[1].append(line)
            continue
        if fence is None and "<!--" in line and "-->" not in line.split("<!--", 1)[1]:
            comment = True
            if cur is not None:
                cur[1].append(line)
            continue
        fm = re.match(r"^(`{3,}|~{3,})(.*)$", line)
        if fm:
            run = fm.group(1)
            if fence is None:
                fence = run
            elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip():
                fence = None
        m = re.match(r"^## (.+?)\s*$", line) if fence is None and not fm else None
        if m:
            cur = (m.group(1), [])
            secs.append(cur)
        elif cur is not None:
            cur[1].append(line)
    return secs


def check(chart, d):
    out = []
    readme = d / "README.md"
    if not readme.is_file():
        return [("missing", "README.md is absent")]
    secs = headings(readme.read_text())
    titles = [t for t, _ in secs]
    exempt = chart in EXEMPT_LAYOUT

    for t in titles:
        if t in DEPRECATED:
            out.append(("title", "`## %s` must be `## %s`" % (t, DEPRECATED[t])))
    for t in sorted({t for t in titles if titles.count(t) > 1}):
        out.append(("duplicate", "`## %s` appears %d times" % (t, titles.count(t))))

    if not exempt:
        seq = [(DEPRECATED.get(t, t), t) for t in titles]
        seq = [(RANK[c], t) for c, t in seq if c in RANK]
        top_rank, top_title = 0, ""
        for r, t in seq:
            if r < top_rank:
                out.append(("order", "`## %s` must come before `## %s`" % (t, top_title)))
            else:
                top_rank, top_title = r, t
        canon = {DEPRECATED.get(t, t) for t in titles}
        need = list(MANDATORY)
        if chart.startswith("cluster-") or (d / "examples" / "argocd").is_dir():
            need.append("Deploy with ArgoCD")
        if chart.startswith("chaos-"):
            need.append("Usage examples")
        vf = "\n".join("\n".join(b) for t, b in secs if t == "Values files")
        for n in need:
            if n == "Default values" and "values.yaml" in vf:
                continue  # the Values files section describes values.yaml itself (example-* charts)
            if n not in canon:
                out.append(("missing", "mandatory section `## %s` is absent" % n))
    elif "Values files" not in titles:
        out.append(("missing", "mandatory section `## Values files` is absent"))
    if titles and titles[-1] != "History":
        out.append(("missing", "`## History` must be the last section (last is `## %s`)" % titles[-1]))

    body = "\n".join("\n".join(b) for t, b in secs if t == "Values files")
    globs = [g for g in re.findall(r"values-[\w.\-*?]+\.ya?ml", body) if "*" in g or "?" in g]
    miss = [p.name for p in sorted(d.glob("values-*.y*ml"))
            if p.name not in body and not any(fnmatch.fnmatch(p.name, g) for g in globs)]
    if miss and "Values files" in titles:
        out.append(("coverage", "%d values file(s) not described in `## Values files`: %s%s"
                    % (len(miss), ", ".join(miss[:4]), ", ..." if len(miss) > 4 else "")))
    return out


def main():
    charts = sys.argv[1:] or sorted(p.name for p in (ROOT / "charts").iterdir() if p.is_dir())
    counts, bad = {}, set()
    for c in charts:
        for rule, msg in check(c, ROOT / "charts" / c):
            print("WARN %s: %s: %s" % (c, rule, msg))
            counts[rule] = counts.get(rule, 0) + 1
            bad.add(c)
    if not counts:
        print("ok   conventions: %d README follow the section conventions" % len(charts))
        return 0
    print("conventions: %d warning(s) in %d of %d chart(s) (%s), report only" % (
        sum(counts.values()), len(bad), len(charts), ", ".join("%s %d" % kv for kv in sorted(counts.items()))))
    return 1 if os.environ.get("CI_CONVENTIONS_STRICT") == "true" else 0


sys.exit(main())
