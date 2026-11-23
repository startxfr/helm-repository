#!/usr/bin/env bash
# Render-golden of a change of charts/project: project + every dependent of project, default values, every values file, every toggle.
# Usage: project-golden.sh <commit> [parent]   (parent defaults to <commit>~1)   Env: JOBS (default 4)
# Both trees are clean archives; in each of them the dependents get the project of THAT tree, packaged under the version they pin.
# The other dependencies are downloaded once (published packages) and shared. Needs the network for `helm dependency update`.
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}; R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
commit=${1:?commit}; parent=${2:-$commit~1}
export JOBS=${JOBS:-4}
G=$S/pg; rm -rf "$G"; mkdir -p "$G/base" "$G/after"
git -C $R archive "$parent" | tar -x -C "$G/base" && git -C $R archive "$commit" | tar -x -C "$G/after" || exit 1
echo "parent $(git -C $R rev-parse --short "$parent")  commit $(git -C $R rev-parse --short "$commit")"
git -C $R diff --stat "$parent" "$commit" | tail -1
deps=$(python3 -I - "$G/base/charts" <<'PY'
import glob, os, sys, yaml
for f in sorted(glob.glob(os.path.join(sys.argv[1], "*", "Chart.yaml"))):
    if any(isinstance(d, dict) and d.get("name") == "project" for d in (yaml.safe_load(open(f)).get("dependencies") or [])):
        print(os.path.basename(os.path.dirname(f)))
PY
)
echo "dependents of project: $(wc -l <<<"$deps")"
# 1. other dependencies once, in the base tree
helm repo update >/dev/null 2>&1 || echo "WARN helm repo update failed"
echo "$deps" | xargs -P 4 -I{} bash -c 'cd "'"$G"'/base" && helm dependency update --skip-refresh charts/{} >/dev/null 2>&1 || echo "WARN dependency update failed for {}"'

# 2. package project of each tree under the pinned version, install it into the dependents of that tree
for t in base after; do
  for c in $deps; do
    pin=$(yq e '.dependencies[] | select(.name=="project") | .version' "$G/$t/charts/$c/Chart.yaml" | head -1)
    mkdir -p "$G/$t/charts/$c/charts" "$G/pk-$t/$c"; rm -rf "$G/pk-$t/$c/project"
    cp -r "$G/$t/charts/project" "$G/pk-$t/$c/project"; rm -rf "$G/pk-$t/$c/project/charts"; sed -i "s/^version: .*/version: $pin/" "$G/pk-$t/$c/project/Chart.yaml"
    if [[ $t == after ]]; then cp "$G"/base/charts/$c/charts/*.tgz "$G/after/charts/$c/charts/" 2>/dev/null; fi
    rm -f "$G/$t/charts/$c/charts/project-"*.tgz
    helm package "$G/pk-$t/$c/project" -d "$G/$t/charts/$c/charts" >/dev/null 2>&1 || echo "WARN package failed $t $c"
  done
done
echo "== snapshots (project + $(wc -l <<<"$deps") dependents)"
for t in base after; do
  ( cd "$G/$t" && GOLDEN_ROOT="$G/$t" python3 .tools/render-golden.py snapshot "$G/snap-$t" project $deps > "$G/snap-$t.log" 2>&1; echo "snapshot $t rc=$?" )
done
echo "== COMPARE (base -> after)"
python3 "$G/after/.tools/render-golden.py" compare "$G/snap-base" "$G/snap-after" > "$G/compare.txt" 2>&1; echo "compare rc=$?"
head -60 "$G/compare.txt"
echo "cases base: $(find $G/snap-base -type f | wc -l)  after: $(find $G/snap-after -type f | wc -l)  ERROR cases base: $(grep -rl '^ERROR' $G/snap-base | wc -l) after: $(grep -rl '^ERROR' $G/snap-after | wc -l)"
