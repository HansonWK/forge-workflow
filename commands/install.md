---
description: Configure forge-workflow for your project
---

# Forge Workflow — Install / Update

Configure the forge-workflow for this project. This command scans the codebase, asks questions about what it can't determine, then installs or updates all workflow files with project-specific values.

## Before You Start

Check if this is a **fresh install** or an **update**:

- If `.claude/docs/workflow-config.md` exists → this is an **update** (go to Phase 1, then use the Update Path in Phase 3)
- If it doesn't exist → this is a **fresh install**

---

## Phase 1 — Scan the Codebase

Read the project to detect as much as possible automatically. Do NOT ask the user about things you can determine from files.

### Language & Framework

Look for these files (check in order, stop when found):

| File | Language | Notes |
|------|----------|-------|
| `package.json` | JavaScript/TypeScript | Check for `typescript` in devDeps. Check `dependencies` for framework (react, next, vue, angular, express, fastify, etc.) |
| `Cargo.toml` | Rust | Check for framework (actix, axum, rocket) |
| `pyproject.toml` / `requirements.txt` / `setup.py` | Python | Check for framework (django, flask, fastapi) |
| `go.mod` | Go | Check for framework (gin, echo, fiber) |
| `pom.xml` / `build.gradle` | Java/Kotlin | Check for framework (spring, quarkus) |
| `Gemfile` | Ruby | Check for framework (rails, sinatra) |
| `*.csproj` / `*.sln` | C# / .NET | Check for framework (ASP.NET) |

### Test Runner

Look for config files:

| Config | Test Runner |
|--------|-------------|
| `jest.config.*` / `"jest"` in package.json | Jest |
| `vitest.config.*` | Vitest |
| `pytest.ini` / `pyproject.toml [tool.pytest]` / `conftest.py` | pytest |
| `Cargo.toml` (Rust has built-in tests) | cargo test |
| `*_test.go` files | go test |
| `.rspec` / `spec/` directory | RSpec |

### Linter

| Config | Linter |
|--------|--------|
| `.eslintrc*` / `eslint.config.*` / `"eslintConfig"` in package.json | ESLint |
| `biome.json` | Biome |
| `.pylintrc` / `pyproject.toml [tool.pylint]` | pylint |
| `.flake8` / `pyproject.toml [tool.flake8]` | flake8 |
| `pyproject.toml [tool.ruff]` / `ruff.toml` | Ruff |
| `.golangci.yml` | golangci-lint |
| `clippy` (Rust, usually via `cargo clippy`) | Clippy |

### Formatter

| Config | Formatter |
|--------|-----------|
| `.prettierrc*` / `"prettier"` in package.json | Prettier |
| `biome.json` | Biome |
| `pyproject.toml [tool.black]` | Black |
| `rustfmt.toml` / `.rustfmt.toml` | rustfmt |
| Go uses `gofmt` by default | gofmt |

### Package Manager

| Lockfile | Package Manager |
|----------|----------------|
| `package-lock.json` | npm |
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | yarn |
| `bun.lockb` | bun |
| `Cargo.lock` | cargo |
| `poetry.lock` | poetry |
| `Pipfile.lock` | pipenv |
| `go.sum` | go |
| `Gemfile.lock` | bundler |

### Build Commands

Read the `scripts` section of `package.json` (or equivalent) to find:
- Test command (e.g., `npm run test`, `pnpm test`)
- Lint command (e.g., `npm run lint`)
- Format command (e.g., `npm run format`)
- Format check command (e.g., `npm run format:check`)
- Build command (e.g., `npm run build`)

For non-JS projects, determine the standard commands (e.g., `cargo test`, `pytest`, `go test ./...`).

### Git Remote

```bash
git remote -v
```

Determine hosting platform: GitHub, GitLab, Bitbucket, or other.

### Existing Setup

- Check if `.claude/` directory exists
- Check if `claude.md` or `CLAUDE.md` exists (check both cases)
- Check if `.claude/docs/workflow-config.md` exists (indicates previous forge-workflow install)
- Check for existing commands in `.claude/commands/`

### Monorepo Detection

Look for: `workspaces` in package.json, `nx.json`, `lerna.json`, `pnpm-workspace.yaml`, `turbo.json`, multiple `package.json` files in subdirectories.

---

## Phase 2 — Present Findings & Ask Questions

Present what you found:

```
I detected the following about your project:

- **Language:** [language]
- **Framework:** [framework]
- **Test runner:** [test runner]
- **Linter:** [linter]
- **Formatter:** [formatter]
- **Package manager:** [package manager]
- **Git hosting:** [platform]
- **Monorepo:** [yes/no]

Does this look correct? Let me know if anything needs adjusting.
```

**STOP and wait for confirmation.**

Then ask about what you couldn't determine:

### Ticket Tracker

```
Which ticket tracking system do you use?

1. **Jira** — I'll set up API integration with a setup wizard
2. **GitHub Issues** — Uses the gh CLI, no extra setup needed
3. **Other** — Tell me which system and I'll create an integration for it
4. **None** — Skip ticket integration for now
```

**STOP and wait for the user's answer.**

**If Jira:**

Check for existing credentials at `~/AI/config/jira.env`. If not found, run the setup wizard:

1. Ask for their Jira email
2. Ask for their Jira instance URL (e.g., `https://mycompany.atlassian.net`)
3. Direct them to generate an API token at `https://id.atlassian.com/manage-profile/security/api-tokens`
4. Wait for them to paste the token
5. Create `~/AI/config/jira.env` with the collected values
6. Verify with a test API call to `/rest/api/3/myself`

**If GitHub Issues:** No setup needed. Note this in the config.

**If Other:** Ask which system. You will generate a custom `ticket-tracker.md` agent in Phase 3 using the existing Jira and GitHub Issues sections as structural templates.

**If None:** Skip ticket integration. Remove ticket-related functionality from commands during install.

### Branch Naming

```
What branch naming convention do you use?

Default: <TICKET-ID>-<kebab-case-summary> (e.g., PROJ-1234-add-user-auth)

Press enter to accept the default, or type your convention:
```

**STOP and wait.**

### Any Gaps

If there are things you couldn't detect (e.g., no test runner config found), ask about them now.

---

## Phase 3 — Install / Update Files

### Fresh Install Path

#### Step 1: Create directories

Create `.claude/docs/`, `.claude/commands/`, `.claude/agents/`, `.claude/temp/` if they don't exist.

#### Step 2: Generate workflow-config.md

Write `.claude/docs/workflow-config.md` with all collected information:

```markdown
# Workflow Configuration

## Project
- **Language:** [detected language]
- **Framework:** [detected framework]
- **Monorepo:** [yes/no]
- **Package manager:** [detected]

## Commands
- **Test:** [detected test command]
- **Lint:** [detected lint command]
- **Format:** [detected format command]
- **Format check:** [detected format check command]
- **Build:** [detected build command]

## Ticket Tracker
- **System:** [Jira / GitHub Issues / Other / None]
- **Base URL:** [if Jira]
- **Project prefix:** [if Jira]
- **Credentials:** [if Jira: ~/AI/config/jira.env]

## Git
- **Hosting:** [GitHub / GitLab / Bitbucket]
- **Default branch:** [main / master / detected]
- **Branch convention:** [convention]

## Working Directories
- **AI temp files:** .claude/temp/
- **AI docs:** .claude/docs/

## Forge Workflow
- **Version:** 1.0.0
```

#### Step 3: Install command and agent files

For each forge-workflow command and agent file in this package:

1. Read the shipped file
2. Replace example values with project-specific values using this mapping:

| Find (example value) | Replace with |
|---|---|
| `PROJ-1234` | Actual ticket prefix pattern (e.g., `MYAPP-1234`, `#123` for GitHub Issues) |
| `npm run test` | Actual test command from detected scripts |
| `npm run lint` | Actual lint command |
| `npm run format` | Actual format command |
| `npm run format:check` | Actual format check command |
| `https://mycompany.atlassian.net` | Actual Jira instance URL (if Jira) |
| `~/AI/config/jira.env` | Actual credentials path (if changed from default) |

3. For framework-specific agents (`test-writer.md`, `security-auditor.md`, `explainer.md`, `pr-sanity-check.md`): these need more substantial adaptation. Read the shipped version, understand its structure and philosophy, then rewrite the framework-specific sections to match the detected project. Keep the structural template, severity classifications, and workflows — replace the framework examples.

4. If the user chose "Other" for ticket tracker: generate a new `ticket-tracker.md` agent using the existing Jira and GitHub Issues sections in the shipped `ticket-tracker.md` as structural templates. Adapt the API calls, authentication, and data parsing for the chosen system.

5. Write each file to `.claude/commands/` or `.claude/agents/`

#### Step 4: Handle claude.md

**If no `claude.md` or `CLAUDE.md` exists:**

Create `.claude.md` (at project root) with:
- Core coding principles adapted to the detected language/framework
- Testing philosophy (black-box testing, predict-then-verify workflow)
- Planning conventions (plans in `.claude/temp/`)
- Permissions (read access everywhere, write access to `.claude/temp/`)
- The Forge Workflow section (see below)

**If `claude.md` or `CLAUDE.md` already exists:**

Check if it already has a `# Forge Workflow` section. If not, append:

```markdown
# Forge Workflow

This project uses [forge-workflow](https://github.com/stuartwhyte/forge-workflow) for AI-assisted development.

## Available Commands
- `/begin` — Start new work (research → plan → signoff)
- `/next` — Execute next subtask
- `/status` — View progress dashboard
- `/resume` — Resume existing plan
- `/pr` — Prepare and create pull request
- `/cr` — Code review
- `/security` — Security audit
- `/workflow` — See all commands

## Working Directories
- `.claude/temp/` — AI workspace for plans, research, status files
- `.claude/docs/workflow-config.md` — Workflow configuration

## Workflow Principles
- All plans live in `.claude/temp/<slug>/plan.md`
- Claude does not commit or push without explicit request
- All .md files created during work go to `.claude/temp/`
```

If it already has the section, update it to match the current version.

### Update Path

When `.claude/docs/workflow-config.md` already exists (previous install detected):

1. Read the existing `workflow-config.md` to get the installed version
2. Compare against the current package version (1.0.0)
3. For each command and agent file:
   - Read the existing file in the user's `.claude/`
   - Compare against the shipped version
   - Identify user customizations (content that differs from what the previous install would have written)
   - Apply new workflow improvements while preserving user customizations
   - If you cannot confidently distinguish a user edit from shipped content, ask the user:
     ```
     In [filename], I found a difference I'm not sure about:
     [show the diff]
     Is this a customization you want to keep, or can I update it?
     ```
4. Present a summary of all changes before writing:
   ```
   Here's what will change:
   - commands/dev.md: Updated test command from `npm run test` to `pnpm vitest`
   - agents/security-auditor.md: Added new OWASP checks (your custom rules preserved)
   - ...

   Proceed? (y/n)
   ```
5. **STOP and wait for confirmation.**
6. Write the updated files
7. Update the version in `workflow-config.md`

---

## Phase 4 — Verify & Recommend

### List what was done

```
✓ Forge Workflow installed successfully!

Files installed:
- 16 commands in .claude/commands/
- 10 agents in .claude/agents/
- Configuration in .claude/docs/workflow-config.md
- [Created / Updated] claude.md with workflow entry points
```

### Recommend .gitignore additions

Check if `.gitignore` exists and whether it already includes these entries. If not, suggest:

```
I recommend adding these to your .gitignore:

.claude/temp/          # Ephemeral work files (plans in progress, research notes)
.claude/settings.local.json  # Personal settings
```

### Suggest next steps

```
Next steps:
1. Run /workflow to see all available commands
2. Commit the workflow files so your whole team shares them
3. Start work with /begin
```

---

## Explicit Exclusions

- Do **NOT** generate or modify `.claude/settings.json` or `.claude/settings.local.json` — these are Claude Code configuration files the user manages independently
- Do **NOT** set up MCP servers — some agents reference optional MCP tools (Memory MCP, GitHub MCP) but these are optional enhancements users configure independently
- Do **NOT** delete any existing files the user has in `.claude/`

## Arguments

$ARGUMENTS - Not used. This command is interactive.
