# Forge Workflow

A shared, version-controlled AI development workflow for Claude Code — one your team and the AI *forge* to fit your project, and keep improving together.

## Why Forge Workflow?

Most teams using Claude Code end up with every developer running their own ad-hoc prompts. Forge Workflow gives your team a **shared, version-controlled workflow** that lives in your repository — the same commands, agents, and quality gates for everyone.

**The name is the point.** A workflow isn't something you install once and freeze — you *forge* it. `/install` scans your codebase and stands up a baseline tailored to your language, framework, test/lint/build commands, ticket tracker, and git hosting. From there, you and Claude keep shaping it: tell Claude how your team actually works — *"we squash-merge"*, *"our logs are in Datadog"*, *"always run the accessibility audit on UI changes"*, *"follow the conventions in CONTRIBUTING.md"* — and it rewrites the relevant workflow files. The workflow starts good and gets better the more you use it, encoding **your** project's real conventions and guidelines instead of a generic template.

Because the workflow is just markdown files in your repo:

- **Every developer gets the same workflow** by cloning the repo
- **You and the AI improve it together** — describe how your team works and Claude edits the workflow files to match
- **Changes go through PRs** like any other code — update a workflow file, get it reviewed, merge it
- **It compounds** — once an improvement merges, every developer gets it, and the workflow keeps encoding more of how you actually build

The package ships with sensible example values so the files are readable out of the box; `/install` rewrites them with your real values, and the examples double as documentation of intent.

## Quick Start

**Requirements:** [Claude Code](https://claude.com/claude-code), and Node.js (for the `npx` installer).

### Option 1: npm

```bash
npx forge-workflow install
```

This copies all workflow files into your `.claude/` directory. Then open Claude Code and run:

```
/install
```

Claude will scan your codebase, ask a few questions, and configure the workflow for your project — including which **optional modules** (observability, audit, release, secrets) to set up now, skip for later, or mark not applicable.

### Option 2: Manual

1. Copy the `commands/`, `agents/`, `docs/`, and `examples/` directories into your `.claude/` directory
2. Open Claude Code and run `/install`

That's it. Claude handles the rest.

## What You Get

### The Workflow

```
/begin → /research → /plan → /signoff → /next (dev → review → present) → /security → /pr
```

Start work with `/begin`. Claude researches the codebase, creates a plan broken into reviewable subtasks, and asks for your approval. Then `/next` cycles through each subtask: implement, review, present for approval. When done, `/security` runs an audit and `/pr` creates the pull request.

### Commands

**Starting Work**
| Command | What it does |
|---------|-------------|
| `/begin` | Start new work — research, plan, get approval |
| `/branch` | Create feature branch from ticket |
| `/research` | Run research phase only |
| `/plan` | Run planning phase only |
| `/signoff` | Present research/plan for approval |

**Doing Work**
| Command | What it does |
|---------|-------------|
| `/next` | Execute next subtask (dev → review → present) |
| `/dev` | Implement current subtask |
| `/review` | Run code review |
| `/present` | Present changes for approval |
| `/resume` | Resume existing plan |
| `/status` | Show progress dashboard |
| `/explain` | Deep-dive explanation/review of a file or component |

**Finishing Work**
| Command | What it does |
|---------|-------------|
| `/cr` | Code review (local or worktree-isolated) |
| `/security` | Run security audit |
| `/pr` | Prepare and create pull request |
| `/ticket` | Create ticket from investigation |

**Reference**
| Command | What it does |
|---------|-------------|
| `/workflow` | Show all available commands |
| `/install` | Configure workflow for your project |

### Agents

Specialized agents handle specific tasks behind the scenes:

- **planner** — Breaks work into atomic, reviewable subtasks
- **researcher** — Deep codebase exploration and documentation
- **test-writer** — Generates tests following black-box testing philosophy
- **security-auditor** — OWASP-focused security review
- **performance** — Performance anti-pattern detection
- **pr-sanity-check** — Comprehensive pre-PR review
- **pr-description** — Generates reviewer-first PR descriptions
- **doc-writer** — Documentation generation
- **explainer** — Deep code analysis
- **ticket-tracker** — Ticket system integration (Jira, GitHub Issues, or custom)

### Optional Modules

Beyond the core loop, forge ships opt-in modules. During `/install`, Claude uses what
it found in your codebase to **recommend** the ones that fit — and you choose to set
each up now, skip it for later, or mark it not applicable. Re-running `/install` (or
`/install <module>`) re-offers anything you skipped, so the workflow grows with you.

| Module | Commands | What it adds |
|--------|----------|--------------|
| **observability** | `/logs`, `/fix-logs`, `/dashboard` | Fetch & analyse logs, audit logging against a strategy doc, design monitoring dashboards — tailored to your log provider (App Insights, Datadog, CloudWatch, Loki, Sentry, …) |
| **audit** | `/audit`, `/audit-fix` | Deep multi-dimension codebase audit that fans out agents and writes actionable, grouped issue files; `/audit-fix` turns a dimension file into reviewable PRs |
| **release** | `/changelog`, `/release` | Changelog from git PR history and a version bump across all packages; Claude can parse your CI release workflow to match your process |
| **secrets** | `/secret` | Add/manage secrets in your secrets manager (Keeper, 1Password, Vault, Doppler, cloud secret managers, or `.env`) with a preview-and-approve gate |

**How modules stay high-quality for any stack.** Each module ships a **generalized
command** plus a **fully-worked reference example** in `.claude/examples/` (e.g. a real
Azure App Insights + KQL implementation for observability). When Claude configures a
module for your project, it reads the example to learn the *depth and structure* expected,
then adapts it to your actual provider. A concrete exemplar produces far better generated
commands than an abstract template — the AI can see how specific to be.

## Ticket Tracker Integration

Forge Workflow integrates with your ticket tracking system. During `/install`, choose:

- **Jira** — Full API integration with setup wizard for credentials
- **GitHub Issues** — Uses the `gh` CLI, no extra setup needed
- **Other** — Tell Claude what you use and it generates a custom integration using the existing ones as a template

## Customization

The workflow is designed to evolve. Every file is a markdown prompt that Claude reads and follows. To customize:

1. Tell Claude what you want changed (e.g., "update the security audit to also check for SQL injection in our ORM queries")
2. Claude updates the workflow file
3. Commit and PR the change so your team reviews it
4. Once merged, every developer gets the improvement

You can also edit the files directly — they're just markdown.

## Recommended Settings

Add to your `.claude/settings.json` for the best experience:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit(.claude/**)",
      "Write(.claude/**)"
    ]
  }
}
```

This lets Claude read your codebase freely and manage its own workspace files without prompting.

If you use a formatter, add a hook to auto-format on file writes:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

## What to .gitignore

```
.claude/temp/                 # Ephemeral work files
.claude/settings.local.json   # Personal settings
```

The workflow files themselves (`commands/`, `agents/`, `docs/`, `examples/`) should be committed so your team shares them.

## License

MIT
