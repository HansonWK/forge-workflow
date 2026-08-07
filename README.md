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

### Option 1: install with npx (from GitHub)

The installer is a **scaffolder** — it stages forge's templates in `.claude/.forge/` and installs the
`/install` command. It does **not** add a dependency to your project:

```bash
npx github:HansonWK/forge-workflow install
```

> ⚠️ Use the `github:` form. A bare `npx forge-workflow` fetches an **unrelated** package that
> already owns that name on npm — not this project.

Then open Claude Code and run:

```
/install
```

`/install` scans your codebase, asks a few questions, and **generates** your tailored workflow into
`.claude/commands|agents|skills|docs` from the staged templates — that generated workflow is what you
commit and edit. It also picks which **optional modules** (observability, audit, release, secrets) to
set up now, skip for later, or mark not applicable.

**Want tracked updates?** Add it as a dev dependency (from GitHub) and re-run the installer:

```bash
npm install --save-dev github:HansonWK/forge-workflow
npx forge-workflow install     # re-stage templates into .claude/.forge/
# later: npm update && npx forge-workflow install   (then /install to merge)
```

> npm publishing is coming later — the `npx github:…` command above works today.

### Option 2: Manual

1. Copy this repo's `commands/`, `agents/`, `skills/`, `docs/`, `examples/` into `.claude/.forge/`
2. Copy `commands/install.md` into `.claude/commands/install.md`
3. Open Claude Code and run `/install`

That's it. Claude generates the rest from the staged templates.

## What You Get

### The Workflow

```
/begin → /research → /plan → /signoff → /next (dev → review → present) → /security → /pr
```

Start work with `/begin`. Claude researches the codebase, creates a plan broken into reviewable subtasks (with acceptance criteria), and asks for your approval. Then `/next` cycles through each subtask: implement, **self-verify**, review, present for approval. When done, `/security` runs an audit and `/pr` creates the pull request.

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
| `/double-check` | Independent second opinion from a different AI CLI |
| `/security` | Run security audit |
| `/pr` | Prepare and create pull request |
| `/ticket` | Create ticket from investigation |

**Reference**
| Command | What it does |
|---------|-------------|
| `/workflow` | Show all available commands |
| `/install` | Configure workflow for your project |
| `/customize` | Add/update a workflow piece (skill/command/agent) |
| `/attribution` | Record credits/resources in ATTRIBUTION.md |

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

### Skills

Skills are the single source of truth for the workflow's rubrics and verifiers — commands and agents
**call** them, so "how we review code" or "how we verify a change" lives in one place and loads only
when needed (progressive disclosure). Forge invokes skills explicitly, so they work across model
generations.

- **Rubrics/methods:** `code-review`, `security-review`, `testing`, `writing-plans`, `logging-compliance`
- **Verification:** `verify` (build/lint/test, self-fix to green), `verify-acceptance` (does it
  satisfy the goal + acceptance criteria), `verify-plan` (critique the plan before building),
  `double-check` (independent second opinion from a *different* AI CLI, e.g. Codex)

This gives the workflow a real **verification loop**: `/dev` self-verifies — deterministic checks
*and* acceptance criteria — and fixes its own failures **before** the human approval gate, instead of
leaving all verification to review. If a task starts with no acceptance criteria, forge drafts some
and asks whether to add them to the ticket (so testers can verify later) or keep them local to the plan.

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

The workflow is designed to **evolve with your team** — that's the whole point. Run **`/customize`**
to add or update a piece of your workflow (a skill, command, or agent); it applies the `authoring`
skill, which encodes *your* specific decisions and keeps each piece lean (no role-priming, no generic
best-practice filler — just what actually changes Claude's output).

Reach for it when a **recurring need** shows up:

- You keep asking for the same step (e.g. an extra logging check) → update the relevant skill.
- You keep adding the same acceptance criterion (e.g. "send an event to our GA property on every
  frontend change") → a new skill holding your specifics.

Claude also **suggests `/customize`** when it notices you repeating the same request. However you
change the workflow, commit and PR it so the whole team gets the improvement. (You can still edit the
markdown files directly — they're just prompts.)

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
.claude/.forge/               # Regenerable template cache (re-staged by the installer)
.claude/temp/                 # Ephemeral work files
.claude/settings.local.json   # Personal settings
```

The **generated** workflow files (`commands/`, `agents/`, `skills/`, `docs/`, `examples/`) should be committed so your team shares them. The `.claude/.forge/` template cache is regenerable, so it's gitignored.

## Attribution

forge-workflow builds on work from others — see [ATTRIBUTION.md](ATTRIBUTION.md). We credit the
origin of an idea rather than a blog that reconceptualizes it.

## License

MIT
