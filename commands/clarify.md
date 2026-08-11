---
description: Interview me to pin down missing info or decisions (optionally build a guideline doc)
argument-hint: [topic — architecture | testing | coding | a task/decision]
---

# Clarify

Apply the **`clarify` skill** to `$ARGUMENTS`:

- A **topic** like `architecture`, `testing`, or `coding` → quiz me, then write/refresh
  `.claude/docs/<topic>.md` starting from the base template in `.claude/examples/guidelines/<topic>.md`.
- A **task or decision** → interview me until the scope and decisions are settled, then summarise
  (write nothing unless asked).

## Rules

- Work in rounds; build questions logically; stop when nothing important is left assumed.
- Prefer concrete multiple-choice options with a recommendation; I can always pick "other".
- If something needs a prototype/spike rather than discussion, say so and stop.
