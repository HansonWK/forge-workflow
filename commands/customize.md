---
description: Add or update a piece of your workflow (a skill, command, or agent) to fit your team
argument-hint: [what to add/change, or a recurring pattern to encode]
---

# Customize the workflow

Evolve this repo's workflow — add or update a **skill**, **command**, or **agent** — so a recurring
need is encoded once instead of re-typed every time. This is how the workflow grows with your team.
(To make a *correction* stick rather than add a new piece, use `/recalibrate`.)

## Instructions

Apply the **`authoring` skill**. From `$ARGUMENTS` (or the recurring pattern you've noticed):

1. **Check it's worth it** — a recurring pain solved by a repeatable process. If it's a one-off, or
   something the model already does by default, say so and stop (don't add noise).
2. **Decide the piece** — skill (a method/rubric), command (a trigger), or agent (isolated work),
   per the `authoring` skill's guide. **Prefer updating an existing skill** over creating a new one.
3. **Draft it** encoding *your* specific decisions — real libraries, services, IDs, naming, and your
   "done" — lean, no generic filler, no role-priming.
4. **Wire it up** — commands invoke skills explicitly; keep the always-loaded part short.
5. **Present for approval**, then suggest a commit + PR so the team shares it.

## Use it proactively

If you notice the user **repeatedly asking for the same step** (e.g. always adding a logging step) or
**repeatedly adding the same acceptance criterion** (e.g. "send an event to GA when the frontend
changes"), suggest `/customize` to encode it — as a new skill, or an update to an existing one.

## Rules

- Don't add noise — if the model already does it by default, don't encode it.
- Update an existing skill when the need fits its domain; only create new for a genuinely new process.
- These are **your** repo's files — be specific to your project; commit + PR so the team shares them.
