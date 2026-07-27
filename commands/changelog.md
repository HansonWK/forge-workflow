---
description: Generate a changelog for a release version from git history
argument-hint: <version e.g. 1.0.1>
---

# Generate Release Changelog

Generate a technical-but-readable changelog for version **$ARGUMENTS** from the project's git history.

> A fully-worked reference implementation lives at
> `.claude/examples/release/changelog-git.md`. `/install` (release module) detects
> the project's real release-commit format and PR-merge convention and tailors this
> command; the `## Release` section of `docs/workflow-config.md` records them.

## Step 1: Determine the commit range

The previous release marks the start of the range. Find it using the project's release-commit convention (see `docs/workflow-config.md`); release commits often vary in format, so search flexibly:

```bash
git log --format="%h %s" --first-parent | grep -iE "(RELEASE|Rel):?\s*v[0-9]" | head -5
```

Pick the most recent release commit as the start boundary (exclusive). If none is found, ask the user for a start date and use `--after="<date>"`. The range ends at HEAD.

## Step 2: Extract the merged work

Get the PR merge commits in the range (adjust the pattern to the project's merge convention):

```bash
git log --format="%h|%an|%ad|%s" --date=format:"%Y-%m-%d %H:%M" --first-parent <range> | grep -E "\(#[0-9]+\)"
```

## Step 3: Analyse and categorise

For each merged PR, read its message and diff summary (`git show --stat <hash>`, `git log -1 --format="%B" <hash>`) and categorise by primary intent: **Features**, **Bug Fixes**, **Refactoring**, **Infrastructure & DevOps**, **Documentation**. Skip empty sections.

## Step 4: Generate the changelog

Write `changelog/CHANGELOG-$ARGUMENTS.md` (create the `changelog/` dir if needed). Each entry: a bold cleaned-up title, the PR reference, author and date, and a 1-2 sentence technical summary readable by a PM or test manager. Order chronologically within each section. Use plain markdown that pastes cleanly into a wiki.

## Step 5: Present for review

Show the full generated changelog and ask for feedback. **STOP and wait.** Iterate until the user is happy.

## Step 6: Verify

Run the project's format-check, lint, and test commands (see `docs/workflow-config.md`); auto-fix formatting and re-verify. Report results.

## Rules

- Never include the previous release commit itself (it's just a version bump)
- Only include reviewed/merged work to keep it clean
- Keep summaries concise but technically informative; use the git author name as-is
