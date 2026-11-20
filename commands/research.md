---
description: Run research phase only
argument-hint: <task-description>
---

# Research Phase

Task: $ARGUMENTS

## Instructions

Run the `researcher` agent to explore the codebase for this task.

### If the work folder exists

Output to the existing work folder's research.md.

### If no work folder

Generate a slug using the same naming rules as `/begin` Step 1:

- If ticket ID found (from branch or task description) → `<TICKET-ID>-<slug>`
- If no ticket ID → prompt user for task type (bugfix/housekeeping/spike/refactor) or ticket ID, then use `<task-type>-<slug>`

Ask user to confirm, then create the work folder:

```bash
mkdir -p .claude/temp/work/<slug>
```

In it, create `status.md` using the template from `/status` ("Creating status.md" section) with `work_status: research`.

Output to `research.md` in the work folder.

## What the Researcher Does

1. Reads docs, READMEs, ADRs, plans, vision files
2. Finds relevant code for the task
3. Identifies patterns to follow
4. Documents constraints and considerations
5. Suggests an approach
6. If an approach is given by users, assesses approach and gives relevant feedback and alternatives

## Optional Integrations

### Ticket Tracker (if configured)

If the task references a ticket or the branch name contains a ticket ID, use the `ticket-tracker` agent to fetch details. If the ticket tracker is not configured, skip this step. If the ticket has **no acceptance criteria**, note that — the planning stage will draft them (see the `verify-plan` skill).

### GitHub (if referenced)

If the task references a GitHub issue or PR, fetch context using `gh`. If not referenced, skip this step.

## After Research

```
Research complete: .claude/temp/work/<slug>/research.md

Run /plan to create implementation plan, or /begin to run full workflow.
```

## Rules

- Use the researcher agent - don't do manual research
- Output must go to the work folder
- If scope is genuinely unclear or there are decisions to make, apply the `clarify` skill (structured rounds) rather than guessing
