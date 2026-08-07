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
| `/customize` | Add or update a workflow piece (skill/command/agent) to fit your team |
| `/attribution` | Record what shaped the workflow (attribution vs resources) in ATTRIBUTION.md |

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
| `/cr`           | Code review (local or worktree-isolated)             |
| `/double-check` | Independent second opinion from a different AI CLI   |
| `/security`     | Run a security audit                                 |
| `/pr`           | Prepare and create a pull request                   |

### Standalone commands

| Command              | Description                                            |
| -------------------- | ------------------------------------------------------ |
| `/ticket`            | Create a ticket from an investigation                  |
| `/explain <file>`    | Deep-dive explanation/review of a file or component    |
| `/workflow`          | Show this command reference                            |

### Optional modules

These are installed and tailored to your project by `/install`. Only the modules you
set up appear; run `/install` (or `/install <module>`) to add a skipped one later.

| Command              | Module        | Description                                            |
| -------------------- | ------------- | ------------------------------------------------------ |
| `/logs`              | observability | Fetch, parse, and analyse logs from your log provider  |
| `/fix-logs`          | observability | Audit and fix a service's logging against the strategy |
| `/dashboard`         | observability | Design a monitoring dashboard from your log/metric data|
| `/audit`             | audit         | Deep multi-dimension audit → actionable issue files    |
| `/audit-fix`         | audit         | Implement fixes from one audit dimension file          |
| `/changelog`         | release       | Generate a changelog from git history                  |
| `/release`           | release       | Changelog + version bump across all packages           |
| `/secret`            | secrets       | Add/manage a secret in your secrets manager            |

### Tips

- You don't need to call `/dev`, `/present`, or `/signoff` directly — `/next` and `/begin` orchestrate these for you. `/signoff` runs automatically after planning and presents clickable file links for you to review.
- All plan and research files live in `.claude/temp/` — clean up after your PR is merged
- Optional modules are opt-in. Re-running `/install` re-offers any module you skipped, so you can grow the workflow as the project needs it.
- Skills (`.claude/skills/`) hold the review/security/testing/verification rubrics; commands call them for you — you don't invoke skills directly. `/dev` self-verifies (build/lint/test + acceptance criteria) before the approval gate.
- The workflow evolves with you: run `/customize` to add/update a skill/command/agent — and Claude will suggest it when it notices you repeating the same request.
```

## Rules

- This command is informational only — it never modifies anything
- Present the guide clearly and ask if the user has questions
