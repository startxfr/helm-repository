#!/usr/bin/env bash
# Compare the manifests rendered by chart versions: <old-ref> (a release tag) against HEAD, with the default values,
# every values-startx*.yaml of each chart and, as one more case per chart, the "forced" values: every top level
# `<key>.enabled: false` of the values.yaml of the chart switched on (--set <key>.enabled=true), so that the resources that
# the defaults do not render are compared too (a chart that renders nothing by default would always look identical).
# Version labels are ignored. Read-only: works on temporary exports.
# Environment: NO_FORCED=1 skips the forced case; FORCED_SKIP="chart:key chart:key" keeps a switch off (a switch that needs
# data before it renders, or a validation that fails on purpose); the same switches are used on both sides, a case that fails
# to render on both sides is reported as identical (its error text is compared).
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
  forced=()
  if [[ -z "${NO_FORCED:-}" ]]; then
    # keys switched on: top level mappings with `enabled: false` in BOTH versions of the chart, minus FORCED_SKIP
    mapfile -t forced < <(python3 - "$tmp/old/charts/$c/values.yaml" "$tmp/new/charts/$c/values.yaml" "$c" "${FORCED_SKIP:-}" <<'PY'
import sys, yaml
def off(p):
    try: v = yaml.safe_load(open(p)) or {}
    except Exception: return set()
    return {k for k, x in v.items() if isinstance(x, dict) and x.get('enabled') is False}
skip = {s.split(':', 1)[1] for s in sys.argv[4].split() if s.startswith(sys.argv[3] + ':')}
for k in sorted((off(sys.argv[1]) & off(sys.argv[2])) - skip):
    print('--set'); print(k + '.enabled=true')
PY
)
    [[ ${#forced[@]} -gt 0 ]] && vfiles+=("@forced")
  fi
  for vf in "${vfiles[@]}"; do
    for v in old new; do
      args=(); [[ -n "$vf" && "$vf" != "@forced" ]] && args=(-f "$vf"); [[ "$vf" == "@forced" ]] && args=("${forced[@]}")
      (cd "$tmp/$v/charts/$c" && helm template t . "${args[@]}" --set auth.enabled=true --set DataScienceCluster.enabled=true 2>&1 | grep -v -E "$ignore" > "$tmp/out/$v.$c.${vf:-default}.out")
    done
    n="$(grep -c '^kind:' "$tmp/out/new.$c.${vf:-default}.out") resources"
    grep -q '^Error:' "$tmp/out/new.$c.${vf:-default}.out" && n="render ERROR in HEAD: $(grep -m1 '^Error:' "$tmp/out/new.$c.${vf:-default}.out" | cut -c1-110)"
    [[ "$vf" == "@forced" ]] && vf_label="forced switches" || vf_label="${vf:-default values}"
    if diff -q "$tmp/out/old.$c.${vf:-default}.out" "$tmp/out/new.$c.${vf:-default}.out" >/dev/null; then
      echo "same  $c [$vf_label] ($n)"
    else
      echo "DIFF  $c [$vf_label] $(diff "$tmp/out/old.$c.${vf:-default}.out" "$tmp/out/new.$c.${vf:-default}.out" | grep -c '^[<>]') line(s)"; rc=1
    fi
  done
done
echo "details in $tmp/out"
exit $rc
