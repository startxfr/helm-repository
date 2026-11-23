#!/usr/bin/env bash
# dep-golden.sh <dep chart> <patch> <base commit> <dependent chart ...> : render-golden of dependents with the patched <dep> packaged at their pinned version.
# Trees: $S/r3f/before (clean archive of base) and $S/r3f/after (base + patch). Needs the network (helm dependency update --skip-refresh).
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}
dep=$1; patch=$2; base=$3; shift 3
G=$S/r3f; export JOBS=${JOBS:-3}
for c in "$@"; do
  [[ $c == $dep ]] && continue
  (cd $G/before && helm dependency update --skip-refresh charts/$c >/dev/null 2>&1) || echo "WARN dependency update $c"
  mkdir -p $G/after/charts/$c/charts; cp $G/before/charts/$c/charts/*.tgz $G/after/charts/$c/charts/
  for t in before after; do
    for al in $(yq e '.dependencies[] | select(.name=="'$dep'") | .version' $G/$t/charts/$c/Chart.yaml | head -1); do pin=$al; done
    rm -rf $G/pk-$t-$c && mkdir -p $G/pk-$t-$c && cp -r $G/$t/charts/$dep $G/pk-$t-$c/$dep && rm -rf $G/pk-$t-$c/$dep/charts && sed -i "s/^version: .*/version: $pin/" $G/pk-$t-$c/$dep/Chart.yaml
    rm -f $G/$t/charts/$c/charts/$dep-*.tgz; helm package $G/pk-$t-$c/$dep -d $G/$t/charts/$c/charts >/dev/null 2>&1 || echo "WARN package $t $c"
  done
done
for t in before after; do (cd $G/$t && GOLDEN_ROOT=$G/$t python3 .tools/render-golden.py snapshot $G/snap-$t "$@" >$G/snap-$t.log 2>&1; echo "snapshot $t rc=$?"); done
python3 $G/after/.tools/render-golden.py compare $G/snap-before $G/snap-after | tail -12
echo "ERROR cases before: $(grep -rl '^ERROR' $G/snap-before | wc -l) after: $(grep -rl '^ERROR' $G/snap-after | wc -l); cases: $(find $G/snap-after -type f | wc -l)"
