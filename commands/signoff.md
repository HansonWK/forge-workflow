---
description: Final checks before the PR — run the plan's sign-off checks in parallel, fix, report, then open the PR
---

# Sign-off

The last step before the PR. Runs every check the plan chose, says what it runs and what it skipped,
fixes what must be fixed, shows the completion report, and carries on into `/pr`.

## Prerequisites

Every subtask in the work folder's `plan.md` has a `**SHA:**`. If not:

```
Subtasks still open: <N>: <title>, …
/signoff is the final step, after /next has committed every subtask. (Plan approval is /present.)
```

Set `work_status: signoff` and `stage: Sign-off` in `status.md`; update the work page.

## 1. Say what runs

Read `## Sign-off checks` in `status.md` (the plan's choice; the defaults in
`docs/workflow-config.md` `## Sign-off` when it has none). Print the checks that will run, and each
one skipped with its reason.

**Early PR:** if the developer asks for the PR now, run `/pr` straight away while the checks run, and
update its description when they finish.

## 2. Run the checks in parallel

One subagent per check, all over the branch diff (`git diff <default branch>...HEAD`):

| Check | Runs |
| --- | --- |
| `code-review` | the `pr-sanity-check` agent (the `code-review` skill), then a fresh subagent for the skill's second pass over the findings below Critical |
| `logs` | (a) the events the ACs' proofs rely on are logged, enough to prove the work complete; (b) the `logging-compliance` skill against `docs/logging-strategy.md`. Queries follow `/logs`' query rules |
| `performance` | frontend: the `performance-review` skill's Baseline mode (after, against the baseline); backend: its Scan mode |
| `security` | the `security-auditor` agent, when the diff touches endpoints, auth, input handling, secrets or another security hotspot; otherwise skipped with the reason |
| `seo` | when the frontend changes: titles and meta descriptions, canonical URLs, one `h1` and heading order, image `alt` text, structured data, `noindex`/robots, sitemap entries, redirects for moved pages |
| `docs` | the `doc-writer` agent: docs and runbooks brought in line with the code; an alert in the report for any architectural change |
| `acceptance` | the `verify-acceptance` skill's sign-off check: every AC proven, with its proof named |

## 3. Fix and tick

- **Critical / High:** fix, then re-run that check. **Medium:** fix when straightforward. **Low:**
  list it.
- Tick each check in `status.md` with a short note: `- [x] code-review — 1 High fixed, 2 dropped by
  the second pass`. A failing check's note starts `fail`, a skipped one's `skipped`.
- **Test on dev:** write the steps that prove the ACs on the PR's environment and on dev, each with
  what to expect, written before it runs. In page mode they're `devTests[]` in `work-page.json`
  (`work-page` → The Test-on-dev tab); in simple mode, `## Test on dev` in `status.md`.

## 4. Completion report

The developer's reason to trust every step is complete:

- the ACs, each with its status and the proof that shows it;
- the subtasks, each with its tier, its commit and how it was proved;
- the proof evidence: log excerpts, script output, screenshot paths;
- every check's result, the performance before/after, and the fixes made.

**Page mode:** it's the work page's **Sign-off** tab — update progress, republish if
`work-page.json` changed, and print `Work page: <url>` with a two-line summary. **Simple mode:**
write it under `## Completion report` in `status.md` and show it in the terminal.

## 5. Commit and carry on

- **Fixes made:** show the files per fix and **STOP** for approval (`/next`, "approved", "go").
  On approval, commit them by name, one commit per check, in the project's commit message format.
- Write `signoff_commit: <git rev-parse HEAD>` to `status.md`.
- Carry on into `/pr` without waiting for a new command.

## Rules

- Run every chosen check; never mark one passed that didn't run.
- Fixes follow the commit rules in the Working agreements (`CLAUDE.md`): by name, never amend.
- A check this project can't run (no frontend, no observability module) isn't in its defaults;
  don't stub it.
