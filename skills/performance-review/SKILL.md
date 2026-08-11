---
name: performance-review
description: Find performance problems — two modes: a fast pattern scan over a diff (for /review) and a deep audit of a whole service or app (for the performance agent). Apply the full performance analysis; the specifics here are what commonly gets missed.
allowed-tools: Read, Grep, Glob, Bash
---

# Performance Review

Two modes. Pick by scope:

| Mode | Scope | Used by |
| --- | --- | --- |
| **Scan** | the current diff, fast, no measurement | `/review` |
| **Audit** | a whole service or app | the `performance` agent |

## Scope — both modes

**Apply the full performance analysis you would run unprompted** — render behaviour, data fetching,
bundle weight, async patterns, memory, query efficiency. Everything below is **additional**. Nothing
here substitutes for reading the code and thinking about what will be slow.

## Mode 1 — Scan (for `/review`)

Only run when the diff touches code that can affect performance; skip silently otherwise (a
backend-only change shouldn't pay for a frontend pass, and vice versa). Look for:

- **Over-fetching** — a query/request pulling more fields, rows, or payload than the caller needs, especially where the API supports narrowing (fields / limit / projection).
- **A cache-buster or cache-disabling flag on a hot path** — defeats caching on every call; should be deliberate, not copied.
- **I/O or expensive work inside a component/render** instead of hoisted out.
- **A query inside a loop, or without its index / partition key.**
- **A whole library imported for one function** (import the function, not the package).
- **A new effect / subscription** that could be derived state or computed on the server.
- **Work done to build a log payload the level then discards.**
- The standard sweep — sequential awaits that could be parallel, unkeyed lists, unbounded caches, uncleaned timers/listeners, blocking scripts, unoptimised images.

Report as **Low** unless there's a clear, quantifiable cost. Keep it fast — a slow scan gets skipped.

## Mode 2 — Audit (whole service or app)

**Ask which target first** — different app/service types have completely different profiles, and a
rule that matters for one may not apply to another.

### Prioritise, don't list

Rank by roughly `frequency × blast radius × expected gain ÷ (risk × effort)`. A hot path that runs on
every request or message beats anything in startup code. **Say what you measured and what you only
inferred.**

### Where to look

- **Hot paths first** — per-request / per-message code over startup code.
- **Third-party client weight** — SDKs and widgets loaded client-side are often the dominant cost on web apps; measure it before optimising your own code.
- **Data layer** — query cost, cross-partition / full-table scans, indexing, batch sizing, N+1s.
- **Queue / stream consumers** — prefetch, concurrency, and batch size; wrong values cause idle throughput or lock-expiry storms.
- **Cold starts** for latency-sensitive serverless.
- **Build / bundle** — what actually ships (dead instrumentation, every theme of a multi-brand build, unused polyfills).
- **Telemetry overhead** — instrumentation enabled for drivers/packages that aren't even installed still patches module loading; live-metrics streams add continuous cost.

### Recurring traps (generalize to your stack)

- A static asset re-fetched on every mount because it wasn't cached at module level.
- A CDN cache poisoned by a bad early response, presenting as a perf/availability bug rather than the underlying error.
- Hydration / visibility work not deferred to post-mount on a prerendered page.

### Measuring

Use the project's real telemetry (APM / logs / metrics), bounded by a time range and a limit. For
structural front-end issues, reading the code is often enough. Never invent a number.

## Reporting

Lead with the single highest-impact finding. For each: what it costs, where it is (file path), and
what to do. **Never present an inference as a measurement** — mark anything unmeasured as such. Three
real findings beat a long list.
