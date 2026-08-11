---
description: Deep performance audit of a service or app
argument-hint: <service or app to audit>
---

# Performance Audit

Dispatch the `performance` agent (which applies the **`performance-review` skill** in audit mode) on
`$ARGUMENTS` — a whole service or app. It asks which target if unclear, prioritises by impact, and
reports the highest-impact findings with file paths, marking measured vs inferred.

(For a fast per-diff performance scan, that's the same skill's scan mode, run inside `/review`.)

## Rules

- Prioritise by frequency × blast radius × gain ÷ (risk × effort); don't list everything.
- Never present an inference as a measurement.
