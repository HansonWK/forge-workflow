---
description: Present the research and plan for approval (on the work page, or in the terminal with -s)
---

# Present the Plan

Plan approval. Runs automatically after `/begin` and `/plan`; call it directly to present again.

## Prerequisites

Requires `research.md` and `plan.md` in the current work folder (`.claude/temp/work/<slug>/`). If
missing:

```
Missing required files.
- research.md: <found/not found>
- plan.md: <found/not found>

Run /research and /plan first, or /begin for full workflow.
```

## Page mode (`mode: page` in status.md)

Apply the **`work-page` skill**: write `work-page.json` from `plan.md`, render, publish (or republish),
seed progress with `stage: Plan review`, and print `Work page: <url>`. Then in the terminal give the
research summary (below) and:

```
The plan is on the work page. Rename subtasks, change a tier or answer questions there, then press
Approve plan, or give feedback here. Type /next or "done" when you're ready.
```

If the page can't be published, follow the skill's fallback and present as in simple mode.

## Simple mode (`mode: simple`)

1. **Research summary** — 3-5 bullets: what was found, where the problem is, which files/services
   are involved, and the root cause.
2. **Acceptance criteria** — the IDs and one line each.
3. **Plan summary** — numbered subtasks, each with its tier (Easy / Medium / Hard) and reason, the
   ACs it proves and its proof (or group). Then the proof groups and any open questions.
4. **Links** — the full paths on their own lines so they're clickable:

```
.claude/temp/work/<slug>/research.md
.claude/temp/work/<slug>/plan.md

Run /next to start if approved, or give feedback. Renames, tier changes and answers can go here too.
```

**STOP and wait for an explicit response.**

## Handling the response

Read the page's input first in page mode (`work-page` → Reading the developer's input).

**Approved** (`/next`, "approved", "go", or Approve plan on the page): check we're on a workflow
branch (the Working agreements in `CLAUDE.md`) and offer `/branch` if not. Set plan.md Status to
`IN_PROGRESS`, `stage: In progress` in status.md, then run `/next`.

**Renames, tier changes, answers:** apply them to `plan.md` (a ledger row for each tier, title or
proof change, `writing-plans`), rebuild the page if there is one, and present again.

**Feedback:**

1. **Research concerns** (missing context, wrong assumptions) — re-run research incorporating the
   feedback, then planning, then present again.
2. **Plan concerns** (wrong approach, missing steps, scope, ACs) — re-run planning, then present
   again.

If unclear which, use judgement: most feedback is about the plan.

## Rules

- NEVER start a subtask without explicit approval of the plan
- Present file paths as clickable links (on their own lines)
- Always make sure we're on the right branch before work starts
