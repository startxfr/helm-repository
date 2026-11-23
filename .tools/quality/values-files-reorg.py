#!/usr/bin/env python3
"""Put a `## Values files` section at the canonical place of every chart README.

  values-files-reorg.py <tree> [--apply]

<tree> is a CLEAN copy of the repository (git archive / clone), never the shared working copy.
Without --apply: report only. With --apply: rewrite charts/*/README.md and copy it to docs/charts/<name>.md.

Three cases:
  A. README has `## Values files` (after the values dictionary today): move it to the canonical place; the
     `## Other available values` section is dropped when it adds no file, else its bullets are kept at the end
     of the section under `### Other values files`.
  B. README has only `## Other available values`: the section is renamed `## Values files` (same place).
  C. README has neither: a section is generated from the `values-*.yaml` files (and `examples/`).
ArgoCD title: `ArgoCD deployment`, `Deploy this helm chart with ArgoCD`, `Install with ArgoCD`, `Deploy via ArgoCD` -> `Deploy with ArgoCD`;
when that leaves two such headings the first becomes `Step by step deployment with ArgoCD`; an ArgoCD `###` subsection
nested in `Values files` (`### Deploy via ArgoCD ...`) is promoted to `## Deploy with ArgoCD`.
Canonical place: right after `## Default values`, else after the last `## Deploy this helm chart on ...`,
and always before `## Values dictionary`.
"""
import re, sys, pathlib

BASE = "https://raw.githubusercontent.com/startxfr/helm-repository/master/charts"
GENERIC = ("default values for configuration of a startx cluster", "see values.yaml")

def split(text):
    """-> (preamble_lines, [[title, lines]]) ; headings inside code fences are ignored"""
    pre, secs, cur, fence = [], [], None, None
    for line in text.split("\n"):
        fm = re.match(r"^(`{3,}|~{3,})(.*)$", line)
        if fm:
            run = fm.group(1)
            if fence is None:
                fence = run
            elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip():
                fence = None
        m = re.match(r"^## (.+?)\s*$", line) if fence is None and not fm else None
        if m:
            cur = [m.group(1), [line]]
            secs.append(cur)
        elif cur is None:
            pre.append(line)
        else:
            cur[1].append(line)
    return pre, secs

def join(pre, secs):
    return "\n".join(pre + [l for s in secs for l in s[1]])

def find(secs, title):
    for i, s in enumerate(secs):
        if s[0] == title:
            return i
    return -1

def canonical_index(secs):
    i = find(secs, "Default values")
    if i >= 0:
        return i + 1
    last = -1
    for k, s in enumerate(secs):
        if s[0].startswith("Deploy this helm chart on") or s[0].startswith("Quick start on"):
            last = k
    if last >= 0:
        return last + 1
    i = find(secs, "Requirements and guidelines")
    return i + 1 if i >= 0 else 0

def trim_blank(lines):
    while lines and lines[-1].strip() == "":
        lines.pop()
    return lines + [""]

def describe(path):
    for line in path.read_text().split("\n")[:6]:
        if line.startswith("#"):
            t = line.lstrip("# ").strip()
            if t and not t.lower().startswith(GENERIC):
                return t.rstrip(".")
    return "STARTX cluster configuration, see values.yaml for the parameters"

def generate(chart, d):
    files = sorted(p for p in d.glob("values-*.y*ml"))
    out = ["## Values files", "", "Example values files shipped with the chart, to use with `helm install -f <file>` :", ""]
    for p in files:
        out.append(f"- **{p.stem[len('values-'):]}** : {describe(p)} (see [{p.name}]({BASE}/{chart}/{p.name}))")
    ex = d / "examples"
    if ex.is_dir():
        for sub in sorted(x for x in ex.iterdir() if x.is_dir()):
            n = sum(1 for _ in sub.rglob("*") if _.is_file())
            out.append(f"- `examples/{sub.name}/` : {n} example manifest(s) (see the ArgoCD or usage sections)")
    if files:
        out += ["", "```bash", f"helm install {chart} startx/{chart} -f {BASE}/{chart}/{files[0].name}", "```"]
    return out + [""]

OLD_ARGO = ("ArgoCD deployment", "Deploy this helm chart with ArgoCD", "Install with ArgoCD", "Deploy via ArgoCD")

def argocd_titles(secs):
    # promote an ArgoCD ### subsection nested in Values files
    iv = find(secs, "Values files")
    if iv >= 0 and find(secs, "Deploy with ArgoCD") < 0:
        lines = secs[iv][1]; fence = None
        for i, l in enumerate(lines):
            fm = re.match(r"^(`{3,}|~{3,})(.*)$", l)
            if fm:
                r = fm.group(1)
                if fence is None: fence = r
                elif r[0] == fence[0] and len(r) >= len(fence) and not fm.group(2).strip(): fence = None
            elif fence is None and re.match(r"^### Deploy via ArgoCD", l):
                moved = ["## Deploy with ArgoCD"] + lines[i + 1:]
                secs[iv][1] = trim_blank(lines[:i])
                secs.insert(iv + 1, ["Deploy with ArgoCD", moved])
                break
    for sec in secs:
        if sec[0] in OLD_ARGO:
            sec[0] = "Deploy with ArgoCD"; sec[1][0] = "## Deploy with ArgoCD"
    idx = [k for k, sec in enumerate(secs) if sec[0] == "Deploy with ArgoCD"]
    if len(idx) > 1:
        k = idx[0]
        secs[k][0] = "Step by step deployment with ArgoCD"; secs[k][1][0] = "## Step by step deployment with ArgoCD"

def process(chart, d):
    rd = d / "README.md"
    text = rd.read_text()
    pre, secs = split(text)
    iv, io = find(secs, "Values files"), find(secs, "Other available values")
    note = ""
    if iv >= 0:
        sec = secs.pop(iv)
        if io > iv:
            io -= 1
        if io >= 0:
            other = secs.pop(io)
            have = set(re.findall(r"values-[\w.\-]+\.ya?ml", "\n".join(sec[1])))
            extra = [l for l in other[1][1:] if re.search(r"values-[\w.\-*]+\.ya?ml", l) and not set(re.findall(r"values-[\w.\-]+\.ya?ml", l)) <= have and "more `values" not in l]
            if extra:
                sec[1] = trim_blank(sec[1]) + ["### Other values files", ""] + extra + [""]
                note = "merged %d bullet(s) of Other available values" % len(extra)
            else:
                note = "Other available values dropped (no file added)"
        secs.insert(canonical_index(secs), [sec[0], trim_blank(sec[1])])
        case = "A move"
    elif io >= 0:
        sec = secs.pop(io)
        sec[1][0] = "## Values files"
        sec[0] = "Values files"
        secs.insert(canonical_index(secs), [sec[0], trim_blank(sec[1])])
        case = "B rename+move"
    else:
        sec = generate(chart, d)
        secs.insert(canonical_index(secs), ["Values files", sec])
        case = "C generate"
    argocd_titles(secs)
    new = join(pre, secs)
    # coverage: every values-*.yaml named, or matched by a glob written in the section
    i = find(split(new)[1], "Values files")
    body = "\n".join(split(new)[1][i][1])
    names = re.findall(r"values-[\w.\-*]+\.ya?ml", body)
    globs = [n for n in names if "*" in n]
    uncovered = []
    for p in sorted(d.glob("values-*.y*ml")):
        if p.name in body or any(p.match(g) for g in globs):
            continue
        uncovered.append(p.name)
    return case, note, new, uncovered

def main():
    tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv
    totals = {}
    for d in sorted((tree / "charts").iterdir()):
        if not (d / "README.md").is_file():
            continue
        case, note, new, unc = process(d.name, d)
        totals[case] = totals.get(case, 0) + 1
        print("%-32s %-11s uncovered=%-3d %s" % (d.name, case, len(unc), note))
        if apply and new != (d / "README.md").read_text():
            (d / "README.md").write_text(new)
            doc = tree / "docs" / "charts" / (d.name + ".md")
            if doc.exists():
                doc.write_text(new)
    print("TOTAL", totals)

main()
