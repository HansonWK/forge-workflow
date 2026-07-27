---
name: logging-compliance
description: Check logging in a service/change against the project's logging strategy — required dimensions, a reason on business decisions, correct levels, logger naming. Requires docs/logging-strategy.md (observability module). Use for /fix-logs, the /dev logging check, and the /audit logging dimension.
allowed-tools: Read, Grep, Glob, Edit
---

# Logging Compliance (rubric)

Measure logging against `docs/logging-strategy.md`. **Only applies if that file exists** (it is
scaffolded by the observability module); if it doesn't, skip.

## What to check

For each logging statement in scope:

1. **Required dimensions** — the core custom dimensions from the strategy (e.g. entity id, entity
   type, tenant, pipeline) are present wherever applicable.
2. **Decisions carry a `reason`** — when code changes an entity's outcome (rejects instead of
   accepts, unpublishes instead of publishes), the decision is logged with a reason.
3. **Levels** — boundary events at INFO, internals at DEBUG, failures at ERROR (per the strategy).
4. **Logger naming** — follows the strategy's convention (e.g. `{service}:{module}`).
5. **Early validation errors** carry maximum context (ids, offending values).
6. **No temporary `[TEMP]` logs** left in the change.

## Discipline

- **Improve existing logs; do not invent new logs or delete logs.** Don't change a message unless
  it's misleading.
- If a required dimension genuinely isn't available in a handler, don't fabricate it — record it as
  a gap.
- Logging changes must not break tests (logs are not asserted — see the `testing` skill).

## Output

When auditing: a table of every log to change (file:line, current, required change), grouped by
file, prioritised (missing core dimensions → pipeline/context → level/naming). When embedded in
`/dev`: report only issues found, say nothing if compliant, and note if the new logs could power a
useful dashboard (suggest `/dashboard`).
