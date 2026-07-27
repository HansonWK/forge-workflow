---
description: Fix all issues from one audit dimension file, grouped into one or more PRs
argument-hint: <target> <dimension> [date]
---

# Audit Fix

Take one dimension file produced by `/audit` and implement its fixes, grouping the work into a single PR or multiple PRs at your discretion.

## Arguments

$ARGUMENTS — `<target> <dimension>` and an optional `<date>`.

- `<target>` — the audited target (e.g. a service or package name).
- `<dimension>` — the file slug (e.g. `dead-code`, `potential-bugs`, `type-safety`).
- `<date>` — optional `YYYY-MM-DD`. If omitted, use the **most recent** `.claude/audit/<date>/` folder that contains this file.

## Step 1: Load the audit file

Read `.claude/audit/<date>/<target>/<dimension>.md` (if models were nested, read the requested model's copy, else the single file). If it doesn't exist, list what audit files DO exist for that target and stop.

Parse every issue with its ID (`H1`, `M2`, …), location, fix, and effort.

## Step 2: Propose a fix plan (get approval first)

Do NOT touch code yet. Decide grouping:

- **Single PR** — the default when the fixes are cohesive and small/medium in total.
- **Multiple PRs** — when there are many High issues, or the fixes are logically separable (e.g. split risky behavioural fixes from safe dead-code deletion), or the diff would be too large to review well. Use your judgement.

Present the plan (PR groups with issue IDs, and anything excluded with a reason). **STOP and wait for approval.** The user may re-group, drop issues, or approve.

## Step 3: Implement, one PR group at a time

For each approved group, in order:

1. Create a branch off the default branch (naming: `audit/<target>-<dimension>-<n>`, or a ticket ID if the user gives one).
2. Implement the fixes for that group exactly as described. If a fix is wrong or unsafe on inspection, stop and flag it rather than guessing.
3. Add/adjust tests per the project's testing guidelines — behaviour, not implementation detail.
4. Run the project's test, lint, and format-check commands (see `docs/workflow-config.md`) and fix failures.
5. Present the group's changes (files, tests, what each issue ID resolved). **Do not commit or push.**

## Step 4: Hand off

After each group is implemented and green, report which issue IDs were resolved and the branch name, then tell the user to commit and run `/pr`. Continue to the next group only after the user confirms.

## Step 5: Mark progress in the audit file

As issues are resolved, prefix the resolved issue heading with `[FIXED]` (e.g. `### [H1] [FIXED] ...`) so re-runs are idempotent. Do not delete issues.

## Rules

- Follow the project's commit/push policy (by default, do not commit or push — the user does).
- Implement only what's in the audit file (plus the tests those fixes need). No drive-by changes.
- If a fix turns out to be wrong or needs a product decision, skip it and report — don't force it.
- Keep each PR group independently reviewable and green before moving on.
- If shared schema/enum values change, update the shared definition in the same group.
