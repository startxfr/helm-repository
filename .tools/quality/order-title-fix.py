#!/usr/bin/env python3
"""Rename deprecated `##` titles and put the known sections in the canonical order of every chart README.

  order-title-fix.py <tree> [--apply]

<tree> is a CLEAN copy of the repository (git archive / clone), never the shared working copy.
Without --apply: report only. With --apply: rewrite charts/*/README.md and copy it to docs/charts/<name>.md
(only when that copy was identical to the README before).
Rules (same tables as .github/scripts/readme-conventions.py, imported from it):
  title  Values, Values overview -> Values dictionary; Resources rendered -> What the chart renders
         (ArgoCD and Other available values titles are handled by values-files-reorg.py)
  order  the sections that have a rank are put back in rank order; they only exchange the slots they occupy,
         sections without rank (chart specific) keep their place; a chart with a duplicate title is left alone.
Idempotent. Sections are moved verbatim (headings and code fences are located like the checker does).
"""
import importlib.util, pathlib, re, sys

tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv
spec = importlib.util.spec_from_file_location("rc", tree / ".github/scripts/readme-conventions.py")
src = (tree / ".github/scripts/readme-conventions.py").read_text().replace("sys.exit(main())", "")
rc = type(sys)("rc"); rc.__file__ = str(tree / ".github/scripts/readme-conventions.py"); exec(compile(src, "rc", "exec"), rc.__dict__)
RANK, DEP = rc.RANK, rc.DEPRECATED
RENAME = {k: v for k, v in DEP.items() if k in ("Values", "Values overview", "Resources rendered")}

def split(text):
    """-> (preamble_lines, [[title, lines]]) with the same comment/fence handling as the checker"""
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
                if fence is None:
                    fence = run
                elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip():
                    fence = None
            elif fence is None:
                hit = re.match(r"^## (.+?)\s*$", line)
        if hit:
            cur = [hit.group(1), [line]]; secs.append(cur)
        elif cur is None:
            pre.append(line)
        else:
            cur[1].append(line)
    return pre, secs

def tails(secs):
    """number of trailing blank lines of every section (the last one counts the file terminator as blank too)"""
    out = []
    for t, lines in secs:
        n = 0
        while n < len(lines) and lines[len(lines) - 1 - n] == "":
            n += 1
        out.append(n)
    return out

def build(pre, secs, tail, last_tail):
    out = list(pre)
    for i, (t, lines) in enumerate(secs):
        body = list(lines)
        while body and body[-1] == "":
            body.pop()
        out += body + [""] * (last_tail if i == len(secs) - 1 else max(tail[t], 1))
    return "\n".join(out)

def process(chart, text):
    pre, secs = split(text)
    notes = []
    for s in secs:
        if s[0] in RENAME:
            notes.append("title %s -> %s" % (s[0], RENAME[s[0]]))
            s[1][0] = "## " + RENAME[s[0]]; s[0] = RENAME[s[0]]
    tl = tails(secs)
    tail = {s[0]: n for s, n in zip(secs, tl)}
    last_tail = tl[-1] if tl else 0
    titles = [s[0] for s in secs]
    if len(set(titles)) != len(titles) or chart in rc.EXEMPT_LAYOUT:
        return text, (notes + ["left alone (duplicate title or exempt layout)"]) if notes else notes, True
    slots = [i for i, s in enumerate(secs) if s[0] in RANK]
    ordered = sorted((secs[i] for i in slots), key=lambda s: RANK[s[0]])
    if [secs[i][0] for i in slots] != [s[0] for s in ordered]:
        notes.append("order " + " | ".join(s[0] for s in ordered))
        for i, s in zip(slots, ordered):
            secs[i] = s
    if not any(n.startswith("order") for n in notes) and not any(n.startswith("title") for n in notes):
        return text, notes, False
    new = build(pre, secs, tail, last_tail)
    return new, notes, False

changed = 0
for d in sorted((tree / "charts").iterdir()):
    rd = d / "README.md"
    if not rd.is_file():
        continue
    old = rd.read_text()
    new, notes, skipped = process(d.name, old)
    if skipped and notes:
        print("%-32s %s" % (d.name, "; ".join(notes)))
    if new == old:
        continue
    changed += 1
    print("%-32s %s" % (d.name, "; ".join(notes)))
    if apply:
        doc = tree / "docs" / "charts" / (d.name + ".md")
        same = doc.exists() and doc.read_text() == old
        rd.write_text(new)
        if same:
            doc.write_text(new)
        elif doc.exists():
            print("   WARNING docs copy differs from the README before the change: not touched")
print("changed", changed)
