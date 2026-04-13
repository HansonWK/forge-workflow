---
description: Start new work - research, plan, and signoff
argument-hint: <task-description>
---

# Begin New Work

Task: $ARGUMENTS

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

Check if the task description contains a Jira ticket ID (e.g., `PROJ-1234`):

- **Jira ticket found:** Offer to create a feature branch automatically:

  ```
  You're on main. Want me to create a feature branch from this ticket? (y/n)
  ```

  If yes, run `/branch <TICKET-ID>` to pull latest main and create the branch, then continue with Step 1.
  If no, remind them they'll need to create a branch before committing:

  ```
  Reminder: You'll need to create a feature branch before any commits.
  I'll start the research and planning — you can create the branch when ready.
  ```

- **No Jira ticket:** Remind the user to create a branch:

  ```
  You're on main with no feature branch. I'll start research and planning,
  but you'll need to create a feature branch before any commits.
  (Tip: use /branch <TICKET-ID> if you have a Jira ticket)
  ```

**If not on main or a feature branch:**

```
Warning: Currently on branch '<branch-name>', not main.
Switch to main before starting new work? (y/n)
```

## Step 1: Generate Task Slug

Generate a folder name for this task:

1. **Check for a Jira ticket ID** — look at the current branch name (`git branch --show-current`) or the task description for a pattern like `BOARD-123` (e.g., `PROJ-1234`).

2. **If ticket ID found:**

   - Generate a kebab-case slug from the task description
   - Combine: `<TICKET-ID>-<slug>` (e.g., `PROJ-1234-update-media-rules`)

3. **If NO ticket ID found** — prompt the user:

   ```
   No Jira ticket found. What type of task is this?
   1. bugfix
   2. housekeeping
   3. spike
   4. refactor

   Or type a ticket ID (e.g., PROJ-1234) to use instead.
   (Tip: type 'ticket' to create a Jira ticket first via /ticket)
   ```

   **STOP and wait for user response.**

   - If they provide a ticket ID → use `<TICKET-ID>-<slug>` format
   - If they type `ticket` → run `/ticket`, then resume with the created ticket ID
   - If they pick a task type → use `<task-type>-<slug>` format (e.g., `bugfix-search-ranking-issue`)

4. **Validate:** only lowercase alphanumeric and hyphens, max 60 chars. **Reject:** any path separators (/, \, ..)

Present to user:

```
Creating plan directory: .claude/temp/<slug>/
Is this name ok? (press 'y' to confirm, or type a different name)
```

Wait for user confirmation or alternative name.

## Step 2: Create Directory

Check if directory already exists:

```bash
ls .claude/temp/<slug> 2>/dev/null
```

**If directory exists:**

```
Plan directory '.claude/temp/<slug>/' already exists.
Options:
1. Use a different slug
2. Resume existing plan (/resume)
```

Do not overwrite existing plans.

**If directory doesn't exist:**

```bash
mkdir -p .claude/temp/<slug>
```

### Create status.md

After creating the directory, create `.claude/temp/<slug>/status.md` using the template defined in `/status` ("Creating status.md" section).

- Set `work_status` to `research` (about to start research phase)
- Set `task_type` based on Step 1 result (ticket → `feature`, or the chosen type)
- Set `ticket` and `ticket_url` if a Jira ticket ID is available
- Set `branch` from `git branch --show-current`
- Set `created` to today's date
- If Jira is configured, fetch ticket status for `ticket_status`. If not configured, set to `—`
- Set `fix_version` to `null`
- Set `name` to a human-readable version of the task description
- Set `summary` to a one-line summary of the task

## Step 3: Research Phase

**Jira Integration (optional):**
If the task references a Jira ticket or the branch name contains a ticket ID, use the `ticket-tracker` agent to fetch ticket details. If Jira credentials are not configured, skip this step and continue.

Use the `researcher` agent to explore the codebase.

Provide the agent with:

- The task description
- Any Jira context (if available)
- Output path: `.claude/temp/<slug>/research.md`

The researcher will:

- Read docs, ADRs, plans, vision files
- Find relevant code
- Identify patterns to follow
- Document findings in research.md

## Step 4: Planning Phase

Use the `planner` agent to create the implementation plan.

Provide the agent with:

- The task description
- Path to research.md
- Output path: `.claude/temp/<slug>/plan.md`

The planner will:

- Break work into subtasks (small, committable steps)
- Define goals and files for each subtask
- Create trackable checklists

## Step 5: Signoff

Run /signoff to present the research and plan for user approval. This will show the user clickable file paths and wait for their response.

Do NOT proceed without signoff.

## Rules

- NEVER skip research or planning phases
- NEVER proceed past signoff without explicit approval
- If research or planning raises questions, ask them before signoff
- Jira is an optional enhancement - proceed without it if unavailable

## Tracking

- **plan.md checkboxes**: Track cross-session progress (persistent)
- **TodoWrite**: Track in-session subtasks (ephemeral, for complex phases)
