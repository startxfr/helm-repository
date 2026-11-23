#!/usr/bin/env bash
# rv.sh <patch> <base commit> <chart ...> : apply a patch on a clean archive of <base>, render before/after (default, every values file) for the charts,
# run the CI modes on the after tree. Off-tree. Needs the network once per chart (helm dependency update, skip-refresh).
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}; R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
patch=$1; base=$2; shift 2
W=$S/rv; rm -rf "$W"; mkdir -p "$W/before" "$W/after"
git -C $R archive "$base" | tar -x -C "$W/before" && cp -r "$W/before/." "$W/after/" || exit 1
(cd "$W/after" && git init -q . && git apply --check "$patch" && git apply "$patch" && echo "patch applies on $base") || { echo "PATCH DOES NOT APPLY"; exit 1; }
for c in "$@"; do
  (cd "$W/before" && helm dependency update --skip-refresh charts/$c >/dev/null 2>&1) || echo "WARN dep update $c"
  mkdir -p "$W/after/charts/$c/charts"; cp "$W/before/charts/$c/charts/"*.tgz "$W/after/charts/$c/charts/" 2>/dev/null
  n=0; d=0
  for f in "" $(cd "$W/after/charts/$c" && ls values-*.yaml 2>/dev/null); do
    a=$(helm template t "$W/before/charts/$c" ${f:+-f "$W/before/charts/$c/$f"} 2>&1); b=$(helm template t "$W/after/charts/$c" ${f:+-f "$W/after/charts/$c/$f"} 2>&1); n=$((n+1))
    if [[ "$a" != "$b" ]]; then d=$((d+1)); echo "-- $c ${f:-default}: $(diff <(echo "$a") <(echo "$b") | grep -c '^[<>]') changed line(s)"; diff <(echo "$a") <(echo "$b") | grep '^[<>]' | head -${DIFFLINES:-6}; fi
  done
  echo "$c: $n cases, $d differ"
done
