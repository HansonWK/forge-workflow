---
description: Fetch, parse, and analyse logs from your log provider
argument-hint: <service-name or file-path> [entity-id] [additional context]
---

# Log Parser

Fetch or parse logs from the project's log provider and analyse them to answer a question, trace an entity, or investigate an error.

> **Provider:** see the `## Observability` section of `docs/workflow-config.md` for the
> configured log provider and how logs are accessed. A fully-worked reference
> implementation for **Azure Application Insights + KQL** lives at
> `.claude/examples/logging/azure-kql-logs.md` — mirror its structure and depth,
> adapting the query language and access mechanism to this project's provider.
>
> `/install` (observability module) tailors this command to your provider. If it
> still reads generically, run `/install` to configure it.

## Arguments

$ARGUMENTS — a service name, a log file path (or several), and optionally an entity ID to focus on.

## Step 1: Get the logs

Depending on the configured provider:

- **Export-file providers** (e.g. App Insights CSV export): locate the most recent export (e.g. in `~/Downloads`) or use a path the user gives.
- **API/CLI providers** (e.g. Datadog, CloudWatch, Grafana/Loki, Sentry): run the provider's query CLI/API for the requested service, entity, and time range.
- **Plain files**: read the referenced log file(s).

If you can't locate logs, tell the user and offer a ready-to-run query (Step 4).

## Step 2: Sample before you boil the ocean

Logs can be huge. Read a bounded sample first (e.g. the first ~100 rows / most recent N entries), identify the columns/fields and time range, then expand only as needed. If the exporter is known to duplicate entries, deduplicate on `timestamp` + `message` + key dimensions before analysing.

## Step 3: Analyse and report

Analyse for the user's actual question:

- **Error patterns** — ERROR/WARN, exceptions, failures
- **Flow tracing** — if given an entity ID, trace its full lifecycle across services
- **Timing** — gaps, slow operations, unusual sequencing

Report as: **Summary** → **Timeline** (chronological, deduplicated) → **Issues found** → **Recommendations**. If an entity ID was given, centre the report on that entity's journey.

## Step 4: Offer a better query

Always leave the user able to get the data themselves. Offer a ready-to-run query for their provider, filled in with the service, entity, and time range. Ask for the identifiers you need. See `docs/logging-strategy.md` for the standard custom dimensions to filter and project.

## Rules

- Sample first, expand only if needed
- Deduplicate if the exporter is known to duplicate
- Never modify log files
- When an entity spans multiple services, note which service each log came from
