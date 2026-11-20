---
name: verify-plan
description: Critique an implementation plan against the research and the acceptance criteria before work starts — catch missing, incorrect or oversized steps, ACs with no proof, tautological proofs and missing tiers. Use in /begin and /plan before /present, for non-trivial tasks.
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion
---

# Verify Plan (pre-build loop)

Before building, check the plan is complete and correct — the iteration a developer would otherwise
do by hand before `/next`. Proportional to task size: a quick pass for a trivial task, thorough for a
complex one.

## Critique the plan against

- **The research** — does the plan address what research found (affected files, patterns,
  constraints, shared schemas/types)? Anything research flagged but the plan ignores is a gap.
- **The acceptance criteria** — every provable AC is named in some subtask's `Proves`, and has a
  proof that can fail. For a bug, the final proof runs the reproduction.
- **The proofs** (`writing-plans` → Proof) — no tautologies (a file exists, a package installed,
  typecheck passed, a mock returned what it was told); no proof where one at the end already covers
  it; the whole piece of work has one.
- **Tiers** — every subtask has one with a reason, matching the tier table and this project's tier
  signals. Raise a tier that's too low; never lower one.
- **Shape** — subtasks atomic, ordered and buildable; nothing missing (migrations, schema/type
  updates, tests); nothing out of scope smuggled in; `## Sign-off checks` written to `status.md`.

Fix genuine gaps in `plan.md` directly; surface real trade-offs or unknowns as open questions on the
subtask rather than guessing.

**No ACs at all** (standalone `/plan` without `/begin`): propose a provable set as `/begin` does,
agree them with the developer, and put them at the top of `plan.md` before the critique. If you can't
draft them from the research and ticket, apply the `clarify` skill rather than inventing criteria.

## Output

A short note: gaps found and fixed, tiers raised, and any open questions — then hand on to
`/present`.
