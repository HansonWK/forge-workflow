---
description: Run planning phase only (requires research.md)
---

# Planning Phase

## Prerequisites

Requires existing research.md. If not found:

```
No research.md found.
Run /research first, or /begin for full workflow.
```

## Instructions

Find the current task directory (using our task <slug>, or the most recent work folder in `.claude/temp/work/` with research.md but no plan.md).
If a plan.md already exists, check it is correct for the task description and then run /resume. If it is not complete or not correct, ask the user to manually review.
If no plan exists, run the `planner` agent to create the implementation plan:

- Input: research.md + task description + existing plan if it exists
- Output: `plan.md` in the work folder

## What the Planner Does

1. Reads research.md to understand context
2. Puts the agreed acceptance criteria at the top of plan.md
3. Breaks work into subtasks (small, committable steps), each with a complexity tier, the ACs it proves and its proof
4. Writes the sign-off checks to status.md
5. At any point where there are unknowns or clarifications needed, pause to prompt the user for more information

## Optional Integrations

### Ticket Tracker (if configured)

If a ticket is referenced or can be derived from the branch name, fetch ticket details using the ticket-tracker agent. If the ticket tracker is not configured, skip this step.

## Testing

For large tasks, add unit-test subtasks where appropriate, as their own subtasks.
For small tasks, add a final unit-test subtask to add unit tests at the end.

## Verify the plan

For non-trivial tasks, apply the **`verify-plan` skill**: critique the plan against research and the
acceptance criteria and fix gaps. With no agreed ACs (`/plan` run without `/begin`), it proposes them
and agrees them with the developer first.

## After Planning

After the plan is verified, automatically run `/present` for plan approval. Do not ask the user to
run it manually.

## Rules

- Use the planner agent - don't create plan manually
- Research must exist first
- Each subtask should be small and committable
- Commits happen in `/next`, once the developer approves a stop (the Working agreements in `CLAUDE.md`)
- If the approach is genuinely ambiguous or decisions are needed, apply the `clarify` skill rather than guessing
- For non-trivial work, apply the `slicing` skill to decide whether it's one PR or a stack; record slices in plan.md
- Always check for a plan first and carry on from wherever we stopped work last
- Always track the work we have done in the plan so we can stop and start work as needed
- Stop and prompt the user rather than making assumptions on unknowns or areas of clarification
