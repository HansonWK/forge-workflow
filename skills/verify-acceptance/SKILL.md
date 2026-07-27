---
name: verify-acceptance
description: Verify a change actually satisfies what was asked — check it against the subtask goal and the acceptance criteria (from the ticket or the plan), self-correct genuine misses, and flag anything that needs a human decision. Use after `verify`, before /present.
allowed-tools: Read, Grep, Glob, Bash, Edit
---

# Verify Acceptance (spec loop)

Deterministic checks (the `verify` skill) prove the code *runs*; this proves it does *what was
asked*. Run it after `verify`, before presenting.

## What to check against

In priority order:

1. The **acceptance criteria** in the ticket (if any).
2. The **acceptance criteria** in `plan.md`.
3. **Fallback:** the current **subtask's Goal** in `plan.md` (use this when there is no ticket and
   no explicit AC).

## Loop

1. For each criterion, determine — from the diff, the code, and where cheap a runtime/test check —
   whether the change actually satisfies it. Be concrete: name the file/behaviour that meets it.
2. If a criterion is **not** met and the fix is within the subtask's scope, implement it and
   re-check (re-run `verify` if you touched code).
3. If a criterion can't be met without a product/scope decision, or is ambiguous, **stop and flag
   it** for the user rather than guessing.

## Output

A short acceptance report: each criterion → met / not met / needs-decision, with the evidence
(file:line or observed behaviour). This feeds the `/present` summary so the human is approving
already-verified work, not doing the first verification themselves.

## Rules

- Don't weaken or reinterpret a criterion to make it pass — meet it or flag it.
- Never commit or push.
