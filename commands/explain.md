---
description: Explain how existing code works — a file, component, service, library, or concept
argument-hint: <file-path, component, service, or concept>
---

# Explain

Explain how something that already exists works — a service, app, library, folder, concept, or file.

## Instructions

Apply the **`explain` skill** to the target in `$ARGUMENTS` (for a large target — a whole service or
subsystem — dispatch the `explainer` agent, which applies the same skill in an isolated context). It
gives an overview, offers specific directions to go deeper, then answers at the depth you ask, always
citing real file paths. If the target is ambiguous, it asks (the `clarify` skill).

## Rules

- **Describe, never judge** — this explains, it does not review or change code. (For a review, use `/review`.)
- If the target is ambiguous, ask which thing is meant before diving in.
