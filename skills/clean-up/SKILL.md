---
name: clean-up
description: Keep .claude/temp/ small. Files strays into place, writes one short record per finished piece of work to .claude/temp/complete/<slug>.md, then removes its worktree, work folder, proof folder and spent /cr reviews, and asks about research, notes and anything unproven or unmerged. Gated on merged, released to production (where the project releases) and proven. Also how to find past work ("we did xyz, can you find it?"). Use for /clean-up, after each release or sprint, when /status says it is overdue, and when the developer asks about old work.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Artifact
---

# Clean-up

`.claude/temp/` is gitignored, so **deletion is permanent**. Nothing is removed before its record is
written and checked, and nothing is removed without the developer's yes. `--dry-run` stops after the
plan.

**When:** <cadence: each release once it reaches production, or each sprint> (`## Clean-up` in
`docs/workflow-config.md`). `/release` suggests it; `/status` says when it's overdue.

## Phase 0: put everything where it belongs

Run first, every time: the gate reads only `work/`. On a tidy repo it finds nothing and says so.

- **Old-style work folders.** A folder at the root of `.claude/temp/` holding `status.md` or
  `plan.md` moves to `.claude/temp/work/<slug>/`. If that folder already exists, ask. List every
  move. A dry run lists the moves without making them.
- **Strays.** A file named for a ticket goes into that ticket's work folder; an audit report into
  `audit/`; a generated report into `reports/`; a one-off note with no ticket into `notes/`. Read
  anything ambiguous before deciding.
- **Duplicates** (two folders for one ticket): report them, never merge them.
- **Stale** (superseded, abandoned, describing code that no longer exists): propose deleting it,
  with what it was and why. Never delete on judgement.

## The gate

Work is **finished** when all three hold:

1. **Merged**: `gh pr view <pr_url> --json state,mergedAt,baseRefName,headRefOid` shows `MERGED`
   into the default branch.
2. **Released**, only where the project releases: <release check, e.g. the ticket's fix version is
   released in the tracker (the `ticket-tracker` agent) and the ticket is Done>. No waiting period
   on top.
3. **Proven**: every line in `status.md`'s `## Proofs` is `pass`, or `skipped` with a reason the
   developer accepted, and no `## Sign-off checks` note starts `fail`. A status with neither section
   predates recorded proofs and counts as proven when its ticket is Done.

| Case | Group |
| --- | --- |
| All three hold | **Finished**: record, then remove |
| Merged, but a proof failed or is missing | **Needs an answer**: name what's missing |
| PR closed unmerged, or `work_status: cancelled` | **Needs an answer**: on a yes, record `abandoned` or `cancelled` |
| No PR, ticket Done (a spike) | **Needs an answer**: on a yes, record `done` |
| No ticket | **Needs an answer**, with its PR and release |
| Merged, not yet released | **Awaiting production**: untouched |
| No merged PR | **In flight**: report `work_status` and the ticket status, untouched |

**Finding the PR.** `pr_url` in `status.md` first. Otherwise match the branch on `headRefName` (not
the title) over the whole PR history: `gh pr list --state all --limit <n> --json
number,state,headRefName,baseRefName,headRefOid,mergedAt,url`. A count equal to `<n>` means the list
was cut: raise it and run again. A cut list makes old merged work look unmerged. Never judge age by
folder mtime.

## The record

Before anything of a finished piece of work is removed, write `.claude/temp/complete/<slug>.md`, one
key per line:

```
---
ticket: <KEY>
ticket_url: <url>
pr: <url>
branch: <branch>
merged: <YYYY-MM-DD>
released: <version and date, or n/a>
status: done | cancelled | abandoned
---
# <ticket>: <title>
<two or three sentences: what changed and why>

## Subtasks
- <n>. <title> (<commit sha>)

## Proof
<one line per AC: how it was proven; the proof folder itself is deleted>

## Docs and pages
- <docs, wiki pages, ADRs created or changed, with links>

## Worth remembering
<gotchas found along the way, or nothing>
```

Fill it from what the folder holds, never from memory: front matter from `status.md`, else the PR
and the tracker; the summary from `## Summary`, `plan.md` and the PR description; subtasks from
`plan.md` with each `**SHA:**`; proof from each AC in `plan.md` and its `## Proofs` line (`not
recorded` for work from before proofs); docs from `gh pr diff <n> --name-only` and the pages the work
named; worth remembering from `## Issues found` and anything in `research.md` that would bite the
next person. Files already in `complete/` in another shape stay as they are.

## What goes for finished work

Once its record is written and checked:

- **Its worktree.** Find it in `git worktree list --porcelain` by `branch refs/heads/<branch>`. Under
  `<worktree folder>` and not a kept checkout (`worktree` skill): check the tip is the PR's
  `headRefOid` or an ancestor of it (`git merge-base --is-ancestor <tip> <headRefOid>`), else name
  the commits the PR never saw and ask; then the `worktree` skill's Remove, and its builds and
  indexes. A worktree anywhere else is the developer's: list it, never remove it.
- **Its work folder**, all of it: plan, research, review notes, status, the work page's local files
  and the proof folder (`proof/`, unless `## Working Directories` names another).
- **Its proof scripts**, read first. One that proves a new feature or a core business rule end to end
  may be worth an e2e test (the `testing` skill): offer it, naming the test file it would join and
  that it adds to every CI run. On a yes, move it to `notes/e2e-<slug>/` for its own branch. Every
  other script goes; nothing is kept "just in case".
- **Its published pages.** `work_page` when it holds an artifact URL (not `local`, `deleted` or
  null), and any test-report artifact URL in `status.md`: offer to delete each with `Artifact`
  `delete`, and delete only on a yes.

## The other folders

- **`cr/<branch>.md` reviews.** Read the branch from the report's `# Code Review: <branch>` heading
  (the filename has `/` replaced). Delete each whose PR merged; one with no PR or an open PR stays.
- **Worktrees no work folder claims.** Under `<worktree folder>`, detached or on a branch no work
  folder names, and not a kept checkout: **Needs an answer**, with branch, `git status --short` and
  size. On a yes, the `worktree` skill's Remove.
- **Research.** A finished ticket's research goes with its work folder. Research with no ticket, or
  for unfinished work (a work folder holding only `research.md`): ask to keep it, delete it, or turn
  it into a doc (a docs page, a runbook, a README section). Offer the doc when it describes how
  something works today and isn't written down anywhere else.
- **`notes/`, `reports/`, `audit/` and loose files.** Propose deleting each one nothing uses any
  more (superseded, describing code that no longer exists, older than the thing it describes), with
  what it was. Never on judgement alone.

## Never touch

- `user/` and every ledger (`ledger/`). This skill only appends its own row to `ledger/clean-up.tsv`.
- `complete/` records.
- <never-touch list: the project's own additions, or none>
- Any `.claude/temp/` path a tracked file names: `git grep -h -o -E '\.claude/temp/[A-Za-z0-9._/-]+'`.
- Kept checkouts (`worktree` skill).
- Anything with uncommitted or unrecorded work: ask instead.

## Procedure

1. **Phase 0.**
2. Scan `work/`, `cr/`, `notes/`, `reports/`, `audit/`, the rest of `.claude/temp/`, and
   `git worktree list --porcelain`. Gate each work folder.
3. **Show the whole plan before deleting anything**, in groups, each item with its `du -sh` size and
   each group with a total:
   1. Records to write
   2. Worktrees to remove
   3. Work folders to remove, with their proof folders
   4. Proof scripts, with any e2e offer
   5. Spent `cr/` reviews
   6. Research
   7. Other temp files
   8. Published pages to delete
   9. Needs an answer, each with what's missing

   Then, untouched: awaiting production, and in flight with their status.
4. **`--dry-run`:** stop here and write only the ledger row (step 8).
5. **Wait for a yes, group by group.**
6. **Write every record first**, then check each landed: non-empty, starting with `---`, with
   `ticket:` and `pr:` lines. Only then act on the confirmed groups. Refuse any group holding an
   item whose record isn't checked. Run batch removals as a `bash` script in a scratch folder (in
   zsh an unquoted variable holding several names stays one word), and count before and after.
7. Report what was removed, with the space freed, and what was skipped, with the reason.
8. Append `<YYYY-MM-DD>\t<marker>` to `.claude/temp/ledger/clean-up.tsv`, dry runs included: read
   it (it may not exist yet) and `Write` it back with the row added, not a shell redirect, so the
   hardening block's `ledger/**` allow covers it. The marker is the newest production release, or
   `-`. If the write is refused, stop and report it.

## Finding old work

When the developer asks about past work ("we did xyz, can you find it?"), search in this order and
stop at the first hit that answers it:

1. `.claude/temp/complete/`: front matter first (`ticket:`, `branch:`, `pr:`), then the text.
2. Live `.claude/temp/work/*/status.md` and `plan.md`.
3. `git log --all -i --grep '<term>'`, and the whole PR list matched on `headRefName` and title.
4. The ticket tracker (the `ticket-tracker` agent), by text search.

Answer with the ticket, branch, PR, the record's summary and its path.
