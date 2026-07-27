---
description: Run review phase for current changes
---

# Review Phase

## Prerequisites

Requires changes to review:

- Active plan with current subtask Dev complete
- Or uncommitted/unstaged changes to review
- This may be called outside of our cycle, in which case ignore the sections about plan.md

## Instructions

This will be called after a subtask as part of a plan has been completed, or after all subtasks on a plan have been completed.

Run review cycle on current changes :

### 1. Code Review

Use `pr-sanity-check` agent:

- Reviews implementation, design, tests
- Classifies issues by severity
- Suggests fixes

**Critical (must fix):**

- Security vulnerabilities
- Data loss risks
- Breaking changes without migration
  → Prompt user, then fix immediately, re-run reviewer

**High (should fix):**

- Bugs causing incorrect behavior
- Missing error handling
- Architectural violations
  → Prompt user, then fix immediately, re-run reviewer

**Medium (address):**

- Code smells
- Missing edge case tests
- Minor performance concerns
  → Prompt user then fix if straightforward, or note for Present

**Low (optional):**

- Style preferences
- Minor improvements
  → Note for user, don't block

### 1b. Performance pass (optional)

For performance-sensitive changes (hot paths, database queries, large payloads, render-heavy UI), also dispatch the `performance` agent for a focused review, and fold its findings into the severities above.

### 2. Re-review Loop

After fixing Critical/High issues:

- Re-run the `pr-sanity-check` agent
- Repeat until no Critical/High issues remain

### 3. Update Plan and Status

Check `- [x] Review` in plan.md for this subtask.

Also update `status.md` in the same task directory: set `work_status` to `review`.

## After Review

```
Review complete for subtask <N>: <title>

Results:
- Critical: 0
- High: 0
- Medium: <N> (noted for Present)
- Low: <N> (noted for Present)

Run /present to continue.
```

## Rules

- ALWAYS run pr-sanity-checks
- NEVER proceed with Critical or High issues unresolved
- Fix and re-review until clean
- Document remaining Medium/Low for user visibility
- Update plan.md checkbox when complete

## Note

Security audit (`security-auditor` agent) runs separately before PR via `/security`.
This keeps per-commit reviews fast while ensuring comprehensive security review of all changes.

## Logging Review (only if the observability module is installed)

If `docs/logging-strategy.md` exists and the changes touch handlers, consumers, or business logic, verify logging compliance against it:

- New/modified logs include the required custom dimensions from the strategy
- Business-logic decisions that change an entity's outcome log a `reason`
- Logger names follow the strategy's naming convention
- No temporary `[TEMP]` logs left in the changes

Flag logging issues as Medium severity.
