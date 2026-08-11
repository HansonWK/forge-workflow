---
description: (forge dev) Build a Forge-branded HTML slide deck (molten-metal house style)
argument-hint: [topic or content spec]
---

# Presentation (Forge)

Apply the **local `presentation` skill** (`.claude/skills/presentation/`) — the Forge house style
(dark steel, molten orange-to-yellow, silver, cooling green) — to build a self-contained HTML deck for
`$ARGUMENTS`. Get the copy approved, then build one offline `.html` in `.claude/temp/`.

> This is the repo-internal, Forge-branded deck skill. The **shipped** generic `presentation` skill
> (root `skills/`) defaults to a Claude palette instead — don't cross the two.

## Rules

- Content approved before styling; one idea per slide.
- Self-contained, offline; keyboard nav + progress.
