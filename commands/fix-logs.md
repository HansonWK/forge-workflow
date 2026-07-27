---
description: Audit and fix logging in a service to match the logging strategy
argument-hint: <service-name>
---

# Fix Logs

Audit and fix all logging in a service so it complies with `docs/logging-strategy.md`.

> Requires the observability module (`docs/logging-strategy.md`). If it doesn't exist yet, run
> `/install` and set up observability first.

## Arguments

$ARGUMENTS — the service/app to audit.

## Steps

1. **Audit** — apply the **`logging-compliance` skill** to the service's source. It checks required
   dimensions, a `reason` on business-logic decisions, correct levels, and logger naming against
   `docs/logging-strategy.md`.
2. **Plan** — write the skill's findings (a table of logs to change, grouped by file, prioritised)
   to `.claude/temp/<service>-logging-fix-plan.md`. **Present it and wait for approval** before
   changing code.
3. **Fix** — after approval, apply the fixes per the skill's discipline: improve existing logs only
   (don't add or remove logs; don't change messages unless misleading).
4. **Verify** — apply the `verify` skill (tests / lint / format). Logging changes should not break
   tests.

## Rules

- Follow the `logging-compliance` skill's discipline — improve existing logs only.
- If a required dimension genuinely isn't available in a handler, note it as a gap — don't fabricate it.
