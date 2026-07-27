---
description: Full release workflow — generate changelog and bump version across all packages
argument-hint: <version e.g. 1.4.0>
---

<!--
  REFERENCE EXAMPLE — monorepo release (changelog + multi-package version bump).

  Fully-worked implementation of the generalized `/release` command for a repo with
  several package.json files whose versions are kept in lockstep. When adapting
  during /install: DETECT the real set of files that carry a version (root
  package.json plus workspace packages, or Cargo.toml, pyproject.toml, etc.), the
  real version-bump mechanism, and whether a CI workflow (.github/workflows/*.yml)
  already performs part of this. Ask the user to confirm the file list — getting it
  wrong ships a half-bumped release. Keep the "changelog first, approve, then bump,
  then report — never commit/push" spine.
-->

# Release Workflow

Prepare a full release for version **$ARGUMENTS**.

## Step 1: Resolve Version

If `$ARGUMENTS` is empty or not a valid semver (pattern: `^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$`), ask the user:

```
What version are we releasing? (e.g. 1.4.0)
```

Store the confirmed value as `$VERSION` for all subsequent steps.

## Step 2: Generate Changelog

Follow every step from the `/changelog` command using `$VERSION` as the version argument:

1. Find the previous release commit to determine the commit range
2. Extract all PR merge commits in that range
3. Analyse and categorise each change (Features, Bug Fixes, Refactoring, Infrastructure & DevOps, Documentation)
4. Create `changelog/CHANGELOG-$VERSION.md` using the standard format
5. **STOP** — present the changelog to the user and wait for approval before continuing

Do not proceed to the next step until the user has approved the changelog content.

## Step 3: Bump Version Numbers

Update the `"version"` field to `$VERSION` in each versioned package file. This list is
project-specific — `/install` fills it in from the detected workspace layout. For example:

- `package.json` (root)
- `packages/*/package.json` (each workspace package)

For each file, read it, update only the top-level `"version"` field, and write it back. Do not modify any other fields or dependency version references.

## Step 4: Install and Format

Run the package manager's install to sync the lockfile with the updated root version, then format:

```bash
# e.g. npm install / pnpm install / yarn install
# then the project's format command
```

## Step 5: Report

List every file that was updated and confirm:

```
Release $VERSION prepared.

Changelog: changelog/CHANGELOG-$VERSION.md
Version bumped in N files:
  ✓ package.json
  ✓ packages/foo/package.json
  ...

Next steps:
- Review and commit all changes with message: "RELEASE: v$VERSION"
- Push and create a PR targeting the default branch
```

## Rules

- Never commit or push — the user handles all git operations
- Do not proceed past Step 2 without explicit changelog approval from the user
- Only bump the top-level `"version"` field — do not touch dependency version references
- Keep the versioned-file list in sync with the real project layout
