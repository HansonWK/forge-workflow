---
description: Run research phase only
argument-hint: <task-description>
---

# Research Phase

Task: $ARGUMENTS

## Instructions

Run the `researcher` agent to explore the codebase for this task.

### If plan directory exists

Output to the existing plan directory's research.md.

### If no plan directory

Generate a slug using the same naming rules as `/begin` Step 1:

- If ticket ID found (from branch or task description) → `<TICKET-ID>-<slug>`
- If no ticket ID → prompt user for task type (bugfix/housekeeping/spike/refactor) or ticket ID, then use `<task-type>-<slug>`

Ask user to confirm, then create:

```bash
mkdir -p .claude/temp/<slug>
```

After creating the directory, create `.claude/temp/<slug>/status.md` using the template from `/status` ("Creating status.md" section) with `work_status: research`.

Output to `.claude/temp/<slug>/research.md`.

## What the Researcher Does

1. Reads docs, READMEs, ADRs, plans, vision files
2. Finds relevant code for the task
3. Identifies patterns to follow
4. Documents constraints and considerations
5. Suggests an approach
6. If an approach is given by users, assesses approach and gives relevant feedback and alternatives

## Optional Integrations

### Jira (if configured)

If the task references a Jira ticket or the branch name contains a ticket ID, attempt to fetch ticket details. If Jira credentials are not configured, skip this step.

### GitHub (if referenced)

If the task references a GitHub issue or PR, fetch context using `gh`. If not referenced, skip this step.

## After Research

```
Research complete: .claude/temp/<slug>/research.md

Run /plan to create implementation plan, or /begin to run full workflow.
```

## Rules

- Use the researcher agent - don't do manual research
- Output must go to a plan directory
- Ask clarifying questions if scope is genuinely unclear
