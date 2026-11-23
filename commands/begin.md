---
description: Start new work - research, agree the ACs, plan, and present the plan for approval
argument-hint: [-s | --simple] <task-description>
---

# Begin New Work

Input: $ARGUMENTS

**Mode.** If the first word is `-s` or `--simple`, strip it: the rest is the task, and the work runs
in **simple** mode (the plan in the terminal, no work page). `-s` anywhere else is task text. With no
flag, use the default under `## Workflow` in `docs/workflow-config.md` (`page` unless it says
`simple`). Everything else — tiers, proofs, stops, commits, sign-off — is the same in both modes.

## Step 0: Safety Checks

Before starting new work, verify git state:

```bash
git status
git branch --show-current
```

**If uncommitted changes:**

```
Warning: Uncommitted changes detected.
Commit, stash, or discard before starting new work? (y/n)
```

Wait for user to resolve before proceeding.

**If on main with no local commits ahead of origin/main:**

Check if the task description contains a ticket ID (e.g., `PROJ-1234`):

- **ticket found:** Offer to create a feature branch automatically:

  ```
  You're on main. Want me to create a feature branch from this ticket? (y/n)
  ```

  If yes, run `/branch <TICKET-ID>` to pull latest main and create the branch, then continue with Step 1.
  If no, remind them I only commit on a workflow branch:

  ```
  Reminder: I only commit on a workflow branch (see the Working agreements in CLAUDE.md).
  I'll start the research and planning — create the branch before /next.
  ```

- **No ticket:** Remind the user to create a branch:

  ```
  You're on main with no feature branch. I'll start research and planning,
  but I only commit on a workflow branch — create one before /next.
  (Tip: use /branch <TICKET-ID> if you have a ticket)
  ```

**If not on main or a feature branch:**

```
Warning: Currently on branch '<branch-name>', not main.
Switch to main before starting new work? (y/n)
```

## Step 1: Generate Task Slug

Generate a folder name for this task:

1. **Check for a ticket ID** — look at the current branch name (`git branch --show-current`) or the task description for a pattern like `BOARD-123` (e.g., `PROJ-1234`).

2. **If ticket ID found:**

   - Generate a kebab-case slug from the task description
   - Combine: `<TICKET-ID>-<slug>` (e.g., `PROJ-1234-update-media-rules`)

3. **If NO ticket ID found** — prompt the user:

   ```
   No ticket found. What type of task is this?
   1. bugfix
   2. housekeeping
   3. spike
   4. refactor

   Or type a ticket ID (e.g., PROJ-1234) to use instead.
   (Tip: type 'ticket' to create a ticket first via /ticket)
   ```

   **STOP and wait for user response.**

   - If they provide a ticket ID → use `<TICKET-ID>-<slug>` format
   - If they type `ticket` → run `/ticket`, then resume with the created ticket ID
   - If they pick a task type → use `<task-type>-<slug>` format (e.g., `bugfix-search-ranking-issue`)

4. **Validate:** only lowercase alphanumeric and hyphens, max 60 chars. **Reject:** any path separators (/, \, ..)

Present to user:

```
Creating work folder: .claude/temp/work/<slug>/
Is this name ok? (press 'y' to confirm, or type a different name)
```

Wait for user confirmation or alternative name.

## Step 2: Create the work folder

Check if the work folder already exists:

```bash
ls .claude/temp/work/<slug> 2>/dev/null
```

**If it exists:**

```
Work folder '<slug>' already exists.
Options:
1. Use a different slug
2. Resume existing plan (/resume)
```

Do not overwrite existing plans.

**If it doesn't exist:**

```bash
mkdir -p .claude/temp/work/<slug>
```

### Create status.md

In the work folder, create `status.md` using the template defined in `/status` ("Creating status.md" section).

- Set `work_status` to `research` (about to start research phase)
- Set `task_type` based on Step 1 result (ticket → `feature`, or the chosen type)
- Set `ticket` and `ticket_url` if a ticket ID is available
- Set `branch` from `git branch --show-current`
- Set `created` to today's date
- If a ticket tracker is configured, fetch ticket status for `ticket_status`. If not configured, set to `—`
- Set `fix_version` to `null`
- Set `name` to a human-readable version of the task description
- Set `summary` to a one-line summary of the task
- Set `mode` to `page` or `simple` (see **Mode** above)

## Step 3: Research Phase

**Ticket Tracker (optional):**
If the task references a ticket or the branch name contains a ticket ID, use the `ticket-tracker` agent to fetch ticket details. If the ticket tracker is not configured, skip this step and continue.

Use the `researcher` agent to explore the codebase.

Provide the agent with:

- The task description
- Any ticket context (if available)
- Output path: `research.md` in the work folder

The researcher will:

- Read docs, ADRs, plans, vision files
- Find relevant code
- Identify patterns to follow
- Document findings in research.md

## Step 4: Acceptance criteria

Make sure the ACs are there and understood before planning (`writing-plans` → Acceptance criteria).

- **The ticket has provable ACs:** use them, and say in one line if any is too vague to prove.
- **None, or too vague:** propose a provable set from the research and the ticket, and agree it with
  the developer (**STOP and wait**). Then ask whether to add them to the ticket (best, so testers can
  verify later; via the `ticket-tracker` agent) or keep them local to the plan.
- **A bug:** record how it reproduces; the fix is proven against the same steps.

## Step 5: Planning Phase

Use the `planner` agent to create the implementation plan.

Provide the agent with:

- The task description and the agreed ACs
- Path to research.md
- Output path: `plan.md` in the work folder

The planner puts the ACs at the top of `plan.md`, breaks the work into subtasks — each with a
complexity tier, the ACs it proves and its proof — and writes the sign-off checks to `status.md`.
Then apply the `verify-plan` skill and set `work_status: planning`.

## Step 6: Present

Run `/present`: it shows the plan (on the work page, or in the terminal in simple mode) and stops for
approval. After approval, `/next` starts the subtasks.

## Work page

In page mode, `/present` builds and publishes the page from `plan.md` (the `work-page` skill); `/begin`
only records `mode`. If the page can't be published, the skill's fallback renders it locally and the
work carries on.

## Rules

- NEVER skip research, the ACs or planning
- NEVER start a subtask before the plan is approved in `/present`
- If research or planning raises questions, ask them (or put them on the subtask) before `/present`
- The ticket tracker is an optional enhancement - proceed without it if unavailable

## Tracking

- **plan.md**: the canonical plan and cross-session progress
- **status.md**: stage, batch, proofs and sign-off checks (and the work page's data source)
