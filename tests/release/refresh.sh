#!/usr/bin/env bash
# Tests (no network, stub helm) of the dependency refresh of a multi-chart release: one `helm repo update` per run (a failure is a WARN), then
# `helm dependency update --skip-refresh` per chart, one retry with a refresh. Usage: tests/release/refresh.sh
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
PASS=0 FAIL=0
ok()  { PASS=$((PASS + 1)); printf 'ok   %s\n' "$*"; }
bad() { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$*"; }
mkdir -p "$W/bin" "$W/charts/demo"
cat > "$W/bin/helm" <<'S'
#!/usr/bin/env bash
echo "helm $*" >> "$HELM_LOG"
[[ "$1 $2" == "repo update" && -n "${FAIL_REPO_UPDATE:-}" ]] && exit 1
[[ "$1 $2" == "dependency update" && "$*" == *--skip-refresh* && -n "${FAIL_SKIP:-}" ]] && exit 1
[[ "$1 $2" == "dependency update" && "$*" != *--skip-refresh* && -n "${FAIL_NORMAL:-}" ]] && exit 1
[[ "$1" == "package" ]] && exit 0
exit 0
S
chmod +x "$W/bin/helm"
# the two functions under test, extracted from the cli
extract() { awk -v f="$1" '$0 ~ "^function "f" \\{" {p=1} p {print} p && /^}/ {exit}' "$ROOT/.tools/cli"; }
{ extract routerChartPackage; extract releaseAllCharts; } > "$W/funcs.sh"
cat > "$W/harness.sh" <<'S'
export PATH="$W/bin:$PATH" HELM_LOG="$W/helm.log" PROJECT_CHARTPATH="$W/charts" SXHELM_SIGN=disabled
git() { :; }
chartReadVersion() { echo 21.3.1; }
releaseAllChartsRun() { echo "run skip=${PACKAGE_SKIP_REFRESH:-unset}" >> "$HELM_LOG"; routerChartPackage demo >/dev/null 2>&1; }
source "$W/funcs.sh"
S
run() { : > "$W/helm.log"; ( W=$W; source "$W/harness.sh"; "$@" ) >"$W/out.log" 2>&1; echo $?; }

rc=$(run routerChartPackage demo)
grep -qx 'helm dependency update '"$W"'/charts/demo' "$W/helm.log" && ! grep -q skip-refresh "$W/helm.log" && [[ $rc -eq 0 ]] && ok "single chart (no run flag): normal dependency update, with refresh" || bad "single chart: rc=$rc $(cat "$W/helm.log")"
rc=$(PACKAGE_SKIP_REFRESH=true run routerChartPackage demo)
grep -qx 'helm dependency update --skip-refresh '"$W"'/charts/demo' "$W/helm.log" && [[ $(grep -c 'dependency update' "$W/helm.log") -eq 1 ]] && [[ $rc -eq 0 ]] && ok "inside a run: --skip-refresh, one call" || bad "skip: rc=$rc $(cat "$W/helm.log")"
rc=$(PACKAGE_SKIP_REFRESH=true FAIL_SKIP=1 run routerChartPackage demo)
[[ $(grep -c 'dependency update' "$W/helm.log") -eq 2 ]] && grep -q 'retrying with a refresh' "$W/out.log" && [[ $rc -eq 0 ]] && ok "--skip-refresh fails: one retry with a refresh, said in the log, packaged" || bad "retry: rc=$rc $(cat "$W/helm.log") $(cat "$W/out.log")"
rc=$(PACKAGE_SKIP_REFRESH=true FAIL_SKIP=1 FAIL_NORMAL=1 run routerChartPackage demo)
[[ $rc -ne 0 ]] && ! grep -q '^helm package' "$W/helm.log" && ok "both fail: nothing packaged, error returned" || bad "both fail: rc=$rc $(cat "$W/helm.log")"

rc=$(run releaseAllCharts x y)
[[ $(grep -c '^helm repo update' "$W/helm.log") -eq 1 ]] && grep -q 'run skip=true' "$W/helm.log" && [[ $rc -eq 0 ]] && ok "a run does ONE helm repo update first, then the charts with the flag" || bad "run: rc=$rc $(cat "$W/helm.log")"
rc=$(FAIL_REPO_UPDATE=1 run releaseAllCharts x y)
[[ $rc -eq 0 ]] && grep -q 'run skip=true' "$W/helm.log" && grep -q 'WARN.*helm repo update failed' "$W/out.log" && ok "helm repo update fails: WARN, the run continues" || bad "repo update failed: rc=$rc $(cat "$W/helm.log") $(cat "$W/out.log")"
# the flag must be gone in the SAME shell once the run is over (a run exports nothing)
leak=$( ( W=$W; source "$W/harness.sh"; unset PACKAGE_SKIP_REFRESH; releaseAllCharts x y >/dev/null 2>&1; echo "${PACKAGE_SKIP_REFRESH-unset}" ) )
[[ "$leak" == "unset" ]] && ok "the flag does not leak after a run (checked in the shell that ran it)" || bad "flag leaked: PACKAGE_SKIP_REFRESH=$leak"

echo "summary: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
