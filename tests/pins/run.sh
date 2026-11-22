#!/usr/bin/env bash
# Tests of .tools/bump-pins.py (ADR-0006) on a throw-away repository: no network, no change in the working tree.
# Usage: tests/pins/run.sh
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
PASS=0 FAIL=0
ok()  { PASS=$((PASS + 1)); printf 'ok   %s\n' "$*"; }
bad() { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$*"; }
BASE=https://sx-test.s3.eu-west-3.amazonaws.com
REPO=$BASE/21
T=$W/repo
mkdir -p "$T/.tools" "$T/charts"
cp "$ROOT/.tools/bump-pins.py" "$T/.tools/"
printf 'HELM_REPO_AWSBUCKET="sx-test"\nHELM_REPO_AWSDC="eu-west-3"\n' > "$T/.tools/config"
cat > "$W/index.yaml" <<YAML
apiVersion: v1
entries:
  lib:
    - {name: lib, version: 21.3.7}
    - {name: lib, version: 21.3.5}
    - {name: lib, version: 21.3.3}
    - {name: lib, version: 21.4.0}
  app:
    - {name: app, version: 21.3.6}
YAML

chart() { # chart <name> <version> <dependencies yaml, indented under dependencies:>
    mkdir -p "$T/charts/$1"
    printf 'apiVersion: v2\nname: %s\nversion: %s\ntype: application\ndependencies:\n%s\nannotations:\n  keep: "me"\n' "$1" "$2" "$3" > "$T/charts/$1/Chart.yaml"
}
run() { python3 -I "$T/.tools/bump-pins.py" --index "$REPO=$W/index.yaml" "$@" 2>"$W/err.log" >"$W/out.log"; echo $?; }
pin() { awk -v n="$2" '$0 ~ "name: "n"$" {f=1} f && /version:/ {gsub(/[" ]|version:|-/,""); print; exit}' "$T/charts/$1/Chart.yaml"; }

chart app 21.3.7 "  - name: lib
    repository: $REPO
    version: 21.3.7
  - name: other
    repository: https://example.com/charts
    version: 1.0.0"
chart quoted 21.3.9 "  - version: \"21.3.7\"
    name: lib
    repository: $REPO/"
chart fresh 21.3.8 "  - name: brandnew
    repository: $REPO
    version: 21.3.8"
chart nextminor 21.4.0 "  - name: lib
    repository: $REPO
    version: 21.4.0"
chart lib 21.3.7 ""
sed -i '/^dependencies:/,/^$/{/^dependencies:$/d}' "$T/charts/lib/Chart.yaml"

# offline: a pin equal to the chart version is refused, whatever the index
rc=$(run --check-offline --only app)
[[ $rc -eq 1 ]] && grep -q 'app 21.3.7: lib is pinned on 21.3.7, not lower' "$W/err.log" && ok "offline check refuses a pin equal to the chart version" || bad "offline check: rc=$rc $(cat "$W/err.log")"
rc=$(run --check-offline --only lib)
[[ $rc -eq 0 ]] && ok "offline check: a chart without internal dependency passes" || bad "offline check on lib: rc=$rc"

# dry run changes nothing, apply writes the highest published version of the same MAJOR.MINOR strictly below the chart
cp "$T/charts/app/Chart.yaml" "$W/app.before"
rc=$(run --only app)
[[ $rc -eq 0 ]] && grep -q 'app: lib 21.3.7 -> 21.3.5' "$W/out.log" && cmp -s "$W/app.before" "$T/charts/app/Chart.yaml" && ok "dry run reports 21.3.7 -> 21.3.5 and writes nothing" || bad "dry run: rc=$rc $(cat "$W/out.log" "$W/err.log")"
rc=$(run --apply --only app)
d=$(diff "$W/app.before" "$T/charts/app/Chart.yaml" | grep -c '^[<>]')
[[ $rc -eq 0 && $(pin app lib) == 21.3.5 && $d -eq 2 ]] && ok "apply rewrites one line, the 21.4.0 package of another minor and the upstream dependency are ignored" || bad "apply: rc=$rc pin=$(pin app lib) diff=$d"
grep -q 'version: 1.0.0' "$T/charts/app/Chart.yaml" && ok "the upstream dependency is untouched" || bad "upstream dependency changed"
rc=$(run --apply --only app)
[[ $rc -eq 0 ]] && ! [[ -s $W/out.log ]] && ok "a second apply changes nothing" || bad "second apply: rc=$rc $(cat "$W/out.log")"

# --below : the version the release is about to give to the chart
rc=$(run --apply --only app --below 21.3.9)
[[ $rc -eq 0 && $(pin app lib) == 21.3.7 ]] && ok "--below 21.3.9 resolves to 21.3.7" || bad "--below: rc=$rc pin=$(pin app lib)"
rc=$(run --apply --only app --below 21.3.7)
[[ $rc -eq 0 && $(pin app lib) == 21.3.5 ]] && ok "--below 21.3.7 never resolves to 21.3.7" || bad "--below equal: rc=$rc pin=$(pin app lib)"

# quoting, key order and a trailing slash in the repository are kept / understood
rc=$(run --apply --only quoted)
grep -q 'version: "21.3.7"' "$T/charts/quoted/Chart.yaml" && ok "quoted version kept, trailing slash in the repository accepted" || bad "quoted: rc=$rc $(cat "$T/charts/quoted/Chart.yaml")"
[[ $rc -eq 0 ]] || bad "quoted: rc=$rc"

# a dependency never published: refused, file unchanged
cp "$T/charts/fresh/Chart.yaml" "$W/fresh.before"
rc=$(run --apply --only fresh)
[[ $rc -eq 1 ]] && grep -q 'publish brandnew first' "$W/err.log" && cmp -s "$W/fresh.before" "$T/charts/fresh/Chart.yaml" && ok "unpublished dependency refused, nothing written" || bad "fresh: rc=$rc $(cat "$W/err.log")"

# first release of a minor: no version of the same MAJOR.MINOR below it, refused (publish the dependencies first)
rc=$(run --apply --only nextminor)
[[ $rc -eq 1 ]] && grep -q 'no version below 21.4.0' "$W/err.log" && ok "first release of a minor refused: the dependencies must be published first" || bad "next minor: rc=$rc $(cat "$W/err.log")"

# online check: the pin must be published
rc=$(run --check --only app)
[[ $rc -eq 0 ]] && ok "online check: 21.3.5 is published" || bad "online check: rc=$rc $(cat "$W/err.log")"
sed -i '0,/version: 21.3.5/s//version: 21.3.4/' "$T/charts/app/Chart.yaml"
rc=$(run --check --only app)
[[ $rc -eq 1 ]] && grep -q 'lib 21.3.4 is not published' "$W/err.log" && ok "online check refuses a pin that is not published" || bad "online check unpublished: rc=$rc $(cat "$W/err.log")"

# lagging pins are reported, nothing is changed
rc=$(run --lagging --only app)
[[ $rc -eq 0 ]] && grep -q 'app: lib pinned on 21.3.4, 21.3.7 is published' "$W/out.log" && ok "lagging report" || bad "lagging: rc=$rc $(cat "$W/out.log")"

# index unreachable: exit 2, nothing written, no fallback on the local tree
cp "$T/charts/app/Chart.yaml" "$W/app.before"
rc=$(BUMP_PINS_SLEEP=0 python3 -I "$T/.tools/bump-pins.py" --apply --only app >/dev/null 2>"$W/err.log"; echo $?)
[[ $rc -eq 2 ]] && cmp -s "$W/app.before" "$T/charts/app/Chart.yaml" && grep -q 'never taken from the local tree' "$W/err.log" && ok "unreachable index: refused (exit 2), nothing written" || bad "unreachable: rc=$rc $(cat "$W/err.log")"

echo "summary: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
