#!/usr/bin/env bash
# CI checks of the helm-repository charts. Plain bash + helm + python3, no other dependency, so it runs the same way on
# a laptop, in GitHub Actions (.github/workflows/ci.yml) and later in GitLab CI.
#
# Usage:
#   .github/scripts/ci-check.sh static                   JSON schemas, docs/charts copies, misspellings
#   .github/scripts/ci-check.sh charts ["pattern ..."]   helm lint + helm template of the matching charts (default: all)
#   .github/scripts/ci-check.sh argocd                   render the values-app files and check the ArgoCD examples
#   .github/scripts/ci-check.sh schema                   values.yaml keys missing from values.schema.json (blocking;
#                                                        fails by default; CI_SCHEMA_STRICT=false = report only)
#   .github/scripts/ci-check.sh toggles [chart ...]      every <key>.enabled switched on alone must render
#   .github/scripts/ci-check.sh conventions [chart ...]  README section order, titles, duplicates, Values files coverage
#                                                        (report only; CI_CONVENTIONS_STRICT=true = fail on a finding)
#   .github/scripts/ci-check.sh all                      static + charts + argocd
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

# Misspellings that CLAUDE.md asks to fix on sight (ERE, case insensitive)
SPELLING='theses resources|environement|plateform|ressource|functionnal|organisational|recommandations|others values availables|projet'
SPELLING_GRAPHANA='graphana'
# Not checked: CLAUDE.md, the conventions page and checker (they quote the misspellings) and the roadmap/ADR pages, the generated indexes, the French
# web templates, the French console links of cluster-console (plateforme, ressources...) and the cluster-dvo values
# keys named graphana (kept for compatibility, never rename them)
SPELLING_EXCLUDES=(':!CLAUDE.md' ':!webtpl' ':!**/webtpl/**' ':!docs/repos' ':!docs/roadmap' ':!docs/adr' ':!*.tgz' ':!*.prov' ':!*.asc' ':!.github/scripts/ci-check.sh' ':!.github/scripts/readme-conventions.py' ':!docs/contribute-conventions.md' ':!charts/cluster-console/values-m*.yaml')

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


# argocd: every charts/cluster-argocd/values-app-*.yaml is rendered with the cluster-argocd chart and every rendered
# Application must have a spec.source.repoURL, a spec.destination.namespace and a revision that is not the implicit
# default (master) unless the values file asks for it; every charts/*/examples/argocd/*.yaml must parse and an
# Application that reads a Helm chart must use the range 21.3.x (pin an exact version in production, ADR-0004)
check_argocd() {
    local tmp f name rc=0 app repo rev dest n explicit
    tmp=$(mktemp -d)
    cp -r charts/cluster-argocd "$tmp/cluster-argocd"
    rm -rf "$tmp/cluster-argocd/charts" "$tmp/cluster-argocd/Chart.lock"
    if ! { helm dependency update "$tmp/cluster-argocd" >"$tmp/dep.log" 2>&1 || { sleep 3; helm dependency update "$tmp/cluster-argocd" >"$tmp/dep.log" 2>&1; }; }; then
        log "FAIL argocd: the dependencies of cluster-argocd cannot be resolved ($(tail -1 "$tmp/dep.log"))"; rm -rf "$tmp"; return 1
    fi
    for f in charts/cluster-argocd/values-app-*.yaml; do
        name=${f##*/}
        if ! helm template argocd-ci "$tmp/cluster-argocd" -f "$f" >"$tmp/out.yaml" 2>"$tmp/err.log"; then
            log "FAIL $name: helm template failed: $(tail -1 "$tmp/err.log")"; rc=1; continue
        fi
        yq e '.application.list[] | .name + "\t" + ((.source.rev // .source.targetRevision // "") | tostring)' "$f" >"$tmp/explicit.tsv" 2>/dev/null
        yq e 'select(.kind == "Application") | .metadata.name + "\t" + (.spec.source.repoURL // "") + "\t" + (.spec.source.targetRevision // "") + "\t" + (.spec.destination.namespace // "")' "$tmp/out.yaml" >"$tmp/apps.tsv" 2>/dev/null
        n=0
        while IFS=$'\t' read -r app repo rev dest; do
            [[ -z $app || $app == '---' ]] && continue
            n=$((n + 1))
            [[ -n $repo ]] || { log "FAIL $name: Application $app has no spec.source.repoURL"; rc=1; }
            [[ -n $dest ]] || { log "FAIL $name: Application $app has no spec.destination.namespace"; rc=1; }
            if [[ -z $rev ]]; then log "FAIL $name: Application $app has no spec.source.targetRevision"; rc=1
            elif [[ $rev == master ]]; then
                explicit=$(awk -F'\t' -v a="$app" '$1 == a {print $2; exit}' "$tmp/explicit.tsv")
                [[ $explicit == master ]] || { log "FAIL $name: Application $app uses the implicit revision master (set source.rev)"; rc=1; }
            fi
        done <"$tmp/apps.tsv"
        [[ $n -gt 0 ]] || { log "FAIL $name: no Application is rendered"; rc=1; }
    done
    for f in charts/*/examples/argocd/*.yaml; do
        if ! yq e '.' "$f" >/dev/null 2>"$tmp/err.log"; then log "FAIL $f does not parse: $(head -1 "$tmp/err.log")"; rc=1; continue; fi
        while IFS= read -r rev; do
            [[ -z $rev || $rev == '---' ]] && continue
            [[ $rev == '21.3.x' ]] || { log "FAIL $f: targetRevision '$rev' of a Helm chart source must be the range 21.3.x"; rc=1; }
        done < <(yq e 'select(.kind == "Application" and ((.spec.source.chart // "") != "")) | .spec.source.targetRevision' "$f" 2>/dev/null)
    done
    rm -rf "$tmp"
    [[ $rc -eq 0 ]] && log "ok   argocd: $(ls charts/cluster-argocd/values-app-*.yaml | wc -l) values-app files render, $(ls charts/*/examples/argocd/*.yaml | wc -l) examples are valid"
    return $rc
}

case "${1:-all}" in
    static)    static ;;
    charts)    shift; charts "$@" ;;
    chart-one) shift; chart_one "$@" ;;
    argocd)    check_argocd ;;
    toggles)   shift; python3 .tools/render-golden.py toggles "$@" ;;
    schema)    python3 .github/scripts/schema-drift.py $([[ ${CI_SCHEMA_STRICT:-true} == true ]] && echo --strict) ;;
    conventions) shift; python3 .github/scripts/readme-conventions.py "$@" ;;
    all)       rc=0; static || rc=1; charts || rc=1; check_argocd || rc=1; exit $rc ;;
    *)         sed -n '2,19p' "${BASH_SOURCE[0]}"; exit 2 ;;
esac
