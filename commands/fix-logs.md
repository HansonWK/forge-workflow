---
description: Audit and fix logging in a service to match the logging strategy
argument-hint: <service-name>
---

# Fix Logs

Audit and fix all logging in a service so it complies with `docs/logging-strategy.md`.

> A fully-worked reference implementation lives at
> `.claude/examples/logging/azure-kql-fix-logs.md`. `/install` (observability module)
> scaffolds `docs/logging-strategy.md` and tailors this command to your logger and
> dimensions. If `docs/logging-strategy.md` doesn't exist yet, run `/install` first.

## Arguments

$ARGUMENTS — the service/app name to audit.

## Step 1: Read the strategy

Read `docs/logging-strategy.md` to understand the rules: logger naming, required custom dimensions, log levels, and when a `reason` must be logged.

## Step 2: Audit the service

Find every logging statement in the service's source. For each, check against the strategy:

1. **Logger naming** — follows the project convention (e.g. `{service}:{module}`)?
2. **Core dimensions** — includes the required entity dimensions where applicable?
3. **Pipeline / context dimension** — present where the strategy requires it?
4. **Log level** — appropriate (boundary = INFO, internal = DEBUG, failure = ERROR)?
5. **Business decisions** — outcome-changing decisions logged with a `reason`?
6. **Early validation errors** — carry maximum context?

## Step 3: Plan (approval-gated)

Write a plan to `.claude/temp/<service>-logging-fix-plan.md`: a table of every log to change (file, line, current state, required change), grouped by file, prioritised (missing core dimensions → pipeline → level corrections). **Present it and wait for approval before changing code.**

## Step 4: Fix

After approval, apply the fixes: introduce a shared log-context object at handler tops where missing, add required dimensions, fix logger names, add `reason` to decision logs, correct levels.

## Step 5: Verify

Run the project's test, lint, and format-check commands (see `docs/workflow-config.md`). Fix failures. Logging changes should not break tests.

## Rules

- Only fix existing logs — do NOT add new logs or remove logs
- Do NOT change log messages unless a message is misleading
- If a required dimension genuinely isn't available in a handler, don't fabricate it — record it as a gap in the plan
