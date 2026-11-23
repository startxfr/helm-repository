#!/usr/bin/env bash
# Review of the project chart change (dockercfg.list[].existingSecret). Usage: project-review.sh <commit>
# Needs $S/dk/snap-base (baseline of 21.3.393). No clone: git archive of the commit, shallow work only.
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}/dk
R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
commit=${1:?commit}
CHARTS="project cluster-config cluster-couchbase cluster-istio cluster-3scale cluster-mongo cluster-crunchy cluster-redis example-fruitapp-project"
[[ -d $S/snap-base/project ]] || { echo "baseline missing"; exit 2; }
echo "commit $(git -C $R log -1 --format='%h %s' "$commit")"
echo "== scope"; git -C $R show --stat --format= "$commit" | cat
echo "== project unchanged between 21.3.393 and the parent, outside this commit?"; git -C $R diff --stat 21.3.393 "$commit~1" -- charts/project | tail -1
rm -rf "$S/after" && mkdir -p "$S/after" && git -C $R archive "$commit" | tar -x -C "$S/after" || exit 1
cd "$S/after" || exit 1
# dependents must use the NEW project: package it under the version each dependent pins
for c in $CHARTS; do
  [[ $c == project ]] && continue
  pin=$(yq e '.dependencies[] | select(.name=="project") | .version' charts/$c/Chart.yaml | sort -u | head -1)
  mkdir -p "$S/pk/$c" && rm -rf "$S/pk/$c/project" && cp -r charts/project "$S/pk/$c/project" && rm -rf "$S/pk/$c/project/charts"
  sed -i "s/^version: .*/version: $pin/" "$S/pk/$c/project/Chart.yaml"
  mkdir -p charts/$c/charts && helm package "$S/pk/$c/project" -d charts/$c/charts >/dev/null 2>&1 && echo "packaged new project as $pin for $c"
done
echo "== render snapshot after (JOBS=4)"
JOBS=4 python3 .tools/render-golden.py snapshot "$S/snap-after" $CHARTS >/dev/null 2>&1; echo "snapshot rc=$?"
echo "== COMPARE baseline vs after (blocking criterion: identical)"
python3 .tools/render-golden.py compare "$S/snap-base" "$S/snap-after"; echo "compare rc=$?"
