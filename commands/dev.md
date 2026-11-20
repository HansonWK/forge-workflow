---
description: Run dev phase for current subtask
---

# Dev Phase

Implement the current subtask, then **self-verify and prove it** — the developer at the `/next` stop
should be approving proven work.

## Prerequisites

- Active plan with Status `IN_PROGRESS`; the current subtask has `- [ ] Dev` unchecked.

## Steps

Use native `TaskCreate` for the steps below so the user sees progress (create them upfront with
dependencies; skip any that don't apply).

### 1. Understand

Read the subtask's Goal, Files, Complexity, Proves and Proof in plan.md, plus the relevant patterns
from research.md and the project's `CLAUDE.md`.

### 2. Predict test impact

Before changing code that has tests, apply the **`testing` skill**'s predict-then-verify: read the
existing tests and write down which you expect to break and which to stay green, and why. (Skip only
when creating new files with no existing tests.)

### 3. Implement

Write the change so it reads like the surrounding code and follows the patterns from research. Stay
within the subtask's scope — don't implement future subtasks.

### 4. Tests & docs

Add/adjust tests per the **`testing` skill** (use the `test-writer` agent for non-trivial suites).
Update docs via the `doc-writer` agent only if public behaviour or API changed.

### 5. Logging (observability module only)

If `docs/logging-strategy.md` exists and you added or changed handlers, consumers, business-logic
decisions, or error paths, apply the **`logging-compliance` skill** — run it as a background agent so
you're not blocked, and surface only issues found.

### 6. Verify — self-close the loop

- Apply the **`verify` skill**: build / typecheck / lint / test, self-fixing until green. Compare
  against your step-2 predictions — an unpredicted break is likely a real side effect, so fix the
  code, not the test.
- Then apply the **`verify-acceptance` skill**: run the subtask's proof (or its group's, once the
  group's last subtask is built), keep the evidence in the proof folder, and check the ACs it proves;
  self-correct genuine misses, and flag anything that needs a human decision.

### 7. Update plan & status

Check `- [x] Dev` in plan.md, and `- [x] Proved` once its proof passed (or it has none); set
`work_status: in-progress` in status.md.

## After dev

Report to `/next`: the files changed, checks green (via `verify`), the proof's result and evidence
(via `verify-acceptance`), and any escalation signal — an issue with the approach, a file outside the
subtask's list, a diff well past its expected size.

## Rules

- Stay within the current subtask's scope; don't implement future subtasks.
- Checks must pass (via the `verify` skill) before completing — never disable/skip/delete a test to
  go green.
- Don't commit here: `/next` commits each subtask once the developer approves the stop.
- If work here will affect later subtasks, tell the user and ask before changing the plan.
