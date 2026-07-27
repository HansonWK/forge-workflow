---
description: Design a KQL dashboard from our log data for Azure Monitor
argument-hint: <what to measure> (e.g. "rejection rates", "sync batch performance", "publish/unpublish trends")
---

<!--
  REFERENCE EXAMPLE — Azure Monitor / Application Insights dashboards from logs.

  Fully-worked implementation of the generalized `/dashboard` command for Azure
  Monitor Workbooks. The Azure Workbook JSON mechanics (parameter tiles, metrics
  tiles, resource deep-links, sparse-metric behaviour) are Azure product facts and
  are kept verbatim — they are the reusable depth. Only the business specifics are
  a fictional example ("Acme").

  When adapting for another platform (Grafana, Datadog dashboards, CloudWatch
  dashboards), keep the shape: understand the data → design one query per tile →
  present ready-to-paste queries → give setup instructions → register tile↔log
  dependencies so log changes don't silently break dashboards. Swap the query
  language and the dashboard-as-JSON format.
-->

# Dashboard Designer (Azure Monitor + KQL)

Design KQL queries and Azure Monitor dashboard setup instructions from structured log data.

## Arguments

$ARGUMENTS — a description of what the user wants to measure or visualise.

## Step 1: Understand the data

Read `docs/logging-strategy.md` to understand:

- Available custom dimensions (entityId, entityType, tenant, pipeline, reason, etc.)
- Log message conventions
- Which services produce relevant logs

Then search the codebase for the specific log messages and dimensions that relate to the user's request. You need the exact message strings and dimension names to write accurate KQL.

## Step 2: Design the queries

For each visualisation, write a KQL query that:

- Uses `customDimensions` to extract structured fields
- Filters to the relevant service(s) and message(s)
- Aggregates appropriately (count, sum, avg, percentiles)
- Uses `bin(timestamp, ...)` for time-series charts
- Includes a `render` hint for the chart type

### Query guidelines

- **Message prefix**: If the logger prepends a prefix (e.g. `APP: {LEVEL}:`) to all messages, account for it. For exact match use `message == "APP: INFO: Item processed successfully"`. For partial match use `message contains "processed successfully"`. Never match against the raw message without accounting for this prefix.
- Always filter by `LoggerName` or `message` first — this is the most selective filter
- Use `extend` to extract dimensions before filtering on them
- For counts over time, use `summarize count() by bin(timestamp, 1d)` (or 1h for recent data)
- For breakdowns, add the dimension to the `by` clause
- For tables, use `summarize count() by Dimension | order by count_ desc`
- Test the time range — default to last 7 days unless the user specifies otherwise
- For log level filtering, use `message startswith "APP: ERROR"` or the dimension `customDimensions["log.level"] == "error"`

### Chart types

| KQL render           | Use for                                   |
| -------------------- | ----------------------------------------- |
| `render timechart`   | Trends over time (counts per day/hour)    |
| `render barchart`    | Comparing categories (failures by reason) |
| `render piechart`    | Proportion breakdowns (tenant split)      |
| `render table`       | Detailed breakdowns with multiple columns |
| `render columnchart` | Side-by-side comparisons                  |

## Workbook JSON patterns

### Resource link tiles

Every service-specific dashboard should include a resource parameter and a conditional links tile immediately after the TimeRange parameter. This lets users click through to the relevant Azure resource when investigating a spike.

**Parameter pattern** — use type 2 (dropdown from ARG query), NOT type 5 (resource picker). Type 5 shows an empty dropdown when the workbook has no subscription context. Always use the ARG query form:

```json
{
  "id": "<guid>",
  "version": "KqlParameterItem/1.0",
  "name": "FunctionApp",
  "label": "Function App",
  "type": 2,
  "isRequired": false,
  "query": "Resources | where type =~ 'microsoft.web/sites' and kind contains 'functionapp' | project value = id, label = strcat(name, ' (', resourceGroup, ')') | order by label asc",
  "queryType": 1,
  "resourceType": "microsoft.resourcegraph/resources",
  "typeSettings": { "additionalResourceOptions": [] }
}
```

For Service Bus namespace, replace `type =~ 'microsoft.web/sites' and kind contains 'functionapp'` with `type =~ 'microsoft.servicebus/namespaces'`.

**Links tile pattern** — type 1 (markdown) with `conditionalVisibility` so it only appears once a resource is selected:

```json
{
  "type": 1,
  "content": {
    "json": "[→ Function App](https://portal.azure.com/#resource{FunctionApp}) &nbsp;·&nbsp; [→ Log stream](https://portal.azure.com/#resource{FunctionApp}/logstream) &nbsp;·&nbsp; [→ Functions](https://portal.azure.com/#resource{FunctionApp}/functions)"
  },
  "conditionalVisibility": {
    "parameterName": "FunctionApp",
    "comparison": "isNotEqualTo",
    "value": ""
  },
  "name": "resource-links"
}
```

`{FunctionApp}` is substituted with the full resource ID from the parameter. The Azure portal `#resource{id}` deep link format works for any resource type.

**Which dashboards get which links:**
- **Service-specific dashboards** (one service): Function App parameter + links tile
- **Dashboards that interact with Service Bus** (pipeline-health): also add SB Namespace parameter and SB links
- **Cross-service dashboards** (end-to-end-pipeline): no resource parameters — no single resource to link to

### Infrastructure metrics tiles (non-App Insights)

For infrastructure-level metrics (Service Bus topic size, active messages, DLQ depth), do **not** use KQL against `AzureMetrics`. Use Workbook Metrics tiles (type 10) instead.

**Why:** `AzureMetrics` lives in the Log Analytics Workspace, not the App Insights scope. Querying it via `"resourceType": "microsoft.insights/components"` produces: _"Failed to resolve table or column expression named 'AzureMetrics'"_ — even in LAW-mode App Insights. Metrics tiles query the Azure Monitor Metrics API directly and require no diagnostic settings.

**Metrics tile structure:**
```json
{
  "type": 10,
  "content": {
    "chartId": "<guid>",
    "version": "MetricsItem/2.0",
    "size": 0,
    "chartType": 2,
    "resourceType": "microsoft.servicebus/namespaces",
    "metricScope": 0,
    "resourceParameter": "SBNamespace",
    "resourceIds": [],
    "timeContextFromParameter": "TimeRange",
    "timeContext": { "durationMs": 0 },
    "metrics": [
      {
        "namespace": "microsoft.servicebus/namespaces",
        "metric": "microsoft.servicebus/namespaces--Size",
        "aggregation": 4,
        "splitBy": "EntityName"
      }
    ],
    "title": "...",
    "showSubtitle": false
  },
  "name": "..."
}
```

Aggregation values: 1=Average, 2=Count, 3=Minimum, 4=Maximum, 7=Total/Sum.

**Sparse metrics — "Error retrieving data":** Azure Monitor does not emit data points when a metric value is zero. For metrics like `DeadLetterMessages`, an entity with an always-empty DLQ will show "Error retrieving data", not a zero line. This is expected — silence means healthy. Avoid `splitBy` on these metrics as it will produce errors for every entity with no historical data. Show namespace totals instead and document this behaviour in the tile header.

## Step 3: Present the dashboard

For each query, present:

1. **What it shows** — one sentence
2. **The KQL query** — ready to paste into Azure
3. **Suggested chart type** — and any axis labels

Group related queries into a logical dashboard with a name.

## Step 4: Setup instructions

After presenting all queries, provide setup instructions:

```markdown
## How to set up this dashboard in Azure

### Option A: Quick queries (Application Insights → Logs)

1. Go to **Azure Portal** → your Application Insights resource
2. Click **Logs** in the left sidebar
3. Paste the KQL query into the query editor
4. Click **Run** to verify results
5. Click **Pin to dashboard** (pin icon) to add to an Azure Dashboard
6. Repeat for each query

### Option B: Workbook (recommended for shared dashboards)

1. Go to **Azure Portal** → your Application Insights resource
2. Click **Workbooks** in the left sidebar
3. Click **+ New**
4. Click **Add** → **Add query**
5. Paste the KQL query
6. Set **Visualization** to the recommended chart type
7. Click **Done Editing** on the query block
8. Repeat for each query (Add → Add query)
9. Click **Save** → give it a name like "<Dashboard Name>"
10. Share via **Save As** → select a shared resource group for team access

### Option C: Pinned Dashboard

1. Run each query in **Logs**
2. Click the **Pin to dashboard** icon
3. Select **Create new** or an existing dashboard
4. Arrange tiles by dragging them in the dashboard editor
```

### Tips

- **Time range**: Workbooks inherit the time picker at the top — queries don't need hardcoded time filters
- **Parameters**: Workbooks support dropdown parameters (e.g. tenant picker) — add these if the dashboard would benefit from filtering
- **Auto-refresh**: Dashboards can auto-refresh on an interval — useful for monitoring dashboards
- **Sharing**: Workbooks saved to a resource group are visible to anyone with access to that resource group

## Step 5: Suggest related queries

After the main dashboard, suggest 2-3 related queries the user might find useful based on the data available. These might reveal patterns they hadn't considered.

## Step 6: Update dependency registry

After creating or modifying dashboard tiles, update `docs/dashboard-dependencies.json` to register the new dependencies. For each tile, add an entry with:

- `tile` — the tile name from the workbook JSON
- `messagePatterns` — exact substrings used in `message contains "..."` filters
- `dimensions` — `customDimensions` keys the KQL queries
- `pipelineValues` — pipeline filter values (e.g. `"sync"`, `"message"`)
- `loggerNames` — logger names filtered by `log.logger` (if any)
- `logLevels` — log levels filtered (if any)
- `sourceFiles` — the service source files that produce the logs this tile depends on

This registry lets the `/review` command flag changes that would break dashboard tiles. Skipping this step means future log changes could silently break the new dashboard.

## Step 7: Update dashboard files

Dashboard workbook JSON files are stored in `dashboards/` at the repo root. These are the source of truth — the infra team copies them into the IaC repo for deployment.

When creating or modifying a dashboard:

1. Save the workbook JSON to `dashboards/<service-or-dashboard-name>.json`
2. Update `docs/dashboard-dependencies.json` (Step 6)
3. **Notify the infra team** that the dashboard files have changed and need redeploying. Include which files changed and a brief description of what changed.

## Rules

- Always search the codebase for exact log messages — don't guess message strings
- Test queries mentally: would this return data given the current logging? If a required dimension isn't logged yet, say so
- Keep queries simple — one concept per query, not mega-queries
- Default to last 7 days for time ranges
- Always include the setup instructions — assume the user hasn't done this before
- If the requested data isn't available from current logs, explain what logging changes would be needed and suggest a `/fix-logs` run or a ticket
- Always update the dependency registry when creating or modifying dashboard tiles
