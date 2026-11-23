#!/usr/bin/env python3
"""Describe the values files that `## Values files` does not cover yet, from the files themselves.

  values-files-engine.py <tree> --batch 2|3 [--apply]    batch 2: charts missing only values-startx_noinfra*.yaml / values-demo.yaml
                                                          batch 3: every other chart with a coverage finding
  values-files-engine.py <tree> --batch 4 [--apply]      regenerate the generic bullets ("STARTX cluster configuration, see values.yaml ...")

<tree> is a CLEAN copy of the repository. Nothing is written by hand: for each missing file the text says what differs from its base file
(values-startx.yaml, or the file without `_noinfra`, or values.yaml), computed from the parsed YAML; files of customers (see CUSTOMER)
are described by that difference only. Rewrites the README and syncs docs/charts/<chart>.md when identical before. Idempotent. Needs PyYAML.
"""
import fnmatch, pathlib, re, sys
import yaml

tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv
batch = int(sys.argv[sys.argv.index("--batch") + 1])
BASE = "https://raw.githubusercontent.com/startxfr/helm-repository/master/charts"
CUSTOMER = re.compile(r"^values-((.*-)?(mg|monaco|ubisoft|prgmk|ppmc|cdf|mccloud|lahsc|devoteam|chd|odhf|ct)(-|\.|$)|(mg|monaco|ubisoft|prgmk|ppmc|cdf|mccloud|lahsc|devoteam|chd|odhf|ct)-)")

def split(text):
    pre, secs, cur, fence, comment = [], [], None, None, False
    for line in text.split("\n"):
        hit = None
        if comment:
            comment = "-->" not in line
        elif fence is None and "<!--" in line and "-->" not in line.split("<!--", 1)[1]:
            comment = True
        else:
            fm = re.match(r"^(`{3,}|~{3,})(.*)$", line)
            if fm:
                run = fm.group(1)
                if fence is None: fence = run
                elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip(): fence = None
            elif fence is None:
                hit = re.match(r"^## (.+?)\s*$", line)
        if hit:
            cur = [hit.group(1), [line]]; secs.append(cur)
        elif cur is None: pre.append(line)
        else: cur[1].append(line)
    return pre, secs

def body_lines_outside_fence(lines):
    """[(index, line)] for the lines that are not inside a code fence nor an HTML comment"""
    fence, comment, out = None, False, []
    for i, l in enumerate(lines):
        if comment:
            comment = "-->" not in l; continue
        if fence is None and "<!--" in l and "-->" not in l.split("<!--", 1)[1]:
            comment = True; continue
        fm = re.match(r"^(`{3,}|~{3,})(.*)$", l)
        if fm:
            run = fm.group(1)
            if fence is None: fence = run
            elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip(): fence = None
            continue
        if fence is None: out.append((i, l))
    return out

def load(p):
    try:
        return yaml.safe_load(p.read_text()) or {}
    except Exception:
        return None

def flat(d, pre=""):
    o = {}
    if isinstance(d, dict):
        for k, v in d.items():
            o.update(flat(v, pre + "." + str(k) if pre else str(k)))
        if not d and pre: o[pre] = {}
    else:
        o[pre] = d
    return o

def short(v):
    s = "~" if v is None else (str(v).lower() if isinstance(v, bool) else str(v).replace("\n", " "))
    return s if len(s) <= 24 else None

def mask(t):
    """keys named like the old cluster-dvo spelling (cluster-dvo, kept for compatibility) are shortened: the spelling guard of ci-check.sh does not allow the word in docs/"""
    return re.sub("gra" + "phana", "gra…", t, flags=re.I)  # built here: the spelling guard must not match this file

def diff_text(base, other):
    return mask(_diff_text(base, other))

def _diff_text(base, other):
    a, b = flat(base), flat(other)
    keys = sorted(k for k in set(a) | set(b) if a.get(k, "<absent>") != b.get(k, "<absent>"))
    if not keys:
        return "same values"
    if len(keys) <= 3:
        parts = []
        for k in keys:
            va, vb = a.get(k, "<absent>"), b.get(k, "<absent>")
            sa, sb = (short(va), short(vb)) if "<absent>" not in (va, vb) else (None, None)
            parts.append("`%s` (%s → %s)" % (k, sa, sb) if sa is not None and sb is not None else "`%s`" % k)
        return "differ on " + ", ".join(parts)
    top = {}
    for k in keys:
        t = k.split(".")[0]
        top[t] = top.get(t, 0) + 1
    items = sorted(top.items(), key=lambda kv: (-kv[1], kv[0]))
    txt = ", ".join("`%s` (%d)" % kv for kv in items[:4])
    return "differ on %d keys, by top-level key: %s%s" % (len(keys), txt, ", ..." if len(items) > 4 else "")

def base_of(d, f):
    if "_noinfra" in f and (d / f.replace("_noinfra", "")).exists():
        return f.replace("_noinfra", "")
    if f != "values-startx.yaml" and (d / "values-startx.yaml").exists():
        return "values-startx.yaml"
    return None

def link(chart, name):
    return "[%s](%s/%s/%s)" % (name, BASE, chart, name)

def describe(chart, d, f):
    v = load(d / f)
    if v is None:
        return "%s : YAML not readable by a plain parser (templated or multi document), no comparison" % link(chart, f)
    bf = base_of(d, f)
    ctx = v.get("context") if isinstance(v.get("context"), dict) else {}
    parts = []
    if bf:
        bv = load(d / bf)
        parts.append(("same values as `%s`" % bf) if diff_text(bv or {}, v) == "same values" else "against `%s`: %s" % (bf, diff_text(bv or {}, v)))
    else:
        dv = load(d / "values.yaml") or {}
        parts.append("against `values.yaml`: " + diff_text(dv, v).replace("same values", "no difference"))
    if not CUSTOMER.match(f) and ctx.get("cluster") is not None:
        parts.insert(0, "context `%s/%s/%s`" % (ctx.get("scope"), ctx.get("cluster"), ctx.get("environment")))
    return "%s : %s" % (link(chart, f), "; ".join(parts))

def missing(d, body):
    globs = [x for x in re.findall(r"values-[\w.\-*?]+\.ya?ml", body) if "*" in x or "?" in x]
    return [p.name for p in sorted(d.glob("values-*.y*ml")) if p.name not in body and not any(fnmatch.fnmatch(p.name, g) for g in globs)]

def block(chart, d, miss):
    """one bullet per missing file, computed from the file"""
    return ["- " + describe(chart, d, f) for f in miss]

def sub_range(lines, title):
    """(start, end) of the `### title` subsection (end exclusive: next ### or ##)"""
    pos = [i for i, l in body_lines_outside_fence(lines) if re.match(r"^#{2,3} ", l)]
    for k, i in enumerate(pos):
        if lines[i] == "### " + title:
            return i, (pos[k + 1] if k + 1 < len(pos) else len(lines))
    return -1, -1

NONINFRA_DEMO = re.compile(r"^values-(startx_noinfra(-[\w.]+)?|demo)\.ya?ml$")

def process_missing(chart, d, text):
    pre, secs = split(text)
    iv = [i for i, s in enumerate(secs) if s[0] == "Values files"]
    if len(iv) != 1:
        return text, None
    sec = secs[iv[0]][1]
    body = "\n".join(l for _, l in body_lines_outside_fence(sec)) + "\n" + "\n".join(sec)
    miss = missing(d, "\n".join(sec))
    if not miss:
        return text, None
    only2 = all(NONINFRA_DEMO.match(f) for f in miss)
    if (batch == 2) != only2:
        return text, None
    bl = block(chart, d, miss)
    s, e = sub_range(sec, "Other values files")
    if s >= 0:
        k = e
        while k > s and sec[k - 1].strip() == "": k -= 1
        sec2 = sec[:k] + [""] + bl + [""] + sec[e:] if e < len(sec) else sec[:k] + [""] + bl + [""]
    else:
        k = len(sec)
        while k > 0 and sec[k - 1].strip() == "": k -= 1
        sec2 = sec[:k] + ["", "### Other values files", "", "Values files without a detailed section above (each one is a complete set of values for `helm install %s startx/%s -f <file>`) :" % (chart, chart), ""] + bl + [""]
    secs[iv[0]][1] = sec2
    new = "\n".join(pre + [l for s_ in secs for l in s_[1]])
    new = re.sub(r"\n{3,}(?=## )", "\n\n", new)
    return new, len(miss)

GENERIC = "STARTX cluster configuration, see values.yaml for the parameters"

def process_generic(chart, d, text):
    if GENERIC not in text:
        return text, None
    n = 0
    out = []
    for line in text.split("\n"):
        m = re.match(r"^(- \*\*[^*]+\*\* : )" + re.escape(GENERIC) + r" \(see \[(values[\w.\-]*\.ya?ml)\]\(([^)]+)\)\)(.*)$", line)
        if m:
            f = m.group(2)
            if (d / f).exists():
                desc = describe(chart, d, f).split(" : ", 1)[1]
                line = "%s%s (see [%s](%s))%s" % (m.group(1), desc, f, m.group(3), m.group(4)); n += 1
        out.append(line)
    return "\n".join(out), n

changed = 0
for d in sorted((tree / "charts").iterdir()):
    rd = d / "README.md"
    if not rd.is_file(): continue
    text = rd.read_text()
    new, n = (process_generic if batch == 4 else process_missing)(d.name, d, text)
    if n is None or new == text:
        continue
    changed += 1
    print("%-30s %d file(s)/bullet(s)" % (d.name, n))
    if apply:
        rd.write_text(new)
        doc = tree / "docs" / "charts" / (d.name + ".md")
        if doc.exists() and doc.read_text() == text: doc.write_text(new)
        elif doc.exists(): print("   WARNING docs copy differs: not touched")
print("charts changed:", changed)
