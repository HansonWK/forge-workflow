---
description: Decide whether/where to split work into independently mergeable PRs
argument-hint: [slug, or describe the work]
---

# Slice

Apply the **`slicing` skill** to the current plan (or the work in `$ARGUMENTS`): decide whether to
split it into independently reviewable, independently mergeable PRs, and where the cuts go. Record any
slices in `plan.md`.

## Rules

- Default to a single PR; split only when a real reason applies.
- Every slice must build, lint, and pass tests on its own (the `verify` skill).
