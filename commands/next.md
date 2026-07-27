---
description: Execute next subtask cycle in current plan
---

# Execute Next Subtask

## Step 1: Find Current Plan

Look for an active plan:

1. First try to match by ticket ID from the current branch name (e.g., branch `PROJ-1234-feature` → look for `.claude/temp/PROJ-1234-*/plan.md`)
2. Fall back to checking all `.claude/temp/*/plan.md` files
3. Find one with Status: `IN_PROGRESS` or `READY`
4. If multiple, show list and ask user to select
5. If none, error: "No active plan found. Run /begin to start new work or /resume to resume existing."

## Step 2: Find Next Subtask

Parse the plan.md to find the next incomplete subtask:

- Look for first subtask where `- [ ] Dev` is unchecked
- Update plan.md Status to `IN_PROGRESS` if it was `READY`

Display:

```
Executing: Subtask <N> of <total>
Title: <subtask title>
Goal: <subtask goal>
```

## Step 3: Dev Phase

Create native tasks for the subtask phases using `TaskCreate` with dependencies:

1. **Dev** — "Implement subtask N: \<title\>" (activeForm: "Implementing \<title\>")
2. **Review** — "Review subtask N" (activeForm: "Reviewing changes", blockedBy: Dev)
3. **Present** — "Present subtask N for approval" (activeForm: "Presenting changes", blockedBy: Review)
4. **Commit** — "Commit subtask N" (activeForm: "Awaiting commit approval", blockedBy: Present)

Mark the Dev task as `in_progress` and run `/dev`. Mark it `completed` when dev finishes.

**Auto-proceed to the Review phase.**

## Step 3b: Review Phase

Mark the Review task as `in_progress`. Run `/review` on the subtask's changes (the `pr-sanity-check` agent). Fix any Critical/High issues and re-review until clean, per `/review`. Update plan.md: check `- [x] Review`. Mark the Review task `completed`.

**Auto-proceed to the Present phase.**

## Step 4: Present Phase

Mark the Present task as `in_progress`.

Present to user:

```markdown
## Subtask <N>: <title>

### Summary

<what was implemented>

### Files Changed

| File | Change           | Lines |
| ---- | ---------------- | ----- |
| ...  | created/modified | +X/-Y |

### Tests

- Added: <N> tests
- Passing: Yes/No

### Outstanding Items

<any issues noted for user attention>

---

**Approve?** (y/go, or provide feedback)
```

**STOP and wait for user approval.**

If user provides feedback:

- Implement changes
- Present again

Mark the Present task as `completed`. Update plan.md: check `- [x] Present`

## Step 5: Commit Phase

Mark the Commit task as `in_progress`.

**NEVER commit automatically.** Always prompt the user to commit work when complete.

Suggest a commit message:

```
Suggested commit message: <concise description of subtask>

Please commit when ready, then say "done" to continue.
```

Wait for user confirmation before proceeding.

Mark the Commit task as `completed`.

## Step 6: Next Steps

After user confirms commit:

```
Subtask <N> complete.

<remaining> subtasks remaining in plan.
Run /next to continue.
```

If this was the last subtask:

```
All subtasks complete!

Next steps:
- /review - Run code review on all branch changes (recommended)
- /security - Run security audit on all changes (recommended)
- /pr - Open pull request
```

## Rules

- NEVER commit without user approval at Present phase
- NEVER commit on behalf of the user - only suggest commit messages
- Update plan.md checkboxes as you complete each phase
- Review runs automatically per subtask (Step 3b, via the pr-sanity-check agent); the comprehensive /security audit runs once before PR

## Tracking

- **plan.md checkboxes**: Track cross-session progress (persistent)
- **Native tasks** (`TaskCreate`/`TaskUpdate`): Track in-session progress with real-time status visibility (ephemeral). Use these for phase-level tracking in `/next` and step-level tracking in `/dev`
