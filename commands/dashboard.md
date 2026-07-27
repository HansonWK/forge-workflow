---
description: Design a monitoring dashboard from your log/metric data
argument-hint: <what to measure>
---

# Dashboard Designer

Design queries and dashboard setup instructions from the project's structured log/metric data, so the user can visualise a trend, rate, or breakdown.

> A fully-worked reference implementation for **Azure Monitor Workbooks + KQL** lives
> at `.claude/examples/logging/azure-kql-dashboard.md` — including workbook JSON
> patterns, resource deep-links, and metrics-tile gotchas. Mirror its structure and
> depth, adapting the query language and dashboard format (Grafana, Datadog,
> CloudWatch, ...) to this project's provider. `/install` (observability module)
> tailors this command.

## Arguments

$ARGUMENTS — a description of what the user wants to measure or visualise.

## Step 1: Understand the data

Read `docs/logging-strategy.md` for the available dimensions and message conventions, then search the codebase for the **exact** log messages and dimension names relevant to the request. You need real strings to write accurate queries — don't guess.

## Step 2: Design the queries

One query per visualisation: extract structured fields, filter to the relevant service(s)/message(s) first (most selective), aggregate appropriately, bucket by time for trends, and note the chart type. Keep each query to one concept.

## Step 3: Present

For each query: **what it shows** (one line) → **the query** (ready to paste) → **suggested chart type**. Group related queries into a named dashboard.

## Step 4: Setup instructions

Give step-by-step instructions for creating the dashboard in the provider's UI (assume the user hasn't done it before), plus how to share it with the team.

## Step 5: Register dependencies (if applicable)

If the project tracks which source logs each dashboard tile depends on (e.g. a
`docs/dashboard-dependencies.json` registry used by `/review` to catch log changes
that would break a tile), update it for every tile you add or change. Skipping this
lets future log edits silently break the dashboard.

## Rules

- Search the codebase for exact message strings — never guess them
- If a required dimension isn't logged yet, say so and suggest a `/fix-logs` run or a ticket
- Keep queries simple — one concept each
- Default to the last 7 days unless told otherwise
