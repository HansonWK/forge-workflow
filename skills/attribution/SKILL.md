---
name: attribution
description: How to credit resources that shaped the workflow — decide attribution vs resource vs neither when a blog, doc, or someone's file is used, trace ideas to their origin, and record it in ATTRIBUTION.md. Use whenever a shared resource informs a skill, command, or agent.
allowed-tools: Read, Grep, Glob, Edit, WebSearch, WebFetch
---

# Attribution

When a resource shapes a piece of the workflow, record it in `ATTRIBUTION.md`. Two kinds of entry
share the one table:

- **Attribution** — credit for *ideas or creative work* we built on:
  - an **LLM-provider blog** (Anthropic / OpenAI / …),
  - a blog proposing a **novel idea**,
  - someone else's **file we adapted** (e.g. a `.md` skill from another developer).
- **Resource** — a *reference* we consulted but aren't crediting as an idea: **official docs, a
  project's own help files or wiki, API references**. Linked, not credited.

If a resource didn't actually shape a file, it's **neither** — don't add it.

## Attribute the origin, not the reconceptualization

If a blog is really just restating an existing idea, credit the idea's **origin** (the original
author or the primary research), not the blog. Credit the blog itself only when it's the source of a
**novel** idea. (Example: an "LLM wiki in Obsidian" blog → credit Karpathy's LLM-wiki idea, not the
blog.)

## When the user shares a resource — ask, don't assume

Before recording anything, ask the user (with your recommendation):

1. **"List this as attribution, a resource, or neither?"** — recommend based on the rules above
   (provider blog / adapted file / novel idea → attribution; official docs or wiki → resource; didn't
   shape a file → neither).
2. **"Want me to find the original source?"** — offer to trace a reconceptualizing blog back to its
   origin (search for the primary source or the idea's author) and attribute *that* instead — or to
   find the canonical resource link. They may want attribution, resources, or neither.

Act on their answer.

## Recording it

Update `ATTRIBUTION.md`. Each row captures the **file(s)** built (the skill, plus any linked
skills / commands / agents), what to **attribute**, and any **resources** consulted. Example — a
"stacked GitHub workflows" skill built from another dev's `.md` plus the GitHub docs:

| Area / files | Attribution | Resources |
| --- | --- | --- |
| `skills/stacked-workflows` (+ `/stacked` command) | \<dev\>'s `stacked-prs.md` (link) — adapted the process | GitHub docs/wiki on stacked PRs (link) |

Verify a link resolves before recording it. Prefer the primary/canonical URL.
