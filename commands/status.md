---
description: Show current plan status and progress
argument-hint: <ticket-number> optional
---

# Status

Show the status of work tracked in `.claude/temp/` by reading `status.md` files.

Two modes:

- `/status <ticket-or-slug>` — show and update status for a specific task
- `/status` (no params) — scan all tasks and show a dashboard

## Arguments

$ARGUMENTS — Optional: ticket ID (e.g., `PROJ-1234`) or folder slug to check a specific task.

---

## Ticket Tracker Integration (Optional)

The `ticket-tracker` agent is used to fetch ticket status and fix version. If not configured, work without it.

### Check for ticket-tracker

Check if a `ticket-tracker` agent is available (defined in `.claude/agents/`). If available, it can be used to fetch ticket details.

### If ticket-tracker is not available

Prompt the user **once per /status invocation**:

```
No ticket-tracker agent is configured. With one I can show ticket status and fix versions.

Would you like to set one up now? (y/n)
```

- **y** → Guide the user to create a `ticket-tracker` agent in `.claude/agents/`, then continue with it enabled
- **n** → Continue without ticket tracking. Ticket status and fix version columns will show `—`

Do NOT prompt again during the same invocation. Store the decision and reuse it.

### Fetching ticket data

Use the `ticket-tracker` agent to fetch ticket details (status, fix version, summary). The agent abstracts away the specific ticket system (Jira, Linear, GitHub Issues, etc.).

If the agent call fails, log the error and continue without ticket data for that ticket. Do not block the entire status run.

---

## Mode 1: Single Task — `/status <ticket-or-slug>`

### 1. Find the folder

Search `.claude/temp/` for a directory matching the argument:

- If argument looks like a ticket ID (e.g., `PROJ-1234`), match directories starting with that ID
- Otherwise, match directories containing the argument as a substring

If no match:

```
No task folder found matching '<argument>'.
Run /begin to start new work.
```

If multiple matches, list them and ask user to pick.

### 2. Read status.md

Read `.claude/temp/<folder>/status.md`. If it doesn't exist, create one with defaults (see "Creating status.md" below).

### 3. Update from external sources

**Git info:**

- Check if the branch from status.md exists: `git branch --list <branch>`
- Check if branch is merged to main: `git branch --merged main | grep <branch>`
- If merged and work_status isn't `merged` or `done`, update work_status to `merged`
- Get merged date if available: `git log main --oneline --merges --grep="<branch>" --format="%ai" | head -1`

**Ticket tracker info (if available):**

- Fetch ticket status → update `ticket_status`
- Fetch fix version → update `fix_version` (use the first version name, or `null` if empty)

### 4. Write updated status.md

Save changes back to the file.

### 5. Display

```markdown
## Status: <name>

| Field         | Value                   |
| ------------- | ----------------------- |
| Ticket        | <ticket> (<ticket_url>)  |
| Task Type     | <task_type>             |
| Branch        | <branch>                |
| Work Status   | <work_status>           |
| Ticket Status | <ticket_status or —>    |
| Fix Version   | <fix_version or —>      |
| Created       | <created>               |
| Merged        | <merged_date or —>      |

### Summary

<summary text>

### Plan Progress

<if plan.md exists, show subtask progress like current /status does>
```

---

## Mode 2: Dashboard — `/status` (no params)

### 1. Scan all folders

```bash
ls -d .claude/temp/*/ 2>/dev/null
```

For each directory, check if `status.md` exists. Skip directories without one (they're not tracked tasks — e.g., standalone files or non-task folders).

### 2. Update incomplete tasks

For each status.md where work_status is NOT `done`, `complete`, or `cancelled`:

- Run the same git and ticket tracker checks as Mode 1
- Update the status.md file

### 3. Display dashboard

```markdown
## Task Dashboard

| Ticket    | Task                     | Work Status | Ticket Status | Fix Version |
| --------- | ------------------------ | ----------- | ------------- | ----------- |
| PROJ-1234 | User notification service | merged      | In Review     | —           |
| PROJ-1200 | Search ranking fix        | in-progress | In Progress   | —           |
| —         | bugfix-media-inheritance  | done        | —             | —           |
| PROJ-1180 | Config republish          | merged      | Done          | v2.45       |

### Summary

- **Active:** <N> tasks in progress
- **Review/Merged:** <N> tasks awaiting QA or merge
- **Complete:** <N> tasks done or cancelled

<N> tasks are marked done/cancelled and could be cleaned up.
Would you like to review any of these for deletion?
```

Wait for user response. If they say yes, list the done/cancelled folders and let them pick which to delete. Do NOT auto-delete.

---

## Creating status.md

When a status.md needs to be created (either by /status or by other commands like /begin), use this template:

```yaml
---
name: <human-readable task name>
ticket: <TICKET-ID or null>
ticket_url: <full ticket URL or null>
branch: <branch name from git or null>
task_type: <feature | bugfix | housekeeping | spike | refactor>
created: <YYYY-MM-DD>
---

## Status
- ticket_status: <from ticket tracker or —>
- work_status: <research | planning | in-progress | review | merged | done | cancelled>
- fix_version: <from ticket tracker or null>
- merged_date: <YYYY-MM-DD or null>

## Summary
<one-line summary of the task>
```

### Work status values

- `research` — research phase started
- `planning` — plan created
- `in-progress` — dev work underway
- `review` — code review phase
- `merged` — PR merged to main
- `done` — ticket closed / QA passed
- `cancelled` — work abandoned

### Determining task_type

- If a ticket exists → `feature` (default, unless ticket type says otherwise)
- If folder starts with `bugfix-` → `bugfix`
- If folder starts with `housekeeping-` → `housekeeping`
- If folder starts with `spike-` → `spike`
- If folder starts with `refactor-` → `refactor`
- Otherwise → infer from folder name or ask

---

## Updating status.md

When updating status.md from other commands (/dev, /review, /pr), only update the specific field that changed. Read the file, find the line, replace the value. Do not rewrite the entire file.

Example — updating work_status:

```
Find: `- work_status: <old-value>`
Replace: `- work_status: <new-value>`
```

---

## Rules

- Ticket tracking is always optional — never block on missing configuration
- Prompt for ticket-tracker setup at most once per invocation
- Never auto-delete folders — always let the user decide
- Update status.md files in-place, don't recreate them
- If a status.md is malformed, fix it rather than erroring
- Show clear, actionable output — the user should know what to do next
