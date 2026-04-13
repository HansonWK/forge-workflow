---
description: Resume an existing plan
---

# Resume Existing Plan

## Step 1: Scan for Plans

First, try to match by ticket ID from the current branch name (e.g., branch `PROJ-1234-some-feature` → look for `.claude/temp/PROJ-1234-*/plan.md`). If no branch match, use the provided slug argument.

```bash
# Try ticket ID from branch first
git branch --show-current
# Then search for matching plan directories
ls -d .claude/temp/*/ 2>/dev/null
find .claude/temp/ -name "plan.md" 2>/dev/null
```

For each plan.md found, extract:

- Plan name (directory name)
- Status (READY, IN_PROGRESS, COMPLETE)
- Current subtask position
- Total subtasks

Also read `status.md` from the same directory (if it exists) to get:

- Ticket ID and ticket status
- Work status
- Fix version

## Step 2: Display Options

If no plans found:

```
No plans found in .claude/temp/<slug> or no <slug> folder found.
Run /begin to start new work.
```

If plans found, display numbered list with status.md info where available:

```
Found <N> plan(s):

1. <plan-name> (IN_PROGRESS - Subtask 2/4)
   Task: <task description from metadata>
   Ticket: <ticket-id> | Ticket Status: <status> | Work: <work_status>

2. <plan-name> (READY - not started)
   Task: <task description from metadata>
   Ticket: — | Work: research

3. <plan-name> (COMPLETE)
   Task: <task description from metadata>
   Ticket: <ticket-id> | Ticket Status: Done | Work: merged | Fix: v2.45

Enter number to resume (or 'q' to cancel):
```

## Step 3: Wait for Selection

**STOP and wait for user to enter a number.**

If user enters 'q' or cancels:

```
Cancelled.
```

## Step 4: Load Plan Context

For selected plan:

1. Read `.claude/temp/<name>/research.md` - understand the research
2. Read `.claude/temp/<name>/plan.md` - understand the plan and progress

Determine current position:

- Find first subtask with unchecked `- [ ] Dev`
- Or if all Dev checked, find first with unchecked `- [ ] Review`
- Etc.

## Step 5: Switch Branch (if needed)

Check if we are on a branch with an appropriate name. It will normally start with the ticket ID, and a sensible name for the task at hand. Prompt the user to switch the branch if not. You may find the branch and swap to that branch if it exists already.

## Step 6: Show Status

```markdown
## Resumed: <plan-name>

**Task:** <task description>
**Branch:** <branch-name>
**Progress:** Subtask <current> of <total>

### Current Subtask

**Title:** <subtask title>
**Goal:** <subtask goal>

### Status

- [x] Dev (if complete)
- [ ] Review (if pending)
- [ ] Present
- [ ] Sign Off

### Key Context

<brief summary from research.md - relevant patterns, constraints>

---

Run /next to continue execution.
```

## Rules

- Always read both research.md and plan.md to restore context
- Ensure correct branch is checked out before continuing
- Show clear status so user knows where they left off
- COMPLETE plans should be noted but user can still select to view
