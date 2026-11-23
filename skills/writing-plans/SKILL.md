---
name: writing-plans
description: How to plan work in this workflow — agreed acceptance criteria at the top, atomic subtasks with a complexity tier and a proof each, proof groups, the sign-off checks, and the tier ledger. Use when creating or revising a plan, and when a tier, title or proof changes.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, AskUserQuestion
---

# Writing Plans (method)

Turn research + agreed acceptance criteria into a `plan.md` of small, proven steps.

## Acceptance criteria first

Step one of every ticket: the ACs are there and understood. `/begin` takes them from the ticket, or
proposes them and agrees them with the developer, before planning.

- They go at the **top of `plan.md`** as `## Acceptance criteria`, each with an ID:
  `- [ ] **AC1** — <observable, provable outcome>`.
- For a **bug**, the end state is the bug fixed: add `## Reproduction` (the steps and what goes
  wrong), so the fix is shown against the same steps.
- Don't write ACs that sign-off already checks (logs, dashboards, docs, security and code review,
  performance). Pick which sign-off checks apply instead (below).

## Subtasks

Each subtask is **atomic** (one logical thing), **reviewable** alone, **buildable** (the code runs
after it), and **ordered** (types → data → logic → API → integration). Its title is imperative, has
no quote marks, backticks, `$`, `!` or `\`, and becomes its commit message. Each carries the fields
in the `planner` template: Complexity, Goal, Files, Proves, Proof, Open questions, Checklist
(`- [ ] Dev`, `- [ ] Proved`) and `**SHA:**`.

## Complexity

Every subtask gets a tier, with the deciding reason beside it in one clause. The developer sees
Easy / Medium / Hard.

| Tier | Typically |
| --- | --- |
| Low | One obvious way, an existing pattern to copy, easy to revert: docs, config values, a rename, a package bump, generated types, tests for existing code, a one-line change |
| Medium | A business rule, or new behaviour following an existing pattern; anything near an architecture rule; a schema or permission change; work across two apps |
| High | Changes the architecture and needs the developer's agreement; an original plan that failed; an existing issue that needs a scope decision; several valid approaches to work through |

**Tier signals in this project** (`/install` and `/recalibrate` fill these: what makes something
Medium or High here):

- _none yet_

**Escalation.** Claude may raise a tier and never lowers one; only the developer lowers a tier.

- An issue with the approach while solving or proving a subtask → raise it to **Medium**, explain
  the issue, and agree the way forward before carrying on.
- The approach itself has to change → raise it to **High**, say why the first approach failed, and
  ask before changing it.
- A file outside the subtask's list, or a diff well past its expected size, is a signal to raise.

## Proof

Every piece of work has an end state, and it must be possible to prove it got there. A proof is worth
running when it gives the developer confidence that each step moves forward, catches a gotcha
mid-session rather than in review, or lets Claude check the work does what it should end to end.

- **Every functional or business AC that can be proven is proven**: behaviour, rules, outcomes.
  Never prove that something exists (a doc, a config entry).
- **The whole piece of work always gets a proof**, against the ACs or the bug's reproduction.
- **A subtask or group gets its own proof only where it helps**: the work touches several surfaces,
  a complex step is worth testing before moving on, it gives Claude confidence, or the developer can
  see the result early. Otherwise prove once at the end.
- **No tautologies.** A proof must be able to fail, and a failure must change what someone does.
  Never plan a proof that a file exists, a package installed, typecheck passed, or a mock returned
  what it was told to.
- **Kinds of proof this project can run** (`/install` fills this list): unit tests; running the
  service with test data and showing the logs (add the log lines the proof needs as part of the
  work); a script written for the proof; running the app and taking screenshots; reproducing the
  bug before and after; for a removal, everything still passes; for housekeeping, being done.
- **Proof groups:** subtasks proven together share a group (`P1`) listed under `## Proof groups`.
- **The final end state may be checked on dev** (a downstream system showing the data, or not).
  If the developer has no dev credentials, name the variables to add to the project's `.env`;
  never take a credential value in chat.
- Proof artefacts (scripts, captured logs, screenshots) live in **the proof folder**, named for their
  subtask or group (`3-confirm.log`, `P1-signup.png`). They're not committed, and are reused at each
  stop, on the ticket and on dev.

## Sign-off checks

The plan picks which `/signoff` checks apply: write them to `status.md` as `## Sign-off checks`
(`- [ ] code-review`, …), starting from the defaults in `docs/workflow-config.md` `## Sign-off`.
Drop one only with a reason the change makes obvious (no frontend change → no `seo`).

## Changing a tier, title or proof

Every change, by the developer or by escalation, is one row appended to
`.claude/temp/ledger/tier-overrides.tsv` (create it with the header if missing) via the shell:

```
date	ticket	subtask	slug	field	from	to	by	reason
2026-01-15	PROJ-1234	3	PROJ-1234-signup	tier	medium	high	claude	signed tokens can't be revoked
```

`field` is `tier`, `title` or `proof`; `by` is `developer` or `claude`. Change `plan.md` first, then
the work page if there is one. `/recalibrate` reads the ledger to tune the tier signals.

## Guardrails

- Stop and ask (`AskUserQuestion`, or an open question on the subtask) on genuine unknowns or real
  trade-offs — don't guess.
- Add test subtasks (or a final test subtask for small work) per the `testing` skill.
- Never plan a commit step: approving a stop commits each subtask under its title.
