#!/usr/bin/env python3
"""Maintain the active History table of a chart README.

Used by .tools/cli (readmeHistoryUpdate) at release time and by
`sx-helm history-prune-all` for bulk migration. Standard library only.

Retention rule (applied to the active table of the `## History` section,
which is the last table of that section):
  1. rows without a valid X.Y.Z release are dropped, duplicated versions keep
     their last occurrence;
  2. for every branch (X.Y) other than the current one, only the last row is kept;
  3. for the current branch, keep: the first row, the N most recent rows, the
     versions referenced as dependencies by any chart, and the non generic
     rows (de-duplicated by description, last occurrence wins).
"""
import argparse
import re
import sys

SEMVER = re.compile(r"^\d+\.\d+\.\d+$")


def cells(line):
    parts = [c.strip() for c in line.strip().strip("|").split("|")]
    return parts


def is_row(line):
    return line.startswith("|") and len(cells(line)) >= 3


def is_separator(line):
    return line.startswith("|") and re.match(r"^\|[\s:|-]+\|?\s*$", line) is not None


def is_header(line):
    return line.startswith("|") and cells(line)[0].lower() == "release"


def blocks(lines, start, end):
    """Return contiguous (first, last_exclusive) blocks of table lines."""
    res, i = [], start
    while i < end:
        if lines[i].startswith("|"):
            j = i
            while j < end and lines[j].startswith("|"):
                j += 1
            res.append((i, j))
            i = j
        else:
            i += 1
    return res


def branch(version):
    return ".".join(version.split(".")[:2])


def prune(rows, args, deps):
    """rows: list of (version, date, desc, raw). Return the kept rows."""
    generic = re.compile(args.generic_regex, re.I)
    # 1. drop invalid rows, de-duplicate versions (last occurrence wins)
    rows = [r for r in rows if SEMVER.match(r[0])]
    last_idx = {}
    for i, r in enumerate(rows):
        last_idx[r[0]] = i
    rows = [r for i, r in enumerate(rows) if last_idx[r[0]] == i]
    keep = set()
    # 2. last row of every other branch
    last_of_branch = {}
    for i, r in enumerate(rows):
        last_of_branch[branch(r[0])] = i
    for b, i in last_of_branch.items():
        if b != args.branch:
            keep.add(i)
    # 3. current branch
    current = [i for i, r in enumerate(rows) if branch(r[0]) == args.branch]
    if current:
        keep.add(current[0])
    keep.update(range(max(0, len(rows) - args.keep_recent), len(rows)))
    last_desc = {}
    for i, r in enumerate(rows):
        if r[0] in deps:
            keep.add(i)
        if branch(r[0]) == args.branch and not generic.fullmatch(r[2]):
            last_desc[r[2]] = i
    keep.update(last_desc.values())
    return [r for i, r in enumerate(rows) if i in keep]


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("readme")
    p.add_argument("--chart", required=True)
    p.add_argument("--branch", required=True, help="current branch X.Y")
    p.add_argument("--keep-recent", type=int, default=5)
    p.add_argument("--generic-regex", required=True)
    p.add_argument("--deps-file", help="lines '<chart> <version>' of all dependencies")
    p.add_argument("--add-row", help="'release|date|description' row to append")
    p.add_argument("--no-prune", action="store_true")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--verbose", action="store_true")
    args = p.parse_args()

    deps = set()
    if args.deps_file:
        for l in open(args.deps_file):
            f = l.split()
            if len(f) == 2 and f[0] == args.chart:
                deps.add(f[1].strip('"'))

    lines = open(args.readme).read().split("\n")
    trailing_nl = lines and lines[-1] == ""
    if trailing_nl:
        lines.pop()

    h = next((i for i, l in enumerate(lines) if l.startswith("## History")), None)
    if h is None:
        print(f"SKIP {args.chart}: no '## History' section", file=sys.stderr)
        return 0
    hend = next((i for i in range(h + 1, len(lines)) if re.match(r"^## ", lines[i])), len(lines))
    tabs = blocks(lines, h + 1, hend)
    if not tabs:
        print(f"SKIP {args.chart}: no table in History", file=sys.stderr)
        return 0
    a, b = tabs[-1]
    head = [l for l in lines[a:b] if is_header(l) or is_separator(l)]
    data = [l for l in lines[a:b] if not (is_header(l) or is_separator(l)) and is_row(l)]

    # stray release rows appended after the History section (end of file)
    tail_end = len(lines)
    while tail_end > hend and not lines[tail_end - 1].strip():
        tail_end -= 1
    s = tail_end
    while s > hend and lines[s - 1].startswith("|") and SEMVER.match(cells(lines[s - 1])[0] or ""):
        s -= 1
    stray = lines[s:tail_end]
    moved = bool(stray)

    rows = []
    for l in data + stray:
        c = cells(l)
        rows.append((c[0], c[1], "|".join(c[2:]).strip(), l))
    before = len(rows)
    if args.add_row:
        v, d, desc = (x.strip() for x in args.add_row.split("|", 2))
        rows.append((v, d, desc, f"| {v} | {d} | {desc} |"))
    if not args.no_prune:
        rows = prune(rows, args, deps)
    else:
        rows = [r for r in rows if SEMVER.match(r[0])]

    new_table = head + [r[3] if r[3].rstrip().endswith("|") else r[3].rstrip() + " |" for r in rows]
    hist = lines[h:a] + new_table + lines[b:hend]
    rest_end = s if moved else len(lines)
    if hend < len(lines):
        # History is not the last section: move it to the end of the file
        before_part = lines[:h] + lines[hend:rest_end]
        while before_part and not before_part[-1].strip():
            before_part.pop()
        out = before_part + [""] + hist
        moved = True
    else:
        out = lines[:h] + hist
    while out and not out[-1].strip():
        out.pop()

    kept = {r[0] for r in rows}
    dropped = [c for c in (cells(l)[0] for l in data + stray) if c not in kept]
    print(f"{args.chart}: {before} -> {len(rows)} rows" + (" (layout fixed)" if moved else ""))
    if args.verbose and dropped:
        print("  dropped: " + " ".join(dropped))
    missing = sorted(d for d in deps if any(r[0] == d for r in rows) is False
                     and any(cells(l)[0] == d for l in data + stray))
    if missing:
        print(f"  ERROR dependency version(s) dropped: {' '.join(missing)}", file=sys.stderr)
        return 1
    if not args.dry_run:
        open(args.readme, "w").write("\n".join(out) + ("\n" if trailing_nl else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
