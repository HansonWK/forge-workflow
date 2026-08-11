---
description: Final checks and prepare pull request for current plan
---

# Check Pull Request

Check that all everything has been commited and is ready for a pull request

## Step 1: Check Security Audit Status

Check if `/security` has been run for this plan:

- Look for security audit results in conversation history
- If not run, remind user:

```
Security audit not run. Consider running /security first.
Note this is not neccisary for every PR, so use discretion
Continue with PR anyway? (y/n)
```

If user declines, stop and let them run `/security`.

For **large or high-stakes** change sets, also consider `/double-check` — an independent second
opinion from a different AI CLI (the `double-check` skill) — before opening the PR. If the change is
large or mixes concerns, consider `/slice` first (the `slicing` skill) — it may want to be a stack of
smaller PRs.

## Step 2: Verify Plan Complete

Find the current active plan and verify all subtasks are complete or marked as to do in another PR:

1. Read `.claude/temp/*/plan.md` for active plan
2. Check all subtasks have `- [x] Dev`, `- [x] Review`, `- [x] Present` checked

If incomplete:

```
Plan is not complete.

Remaining subtasks:
- Subtask <N>: <title> (needs: Dev, Review, Present)
- Subtask <M>: <title> (needs: Present)

Run /next to continue.
```

## Step 3: Verify Branch State

```bash
git status
git log main..HEAD --oneline
```

Ensure:

- No uncommitted changes
- Branch has commits ahead of main
- All planned commits are present

If uncommitted changes:

```
Warning: Uncommitted changes detected.
Commit or stash before opening PR? (y/n)
```

## Step 4: Generate PR Description

Use the `pr-description` agent to generate the description, following this structure. The description must start with the ticket context (what problem we're solving) before listing the changes.

**Template:**

```markdown
## Ticket

<TICKET-ID>: <ticket title or one-line problem statement>
<ticket link/reference if available, otherwise omit>

## Problem

<1-3 sentences explaining what was wrong or what needed to change and why>

## Changes

<Bulleted list of what was actually changed>

## Test plan

<Bulleted checklist of how to verify the changes>
```

**Where to get the information:**

- **Ticket ID**: from plan metadata or branch name
- **Problem**: from research.md or task description — what was the user trying to solve?
- **Changes**: from git diff and plan subtasks
- **Test plan**: from test cases written and manual verification steps

## Step 5: Present for Approval

```markdown
## Pull Request Preview

**Title:** <TICKET-ID>: <short description>

**Description:**
<generated description using template above>

---

**Approve?** (y/go, or provide feedback)
```

**STOP and wait for user approval.**

If user provides feedback:

- Adjust title/description
- Present again

## Step 6: Create PR

After approval, open the PR/MR in the browser so the user can make final edits before submitting, using the configured git hosting and default branch (see `docs/workflow-config.md`):

```bash
# GitHub (default). For GitLab use `glab mr create`; for Bitbucket, open the compare URL.
gh pr create --base <default-branch> --title "<title>" --body "<description>" --web
```

**IMPORTANT:** Always open the PR in the browser (GitHub's `--web`, or the platform equivalent) rather than submitting it directly. The user reviews and makes final edits before clicking "Create" on the hosting site. Do NOT create the PR without opening it for review.

## Step 7: Update Plan and Status

Update plan.md:

- Set Status to `COMPLETE`
- Add PR link if desired

Update `status.md` in the same task directory:

- Set `work_status` to `merged`
- Set `merged_date` to today's date
- Add the PR URL as a new line: `- pr_url: <url>`

## Step 8: Report

```
PR created: <url>

Plan '<plan-name>' is now complete.
```

## Rules

- NEVER create PR with incomplete commits
- NEVER create PR without user approval of title/description
- Always ask user to push branch before creating PR
- Use pr-description agent for consistent formatting
