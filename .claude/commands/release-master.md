# release-master

Promote the `devel` branch to `master`: merge, publish stable/noschema/current repos.

## Usage

```
/release-master
```

No arguments. The version is inherited from the devel branch state (already bumped by `/release-devel`).

## What this command does

1. Verifies `devel` is clean, committed, and pushed
2. Merges `devel` → `master`
3. Runs `make publish` - regenerates stable + noschema + release-XX repos and uploads to S3
6. Pushes `master` to `origin` and `gitlab`
7. Returns to `devel`

**Does NOT** bump chart versions (that was done by `/release-devel`).
**Does NOT** touch `stable`. Use `/release-stable` to promote to stable.

> **Note (2026-11)**: `make publish` already merges `devel` into `master` and pushes both, so Step 4 only matters when `master` must be merged without publishing. The `-4.x` propagation is retired (Step 6).

## Instructions

You are executing the release-master command. No arguments expected.

**Step 1 - Check devel is ready**

Run: `git branch --show-current`
If not `devel`, run `git checkout devel`.

Run: `git status --short`
If there are uncommitted changes, stop:
```
✗ devel has uncommitted changes. Commit or stash before releasing to master.
```

Run: `git log origin/devel..HEAD --oneline`
If there are unpushed commits, ask:
```
⚠ devel has <n> unpushed commit(s):
<list>
Push devel first? [Y/n]
```
If confirmed (or default): `git push origin devel && git push gitlab devel`

**Step 2 - Read current version**

Read `.tools/repo-release` for the version being promoted.

**Step 3 - Confirm**

```
Merging devel → master
Version   : <version from .tools/repo-release>
Repos     : stable, noschema, release-<STABLE_MAINRELEASE>
Branches  : master only

Proceed? [y/N]
```
Stop if not confirmed.

**Step 4 - Merge devel → master**

```bash
git checkout master
git merge devel --no-edit -m "chore: merge devel into master for release <version>"
```

**Step 5 - Publish stable+noschema+current repos**

```bash
make publish
```

**Step 6 - master-4.x branches (retired)**

The propagation to the `master-4.x` branches is retired (decision 2026-11-19): those branches map to old OpenShift releases and the step failed on ambiguous refs. Do nothing here; tell the user if a `master-4.x` branch must be updated and do it manually with explicit `refs/remotes/origin/...` references.

**Step 7 - Push master**

```bash
git push origin master
git push gitlab master
git checkout devel
```

**Step 8 - Report**

```
✓ master released - version <version>

Published repos : stable, noschema, release-<STABLE_MAINRELEASE>
Propagated to   : (retired)
Skipped (conflict): ... (list failed branches, if any)

Next: run /release-stable to promote master → stable.
```
