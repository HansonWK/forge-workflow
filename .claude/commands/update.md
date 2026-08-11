---
description: (forge dev) Make a larger update / overhaul to forge on a fresh branch → PR
argument-hint: <what to change>
---

# Update — a larger change to forge

> **Repo-internal command for building forge itself — NOT shipped.** For changes bigger than one new
> piece (a multi-file update or an overhaul), always on a branch via a PR. Same concept as forge's
> shipped workflow, scaled to the size of the change.

## Arguments

`$ARGUMENTS` — a description of the update / overhaul.

## Steps

1. **Branch — never work on `main`.** Clean tree on latest `main`, propose a slug, create + switch to
   the branch (**confirm with the user**).
2. **Scale the ceremony to the size:**
   - **Small / medium** (a few files, clear scope) — make the edits directly, then review.
   - **Large overhaul** (many files, unclear scope, real sequencing) — dogfood the real workflow:
     write a plan under `.claude/temp/<slug>/` (research + a plan with subtasks and acceptance
     criteria, per `skills/writing-plans/SKILL.md`), **present it for signoff**, then work through it.
3. **Follow the skills** — `skills/authoring/SKILL.md` for any new/updated pieces; keep shipped content
   de-branded and lean; commands invoke skills explicitly.
4. **Attribution** — apply `skills/attribution/SKILL.md` for any resources used; update `ATTRIBUTION.md`.
5. **Verify** — install dry-run + de-brand grep. If it's a release-worthy change, bump the version in
   `package.json`, the install config template, and `docs/workflow-config.md`.
6. **Present, then PR.** Show the diff, **get approval**, then commit, push, and open a PR. Not `main`.

## Rules

- Always a branch + PR — never commit to `main`.
- Match the process to the size: direct edits for small, a `.claude/temp/` plan for an overhaul.
- Keep the PR focused and reviewable; split it if it sprawls.
