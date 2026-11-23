#!/usr/bin/env bash
# Emit one line per new commit touching charts/ or .tools/, and one line when the set of
# uncommitted chart files changes in the shared working copy.
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)" || exit 1
last_head=$(git rev-parse HEAD 2>/dev/null)
last_dirty=$(git status --porcelain -- charts .tools .claude 2>/dev/null | sort)
while true; do
    head=$(git rev-parse HEAD 2>/dev/null || echo "$last_head")
    if [[ $head != "$last_head" ]]; then
        git log --format='COMMIT %h %s' "$last_head..$head" 2>/dev/null | while read -r line; do
            h=$(awk '{print $2}' <<<"$line")
            files=$(git show --name-only --format= "$h" | grep -E '^(charts|\.tools|\.claude)/' | cut -d/ -f1-2 | sort -u | tr '\n' ' ')
            [[ -n $files ]] && echo "$line :: $files"
        done
        # any commit touching charts/, .tools/ or .claude/ counts as a change
        git diff --quiet "$last_head" "$head" -- charts .tools .claude 2>/dev/null || emitted=1
        last_head=$head
    fi
    dirty=$(git status --porcelain -- charts .tools .claude 2>/dev/null | sort)
    if [[ $dirty != "$last_dirty" ]]; then
        new=$(comm -13 <(echo "$last_dirty") <(echo "$dirty") | awk '{print $2}' | cut -d/ -f1-2 | sort -u | tr '\n' ' ')
        [[ -n $new ]] && { echo "WORKTREE changed: $new"; emitted=1; }
        last_dirty=$dirty
    fi
    # ONESHOT=1: stop after the first reported change (background wait without expiry)
    [[ ${ONESHOT:-0} == 1 && ${emitted:-0} == 1 ]] && exit 0
    sleep 20
done
