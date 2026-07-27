---
description: Audit and fix logging in a service to match the logging strategy
argument-hint: <service-name> (e.g. content-service, search-service)
---

<!--
  REFERENCE EXAMPLE — logging cleanup against a project logging strategy.

  Fully-worked implementation of the generalized `/fix-logs` command. The logging
  provider here is Azure App Insights with structured custom dimensions, but the
  SHAPE is provider-agnostic: read the strategy doc, audit every log call against
  it, write an approval-gated plan, fix, verify. When adapting, keep that shape and
  the "improve existing logs, don't invent or delete logs" discipline; swap the
  specific dimensions (productId/entityType/tenant/pipeline) and the logger API
  (logger.info/error) for the project's real ones.

  Company-specific details are a fictional example ("Acme"). Replace during /install.
-->

# Fix Logs

Audit and fix all logging in a service to comply with `docs/logging-strategy.md`.

## Arguments

$ARGUMENTS — the service name to audit (e.g. `content-service`, `search-service`, `catalog-service`)

## Step 1: Read the strategy

Read `docs/logging-strategy.md` to understand the rules.

## Step 2: Audit the service

Search all source files in the service's directory for logging statements (`logger.info`, `logger.error`, `logger.warn`, `logger.debug`, `createLogger`).

For each log statement, check:

1. **Logger naming**: Does it follow `{service-name}:{module-name}` format?
2. **Core dimensions**: Does it include `entityId`, `entityType`, `tenant` where applicable?
3. **Pipeline dimension**: Does it include `pipeline`?
4. **Log level**: Is it appropriate (boundary = INFO, internal = DEBUG, failure = ERROR)?
5. **Business logic decisions**: If code changes an entity's outcome (e.g. rejects instead of accepts), is the decision logged with a `reason`?
6. **Early validation errors**: Do they include as much context as possible?

## Step 3: Create a plan

Write a plan to `.claude/temp/<service-name>-logging-fix-plan.md` with:

- A table of every log that needs changing, with file path, line number, current state, and what needs to change
- Grouped by file
- Priority: missing core dimensions first, then pipeline, then level corrections

Present this plan to the user for approval before making changes.

## Step 4: Fix

After approval, implement the fixes:

1. Add `logContext` objects at the top of handlers where missing
2. Add `pipeline` dimension to all log contexts
3. Ensure `entityId`, `entityType`, `tenant` are spread into every log in entity-processing code
4. Fix logger names that don't follow the convention
5. Add `reason` to business logic decision logs that are missing it
6. Adjust log levels where incorrect

## Step 5: Verify

Run the project's test, lint, and format-check commands (see `docs/workflow-config.md`). Fix any failures. Log changes should not break tests (logging calls are not asserted per the testing guidelines).

## Rules

- Do NOT add new logs that don't exist — only fix existing ones
- Do NOT remove logs — only improve their dimensions and levels
- Do NOT change log messages unless the message is misleading
- If a handler doesn't have a `logContext` pattern, introduce one at the top and spread it
- If a dimension isn't available in a handler (e.g. `tenant` isn't in the message schema), don't fabricate it — note it in the plan as a gap
