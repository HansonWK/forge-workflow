---
name: work-page
description: Build and run the work page — a private claude.ai artifact, rebuilt from plan.md, that shows one piece of work's plan, live progress, sign-off report and test on dev, and takes the developer's renames, tier changes, answers and approvals through its database. Covers publishing, writing progress cheaply, reading input at stops, the Sign-off and Test-on-dev tabs, the local fallback, and deleting the page after merge. Use whenever status.md has mode: page, from /begin to after the merge.
allowed-tools: Read, Write, Edit, Bash, Artifact, ArtifactData
---

# Work page

One page per piece of work, kept for its whole life. `plan.md` is canonical: a change goes into
`plan.md` first, then the page is rebuilt from it. With `mode: simple` there is no page; the same
changes are made by asking in the terminal.

**Keep it cheap.** Claude never writes the page's HTML: `render.mjs` builds it from the template, and
a publish sends the file from disk. Claude writes data only, through files, at stops and state
changes — never per file edited and never on a timer.

## Files

| Path | What |
| --- | --- |
| `template.html` | The page: Plan, Progress, Sign-off and Test-on-dev tabs, laid out for half a screen. Change the layout here, never per ticket |
| `render.mjs` | `node .claude/skills/work-page/render.mjs <work folder>` checks `work-page.json` against `plan.md`, renders `work-page.html` with the house style (`presentation/house-style.css`) and runs `node --check` on its scripts |
| `progress.mjs` | `node .claude/skills/work-page/progress.mjs <work folder> [--changed]` builds the live progress document from the work's files |
| `example/work-page.json` | The full data shape, every tab filled in |
| `<work folder>/work-page.json` | The page's data |
| `<work folder>/progress.json` | The progress document, sent to the page and read by the local fallback |
| `<proof folder>/assets.json` | `{"<file>.png": "<asset url>"}` for every screenshot uploaded to the page |

## Building and publishing

1. Write `work-page.json` from `plan.md` in the example's shape: `ticket`, `ticketUrl`, `name`,
   `shortName` (two or three words, the tab title), `branch`, `problem`, `summary`, `reproduction`
   (bugs), `acs[]` (`id`, `text`, `provedBy`), `subtasks[]` (`n`, `title`, `tier`, `tierWhy`, `size`,
   `approach`, `files`, `proves`, `proof`, `questions`), `proofGroups[]` (`id`, `subtasks`, `proof`),
   `complete`. A subtask's `proof` is `{kind, what, keep}`, `{group: "P1"}` or `{none: "<reason>"}`.
   Leave out `example` and `seedProgress`.
2. Render. An error names the field to fix. Every open question in `plan.md` must be a card: the
   render refuses a page whose question count per subtask differs from `plan.md`'s.
3. **First publish:** `Artifact` with `file_path: <work folder>/work-page.html`, `icon: "checklist"`,
   a one-line `description`, and `capabilities: {"db": {}, "assets": {}}`. Write the URL into
   `status.md` as `work_page: <url>`.
4. **Seed progress:** run `progress.mjs`, then `ArtifactData` `set` on collection `state`, doc
   `progress`, with `file_path: <work folder>/progress.json`; copy `progress.json` to
   `progress.sent.json`. Then one `ArtifactData` `list` of `state`, to see the write landed.
5. Print `Work page: <url>` on its own line — every time it's published, at every stop, and in
   `/status` and `/resume`. The publish may open the page in the default browser; say so in one line.

**Republish** after a change to `plan.md`: the same `file_path` in this session, or `url: <work_page>`
from another session after an `Artifact` `read`. Omit `capabilities` and `icon`. For a rename or a
tier change, edit that field in `work-page.json`; rebuild the whole file only when `plan.md`'s
structure changes.

The artifact is private to the developer. Never share it and never pass `pin`.

## Keeping it live

At every change of stage, batch status, proof, commit, sign-off check or escalation, and nowhere else:

1. Write what only Claude knows into the work's files: in `status.md`, `stage` (`Plan review`,
   `In progress`, `Sign-off`, `PR`, `Testing on the PR environment`, `Merged`, `Testing on dev`,
   `Done`), `batch` (`[3, 4]`), `batch_status` (`doing`, `proving`, `discussing`, `waiting`) and, at a
   stop, `stop_summary` (its "Proved by" line); a one-line proof result under `## Proofs`
   (`- 3: pass — <summary>`, or `- P1: …` for a group); logs and screenshots in the proof folder,
   named for their subtask or group (`3-confirm.log`, `P1-signup.png`).
2. `progress.mjs <work folder> --changed`. It prints `no change`, or the path of
   `progress.patch.json`, which holds only the top-level keys that changed.
3. `ArtifactData` `update` on `state`/`progress` with `file_path: <work folder>/progress.patch.json`.
   If the update fails, delete `progress.sent.json`, so the next write sends everything with `set`.

The script takes commits from `plan.md`'s `**SHA:**` lines and `git log` by subtask title,
escalations from the tier ledger, AC status from `plan.md`'s ticks, sign-off checks from
`status.md`'s `## Sign-off checks`, and evidence from the proof folder: the last 20 lines of each log
and each screenshot listed in `assets.json`.

**Screenshots:** upload each with `Artifact` `publish`, `url: <work_page>`, `file_path: <png>`,
`asset: true`, and add its returned `url` to `assets.json`.

## Reading the developer's input

The page writes three collections and nothing else. Read them with `ArtifactData` `list` at a stop,
and on a terminal message while a stop is open, before acting on the message. Never at other times.

| Collection | Doc id | Fields | What Claude does |
| --- | --- | --- | --- |
| `overrides` | `<n>` | `title`, `tier` | For each field that differs from `plan.md`: change `plan.md`, add a ledger row (`writing-plans`), edit `work-page.json` and republish. A title arrives with quote marks, backticks, `$`, `!` and `\` removed |
| `answers` | `<n>-<question id>` | `option`, `mode` | `choose`: move the question to `**Decided:** <option>` in `plan.md`, rebuild. `confirm`: say the choice in one line and act on it only once the developer agrees. `discuss`: never written |
| `approvals` | `plan` or `next` | `batch`, `at` | `plan` approves the plan while `stage` is `Plan review`. `next` approves the stop whose `batch` it names. Anything else is ignored and mentioned |

The page cannot wake the session: after acting on it, the developer types `/next` or "done" in the
terminal, and every stop's message says so. **Next** on the page is the same as `/next`.

**Question modes.** Claude sets `mode` on every question; the developer can say otherwise.

| `mode` | Use for | On the page |
| --- | --- | --- |
| `choose` | Questions on Medium subtasks, and small reversible settings anywhere | Choose buttons; the answer is used at the next step |
| `confirm` | A real trade-off still contained to this subtask | Choose buttons; Claude confirms in the terminal before acting |
| `discuss` | High questions that touch the architecture, a security design or a large change | A button that copies a prompt; no answer is taken on the page |

A question that comes up during the work goes into `plan.md` and onto the page, republished, before
it's asked in the terminal.

## The Sign-off tab

It appears once `stage` is `Sign-off`, or once a check is ticked. `/signoff` ticks the checks with a
short note each (`- [x] code-review — 1 High fixed`; a failing check's note starts `fail`, a skipped
one's `skipped`), and the script adds the ACs, the subtasks with their commits and proofs, and the
performance rows from `perf-baseline.json` and `perf-after.json` in the proof folder. This tab is the
completion report. Republish only when `work-page.json` changed; otherwise the progress write is
enough.

## The Test-on-dev tab

It appears from `stage: PR` on. Two ways to fill it:

- **The `test-plan` skill, when the project has it.** `render.mjs` imports
  `.claude/skills/test-plan/render.mjs` (`renderCases(data)`, `pageScript`) and renders
  `<work folder>/test-plan/<env>/test-plan.json` for each environment there, the PR's environment
  first and dev last.
- **Otherwise, `devTests[]`** in `work-page.json`: one entry per step (`id`, `step`, `expect`),
  written at `/signoff` from the ACs' proofs, with `expect` written before the step runs.

Either way the results go in two collections Claude writes with one `ArtifactData` `batch`:
`checks/<stepId>` = `{state, note}` (`Pass`, `Fail`, `In progress`, `Not started`, `Skipped`) and
`evidence/<caseId>` = `{status, at, rows: [{check, expected, actual, ok}], text}`. After every message
where the developer says they did something, update that step's state and note and write its log
proof before replying. Query logs as `/logs`' query rules say: validate a query on a short window
before relying on an empty result.

**On the ticket.** Once the run on the PR's environment (or on dev) passes, offer a comment for the
ticket: each AC, how it was proved, the evidence, and the PR link. Show the draft and post it only on
the developer's yes, through the `ticket-tracker` agent's Comment action. Never put secrets, personal
data or private record content in it.

## When the artifact doesn't work

No Artifact tool, or a publish or database write fails and one retry doesn't fix it:

1. Write what failed and the exact error under `status.md`'s `## Issues found`, and set
   `work_page: local`.
2. Run `progress.mjs` (no `--changed`), render, and open `file://<work folder>/work-page.html`. It
   shows progress as of its last render and its controls do nothing: approval is `/next`, and changes
   are asked for in the terminal. Re-render after each change and tell the developer to reload.

## After the merge

Once the Test-on-dev tab is complete (every step Pass, Fail or Skipped with a reason), ask once:
"Delete the work page and the proof evidence for <ticket>?" On yes: `Artifact` `delete` with
`url: <work_page>`, delete the proof folder, and set `work_page: deleted`. On no, leave both.

## Known limits

- The page can't start a turn, and has no comments: comment wake-ups were refused by auto mode and
  answered by automatic replies before any work happened.
- A card that already holds an answer writes again only when the choice changes.
