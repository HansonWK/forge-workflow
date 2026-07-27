---
description: Run review phase for current changes
---

# Review Phase

## Prerequisites

- Active plan with the current subtask's Dev complete, **or** uncommitted/unstaged changes to review.
- May be called outside the cycle — then ignore the plan.md steps.

## Instructions

### 1. Code review

Apply the **`code-review` skill** to the current changes (or dispatch the `pr-sanity-check` agent to
run it in the background / a worktree). It classifies findings by severity.

Act on severity:

- **Critical / High** — prompt the user, then fix immediately and re-review until none remain.
- **Medium** — fix if straightforward, otherwise note for Present.
- **Low** — note for the user; don't block.

### 2. Logging (only if the observability module is installed)

If `docs/logging-strategy.md` exists and the changes touch handlers/consumers/business logic, apply
the **`logging-compliance` skill** and flag issues as Medium.

### 3. Update plan and status

Check `- [x] Review` in plan.md for this subtask, and set `work_status: review` in status.md.

## After review

Report counts by severity (Critical/High resolved; Medium/Low noted), then continue to `/present`.

## Rules

- Always run the code review; never proceed with Critical or High unresolved.
- Fix-and-re-review until clean; document remaining Medium/Low for user visibility.
- The deep security audit runs separately before PR via `/security` — this keeps per-subtask review fast.
