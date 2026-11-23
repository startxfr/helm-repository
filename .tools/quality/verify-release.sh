#!/usr/bin/env bash
# Independent check of a published release. Usage: verify-release.sh <version> <approved-head>
# Read-only, no clone: indexes over https, git object queries on the shared repository, a few small downloads.
set -uo pipefail
ver=${1:?version, e.g. 21.3.397}; approved=${2:?approved commit}
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}
U=https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com
R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
mkdir -p "$S/pub" && cd "$S/pub" || exit 1
fail=0
for r in stable 21; do
  curl -sf --max-time 120 "$U/$r/index.yaml" -o "idx-$r.yaml" || { echo "FAIL fetch of the $r index"; fail=1; continue; }
  tree=$(git -C "$R" ls-tree --name-only "$ver^{commit}" charts/ | sed 's|charts/||' | sort)
  n=$(wc -l <<<"$tree"); bad=0
  for c in $tree; do
    v=$(yq e ".entries.\"$c\"[].version" "idx-$r.yaml" | sort -V | tail -1)
    [[ $v == "$ver" ]] || { echo "FAIL $r: $c latest is '$v'"; bad=$((bad+1)); }
  done
  echo "$r: $n charts of the tag, $bad not at $ver (index has $(yq e '.entries | length' "idx-$r.yaml") entries)"
  [[ $bad -eq 0 ]] || fail=1
done
echo "== git"
t=$(git -C "$R" rev-parse "$ver^{commit}" 2>&1); s=$(git -C "$R" rev-parse stable 2>&1)
echo "tag $ver = ${t:0:10} ($(git -C "$R" cat-file -t "$ver" 2>&1)), stable = ${s:0:10}"; [[ $t == "$s" ]] || { echo "FAIL tag != stable"; fail=1; }
echo "== content of the tag versus the approved head $approved"
git -C "$R" merge-base --is-ancestor "$approved" "$ver" && echo "approved head is an ancestor of the tag" || { echo "FAIL approved head not in the tag"; fail=1; }
other=$(git -C "$R" diff --name-only "$approved" "$ver" | grep -vE '^charts/[^/]+/Chart\.yaml$|^charts/[^/]+/README\.md$|^docs/charts/[^/]+\.md$|^docs/repos/|^docs/roadmap/|^\.tools/repo-release$' || true)
echo "files changed outside Chart.yaml / README / docs copies / indexes / roadmap / repo-release: $(grep -c . <<<"$other")"; [[ -z $other ]] || { echo "$other" | head -15; fail=1; }
echo "-- Chart.yaml lines changed other than version, pins, appVersion-free keys:"
git -C "$R" diff -U0 "$approved" "$ver" -- 'charts/*/Chart.yaml' | grep '^[-+]' | grep -vE '^(\+\+\+|---)' | grep -vE '^[-+]version:|^[-+]\s+version:|^[-+]\s+(- )?kind: |^[-+]\s+description: |artifacthub' | head -8
echo "== packages: digest of 3 downloads"
for c in project cluster-argocd chaos-pipeline; do
  u=$(yq e ".entries.\"$c\"[] | select(.version==\"$ver\") | .urls[0]" idx-stable.yaml); d=$(yq e ".entries.\"$c\"[] | select(.version==\"$ver\") | .digest" idx-stable.yaml)
  curl -sf --max-time 120 "$u" -o "$c.tgz" && [[ $(sha256sum "$c.tgz" | cut -d' ' -f1) == "$d" ]] && echo "ok   $c digest" || { echo "FAIL $c digest/download"; fail=1; }
  tar -xzOf "$c.tgz" "$c/Chart.yaml" 2>/dev/null | grep -m1 '^version:' | sed "s/^/     $c package /"
done
df -h / | tail -1 | awk '{print "root fs used:", $5}'
[[ $fail -eq 0 ]] && echo "RESULT: OK" || echo "RESULT: FAIL"
