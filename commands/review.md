---
description: Run a code review of the current changes, outside the /next cycle
---

# Review

An on-demand code review of the current changes or the branch. The workflow's own full review runs
once, at `/signoff`; `/next` stops show the proof, not review findings.

## Instructions

### 1. Code review

Apply the **`code-review` skill** to the current changes (or dispatch the `pr-sanity-check` agent to
run it in the background / a worktree). It classifies findings by severity.

Act on severity:

- **Critical / High** — prompt the user, then fix and re-review until none remain.
- **Medium** — fix if straightforward, otherwise note it.
- **Low** — note for the user; don't block.

### 1b. Performance (optional)

For performance-sensitive changes (hot paths, DB queries, large payloads, render-heavy UI), apply the
**`performance-review` skill** (scan mode), or dispatch the `performance` agent, and fold its findings
into the severities above.

### 2. Logging (only if the observability module is installed)

If `docs/logging-strategy.md` exists and the changes touch handlers/consumers/business logic, apply
the **`logging-compliance` skill** and flag issues as Medium.

## After review

Report counts by severity (Critical/High resolved; Medium/Low noted).

## Rules

- Never leave Critical or High unresolved without telling the user.
- Fix-and-re-review until clean; document remaining Medium/Low for user visibility.
