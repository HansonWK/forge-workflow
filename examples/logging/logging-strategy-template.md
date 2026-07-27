# Logging Strategy

> Scaffolded by `/install` (observability module). This is a starting template —
> Claude fills in the real logger, dimensions, and conventions from your codebase
> during install, and you refine it over time. `/fix-logs`, `/dashboard`, and the
> `logging` audit dimension all measure your code against THIS document, so keep it
> accurate.

## Logger

- **Library:** <e.g. pino, winston, bunyan, the platform logger>
- **Factory:** <e.g. `createLogger('service:module')`>
- **Naming convention:** `{service-name}:{module-name}` (e.g. `search-service:indexer`)
- **Message prefix (if any):** <e.g. the logger prepends `APP: {LEVEL}:` — dashboards must account for this>

## Log levels

| Level | Use for |
| ----- | ------- |
| ERROR | A failure that needs attention — caught exceptions at boundaries, rejected work |
| WARN  | Unexpected but handled — retries, fallbacks, degraded behaviour |
| INFO  | Boundary events — a message received/processed, a request handled |
| DEBUG | Internal detail — intermediate steps, values during processing |

## Core custom dimensions

Every log emitted from entity-processing code should carry these where available:

| Dimension    | Meaning                                   | Example              |
| ------------ | ----------------------------------------- | -------------------- |
| `entityId`   | The primary entity being processed        | `PROJ-344-ITEM`      |
| `entityType` | The kind of entity                        | `Product`, `Order`   |
| `tenant`     | Tenant / brand / customer scope           | `acme`               |
| `pipeline`   | Which pipeline this log belongs to        | `sync`, `message`    |
| `reason`     | Why a business decision was made          | `expired`, `hidden`  |
| `operation`  | The operation being performed             | `upsert`, `delete`   |

## Rules

- **Business logic decisions must be logged with a `reason`.** If code changes an
  entity's outcome (rejects instead of accepts, unpublishes instead of publishes),
  log the decision and why.
- **Early validation errors carry maximum context** — include the entity ID and the
  offending value.
- **Boundary in/out at INFO, internals at DEBUG, failures at ERROR.**
- **Don't log secrets or PII.**
- **Tests do not assert on logging calls** — logs are observability, not behaviour.

## Services

<!-- List the services/apps that produce logs, and any per-service specifics. -->

| Service            | Purpose                          |
| ------------------ | -------------------------------- |
| `catalog-service`  | <purpose>                        |
| `search-service`   | <purpose>                        |
| `content-service`  | <purpose>                        |
