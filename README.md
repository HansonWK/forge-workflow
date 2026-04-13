# Forge Workflow

An opinionated AI-assisted development workflow for Claude Code.

## Why Forge Workflow?

Most teams using Claude Code end up with every developer running their own ad-hoc prompts and workflows. Forge Workflow gives your team a **shared, version-controlled workflow** that lives in your repository. Every developer uses the same commands, agents, and quality gates.

The package ships with sensible example values that make the files readable and understandable out of the box, and `/install` rewrites them with the real values. The examples serve as documentation of intent too.

Because the workflow is just markdown files in your repo:

- **Every developer gets the same workflow** by cloning the repo
- **Changes go through PRs** like any other code — update a workflow file, get it reviewed, merge it
- **The workflow evolves with your team** as you discover what works and what doesn't
- **Claude can update its own workflows** — ask it to improve a command, then PR the change

## Quick Start

### Option 1: npm

```bash
npx forge-workflow install
```

This copies all workflow files into your `.claude/` directory. Then open Claude Code and run:

```
/install
```

Claude will scan your codebase, ask a few questions, and configure the workflow for your project.

### Option 2: Manual

1. Copy the `commands/`, `agents/`, and `docs/` directories into your `.claude/` directory
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

The workflow files themselves (`commands/`, `agents/`, `docs/`) should be committed so your team shares them.

## License

MIT
