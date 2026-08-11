---
description: (forge dev) Add a new workflow piece to forge on a fresh branch → PR
argument-hint: [skill|agent|command|none] <concept>
---

# New — add a workflow piece to forge

> **Repo-internal command for building forge itself — this is NOT shipped to users.** It adds a new
> workflow piece to the **root** `skills/` `commands/` `agents/` (the templates users install), always
> on a branch via a PR. Same concept as forge's shipped workflow, streamlined for authoring forge.

## Arguments

`$ARGUMENTS` — an optional type (`skill` / `agent` / `command` / `none`) followed by the concept.
`none` (or no type) = choose the type yourself, and it may be **more than one** piece.

## Steps

1. **Decide the type.** Read `skills/authoring/SKILL.md` and apply its skill-vs-command-vs-agent
   guide. If the user named a type, use it; if `none`, choose (possibly several tightly-related pieces).
2. **Branch — never work on `main`.** Ensure a clean tree on latest `main` (`git status`,
   `git pull origin main`), propose a slug from the concept, create the branch, **confirm with the
   user**, and switch to it.
3. **Write it** in the root shipped dirs (`skills/<name>/SKILL.md`, `commands/<name>.md`,
   `agents/<name>.md`), following `skills/authoring/SKILL.md`: encode decisions not principles, keep it
   lean, **de-branded** (this ships to users — no employer specifics), commands invoke skills explicitly.
4. **Wire it up** — reference it from the relevant command(s), and add it to `skills/README.md`,
   `commands/workflow.md`, and `README.md` wherever the piece should be listed.
5. **Attribution** — if you built it from a shared resource, apply `skills/attribution/SKILL.md`
   (attribution vs resources) and update `ATTRIBUTION.md`.
6. **Verify** — stage it in a temp dir (`node bin/install.js install`) to confirm it copies, and grep
   for de-brand leaks.
7. **Present, then PR.** Show the change and **get approval**, then commit, push the branch, and open a
   PR with `gh pr create --web`. Do **not** push to `main`.

## Rules

- Always a branch + PR — never commit to `main`.
- Shipped pieces stay **de-branded and lean**; be concrete only in illustrative examples.
- Keep it one focused piece (or a small, tightly-related set). Bigger changes → `/update`.
