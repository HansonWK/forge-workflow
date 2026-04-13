---
description: Show the development workflow and available commands
---

# Development Workflow

Present the following workflow guide to the user:

```markdown
## Workflow Overview

### Setup

| Command    | Description                                                                      |
| ---------- | -------------------------------------------------------------------------------- |
| `/install` | Configure forge-workflow for your project (scan codebase, set up ticket tracker, update files) |

### Starting work

| Command              | Description                                            |
| -------------------- | ------------------------------------------------------ |
| `/begin <task>`      | Start new work — runs research, plan, and signoff automatically |
| `/branch <TICKET>`   | Create a feature branch from a ticket                  |
| `/research <topic>`  | Run the research phase only                            |
| `/plan`              | Run the planning phase only                            |
| `/signoff`           | Present research and plan for approval                 |

### Executing work

| Command    | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| `/next`    | Execute the next subtask cycle (dev, review, present)          |
| `/dev`     | Implement the current subtask                                  |
| `/review`  | Run code review for current changes                            |
| `/present` | Present changes for user approval                              |

### Resuming work

| Command   | Description                                                     |
| --------- | --------------------------------------------------------------- |
| `/resume` | Resume an existing plan — picks up where you left off           |
| `/status` | Show the progress dashboard without executing anything          |

### Finishing work

| Command     | Description                                              |
| ----------- | -------------------------------------------------------- |
| `/cr`       | Code review (local or worktree-isolated)                 |
| `/security` | Run a security audit                                     |
| `/pr`       | Prepare and create a pull request                        |

### Standalone commands

| Command              | Description                                            |
| -------------------- | ------------------------------------------------------ |
| `/ticket`            | Create a ticket from an investigation                  |
| `/workflow`          | Show this command reference                            |

### Tips

- You don't need to call `/dev`, `/present`, or `/signoff` directly — `/next` and `/begin` orchestrate these for you. `/signoff` runs automatically after planning and presents clickable file links for you to review.
- All plan and research files live in `.claude/temp/` — clean up after your PR is merged
```

## Rules

- This command is informational only — it never modifies anything
- Present the guide clearly and ask if the user has questions
