#!/usr/bin/env bash
# CI checks of the helm-repository charts. Plain bash + helm + python3, no other dependency, so it runs the same way on
# a laptop, in GitHub Actions (.github/workflows/ci.yml) and later in GitLab CI.
#
# Usage:
#   .github/scripts/ci-check.sh static                   JSON schemas, docs/charts copies, misspellings
#   .github/scripts/ci-check.sh charts ["pattern ..."]   helm lint + helm template of the matching charts (default: all)
#   .github/scripts/ci-check.sh all                      static + charts
#   .github/scripts/ci-check.sh chart-one <chart>        one chart (used by the parallel run)
#
# Patterns are shell globs on the chart names, for example: "cluster-[a-f]*" or "chaos* example-*".
# Environment:
#   CI_JOBS        number of charts checked in parallel (default 4)
#   CI_BASE_REF    git ref the misspelling guard compares with (default origin/devel, falls back to HEAD~1)
#   CI_SPELLING    all (default: the whole tree, failing) | changed (only the lines added since CI_BASE_REF) | off
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$ROOT" || exit 2
CI_JOBS=${CI_JOBS:-4}
CI_SPELLING=${CI_SPELLING:-all}

# The charts declare their dependencies on the S3 website endpoint (http only): the public HTTPS endpoint of the same
# bucket is used for the dependency resolution of the copy that is checked.
S3_HTTP='http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com'
S3_HTTPS='https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com'

# Misspellings that CLAUDE.md asks to fix on sight (ERE, case insensitive)
SPELLING='theses resources|environement|plateform|ressource|functionnal|organisational|recommandations|others values availables|projet'
SPELLING_GRAPHANA='graphana'
# Not checked: CLAUDE.md and the roadmap/ADR pages (they quote the misspellings), the generated indexes, the French
# web templates, the French console links of cluster-console (plateforme, ressources...) and the cluster-dvo values
# keys named graphana (kept for compatibility, never rename them)
SPELLING_EXCLUDES=(':!CLAUDE.md' ':!webtpl' ':!**/webtpl/**' ':!docs/repos' ':!docs/roadmap' ':!docs/adr' ':!*.tgz' ':!*.prov' ':!*.asc' ':!.github/scripts/ci-check.sh' ':!charts/cluster-console/values-m*.yaml')

log() { printf '%s\n' "$*"; }

check_schemas() {
    local f bad=0
    for f in charts/*/values.schema.json; do
        python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null || { log "FAIL schema is not valid JSON: $f"; bad=1; }
    done
    [[ $bad -eq 0 ]] && log "ok   every values.schema.json is valid JSON"
    return $bad
}

check_docs() {
    local c bad=0
    for c in $(ls charts); do
        [[ -f charts/$c/README.md ]] || continue
        if [[ ! -f docs/charts/$c.md ]]; then log "FAIL docs/charts/$c.md is missing"; bad=1
        elif ! cmp -s "charts/$c/README.md" "docs/charts/$c.md"; then log "FAIL docs/charts/$c.md differs from charts/$c/README.md"; bad=1; fi
    done
    [[ $bad -eq 0 ]] && log "ok   docs/charts/<chart>.md equal charts/<chart>/README.md"
    return $bad
}

# spelling_hits_all: every offending line of the tree ("graphana" is allowed in cluster-dvo only)
spelling_hits_all() {
    git grep -nIiE -- "$SPELLING" -- . "${SPELLING_EXCLUDES[@]}" || true
    git grep -nIiE -- "$SPELLING_GRAPHANA" -- . "${SPELLING_EXCLUDES[@]}" ':!charts/cluster-dvo' || true
}

# spelling_hits_added <base>: offending lines among the lines added since <base>
spelling_hits_added() {
    git diff -U0 "$1" -- . "${SPELLING_EXCLUDES[@]}" | grep -E '^\+[^+]' | grep -iE -- "$SPELLING|$SPELLING_GRAPHANA" || true
}

check_spelling() {
    case "$CI_SPELLING" in
        off) log "skip misspelling guard (CI_SPELLING=off)"; return 0 ;;
        all)
            local hits
            hits=$(spelling_hits_all)
            if [[ -n "$hits" ]]; then log "FAIL misspellings in the tree ($(wc -l <<<"$hits") lines, see CLAUDE.md):"; head -60 <<<"$hits"; return 1; fi
            log "ok   no misspelling in the tree"; return 0 ;;
    esac
    local base=${CI_BASE_REF:-origin/devel}
    git rev-parse --verify -q "$base" >/dev/null || base=HEAD~1
    git rev-parse --verify -q "$base" >/dev/null || { log "skip misspelling guard (no base ref)"; return 0; }
    local added
    added=$(spelling_hits_added "$base")
    if [[ -n "$added" ]]; then
        log "FAIL misspellings in the lines added since $base (see CLAUDE.md):"; head -40 <<<"$added"; return 1
    fi
    log "ok   no misspelling in the lines added since $base"
}

static() {
    local rc=0
    check_schemas || rc=1
    check_docs || rc=1
    check_spelling || rc=1
    return $rc
}

# helm lint and helm template of one chart, in a throw-away copy so the working tree stays untouched
chart_one() {
    local c=$1 tmp rc=0 out f
    [[ -f charts/$c/Chart.yaml ]] || { echo "unknown chart: $c"; return 2; }
    tmp=$(mktemp -d)
    out=$(mktemp)
    {
        cp -r "charts/$c" "$tmp/$c"
        rm -rf "$tmp/$c/charts" "$tmp/$c/Chart.lock"
        if grep -q '^dependencies:' "$tmp/$c/Chart.yaml"; then
            sed -i "s#$S3_HTTP#$S3_HTTPS#g" "$tmp/$c/Chart.yaml"
            if ! { helm dependency update "$tmp/$c" >"$tmp/dep.log" 2>&1 || { sleep 3; helm dependency update "$tmp/$c" >"$tmp/dep.log" 2>&1; }; }; then
                echo "SKIP $c: dependencies not resolvable ($(tail -1 "$tmp/dep.log"))"
                echo "SKIPPED" >"$tmp/status"
            fi
        fi
        if [[ ! -f $tmp/status ]]; then
            if helm lint "$tmp/$c" >"$tmp/lint.log" 2>&1; then echo "ok   $c: helm lint"; else echo "FAIL $c: helm lint"; sed 's/^/       /' "$tmp/lint.log" | head -15; rc=1; fi
            for f in "" "$tmp/$c"/values-startx*.yaml; do
                [[ -n $f && ! -f $f ]] && continue
                local label=${f##*/}; label=${label:-default values}
                if helm template ci "$tmp/$c" ${f:+-f "$f"} >"$tmp/t.log" 2>&1; then echo "ok   $c: helm template ($label)"
                else echo "FAIL $c: helm template ($label)"; sed 's/^/       /' "$tmp/t.log" | head -8; rc=1; fi
            done
        fi
    } >"$out" 2>&1
    cat "$out"
    rm -rf "$tmp" "$out"
    return $rc
}

charts() {
    local pats=("$@") c list=()
    [[ ${#pats[@]} -eq 0 ]] && pats=('*')
    set -f
    local words=() p
    for p in "${pats[@]}"; do read -ra w <<<"$p"; words+=("${w[@]}"); done
    set +f
    for c in $(ls charts); do
        [[ -f charts/$c/Chart.yaml ]] || continue
        for p in "${words[@]}"; do
            # shellcheck disable=SC2053
            if [[ $c == $p ]]; then list+=("$c"); break; fi
        done
    done
    [[ ${#list[@]} -eq 0 ]] && { log "no chart matches: ${words[*]}"; return 1; }
    log "checking ${#list[@]} chart(s) with $CI_JOBS job(s): ${list[*]}"
    printf '%s\n' "${list[@]}" | xargs -P "$CI_JOBS" -I{} "${BASH_SOURCE[0]}" chart-one {} | tee /tmp/ci-charts.$$.log
    local fails skips
    fails=$(grep -c '^FAIL' /tmp/ci-charts.$$.log) skips=$(grep -c '^SKIP' /tmp/ci-charts.$$.log)
    rm -f /tmp/ci-charts.$$.log
    log "summary: ${#list[@]} chart(s), $fails failure(s), $skips skipped"
    [[ $fails -eq 0 ]]
}

case "${1:-all}" in
    static)    static ;;
    charts)    shift; charts "$@" ;;
    chart-one) shift; chart_one "$@" ;;
    all)       rc=0; static || rc=1; charts || rc=1; exit $rc ;;
    *)         sed -n '2,16p' "${BASH_SOURCE[0]}"; exit 2 ;;
esac
