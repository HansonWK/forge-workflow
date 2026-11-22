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
| `/clarify` | Interview me to pin down missing info/decisions (or build a guideline doc) |
| `/recalibrate` | Turn this session's corrections into proposed workflow-file updates |

### Starting work

| Command              | Description                                            |
| -------------------- | ------------------------------------------------------ |
| `/begin <task>`      | Start new work — research, agree the ACs, plan, then `/present`. `/begin -s <task>` keeps it in the terminal (no work page) |
| `/branch <TICKET>`   | Create a feature branch from a ticket                  |
| `/research <topic>`  | Run the research phase only                            |
| `/plan`              | Run the planning phase only                            |
| `/present`           | Present the plan for approval (on the work page, or in the terminal) |

### Executing work

| Command    | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| `/next`    | Run subtasks until a stop, show how they were proved; approve to commit each one |
| `/dev`     | Implement, verify and prove the current subtask                |
| `/review`  | On-demand code review (the full review runs at `/signoff`)     |
| `/run`     | Run the app or a service locally (Claude-bg vs your terminal)  |

### Resuming work

| Command   | Description                                                     |
| --------- | --------------------------------------------------------------- |
| `/resume` | Resume an existing plan — picks up where you left off           |
| `/status` | Show the progress dashboard without executing anything          |

### Finishing work

| Command     | Description                                              |
| ----------- | -------------------------------------------------------- |
| `/signoff`      | Final checks in parallel (review, logs, performance, security, SEO, docs, ACs), the completion report, then `/pr` |
| `/pr`           | Push and open the pull request once sign-off covers every commit |
| `/cr`           | Code review (local or worktree-isolated)             |
| `/double-check` | Independent second opinion from a different AI CLI   |
| `/security`     | Run a security audit (`/signoff` runs it on security hotspots) |
| `/slice`        | Decide whether/where to split into mergeable PRs     |
| `/performance`  | Deep performance audit of a service or app           |
| `/clean-up`     | Record finished work, then remove its worktree, work folder and spent reviews (`--dry-run` to preview) |

### Standalone commands

| Command              | Description                                            |
| -------------------- | ------------------------------------------------------ |
| `/ticket`            | Create a ticket from an investigation                  |
| `/explain <target>`  | Explain how existing code works (not a review)         |
| `/presentation`      | Build a deck or a page as a live Artifact (`--slides` / `--page`) |
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

- The loop: `/begin` → `/present` (approve the plan) → `/next` … `/next` (each stop shows the proof; approving commits each subtask) → `/signoff` → `/pr`. You rarely call `/dev` or `/present` directly.
- With a work page, everything is on one live page beside the terminal: rename subtasks, change a tier, answer questions and press Approve or Next there, then type `/next` or "done".
- Every subtask has a tier (Easy / Medium / Hard) and a proof. Claude may raise a tier; only you lower one.
- Each piece of work lives in its work folder, `.claude/temp/work/<slug>/`. Run `/clean-up` each release (or sprint): it keeps one record per finished piece of work in `.claude/temp/complete/` and removes the rest
- Optional modules are opt-in. Re-running `/install` re-offers any module you skipped, so you can grow the workflow as the project needs it.
- Skills (`.claude/skills/`) hold the review/security/testing/verification rubrics; commands call them for you — you don't invoke skills directly. `/dev` self-verifies (build/lint/test) and runs the subtask's proof before the stop.
- The workflow evolves with you: run `/customize` to add/update a skill/command/agent — and Claude will suggest it when it notices you repeating the same request.
```

## Rules

- This command is informational only — it never modifies anything
- Present the guide clearly and ask if the user has questions
