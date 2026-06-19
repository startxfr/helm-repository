# release-master

Promote the `devel` branch to `master`: merge, publish stable/noschema/current repos, and propagate to all `master-4.x` branches.

## Usage

```
/release-master
```

No arguments. The version is inherited from the devel branch state (already bumped by `/release-devel`).

## What this command does

1. Verifies `devel` is clean, committed, and pushed
2. Merges `devel` → `master`
3. Runs `make publish` - regenerates stable + noschema + release-XX repos and uploads to S3
4. Discovers all `master-4.x` remote branches dynamically
5. Merges `master` into each `master-4.x` branch and pushes
6. Pushes `master` to `origin` and `gitlab`
7. Returns to `devel`

**Does NOT** bump chart versions (that was done by `/release-devel`).
**Does NOT** touch `stable`. Use `/release-stable` to promote to stable.

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
Branches  : master + all master-4.x

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

**Step 6 - Propagate to master-4.x branches**

Discover branches:
```bash
git fetch --all --prune
git branch -r | grep 'origin/master-4\.'
```

For each `origin/master-4.X` found:
```bash
git checkout -B master-4.X origin/master-4.X
git merge master --no-edit -m "chore: auto-merge master into master-4.X for release <version>"
git push origin master-4.X
git push gitlab master-4.X
```

If a merge fails (conflict):
```
⚠ Conflict on master-4.X - skipped. Resolve manually:
  git checkout master-4.X
  git merge master
```
Continue with remaining branches (do not stop).

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
Propagated to   : master-4.11, master-4.12, ... (list successful branches)
Skipped (conflict): ... (list failed branches, if any)

Next: run /release-stable to promote master → stable.
```
