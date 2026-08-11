---
name: explain
description: Explain something that already exists — a service, app, library, folder, concept, or file. Give an overview, offer specific directions to go deeper, then answer at the depth asked. Not a review — never judges the code. Use for /explain and for onboarding onto unfamiliar code.
allowed-tools: Read, Grep, Glob, Bash
---

# Explain

Answer *"what is this and how does it work?"* — never *"what's wrong with it?"*

## This is not a review

**Read-only. Describe, never judge, never suggest edits.**

If you notice something wrong, mention it **once, briefly, at the end** — *"worth noting X looks off;
run `/review` if you want that checked"* — then stop. Never lead with problems, never produce a
findings list, never rank by severity. Someone asking how a subsystem works does not want an audit.

## Targets — never file-only

| Target | Example |
| --- | --- |
| Service / app | `/explain search-service`, `/explain the web app` |
| Library / package | `/explain libs/logger` |
| Folder | `/explain src/handlers` |
| Concept / subsystem | `/explain "the sync pipeline"`, `/explain "how offers work"` |
| File / component | `/explain Card.tsx` |

Cover the **whole codebase, not just the frontend** — services, data flows, storage access patterns,
shared libs, and infra are as much the job as UI components.

Concept targets are the hardest and most valuable — they span modules and no single doc describes
them. **Resolve an ambiguous target by asking** (the `clarify` skill), not guessing: `/explain offers`
could mean the schema, the UI, or the business rules.

## Read the docs before the code

Read existing documentation first — it carries *intent* the code can't, and makes the explanation
match how the team already describes the system. Rough order: the project's architecture/design docs
and any `docs/` (incl. domain-rules / guideline docs) → the component's README → the source (always,
to confirm the docs are still true).

**Say where an answer came from** — *"per the architecture doc"* vs *"from the code"*. It tells the
developer how much to trust it and surfaces stale docs. **If a doc contradicts the code, the code
wins** — say so, and note the gap. Report stale/missing docs as a by-product; don't fix them here.

## The shape: overview → directions → depth

**1. Overview** (~150–250 words) covering: what it's for, where it sits in the system, what it talks
to, its entry points, and the key concepts. Fewer and the developer can't orient; more and it stops
being an overview.

**2. Offer specific directions** — concrete to this target, never generic:

```
search-service indexes records into the search index from queue messages.

Want to go deeper on:
  1. Message flow — which topics it subscribes to, what triggers a reindex
  2. The write path — batching and back-pressure
  3. Filtering — which records are excluded and why
  4. Index shape — the record and its attributes
  … or ask me anything about it.
```

**3. Answer at the depth asked, then re-offer.** It's a conversation, not a report — don't pre-empt
by dumping everything.

## Always cite paths

Every explanation names real files. *"The write path is in `src/handlers/index.ts`"* is a map; *"it
writes to the index"* is prose. The developer should be able to open the right file immediately, and
paths make the explanation checkable.
