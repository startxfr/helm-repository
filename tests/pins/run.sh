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
# lagging: the reproduced case. lagx is at 21.3.6 and pins lib 21.3.3 ; lib 21.3.7 (the fix) is published
chart lagx 21.3.6 "  - name: lib
    repository: $REPO
    version: 21.3.3"
rc=$(run --lagging --only lagx)
[[ $rc -eq 0 ]] && grep -q 'lagx: lib pins 21.3.3, 21.3.7 is published: release lagx at a version above 21.3.7' "$W/out.log" && ok "lagging lists a dependent whose dependency was published above it, with the action" || bad "lagging lagx: rc=$rc $(cat "$W/out.log")"
# quiet after a full release: the highest published version of lib is the version of app (21.3.7)
rc=$(run --lagging --only app)
[[ $rc -eq 0 ]] && ! [[ -s $W/out.log ]] && ok "lagging: a dependency whose highest published version is the chart own version is not listed" || bad "lagging app: rc=$rc $(cat "$W/out.log")"
rc=$(run --lagging --only quoted)
[[ $rc -eq 0 ]] && ! [[ -s $W/out.log ]] && ok "lagging: nothing for a pin already on the highest published version (21.4.0 is another minor)" || bad "lagging quoted: rc=$rc $(cat "$W/out.log")"
# the release path: lagx released at its default next version 21.3.7 cannot take lib 21.3.7: visible warning, no failure
rc=$(run --apply --only lagx --below 21.3.7)
[[ $rc -eq 0 ]] && grep -q 'WARNING lagx: lib 21.3.7 is published and cannot be pinned by a release at 21.3.7: release lagx at a version above 21.3.7' "$W/err.log" && [[ $(pin lagx lib) == 21.3.5 ]] && ok "a release that cannot take a published dependency warns (pin resolved to 21.3.5)" || bad "warning: rc=$rc pin=$(pin lagx lib) $(cat "$W/err.log")"
rc=$(run --apply --only lagx --below 21.3.8)
[[ $rc -eq 0 ]] && [[ $(pin lagx lib) == 21.3.7 ]] && ! grep -q WARNING "$W/err.log" && ok "a release above the dependency takes it (21.3.7) without warning" || bad "release above: rc=$rc pin=$(pin lagx lib) $(cat "$W/err.log")"
rm -rf "$T/charts/lagx"

# index unreachable: exit 2, nothing written, no fallback on the local tree
cp "$T/charts/app/Chart.yaml" "$W/app.before"
rc=$(BUMP_PINS_SLEEP=0 python3 -I "$T/.tools/bump-pins.py" --apply --only app >/dev/null 2>"$W/err.log"; echo $?)
[[ $rc -eq 2 ]] && cmp -s "$W/app.before" "$T/charts/app/Chart.yaml" && grep -q 'never taken from the local tree' "$W/err.log" && ok "unreachable index: refused (exit 2), nothing written" || bad "unreachable: rc=$rc $(cat "$W/err.log")"

# a malformed index is an unreadable index: exit 2, a clear message, no traceback, nothing written
cp "$T/charts/app/Chart.yaml" "$W/app.before"
for kind in 'entries: [lib]' 'entries: {lib: null}' 'entries: {lib: "21.3.5"}' 'entries: {lib: [{version: 21.3}]}' 'entries: {lib: [{name: lib}]}' 'nothing: here'; do
    printf 'apiVersion: v1\n%s\n' "$kind" > "$W/bad-index.yaml"
    rc=$(python3 -I "$T/.tools/bump-pins.py" --index "$REPO=$W/bad-index.yaml" --apply --only app >/dev/null 2>"$W/err.log"; echo $?)
    [[ $rc -eq 2 ]] && ! grep -q Traceback "$W/err.log" && grep -q 'unreachable or unreadable' "$W/err.log" && cmp -s "$W/app.before" "$T/charts/app/Chart.yaml" || bad "malformed index '$kind': rc=$rc $(tail -1 "$W/err.log")"
done
printf 'apiVersion: v1\nentries: {lib: [{version: 18.11}]}\n' > "$W/bad-index.yaml"
python3 -I "$T/.tools/bump-pins.py" --index "$REPO=$W/bad-index.yaml" --apply --only app >/dev/null 2>"$W/err.log"
grep -q "entry 'lib' has the version 18.11 that is not a string" "$W/err.log" && grep -q 'quote it' "$W/err.log" && ok "the message names the entry, the version and the fix" || bad "message: $(cat "$W/err.log")"
ok "malformed indexes (list, null, string, version without string, no entries) exit 2 without traceback"

# a version with a leading zero is read as published, never as another version, and never selected
cat > "$W/zero-index.yaml" <<YAML
apiVersion: v1
entries:
  lib:
    - {name: lib, version: 21.3.05}
    - {name: lib, version: 21.3.3}
YAML
cp "$T/charts/app/Chart.yaml" "$W/app.before"
rc=$(python3 -I "$T/.tools/bump-pins.py" --index "$REPO=$W/zero-index.yaml" --apply --only app --below 21.3.9 2>"$W/err.log" >"$W/out.log"; echo $?)
[[ $rc -eq 0 ]] && [[ $(pin app lib) == 21.3.3 ]] && ok "21.3.05 is never selected nor rewritten as 21.3.5" || bad "leading zero: rc=$rc pin=$(pin app lib) $(cat "$W/err.log")"
sed -i '0,/version: 21.3.3/s//version: 21.3.05/' "$T/charts/app/Chart.yaml"
rc=$(run --check-offline --only app)
[[ $rc -eq 1 ]] && grep -q 'an exact X.Y.Z version is required' "$W/err.log" && ok "a pin with a leading zero is refused by the offline check" || bad "leading zero pin: rc=$rc $(cat "$W/err.log")"
cp "$W/app.before" "$T/charts/app/Chart.yaml"

# --apply without --only is all or nothing: one chart in error, no chart written
cp "$T/charts/app/Chart.yaml" "$W/app.before"; cp "$T/charts/quoted/Chart.yaml" "$W/quoted.before"
rc=$(run --apply --below 21.3.8)
[[ $rc -eq 1 ]] && cmp -s "$W/app.before" "$T/charts/app/Chart.yaml" && cmp -s "$W/quoted.before" "$T/charts/quoted/Chart.yaml" && grep -q 'NOT written' "$W/err.log" && ok "--apply without --only writes nothing while a chart fails" || bad "all or nothing: rc=$rc $(cat "$W/err.log")"

# flow style dependencies cannot be rewritten: refused, never silently ignored
chart flowy 21.3.9 "  - {name: lib, repository: $REPO, version: 21.3.7}"
for opt in --check-offline --apply; do
    cp "$T/charts/flowy/Chart.yaml" "$W/flowy.before"
    rc=$(run $opt --only flowy)
    [[ $rc -eq 1 ]] && grep -q 'flow style' "$W/err.log" && cmp -s "$W/flowy.before" "$T/charts/flowy/Chart.yaml" || bad "flow style with $opt: rc=$rc $(cat "$W/err.log")"
done
ok "flow style dependencies are refused (offline check and apply)"
rm -rf "$T/charts/flowy"

# --levels : depth in the internal dependency graph
chart umbrella 21.3.9 "  - name: app
    repository: $REPO
    version: 21.3.6"
python3 -I "$T/.tools/bump-pins.py" --levels > "$W/levels.log" 2>&1
grep -q '^level 0 (2): fresh lib$' "$W/levels.log" && grep -q '^level 1 (3): app nextminor quoted$' "$W/levels.log" && grep -q '^level 2 (1): umbrella$' "$W/levels.log" && ok "--levels lists the charts by depth" || bad "levels: $(cat "$W/levels.log")"

echo "summary: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
