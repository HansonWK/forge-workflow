---
description: Full release workflow — generate changelog and bump version across all packages
argument-hint: <version e.g. 1.4.0>
---

# Release Workflow

Prepare a full release for version **$ARGUMENTS**: generate the changelog, then bump the version everywhere it lives.

> A fully-worked reference implementation lives at
> `.claude/examples/release/release-monorepo.md`. `/install` (release module) records
> the exact set of versioned files and the bump mechanism in the `## Release` section
> of `docs/workflow-config.md`. If a CI workflow already performs part of the release,
> `/install` aligns this command with it rather than duplicating it.

## Step 1: Resolve the version

If `$ARGUMENTS` is empty or not valid semver (`^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$`), ask the user for the version. Store it as `$VERSION`.

## Step 2: Generate the changelog

Follow every step of `/changelog` with `$VERSION`. **STOP** and get explicit approval of the changelog before continuing.

## Step 3: Bump version numbers

Update the top-level `"version"` (or the language equivalent) to `$VERSION` in each versioned file listed under `## Release` in `docs/workflow-config.md`. Read, change only the version field, write back. Do not touch dependency version references.

## Step 4: Sync and format

Run the package manager's install to sync the lockfile, then the project's format command.

## Step 5: Report

List every file updated and give the next steps (commit with the project's release-commit message convention, push, open a PR to the default branch).

## Rules

- Never commit or push — the user handles all git operations
- Do not proceed past Step 2 without explicit changelog approval
- Only bump version fields — never dependency version references
- Keep the versioned-file list in `docs/workflow-config.md` in sync with the real layout
