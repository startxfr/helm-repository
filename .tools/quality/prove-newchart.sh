#!/usr/bin/env bash
# prove-newchart.sh <SRC> <NEW> <SRCSHORT> <SHORT> : runs the commands of the patched skill ($S/sk/.claude/commands/new-chart.md) on a copy of $S/sk
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}
SRC=$1; NEW=$2; SRCSHORT=$3; SHORT=$4
W=$S/sim-$NEW; rm -rf "$W" && cp -r $S/sk "$W" && cd "$W" || exit 1
# commands extracted from the skill: every ```bash block between "Step 3" and "Step 9" that does not need a human (step 3 block 2, 6 schema, 7 values-app, 8)
echo "== step 3"
cp -r charts/$SRC charts/$NEW
rm -rf charts/$NEW/charts charts/$NEW/Chart.lock
find charts/$NEW -maxdepth 1 -name 'values-*.yaml' ! -name values-startx.yaml ! -name values-startx_noinfra.yaml ! -name values-demo.yaml -delete
grep -rlI -- "$SRC" charts/$NEW | xargs -r sed -i "s/$SRC/$NEW/g"
echo "source name left: $(grep -rnI -- "$SRC" charts/$NEW | wc -l)"
echo "short name lines to review: $(grep -rnIw -- "$SRCSHORT" charts/$NEW | wc -l)"; ls charts/$NEW | tr '\n' ' '; echo
echo "== step 4/6 manual edits emulated (description, annotations, History, context.app, short name)"
python3 - "$NEW" "$SRCSHORT" "$SHORT" <<'PY'
import re, sys, pathlib, json
new, ss, sh = sys.argv[1:]
d = pathlib.Path("charts") / new
r = (d / "README.md").read_text()
i = r.index("## History")
r = r[:i] + "## History\n\n| Release  | Date       | Description           |\n| -------- | ---------- | --------------------- |\n| 21.3.412 | 2026-11-22 | Initial chart creation |\n"
(d / "README.md").write_text(r)
# step 6 emulated: the keys named after the source short name (top-level keys of values files, .Values.<short> in templates, `properties` of the schema)
for p in list(d.glob("values*.yaml")):
    t = p.read_text(); p.write_text(re.sub(r"(?m)^%s:" % re.escape(ss), "%s:" % sh, t))
for p in (d / "templates").glob("*"):
    t = p.read_text(); p.write_text(re.sub(r"\.Values\.%s\b" % re.escape(ss), ".Values.%s" % sh, t))
sc = d / "values.schema.json"
t = sc.read_text(); sc.write_text(re.sub(r'(?m)^(\s*)"%s":' % re.escape(ss), r'\1"%s":' % sh, t))
json.load(open(sc))
PY
echo "== step 6 schema"
python3 .tools/schema-sync.py $NEW; python3 .tools/schema-sync.py --check $NEW; echo "schema-sync --check rc=$?"
.github/scripts/ci-check.sh schema | tail -1
echo "== step 7 argocd"
if [[ -d charts/$NEW/examples/argocd ]]; then
  python3 .tools/generate-values-app.py $NEW; ls charts/cluster-argocd/values-app-$NEW.yaml; echo "source name in values-app: $(grep -c "$SRC" charts/cluster-argocd/values-app-$NEW.yaml)"
  grep -h 'name:' charts/$NEW/examples/argocd/appproject.yaml | head -2
else echo "no examples/argocd (example-* family): step skipped"; fi
echo "== step 8"
cp docs/img/$SRC.svg docs/img/$NEW.svg
cp charts/$NEW/README.md docs/charts/$NEW.md
python3 - "$SRC" "$NEW" <<'PY'
import re, sys
src, new = sys.argv[1:]
t = open("docs/index.md").read()
m = re.search(r"(?m)^\| \*\*\[%s\]\(charts/%s\.md\)\*\*.*$" % (src, src), t)
row = m.group(0).replace(src, new)
open("docs/index.md", "w").write(t.replace(m.group(0), m.group(0) + "\n" + row, 1))
t = open("mkdocs.yml").read()
m = re.search(r"(?m)^( *- '[^']*': 'charts/%s\.md')$" % src, t)
open("mkdocs.yml", "w").write(t.replace(m.group(0), m.group(0) + "\n" + m.group(1).replace(src, new).replace("'" + m.group(1).split("'")[1] + "'", "'Demo'"), 1))
PY
git add -A >/dev/null 2>&1; git -c user.name=q -c user.email=q@q commit -qm sim 2>&1 | tail -1
echo "== step 9: the four CI modes"
.github/scripts/ci-check.sh static 2>&1 | grep -v '^ok'; echo "static rc=${PIPESTATUS[0]}"
.github/scripts/ci-check.sh schema 2>&1 | tail -1; echo "schema rc=${PIPESTATUS[0]}"
.github/scripts/ci-check.sh argocd 2>&1 | tail -2; echo "argocd rc=${PIPESTATUS[0]}"
CI_CONVENTIONS_STRICT=true .github/scripts/ci-check.sh conventions $NEW 2>&1 | tail -3; echo "conventions rc=${PIPESTATUS[0]}"
