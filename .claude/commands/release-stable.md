# release-stable

Promote `master` to `stable`: merge, publish stable/noschema/current repos, and propagate to all `stable-4.x` branches.

## Usage

```
/release-stable
```

No arguments. The version is inherited from the master branch state (already promoted by `/release-master`).

## What this command does

1. Verifies `master` is clean, committed, and pushed
2. Merges `master` → `stable`
3. Runs `make publish` — regenerates stable + noschema + release-XX repos and uploads to S3
4. Discovers all `stable-4.x` remote branches dynamically
5. Merges `stable` into each `stable-4.x` branch and pushes
6. Pushes `stable` to `origin` and `gitlab`
7. Creates a git tag for the release
8. Returns to `devel`

**Does NOT** bump chart versions (that was done by `/release-devel`).
**Requires** `/release-master` to have been run first.

## Instructions

You are executing the release-stable command. No arguments expected.

**Step 1 — Check master is ready**

Run: `git checkout master`

Run: `git status --short`
If there are uncommitted changes, stop:
```
✗ master has uncommitted changes. Run /release-master first.
```

Run: `git log origin/master..HEAD --oneline`
If there are unpushed commits on master, ask:
```
⚠ master has <n> unpushed commit(s). Push first? [Y/n]
```
If confirmed: `git push origin master && git push gitlab master`

**Step 2 — Read current version**

Read `.tools/repo-release` for the version being promoted.

**Step 3 — Confirm**

```
Merging master → stable
Version   : <version from .tools/repo-release>
Repos     : stable, noschema, release-<STABLE_MAINRELEASE>
Branches  : stable + all stable-4.x
Tag       : <version>

⚠ This is the production-facing release. Proceed? [y/N]
```
Stop if not confirmed.

**Step 4 — Merge master → stable**

```bash
git checkout stable
git merge master --no-edit -m "chore: merge master into stable for release <version>"
```

**Step 5 — Publish stable+noschema+current repos**

```bash
make publish
```

**Step 6 — Propagate to stable-4.x branches**

Discover branches:
```bash
git fetch --all --prune
git branch -r | grep 'origin/stable-4\.'
```

For each `origin/stable-4.X` found:
```bash
git checkout -B stable-4.X origin/stable-4.X
git merge stable --no-edit -m "chore: auto-merge stable into stable-4.X for release <version>"
git push origin stable-4.X
git push gitlab stable-4.X
```

If a merge fails (conflict):
```
⚠ Conflict on stable-4.X — skipped. Resolve manually:
  git checkout stable-4.X
  git merge stable
```
Continue with remaining branches (do not stop).

**Step 7 — Create release tag**

```bash
git tag "<version>" -m "[release/<version>] stable release"
git push origin "<version>"
git push gitlab "<version>"
```

**Step 8 — Push stable and return to devel**

```bash
git push origin stable
git push gitlab stable
git checkout devel
```

**Step 9 — Report**

```
✓ stable released — version <version>

Tag             : <version>
Published repos : stable, noschema, release-<STABLE_MAINRELEASE>
Propagated to   : stable-4.11, stable-4.12, ... (list successful branches)
Skipped (conflict): ... (list failed branches, if any)

Release complete. To install from stable:
  helm repo add startx https://<HELM_REPO_BASEURL>/stable
  helm repo update
```
