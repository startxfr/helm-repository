#!/usr/bin/env bash
# Review of the unifai v0.1.75 bump. Usage: unifai-review.sh <commit>
# Works in a clean clone of the repository, never in the shared working copy.
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}
commit=${1:?commit}
NEW=$S/ua/rel75.json
rm -rf "$S/ur" && mkdir -p "$S/ur" && cd "$S/ur" || exit 1
R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
mkdir after before && git -C $R archive "$commit" | tar -x -C after && git -C $R archive "$commit~1" | tar -x -C before || exit 1
echo "after=$(git -C $R rev-parse --short "$commit") before=$(git -C $R rev-parse --short "$commit~1")"
echo "== files changed"; git -C $R show --stat --format='%h %s' "$commit" | cat

echo "== every digest of the release is in the chart (and where)"
python3 -I - "$NEW" after/charts/unifai <<'EOF'
import json, sys, subprocess
r = json.load(open(sys.argv[1])); chart = sys.argv[2]
want = {k: v["ref"].split("@sha256:")[-1] for k, v in r["images"].items()}
want["bundle"] = r["bundle"].split("@sha256:")[-1]; want["catalog"] = r["catalog"].split("@sha256:")[-1]
for k, d in want.items():
    out = subprocess.run(["grep", "-rl", d, chart], capture_output=True, text=True).stdout.split()
    print("%-11s %s %s" % (k, d[:8], "in " + ",".join(sorted(set(x.split("unifai/")[-1] for x in out))) if out else "NOT FOUND in the chart"))
EOF

echo "== leftovers of the previous release"
old=$(grep -rhoE 'sha256:[0-9a-f]{64}' before/charts/unifai | sort -u)
for d in $old; do grep -rq "$d" after/charts/unifai && echo "OLD digest still present: ${d:0:20} in $(grep -rl "$d" after/charts/unifai | sed 's|.*/unifai/||' | tr '\n' ' ')"; done
grep -rn '0\.1\.71' after/charts/unifai after/docs/charts/unifai.md 2>/dev/null | grep -v 'Migration\|migration\|since\|before\|earlier' | head
echo "== CRDs / rules unchanged"
diff -rq before/charts/unifai/crds after/charts/unifai/crds && echo "crds identical"
diff -q before/charts/unifai/files/manager-rules.yaml after/charts/unifai/files/manager-rules.yaml && echo "manager-rules identical"
echo "== schema untouched (hand written)"; diff -q before/charts/unifai/values.schema.json after/charts/unifai/values.schema.json && echo "schema identical"
echo "== Chart.yaml / values.yaml diff"; git -C $R diff "$commit~1" "$commit" -- charts/unifai/Chart.yaml charts/unifai/values.yaml | grep '^[-+]' | grep -v '^+++\|^---' | cut -c1-170
cd after && for c in unifai; do helm dependency update charts/$c >/dev/null 2>&1; done
cd ../before && helm dependency update charts/unifai >/dev/null 2>&1; cd ..
echo "== render diff (default + every values file)"
for f in "" $(cd after/charts/unifai && ls values-*.yaml 2>/dev/null); do
  a=$(helm template ci after/charts/unifai ${f:+-f after/charts/unifai/$f} 2>&1); b=$(helm template ci before/charts/unifai ${f:+-f before/charts/unifai/$f} 2>&1)
  echo "-- ${f:-default values}: $(diff <(echo "$b") <(echo "$a") | grep -c '^[<>]') changed lines"
  diff <(echo "$b") <(echo "$a") | grep '^[<>]' | grep -vE 'sha256:|0\.1\.7[0-9]|helm\.sh/chart|app.kubernetes.io/version|app.startx.fr/version|unifai-2[0-9]\.|21\.3\.[0-9]+' | head -8
done
echo "== CI"; cd after
.github/scripts/ci-check.sh static 2>&1 | grep -v '^ok'; echo "static rc=${PIPESTATUS[0]}"
.github/scripts/ci-check.sh schema | tail -1
CI_JOBS=2 .github/scripts/ci-check.sh charts unifai 2>&1 | tail -3
