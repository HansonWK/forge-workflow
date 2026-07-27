---
description: Create a feature branch from a ticket
argument-hint: <ticket-id> (e.g., PROJ-1234)
---

# Create Feature Branch from a Ticket

Create a feature branch named after a ticket, ensuring a clean state on latest main.

## Arguments

$ARGUMENTS — Required: ticket ID (e.g., `PROJ-1234` for Jira, `#123` for GitHub Issues)

If no ticket ID is provided, ask the user for one and stop.

## Step 1: Validate Ticket ID

Check that `$ARGUMENTS` matches your ticket ID pattern (e.g., `PROJ-1234`, `BOARD-123`, or `#123`). If not, ask the user:

```
Please provide a valid ticket ID (e.g., PROJ-1234)
```

## Step 2: Check for Uncommitted Changes

```bash
git status --porcelain
```

**If there are uncommitted changes:**

```
You have uncommitted changes. Please commit, stash, or discard them before creating a new branch.
```

**STOP and wait for user to resolve.**

## Step 3: Ensure We're on Main

```bash
git branch --show-current
```

**If not on main:**

```
Currently on branch '<branch-name>'. I need to switch to main to create the new branch.
Switch to main? (y/n)
```

**STOP and wait for confirmation.** If the user declines, stop entirely.

If confirmed:

```bash
git checkout main
```

## Step 4: Get Latest Main

```bash
git pull origin main
```

If pull fails, inform the user and stop.

## Step 5: Fetch the Ticket

Use the `ticket-tracker` agent to fetch the ticket and get its title/summary. The agent handles whichever system is configured (Jira, GitHub Issues, or other) and manages its own credentials.

If the ticket tracker isn't configured or the fetch fails, fall back to asking the user for a branch name:

```
Couldn't fetch ticket details. What should the branch be called?
(I'll prefix it with <TICKET-ID>-)
```

## Step 6: Generate Branch Name

Build the branch name from the ticket:

1. Take the ticket ID (uppercase as-is, e.g., `PROJ-1234`)
2. Take the ticket summary and convert to kebab-case: lowercase, replace spaces/special chars with hyphens, remove consecutive hyphens
3. Combine: `<TICKET-ID>-<kebab-summary>`
4. Truncate to 60 characters max (don't cut mid-word)

Present to user:

```
Branch name: <generated-name>
Create this branch? (y, or type a different name)
```

**STOP and wait for confirmation or alternative.**

## Step 7: Create and Checkout Branch

```bash
git checkout -b <branch-name>
```

## Step 8: Confirm

```
Branch '<branch-name>' created from latest main.
You're ready to start work.
```

## Rules

- NEVER create a branch with uncommitted changes
- NEVER switch branches without user confirmation
- Always pull latest main before branching
- Always confirm the branch name with the user before creating
