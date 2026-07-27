---
description: Generate a changelog for a release version
argument-hint: <version e.g. 1.0.1>
---

<!--
  REFERENCE EXAMPLE — changelog from git PR-merge history.

  This is a fully-worked implementation of the generalized `/changelog` command.
  It derives a changelog from squash-merged PR commits (the `(#NNN)` pattern) and a
  RELEASE-commit convention. Almost all of this is provider-neutral. When adapting
  during /install: detect the project's real release-commit format (grep git log),
  the real PR-merge pattern, and whether they cut releases from `main` or from tags,
  and adjust Step 1-2 accordingly. If the project has a CHANGELOG.md convention or
  a CI release workflow (.github/workflows), align the output format to it.
-->

# Generate Release Changelog

Generate a technical-but-readable changelog for version **$ARGUMENTS**.

## Step 1: Determine Commit Range

This command is run **before** the RELEASE commit is created. The workflow is:

1. Developer bumps package versions
2. This command generates the changelog from the previous release to HEAD
3. Developer creates the RELEASE commit with the changelog included

Find the previous release commit (the start of the range). Release commits may use different formats (`RELEASE: v1.0.1`, `Rel v1.0.2`, etc.), so search flexibly:

```bash
git log --format="%h %s" --first-parent | grep -iE "(RELEASE|Rel):?\s*v[0-9]" | head -5
```

Pick the most recent release commit — this is the start boundary. If none found, ask the user for a start date and use `--after="<date>"`.

The commit range is: **previous release commit..HEAD** (exclusive of the release commit itself, inclusive of HEAD).

## Step 2: Extract PR Merge Commits

Get all PR merge commits in the range (commits matching `(#NNN)` pattern):

```bash
git log --format="%h|%an|%ad|%s" --date=format:"%Y-%m-%d %H:%M" --first-parent <range> | grep -E "\(#[0-9]+\)"
```

These represent reviewed, complete units of work merged via pull request.

## Step 3: Analyse and Categorise Changes

For each PR merge commit, read the full commit message and the diff summary to understand what changed:

```bash
git show --stat <hash>
git log -1 --format="%B" <hash>
```

Categorise each change into one of these sections (skip empty sections):

- **Features** - New functionality
- **Bug Fixes** - Corrections to existing behavior
- **Refactoring** - Code improvements without behavior changes
- **Infrastructure & DevOps** - CI/CD, deployment, monitoring, performance testing
- **Documentation** - Documentation changes

Use your judgement based on the commit message, PR title, and files changed. A single PR may touch multiple areas - categorise by primary intent.

## Step 4: Generate Changelog

Create the file at `changelog/CHANGELOG-$ARGUMENTS.md` with this format:

```markdown
# Release $ARGUMENTS

**Release date:** <today's date, YYYY-MM-DD>
**Commits included:** <count> pull requests merged

---

## Features

- **<Short description of change>** (<PR link or #NNN>) — <Developer Name>, <YYYY-MM-DD HH:MM>
  <1-2 sentence technical summary of what was added/changed and why it matters>

## Bug Fixes

- **<Short description>** (#NNN) — <Developer Name>, <YYYY-MM-DD>
  <Brief technical summary>

## Refactoring

...

## Infrastructure & DevOps

...

---

_Generated from git history. For detailed changes, see individual pull requests._
```

### Formatting Rules

- Each entry has a **bold title** derived from the PR title (cleaned up for readability)
- PR number as a reference (e.g., #1234)
- Developer name and merge date/time
- A 1-2 sentence technical summary explaining the change in context
- Group related PRs together where they form a logical unit of work
- Within each section, order chronologically (oldest first)
- The summary should be technical but readable by a project manager or test manager

### Wiki / Confluence Compatibility

The markdown format should paste cleanly into a wiki. Use standard markdown:

- Use `#`, `##` for headings
- Use `-` for bullet lists
- Use `**bold**` for emphasis
- Avoid HTML tags or complex markdown features

## Step 5: Present for Review

Show the user the generated changelog content and ask for feedback:

```
Changelog generated at changelog/CHANGELOG-$ARGUMENTS.md

<show full content>

Does this look right, or would you like any changes?
```

**STOP and wait for user feedback.** Iterate on the format and content until the user is happy.

## Step 6: Run Quality Checks

After the changelog is finalised, run the project's format-check, lint, and test commands (see `docs/workflow-config.md`). If format check fails, auto-fix and re-verify. Report the results before considering the task complete.

## Rules

- NEVER include the previous release commit itself (it's just a version bump)
- The range ends at HEAD (the RELEASE commit for this version hasn't been created yet)
- Only include PR merge commits (pattern: `(#NNN)`) to keep it clean
- Keep summaries concise but technically informative
- Use the developer's git author name as-is
- Create the `changelog/` directory if it doesn't exist
