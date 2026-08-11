---
name: clarify
description: When there isn't enough information to proceed, or there are decisions to pin down, interview the user in rounds until nothing important is left assumed. Use anywhere in the workflow — research, planning, gathering project guidelines, drafting acceptance criteria — that you'd otherwise guess.
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion
---

# Clarify — grill the decision out

Take a loose idea or an under-specified task and interview the user until they can commit to it.
Adapted from Matt Pocock's `grill-me` (see Attribution) — named `clarify` so you can keep `grill-me`
alongside it.

## When to use

Any time you're about to guess: unclear scope in `/research` or `/plan`; missing acceptance criteria;
building the project guideline docs (`/install`, or `/clarify architecture|testing|coding`); a design
decision inside `/customize`. If you'd otherwise silently assume something that matters, clarify first.

## How to run it

- **Work in rounds, not rapid-fire.** Each round asks every question whose prerequisites are already
  settled — the current "frontier." The answers open the next round. Prefer `AskUserQuestion` with
  concrete options **and a recommendation** over open-ended prompts; the user can always pick "other".
- **Build logically.** Never ask something that depends on an unanswered question.
- **Stop when the frontier is empty** — nothing important is left silently assumed. A handful of rounds
  is normal; if it balloons past dozens of open questions, the scope is too big — suggest splitting the
  work first.
- **Know what's ungrillable.** Some things need a prototype or a spike, not more discussion — say so
  and stop rather than grinding.
- **The user drives.** The failure mode is passivity; if they're rubber-stamping, surface the trade-off
  behind a question so they engage.

## Output

- **To unblock a task:** summarise the decisions reached and carry on — write nothing unless asked.
- **To create a document** (a guideline file, acceptance criteria, a plan): write the answers into the
  target, starting from the base template where one exists (e.g. `examples/guidelines/<topic>.md`), and
  keep it decision-focused (see the `authoring` skill).

## Attribution

Adapted from **Matt Pocock's `grill-me` skill** — https://www.aihero.dev/skills-grill-me (credited in
`ATTRIBUTION.md`). This is a differently-named variant, so if you already use `grill-me`, both coexist.
