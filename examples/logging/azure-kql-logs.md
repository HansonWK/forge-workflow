---
description: Parse and analyse Azure Application Insights logs exported as CSV
argument-hint: <service-name or file-path> [entity-id] [additional context]
---

<!--
  REFERENCE EXAMPLE — Azure Application Insights + KQL.

  This is a fully-worked implementation of the generalized `/logs` command for one
  specific log provider (Azure App Insights, queried with KQL). The `/install`
  command reads this file when a project uses App Insights, and mirrors its
  STRUCTURE and DEPTH when generating a `/logs` command for a different provider
  (Datadog, CloudWatch, Grafana/Loki, Sentry, plain files, ...).

  When adapting for another provider, keep: the "locate → sample → analyse →
  report → offer a better query" shape, the dedup discipline, the entity-trace
  focus, and the "always give the user a ready-to-run query" habit. Swap: the
  query language (KQL), the export mechanism (CSV from portal), and the custom
  dimension names.

  The company-specific details here are a fictional example ("Acme"). Replace them
  during /install with the real services, dimensions, and message conventions.
-->

# Log Parser (Azure App Insights + KQL)

Parse and analyse logs exported from Azure Application Insights via KQL queries.

## Arguments

$ARGUMENTS — Can be:

- A **service name** (e.g., `search-service`, `catalog-service`) — fetches the latest `query_data*.csv` from `~/Downloads`
- A **file path** — parses that specific file
- Multiple file paths separated by spaces
- A service name + entity ID for focused analysis (e.g., `search-service PROJ-344-ITEM`)

## Step 1: Locate the log file(s)

**If a file path was provided:** Use that path directly. If multiple paths, process all of them.

**If a service name or no file was provided:** Find the most recent log export:

```bash
ls -t ~/Downloads/query_data*.csv 2>/dev/null | head -5
```

Pick the most recent file. If no files found, inform the user and suggest they export logs from Azure Application Insights using a KQL query (see Step 5).

## Step 2: Initial parse

Logs can be large. Read the first 100 lines to understand the structure and content:

1. Read the CSV header row to identify columns
2. Read the first ~100 data rows
3. Note the time range covered by these rows

**Known issue:** An OpenTelemetry + Azure Monitor setup can produce duplicate log entries. When analysing, deduplicate by matching on `timestamp` + `message` + key dimension values. Do not flag duplicates as anomalies if this is a known infrastructure quirk of the exporter.

## Step 3: Analyse

Based on the user's request and the arguments provided, analyse the logs for:

- **Error patterns**: Look for ERROR/WARN level logs, exceptions, and failure messages
- **Flow tracing**: If an entity ID was provided, trace the full lifecycle of that entity across the logs
- **Timing**: Note any gaps, slow operations, or unusual sequencing
- **Service-specific context**: Use knowledge of the service architecture (e.g. Catalog Service → Service Bus → downstream services) to understand the flow

If the initial 100 rows aren't sufficient to answer the user's question, read additional rows in batches of 100 until you have enough context or reach the end of the file.

## Step 4: Report

Present findings as:

1. **Summary**: What the logs show at a high level
2. **Timeline**: Key events in chronological order (deduplicated)
3. **Issues found**: Any errors, warnings, or unexpected behaviour
4. **Recommendations**: Next steps for investigation if applicable

If the user provided an entity ID, focus the report around that entity's journey through the system.

## Step 5: KQL assistance

If the user needs to gather different or more targeted logs, offer a KQL query. Ask the user:

- Which service(s) they want logs from
- Any entity IDs or other identifiers to filter on
- The time range they care about

Example services: `catalog-service`, `search-service`, `content-service`, `order-service`, `notification-service`

### Template KQL for service + entity ID filtering:

See `docs/logging-strategy.md` for the full list of standard custom dimensions.

```
traces
| extend
    LogLevel = tostring(customDimensions["log.level"]),
    LoggerName = tostring(customDimensions["log.logger"]),
    ServiceName = cloud_RoleName,
    Pipeline = tostring(customDimensions["pipeline"]),
    TraceId = tostring(customDimensions["trace_id"]),
    SpanId = tostring(customDimensions["span_id"]),
    EntityType = tostring(customDimensions["entityType"]),
    EntityId = tostring(customDimensions["entityId"]),
    Tenant = tostring(customDimensions["tenant"]),
    Method = tostring(customDimensions["method"]),
    Reason = tostring(customDimensions["reason"]),
    Operation = tostring(customDimensions["operation"])
| where LoggerName startswith "<SERVICE_NAME>"
| where EntityId in ("<ENTITY_ID>")
    or message contains "<ENTITY_ID>"
    or tostring(customDimensions) contains "<ENTITY_ID>"
| project
    timestamp,
    ServiceName,
    LogLevel,
    LoggerName,
    Pipeline,
    message,
    EntityType,
    EntityId,
    Tenant,
    Method,
    Reason,
    customDimensions
| order by timestamp desc
```

### Template KQL for general service logs:

```
traces
| extend
    LogLevel = tostring(customDimensions["log.level"]),
    LoggerName = tostring(customDimensions["log.logger"]),
    ServiceName = cloud_RoleName
| where LoggerName startswith "<SERVICE_NAME>"
| where LogLevel in ("ERROR", "WARN")
| project timestamp, ServiceName, LogLevel, LoggerName, message, customDimensions
| order by timestamp desc
| take 500
```

If the user hasn't provided enough context to know what KQL they used, ask them — understanding the query helps interpret the results correctly.

## Rules

- Always deduplicate logs before analysis if the exporter is known to duplicate
- Start with 100 rows, expand only if needed
- If the CSV has no data or is malformed, tell the user and suggest re-exporting
- When entity IDs span multiple services, note which service each log came from
- Do not modify log files
