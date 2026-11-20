---
description: Run the plan's subtasks until the next stop, then commit them on approval
---

# Next

Runs subtasks until a stop, shows what was done and how it was proved, and commits each subtask on
approval. Approving a stop (`/next`, "approved", "go", or **Next** on the work page) is the same
command.

## Step 1: Find the plan

1. Match the ticket ID in the branch name to a work folder (branch `PROJ-1234-feature` →
   `.claude/temp/work/PROJ-1234-*/plan.md`), else check every work folder's `plan.md`.
2. Take the one with Status `IN_PROGRESS` or `READY`; if several, ask which.
3. None, but an old-style `.claude/temp/<slug>/plan.md` exists: say "Found an old-style folder at
   `<path>`; move it to `.claude/temp/work/<slug>/` to carry on." and stop.
4. Nothing at all: "No active plan found. Run /begin to start new work or /resume to resume existing."

## Step 2: Is a stop open?

If `status.md` has `batch_status: waiting`, this message answers that stop. In page mode, read the
page's input first (`work-page` → Reading the developer's input).

- **Approved** → Step 6 (commit), then carry on.
- **The developer committed themselves** → record each subtask's SHA from `git log`, then carry on.
- **Feedback or a change** → make it, re-run the proof, and stop again.

## Step 3: Choose the batch

Start from the first subtask without a `**SHA:**`. (An older plan's `- [x] Present` counts as
`Proved`.)

- **Lows run on** without a stop. "Some Lows and a Medium" can run together, and so can a couple of
  related Mediums proven together. A proof group stays in one batch. Suggest combining when it fits
  and say so in one line; it's case by case.
- **A High** starts with a discussion: put its open questions to the developer (on the page, or in
  the terminal), set `batch_status: discussing`, and write no code until they're answered.
- **Performance baseline:** before the first subtask marked `**Frontend:** yes`, if the proof folder
  has no `perf-baseline.*`, run the `performance-review` skill's Baseline mode.

Write `batch: [<n>, …]` and `batch_status: doing` to `status.md`; in page mode, update progress
(`work-page` → Keeping it live).

## Step 4: Build and prove each subtask

For each subtask in the batch, run `/dev`: it implements, verifies, and runs the subtask's proof (or,
at the end of a group, the group's) through `verify-acceptance`, with the evidence in the proof
folder. Record the files each subtask touched under `## Subtask files` in `status.md`
(`- 3: src/a.ts, src/a.test.ts`), so the commits stay per subtask across sessions. Tick `- [x] Dev`
and, once its proof passes, `- [x] Proved` (a subtask with `none — <reason>` is Proved when Dev is).

**Escalate** as `writing-plans` says: an issue with the approach → raise the subtask to Medium; the
approach must change → High; a file outside the subtask's list or a diff well past its size → a
signal. Each change of tier is a ledger row. An escalation is a stop.

## Step 5: Stop

Stop at a Medium or High that isn't combined, at the end of a proof group, at an escalation, when a
decision the plan didn't make is needed, or when the batch is done. No code review at stops: the full
review runs once, at `/signoff`.

Set `batch_status: waiting`, write each proof's result under `## Proofs` and the "Proved by" line as
`stop_summary`, then update the page. Show:

```markdown
Subtasks 1–3 done: <title 1>, <title 2>, <title 3>. Proved by <how>.

<the proof itself: a log excerpt, script output, or the screenshot path>

Files to read:
<path>   (subtask 1)
<path>   (subtask 2, 3)

<any escalation, open question or outstanding item>

Work page: <url>      (page mode)

Approve to commit each subtask under its title (/next, "approved", "go", or Next on the page),
commit yourself, or give feedback.
```

**STOP and wait.**

## Step 6: Commit on approval

Only on a branch the workflow owns (the Working agreements in `CLAUDE.md`); otherwise stop and
suggest a correctly named branch. For each subtask in the batch, in order:

```bash
git add <that subtask's files, by name>
git commit -m "<subtask title, in the project's commit message format>"
```

Never `git add -A` or `.`, never amend. Subtasks proven together may share one commit only if you
suggest it and the developer agrees. Fill each subtask's `**SHA:**` in `plan.md`, and update the page.
If a hook or permission refuses a commit, show its message, hand the commit to the developer, and
don't retry another way.

## Step 7: Carry on

More subtasks → back to Step 3. All committed:

```
All subtasks committed. Next: /signoff — the final checks, then the PR.
```

## Rules

- Never commit without approval of the stop, and never push (`/pr` pushes).
- Never lower a tier; only the developer does.
- Read the page's input only at a stop, never mid-batch.
- Keep `plan.md` canonical: a rename, tier change or answer goes there first, then the page.

## Tracking

- **plan.md** (`Dev`, `Proved`, `SHA`) and **status.md** (`batch`, `## Proofs`, `## Subtask files`):
  cross-session progress
- **Native tasks** (`TaskCreate`/`TaskUpdate`): in-session progress through the batch
