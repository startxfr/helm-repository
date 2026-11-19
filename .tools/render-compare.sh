#!/usr/bin/env bash
# Compare the manifests rendered by chart versions: <old-ref> (a release tag) against HEAD, with the default values and
# every values-startx*.yaml of each chart. Version labels are ignored. Read-only: works on temporary exports.
# Usage: .tools/render-compare.sh <old-ref> [chart ...]     (default charts: the ones consumers use, see ADR-0004)
# Exit 1 when a rendered manifest differs; the diff is kept in the temporary directory that is printed.
set -u
root="$(dirname "$(dirname "$(readlink -f "$0")")")"
cd "$root" || exit 1
export PATH="$HOME/.local/bin:$PATH"
old="${1:?usage: render-compare.sh <old-ref> [chart ...]}"; shift
charts=("$@")
[[ ${#charts[@]} -eq 0 ]] && charts=(operator project example-imagestreams cluster-rbac cluster-config cluster-auth cluster-ods cluster-certmanager cluster-gpu cluster-nfd cluster-machine cluster-prometheus cluster-istio)
tmp=$(mktemp -d) || exit 1
mkdir -p "$tmp/old" "$tmp/new" "$tmp/out" || exit 1
git archive "$old" charts | tar -x -C "$tmp/old" || exit 1
git archive HEAD charts | tar -x -C "$tmp/new" || exit 1
ignore='^\s+(app.startx.fr/version|app.kubernetes.io/version|app.kubernetes.io/instance|helm.sh/chart|startx.fr/generated-by|startx.fr/generator-cmd)'
rc=0
for c in "${charts[@]}"; do
  [[ -d "$tmp/new/charts/$c" && -d "$tmp/old/charts/$c" ]] || { echo "skip  $c (absent in $old or HEAD)"; continue; }
  for v in old new; do (cd "$tmp/$v/charts/$c" && helm dependency update --skip-refresh >/dev/null 2>&1); done
  vfiles=("" $(cd "$tmp/new/charts/$c" && ls values-startx*.yaml 2>/dev/null))
  for vf in "${vfiles[@]}"; do
    for v in old new; do
      args=(); [[ -n "$vf" ]] && args=(-f "$vf")
      (cd "$tmp/$v/charts/$c" && helm template t . "${args[@]}" --set auth.enabled=true --set DataScienceCluster.enabled=true 2>&1 | grep -v -E "$ignore" > "$tmp/out/$v.$c.${vf:-default}.out")
    done
    n=$(grep -c '^kind:' "$tmp/out/new.$c.${vf:-default}.out")
    if diff -q "$tmp/out/old.$c.${vf:-default}.out" "$tmp/out/new.$c.${vf:-default}.out" >/dev/null; then
      echo "same  $c [${vf:-default values}] ($n resources)"
    else
      echo "DIFF  $c [${vf:-default values}] $(diff "$tmp/out/old.$c.${vf:-default}.out" "$tmp/out/new.$c.${vf:-default}.out" | grep -c '^[<>]') line(s)"; rc=1
    fi
  done
done
echo "details in $tmp/out"
exit $rc
