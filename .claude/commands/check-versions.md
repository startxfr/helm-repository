# check-versions

Review and fix version consistency across all Helm chart documentation.

## Usage

```
/check-versions [--fix] [chart-name]
```

Examples:
```
/check-versions                    # audit all charts, report mismatches only
/check-versions --fix              # audit all charts and auto-fix mismatches
/check-versions cluster-redis      # audit a single chart
/check-versions --fix cluster-redis
```

## What this command does

1. Collects the current version from every `charts/*/Chart.yaml`
2. Checks three consistency points per chart:
   - **targetRevision** — all `targetRevision: X.Y.Z` in `charts/*/README.md` and `docs/charts/*.md` must equal the chart version
   - **History last row** — the last version row in the README `## History` table must equal the chart version
   - **Docs sync** — `docs/charts/<name>.md` must be byte-identical to `charts/<name>/README.md`
3. If `--fix` is passed (or when mismatches are found and user confirms), applies fixes:
   - Replaces all stale `targetRevision:` values in README and docs
   - Copies README → docs/charts/<name>.md to re-sync
   - Reports each fix applied
4. Prints a summary: ✓ charts OK, ✗ charts with mismatches (and what was fixed)

## Instructions

You are executing the check-versions command. Arguments: `$ARGUMENTS`

**Step 0 — Parse arguments**

- If `--fix` is in `$ARGUMENTS`, set `AUTO_FIX=true`, else `AUTO_FIX=false`
- If a chart name (not starting with `--`) is in `$ARGUMENTS`, set `SINGLE_CHART=<name>`, else `SINGLE_CHART=""`

**Step 1 — Collect chart versions**

Run:
```bash
for f in charts/*/Chart.yaml; do
  chart=$(basename $(dirname $f))
  ver=$(grep '^version:' $f | awk '{print $2}')
  echo "$chart $ver"
done | sort
```

Store as the reference list. If `SINGLE_CHART` is set, filter to that chart only.

**Step 2 — Check targetRevision consistency**

For each chart/version pair, run:
```bash
chart=<name>; ver=<version>
# In README
grep -n 'targetRevision:' charts/$chart/README.md 2>/dev/null | grep -v "targetRevision: $ver"
# In docs
grep -n 'targetRevision:' docs/charts/$chart.md 2>/dev/null | grep -v "targetRevision: $ver"
```

Record any line where the version differs from the chart version.

**Step 3 — Check history last row**

For each chart, run:
```bash
last_ver=$(grep -E '^\| [0-9]+\.[0-9]+\.[0-9]+' charts/$chart/README.md | tail -1 | awk '{print $2}')
```

If `last_ver` is missing or differs from the chart version, record it as a mismatch.

**Step 4 — Check docs/charts sync**

For each chart that has both `charts/<name>/README.md` and `docs/charts/<name>.md`:
```bash
diff -q charts/$chart/README.md docs/charts/$chart.md
```

If they differ, record as out-of-sync. If only `README.md` exists but no docs file, record as missing.

**Step 5 — Report and fix**

Print a table of results:

```
Chart                  | Ver      | targetRevision | History | Docs sync
-----------------------|----------|----------------|---------|----------
cluster-redis          | 21.3.67  | ✓              | ✓       | ✓
cluster-mongo          | 21.3.55  | ✗ (21.3.27)    | ✓       | ✗ (diff)
```

If no mismatches: print `All charts are consistent. Nothing to fix.` and stop.

If mismatches exist and `AUTO_FIX=false`: print the table and ask:
```
Found N chart(s) with mismatches. Fix them now? [y/N]
```
If confirmed (or if `AUTO_FIX=true`), proceed to Step 6.

**Step 6 — Apply fixes**

For each chart with a `targetRevision` mismatch in README:
```bash
sed -i "s/targetRevision: [0-9][0-9.]*/targetRevision: $ver/g" charts/$chart/README.md
```

For each chart with a `targetRevision` mismatch in docs:
```bash
sed -i "s/targetRevision: [0-9][0-9.]*/targetRevision: $ver/g" docs/charts/$chart.md
```

For each chart where docs/charts are out of sync or missing:
```bash
cp charts/$chart/README.md docs/charts/$chart.md
```

**Note on history rows**: Do NOT auto-add missing history rows. If the last history row version doesn't match the chart version, report it but ask the user whether to add a row (since the description must be meaningful). Only add if user confirms and provides a description or accepts the default `"Align documentation version"`.

**Step 7 — Final summary**

```
Version check complete.

Fixed   : N charts
  - <chart> : targetRevision updated (21.3.27 → 21.3.67)
  - <chart> : docs/charts/<name>.md re-synced from README

OK      : M charts (no changes needed)

History : K charts with last row < chart version (manual review needed)
  - <chart> : last history row 21.3.55, chart version 21.3.67
```

If fixes were applied, remind: "Run `make publish` if the updated READMEs affect charts that are already released."
