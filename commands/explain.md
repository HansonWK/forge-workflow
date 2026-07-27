---
description: Deep-dive explanation and review of a file or component
argument-hint: <file-path or component>
---

# Explain

Get a deep, senior-level explanation and review of a file or component — its logic, dependencies, potential bugs, security and performance concerns, and recommendations.

## Instructions

Dispatch the `explainer` agent with the target from $ARGUMENTS (a file path, or a description of the component to analyse). If no target is given, ask which file or component to explain.

The agent reads the target and its key dependencies and returns a structured analysis (overview, architecture & logic, quality assessment, recommendations). It is **read-only** — it never edits code.

## Rules

- Read-only — this command explains and reviews, it does not change code
- If the target is ambiguous, ask the user to point to a specific file or component
