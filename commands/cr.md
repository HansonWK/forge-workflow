---
description: Code review a branch without leaving your current work
argument-hint: <branch-name> (optional - reviews current branch if omitted)
---

# Code Review

Run a code review (and security review if applicable) without interrupting your current workflow.

## Arguments

$ARGUMENTS — Optional branch name to review. If omitted, reviews the current branch.

## Mode Selection

- **`$ARGUMENTS` is empty or matches the current branch** → Mode 2 (foreground, no worktree, live feedback)
- **`$ARGUMENTS` is a different branch** → Mode 1 (background, isolated worktree)

## Context Gathering

Before launching the review, gather context about _why_ the changes were made. This context is passed to the review agent so it can assess whether the implementation matches the intent.

### Steps:

1. **Ticket** — If the branch name starts with a ticket ID pattern (e.g., `PROJ-1234-...`, `BOARD-123-...`), fetch the ticket using the `ticket-tracker` agent:

   - The `ticket-tracker` agent will fetch the ticket and extract: title, description, and acceptance criteria
   - If the agent is not configured or the fetch fails, skip silently

2. **PR description** — Always check for an open PR regardless of whether a ticket was found:

   ```bash
   gh pr view "$BRANCH_NAME" --json title,body --jq '.title + "\n\n" + .body' 2>/dev/null
   ```

   - If a PR exists and has a non-empty body, include the title + body

3. **Combine context** — Build `REVIEW_CONTEXT` from all available sources:
   - If both ticket and PR description exist, include both (ticket first, then PR description)
   - If only one exists, use that
   - If neither is available, infer from branch name: `"No ticket or PR description available. Branch name: $BRANCH_NAME — likely a bugfix or improvement based on the branch name. Review should focus on whether the changes are sensible given this context."`

Include the gathered `REVIEW_CONTEXT` in the agent prompt so it can validate the implementation against the stated goals.

## Mode 1: Review another branch (branch name provided)

When a branch name is provided, spin up an **isolated background agent** so the developer can keep working.

### Steps

1. **Fetch latest** so the branch is available locally:

```bash
git fetch origin
```

2. **Validate the branch exists**:

```bash
git branch -r --list "origin/$BRANCH_NAME"
```

If not found, try matching partially (the user may have omitted a prefix). If still not found, tell the user and stop.

3. **Gather context** using the Context Gathering steps above.

4. **Launch an isolated background agent** using the Agent tool with:

   - `isolation: "worktree"` — works on a separate copy of the repo
   - `run_in_background: true` — doesn't block the developer
   - `subagent_type: "pr-sanity-check"` — the code review agent

   The agent prompt should instruct it to:

   - Check out the target branch in the worktree
   - Run `git diff main...HEAD --name-only` to identify changed files
   - **Use the provided `REVIEW_CONTEXT`** to understand the intent behind the changes and validate that the implementation matches
   - Apply the `code-review` skill: implementation quality, design, tests, bugs, and security concerns
   - If acceptance criteria were provided from the ticket, explicitly check whether each criterion is met
   - Classify issues by severity (Critical / High / Medium / Low)
   - If any service-level code was changed, check for security concerns (input validation, auth, secrets, injection)
   - Produce a structured report
   - **⛔ READ-ONLY: The agent MUST NOT edit, create, or modify any files. This is a review of a remote branch — the purpose is to produce a report, not to make fixes. Do not use the Edit, Write, or NotebookEdit tools. Do not run `npm run format` or any command that modifies files. Only read files, run searches, and run read-only commands (e.g. tests, git diff).**
   - **Clean up**: when finished, remove the worktree by running `git worktree remove <worktree-path> --force`

5. **Inform the user** that the review is running in the background and they'll be notified when it completes. Include the branch name being reviewed.

6. **When the agent completes**, save the full structured review report to `.claude/temp/cr/<branch-name>.md` (create the `cr/` directory if needed). Use the branch name as the filename, replacing `/` with `-`.

   The full report saved to file should follow this format:

```markdown
# Code Review: <branch-name>

**Date**: <YYYY-MM-DD>
**Files changed**: <N>
**Verdict**: PASS | NEEDS ATTENTION | FAIL

## Critical Issues

[List or "None"]

## High Issues

[List or "None"]

## Medium Issues

[List or "None"]

## Low Issues

[List or "None"]

## Security Notes

[Any security-relevant observations, or "No security concerns identified"]

## Acceptance Criteria Check

[If the ticket had acceptance criteria, list each criterion with PASS/FAIL/PARTIAL. Otherwise omit this section.]

## Summary

[2-3 sentence overview of the changes and overall quality]
```

7. **Present a brief overview to the user** — not the full report. Include:

   - Verdict (PASS / NEEDS ATTENTION / FAIL)
   - Count of issues by severity
   - The 2-3 sentence summary
   - A clickable link to the full review file using its absolute path

   Example output:

   ```
   Code Review: feature/my-branch — NEEDS ATTENTION
   Critical: 0 | High: 2 | Medium: 3 | Low: 1

   Summary: The implementation correctly handles the new media types but
   is missing input validation on the Service Bus handler. Test coverage
   is good but two edge cases are untested.

   Full review: /absolute/path/.claude/temp/cr/feature-my-branch.md
   ```

## Mode 2: Review current branch (no branch name provided)

When no branch name is provided, run the review on the current branch directly (no worktree needed).

### Steps

1. **Gather context** using the Context Gathering steps above (using the current branch name).

2. Launch the `pr-sanity-check` agent (foreground, no isolation needed since we're already on the branch):

   - **Include the gathered `REVIEW_CONTEXT`** in the agent prompt
   - Review all changes compared to main: `git diff main...HEAD`
   - Include any uncommitted/unstaged changes
   - If acceptance criteria were provided, check each one
   - Full code review + security check
   - Classify issues by severity

3. Present the same structured report format as Mode 1.

## Rules

- **Never switch the developer's current branch** — that's the whole point of this command
- **Mode 1 is strictly read-only** — when reviewing a remote branch, the agent must NEVER modify any files. No edits, no formatting, no fixes. The output is a report only. Changes to a remote branch cannot help the developer and would pollute the worktree or current branch.
- Background agents in worktrees are fully isolated — no risk to current work
- The review should consider the full changeset against main, not individual commits
- Only flag issues in changed code, not pre-existing problems
- If the branch has changes in security-sensitive directories, include security observations
- Keep the report actionable — specific files, line numbers, and fix suggestions
- For a second opinion from a *different* model, run `/double-check` (the `double-check` skill)
