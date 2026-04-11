---
description: Present research and plan for approval
---

# Signoff Phase

## Prerequisites

Requires both research.md and plan.md in the current task directory (`.claude/temp/<slug>/`). If missing:

```
Missing required files.
- research.md: <found/not found>
- plan.md: <found/not found>

Run /research and /plan first, or /begin for full workflow.
```

## Instructions

Read both files, then present to the user with summaries followed by links for full review.

### Format

1. **Research summary** — 3-5 bullet points covering: what was found, where the problem is, which files/services are involved, and the root cause.
2. **Plan summary** — numbered list of subtasks with a one-line description of each. Include the total number of subtasks/commits.
3. **Links** — present the full file paths on their own lines so they are clickable in the IDE.

```
## Research Summary
- <bullet points summarising key findings>

## Plan Summary
<numbered subtask list with one-line descriptions>

Full details:

.claude/temp/<slug>/research.md
.claude/temp/<slug>/plan.md

Run /next to continue if approved, or provide feedback to restart the workflow.
```

Where `<slug>` is replaced with the actual task directory name.

**STOP and wait for explicit user response.**

## Handling User Response

### If user runs /next or says approved/go/y:

Check that we are on the correct branch. Prompt the user if not.
Update plan.md Status to `IN_PROGRESS`.
Proceed with /next.

### If user provides feedback:

Determine whether the feedback relates to:

1. **Research concerns** (missing context, wrong assumptions, need to investigate more) — re-run the research phase incorporating the feedback, then re-run planning, then present signoff again.
2. **Plan concerns** (wrong approach, missing steps, wrong scope, implementation details) — re-run the planning phase incorporating the feedback, then present signoff again.

If unclear which phase the feedback targets, use your judgement based on content. Most feedback will be about the plan (implementation details, scope, ordering).

After re-running the relevant phase, present the signoff again in the same format.

## Rules

- NEVER proceed without explicit user approval
- Present file paths as clickable links (on their own lines)
- If user has concerns, address them by re-running the appropriate phase
- Always make sure we are on the right branch before starting work
- This is a 'hidden' workflow command — users should rarely need to call it directly. It runs automatically after /plan and /begin.
