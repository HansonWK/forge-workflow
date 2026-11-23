---
description: Open the pull request once sign-off has covered every commit
---

# Pull Request

`/signoff` carries on into this. Run it directly for an early PR, or after `/signoff`.

## Step 1: Sign-off gate

Read `signoff_commit` in the work folder's `status.md`. If it's missing, or
`git log <signoff_commit>..HEAD --oneline` isn't empty:

```
Sign-off hasn't covered <N> commit(s) (or hasn't run). Run /signoff, or say "go anyway".
```

**STOP.** On "go anyway", carry on and list what wasn't signed off (the commits, or the checks that
didn't run) under "Not signed off" in the description. **Early PR** (the developer asked while
`/signoff` runs) skips the gate and asks the Step 5 question; update the description when the checks
finish.

For **large or high-stakes** change sets, also consider `/double-check` — an independent second
opinion from a different AI CLI (the `double-check` skill) — before opening the PR. If the change is
large or mixes concerns, consider `/slice` first (the `slicing` skill) — it may want to be a stack of
smaller PRs.

## Step 2: Verify Plan Complete

Find the active plan (`.claude/temp/work/*/plan.md`) and check every subtask has a `**SHA:**` (an older
plan: `- [x] Dev` and `- [x] Present`), or is marked as left for another PR.

If incomplete:

```
Plan is not complete.

Remaining subtasks:
- Subtask <N>: <title> (needs: Dev, Proved, commit)

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

## Proof

<Each AC: how it was proved, with the evidence (a log line, script output, a screenshot)>

## Test plan

<Bulleted checklist of how to verify the changes on the PR's environment and on dev>

## Not signed off

<Only after "go anyway": the commits or checks sign-off didn't cover>
```

**Where to get the information:**

- **Ticket ID**: from plan metadata or branch name
- **Problem**: from research.md or task description — what was the user trying to solve?
- **Changes**: from git diff and plan subtasks
- **Proof**: from plan.md's ACs, `## Proofs` in status.md and the proof folder
- **Test plan**: the Test-on-dev steps `/signoff` wrote

## Step 5: Ask once

The work is not pushed when `git log @{u}..HEAD --oneline` lists commits or fails (no upstream).
Show the preview and end it with the one question:

```markdown
## Pull Request Preview

**Title:** <TICKET-ID>: <short description>

**Description:**
<generated description using template above>

---

The current work is not pushed. Approve to push and open the PR?
```

When it's already pushed, the question is `Approve to open the PR?`. An early PR asks the same.

**STOP and wait.** Any yes ("yes", "go", "approved", `/next`) approves the push, the title and the
description together. Feedback instead changes the title or description; show them again with the
same question.

## Step 6: Push and open the PR

On the yes, push through the push script (skip it when already pushed), then open the PR/MR in the
browser so the user can make final edits before submitting, using the configured git hosting and
default branch (see `docs/workflow-config.md`):

```bash
bash .claude/scripts/push-branch.sh
# GitHub (default). For GitLab use `glab mr create`; for Bitbucket, open the PR link the script printed.
gh pr create --base <default-branch> --title "<title>" --body "<description>" --web
```

If the script refuses, show its reason and stop: never push another way.

**IMPORTANT:** Always open the PR in the browser (GitHub's `--web`, or the platform equivalent) rather than submitting it directly. The user reviews and makes final edits before clicking "Create" on the hosting site. Do NOT create the PR without opening it for review.

## Step 7: Update Plan and Status

Update plan.md:

- Set Status to `COMPLETE`
- Add PR link if desired

Update `status.md` in the same work folder:

- Set `work_status: review` and `stage: PR` (`/status` moves it to `merged` once the branch merges)
- Set `pr_url` once the PR exists (`gh pr view --json url -q .url`)

In page mode, update progress: the Test-on-dev tab appears, and the Sign-off tab links the PR.

## Step 8: Report

```
PR opened in the browser: <url, once created>
Work page: <url>      (page mode)

Next: test on the PR's environment (or dev) — the Test on dev tab, or `## Test on dev` in status.md.
Once it passes, I'll offer a comment for the ticket setting out the proof.
```

After the run passes, draft the ticket comment (each AC, how it was proved, the evidence, the PR
link), show it, and post it only on the developer's yes, through the `ticket-tracker` agent's Comment
action. Never put secrets, personal data or private record content in it. In page mode, once the
Test-on-dev tab is complete after the merge, ask once about deleting the page (`work-page` → After
the merge).

## Rules

- NEVER create PR with incomplete commits
- NEVER push or open the PR before the developer's yes to the Step 5 question
- Push only through `.claude/scripts/push-branch.sh`; any other push goes through the permission prompt
- Use pr-description agent for consistent formatting
