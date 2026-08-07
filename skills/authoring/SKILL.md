---
name: authoring
description: How to add or update a piece of THIS project's workflow — a skill, command, or agent — so it's specific, lean, and actually earns its context. Use when creating/updating a skill/command/agent, or when the user keeps asking for the same thing.
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Authoring the workflow

Evolve this repo's workflow when a **recurring pain** meets a **repeatable process**. If it's a
one-off, or the model already does it well by default, add nothing — every always-loaded line costs
context on every relevant turn.

## Skill vs command vs agent

- **Skill** — a reusable rubric / method / verifier the main loop, commands, and agents pull in on
  demand. Use for *how we do X* (single source of truth, progressive disclosure). Most new workflow
  knowledge belongs here.
- **Command** (`/foo`) — a user-invokable entry point that orchestrates a step. Keep it **thin** and
  have it **invoke skills explicitly**. Use when the user needs to trigger something.
- **Agent** — a context-isolated / parallel / file-writing worker with its own context window. Use
  for heavy or background/worktree work, or when isolation helps. Agents also call skills.

Rule of thumb: knowledge/rubric → **skill**; trigger/orchestration → **command**; isolated heavy
execution → **agent**.

## Writing a skill worth its context

- **Start from the real recurring pain**, not a topic or a role. "You are an expert in X" teaches a
  frontier model nothing — cut it.
- **Encode the decision, not the principle.** Not "handle errors gracefully" → "wrap external calls
  in `withRetry` and surface failures via `AppError`, never raw exceptions." Not "write clean code" →
  the specific pattern, library, and naming your codebase uses.
- **Cut anything the model does by default.** If deleting a line wouldn't change what Claude does,
  it's noise — delete it.
- **Be specific to THIS project.** This is your repo, not the shipped template — put in your real
  library names, service names, endpoints, IDs (e.g. your analytics/GA property), naming rules, and
  your definition of "done." Generic advice doesn't move the needle; your specifics do.
- **Keep the always-loaded `SKILL.md` short; push depth into referenced files** the skill reads only
  when needed (progressive disclosure).
- **Write a precise `description`** — it's the trigger. Say exactly when to use it.
- **Measure.** Run the task with and without the skill; if the output doesn't change for the better,
  it isn't earning its place — cut it back.

## Update, don't duplicate

If a recurring request fits an existing skill's domain, **update that skill** — e.g. "add another
logging step" → extend `logging-compliance`; a repeated review nit → add it to `code-review`. Only
create a **new** skill for a genuinely new recurring process — e.g. "always send an event to our GA
property when the frontend app changes" → a new `analytics` skill holding your GA specifics.

## After authoring

Wire it up (commands invoke skills explicitly; keep the always-loaded part short). Keep a piece
de-branded/generic **only** if you're contributing it back upstream to forge — otherwise make it
concretely yours. If you built it from a shared resource, apply the `attribution` skill to credit it.
Then **commit + PR it** so the whole team shares the improvement.
