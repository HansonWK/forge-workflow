---
name: architecture
description: Keep new and changed code within this project's chosen architecture (hexagonal / layered / vertical slice / …) and its boundary rules. Reads docs/architecture.md. Use when writing or reviewing code that touches module boundaries, dependencies, or where logic lives.
allowed-tools: Read, Grep, Glob
---

# Architecture

Keep code within the project's architecture as recorded in `docs/architecture.md`. **Only applies if
that file exists** (scaffolded by `/install` or `/clarify architecture`); if it doesn't, skip.

## What to enforce

- **The pattern's dependency rule** — whatever `docs/architecture.md` names: hexagonal (the domain
  imports no infrastructure; dependencies point inward), layered (depend only downward), vertical slice
  (a feature owns its stack), or the project's own. Keep new code on the right side of it.
- **Where things go** — put new code in the directory the doc assigns (domain / use-case / adapter /
  entrypoint, or the feature slice).
- **Boundaries** — IO and framework concerns stay at the edges/adapters; business logic stays in the
  domain/use-case; ports/contracts mediate between them.
- **Reject the doc's anti-patterns** (e.g. a DB call inside a domain entity, framework types leaking
  into the domain).

When a change would cross a boundary the doc forbids, flag it and propose the in-pattern alternative
rather than taking the shortcut.
