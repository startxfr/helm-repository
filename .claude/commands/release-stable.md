# release-stable

Promote `master` to `stable`: merge, publish stable/noschema/current repos.

## Usage

```
/release-stable
```

No arguments. The version is inherited from the master branch state (already promoted by `/release-master`).

## What this command does

1. Verifies `master` is clean, committed, and pushed
2. Merges `master` → `stable`
3. Runs `make publish` - regenerates stable + noschema + release-XX repos and uploads to S3
6. Pushes `stable` to `origin` and `gitlab`
7. Creates a git tag for the release
8. Returns to `devel`

**Does NOT** bump chart versions (that was done by `/release-devel`).
**Requires** `/release-master` to have been run first.

> **Note (2026-11)**: set `.tools/repo-release` to the highest released version before this step: the tag is created from it and an existing tag cannot be reused.

## Instructions

You are executing the release-stable command. No arguments expected.

**Step 1 - Check master is ready**

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

**Step 2 - Read current version**

Read `.tools/repo-release` for the version being promoted.

**Step 3 - Confirm**

```
Merging master → stable
Version   : <version from .tools/repo-release>
Repos     : stable, noschema, release-<STABLE_MAINRELEASE>
Branches  : stable only
Tag       : <version>

⚠ This is the production-facing release. Proceed? [y/N]
```
Stop if not confirmed.

**Step 4 - Merge master → stable**

```bash
git checkout stable
git merge master --no-edit -m "chore: merge master into stable for release <version>"
```

**Step 5 - Publish stable+noschema+current repos**

```bash
make publish
```

**Step 6 - stable-4.x branches (retired)**

The propagation to the `stable-4.x` branches is retired (decision 2026-11-19): those branches map to old OpenShift releases and the step failed on ambiguous refs. Do nothing here; tell the user if a `stable-4.x` branch must be updated and do it manually with explicit `refs/remotes/origin/...` references.

**Step 7 - Create release tag**

```bash
git tag "<version>" -m "[release/<version>] stable release"
git push origin "<version>"
git push gitlab "<version>"
```

**Step 8 - Push stable and return to devel**

```bash
git push origin stable
git push gitlab stable
git checkout devel
```

**Step 9 - Report**

```
✓ stable released - version <version>

Tag             : <version>
Published repos : stable, noschema, release-<STABLE_MAINRELEASE>
Propagated to   : (retired)
Skipped (conflict): ... (list failed branches, if any)

Release complete. To install from stable:
  helm repo add startx https://<HELM_REPO_BASEURL>/stable
  helm repo update
```
