---
description: Build a self-contained HTML slide deck (Claude-style palette by default)
argument-hint: [topic or content spec]
---

# Deck

Apply the **`presentation` skill** to build a self-contained HTML slide deck for `$ARGUMENTS`. It gets
the copy approved first, defaults to a Claude-style palette (and asks if you have your own), then
builds one offline `.html` file in `.claude/temp/`.

## Rules

- Content approved before styling.
- Ask for a palette; default to the Claude-style one.
- Self-contained, offline, one idea per slide.
