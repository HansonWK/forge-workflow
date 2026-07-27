---
description: Configure forge-workflow for your project (core + optional modules)
---

# Forge Workflow — Install / Update

Configure forge-workflow for this project. This command scans the codebase, uses what it finds to make recommendations, asks about what it can't determine, then installs or updates the workflow files with project-specific values.

Forge has a **core** workflow (always installed) and a set of **optional modules** (observability, audit, release, secrets). Modules are opt-in: for each one you can **set it up now**, **skip it for later**, or mark it **not applicable**. Re-running `/install` at any time re-offers anything you skipped — so this command is the single entry point for both first-time setup and adding capabilities later.

## Before You Start

Check if this is a **fresh install** or an **update / re-run**:

- If `.claude/docs/workflow-config.md` exists → **update / re-run** (do Phase 1, then use the Re-run rules in Phases 4–5)
- If it doesn't exist → **fresh install**

---

## Phase 1 — Scan the Codebase

Read the project to detect as much as possible automatically. Do NOT ask the user about things you can determine from files.

### Language & Framework

Check these files in order, stop when found:

| File | Language | Notes |
|------|----------|-------|
| `package.json` | JavaScript/TypeScript | `typescript` in devDeps? Framework in `dependencies` (react, next, vue, angular, express, fastify, nest, …) |
| `Cargo.toml` | Rust | Framework (actix, axum, rocket) |
| `pyproject.toml` / `requirements.txt` / `setup.py` | Python | Framework (django, flask, fastapi) |
| `go.mod` | Go | Framework (gin, echo, fiber) |
| `pom.xml` / `build.gradle` | Java/Kotlin | Framework (spring, quarkus) |
| `Gemfile` | Ruby | Framework (rails, sinatra) |
| `*.csproj` / `*.sln` | C# / .NET | Framework (ASP.NET) |

### Test / Lint / Format / Package manager / Build

Detect from config files and the `scripts` section (or language equivalent):

- **Test:** `jest.config.*`, `vitest.config.*`, `pytest.ini`/`conftest.py`, `*_test.go`, `.rspec`, `cargo test`
- **Lint:** `.eslintrc*`/`eslint.config.*`, `biome.json`, `.pylintrc`/`ruff.toml`, `.golangci.yml`, `clippy`
- **Format:** `.prettierrc*`, `biome.json`, `black`, `rustfmt.toml`, `gofmt`
- **Package manager:** lockfile — `package-lock.json`(npm), `pnpm-lock.yaml`(pnpm), `yarn.lock`(yarn), `bun.lockb`(bun), `Cargo.lock`, `poetry.lock`, `Pipfile.lock`, `go.sum`, `Gemfile.lock`
- **Build:** the build script/target

### Git remote & existing setup

```bash
git remote -v
```

Determine hosting (GitHub / GitLab / Bitbucket / other). Check for `.claude/`, `claude.md`/`CLAUDE.md` (both cases), `.claude/docs/workflow-config.md` (previous install), and existing commands.

### Monorepo / targets

Look for `workspaces` in package.json, `nx.json`, `lerna.json`, `pnpm-workspace.yaml`, `turbo.json`, or multiple `package.json` files in subdirectories. Record the list of packages/services/apps — this is the **audit target list** and the **release versioned-file list**.

### Module signals (drives the recommendations in Phase 4)

Scan for evidence that an optional module is relevant, and remember what you found and where:

| Module | Look for | If found, recommend |
|--------|----------|---------------------|
| **observability** | A logging library (`pino`, `winston`, `bunyan`, `serilog`, `zap`, …); an APM/log SDK (`applicationinsights`, `@opentelemetry/*`, `datadog`, `@sentry/*`, `aws-sdk` CloudWatch); `*.kql` files; a `dashboards/` dir; existing `logging*.md` docs | Set up `/logs`, `/fix-logs`, `/dashboard` and scaffold `docs/logging-strategy.md`. Note the detected provider. |
| **audit** | Any non-trivial codebase (always applicable) | Offer the `/audit` + `/audit-fix` sweep, pre-filled with the detected target list. |
| **release** | `.github/workflows/*release*.y*ml` or other CI release config; `CHANGELOG*` files; a `changelog/` dir; a version field + multiple packages; release-style commits in `git log` | Set up `/changelog` + `/release`. **Offer to parse the CI release workflow** to match the existing process. |
| **secrets** | A secrets-manager CLI/config (`.keeper`, `1password`/`op`, `.vault`, `doppler.yaml`, `.aws/`); a large `.env.example`; many secrets referenced in CI | Set up `/secret` for the detected provider. |

Run a couple of quick greps to gather this evidence (e.g. `ls .github/workflows`, `grep -l` for logger/APM deps in the manifest, `git log --oneline | grep -iE 'release'`). Keep the findings for Phase 4.

---

## Phase 2 — Present Findings & Confirm

Present what you found and let the user correct it:

```
I detected the following about your project:

- Language:        [language]
- Framework:       [framework]
- Test runner:     [test runner]
- Linter:          [linter]
- Formatter:       [formatter]
- Package manager: [package manager]
- Git hosting:     [platform]
- Monorepo:        [yes/no]  ([N packages/services detected])

Optional modules I think may apply (I'll ask about each in a moment):
- observability — [evidence, e.g. "found `applicationinsights` + a dashboards/ dir"]
- release       — [evidence, e.g. "found .github/workflows/release.yml"]
- ...

Does the detected setup look correct?
```

**STOP and wait for confirmation.**

---

## Phase 3 — Core Configuration

These apply to the always-installed core workflow.

### Ticket Tracker

```
Which ticket tracking system do you use?

1. Jira          — API integration with a setup wizard
2. GitHub Issues — uses the gh CLI, no extra setup
3. Other         — tell me which and I'll build an integration
4. None          — skip ticket integration
```

**STOP and wait.**

- **Jira:** check for `~/AI/config/jira.env`; if absent, run the setup wizard (email → instance URL → API token from https://id.atlassian.com/manage-profile/security/api-tokens → write the file → verify with `/rest/api/3/myself`).
- **GitHub Issues:** no setup needed; note it in the config.
- **Other:** ask which system; generate a `ticket-tracker.md` using the shipped Jira and GitHub Issues sections as structural templates.
- **None:** remove ticket-related functionality from commands during install.

### Branch Naming

```
Branch naming convention?  Default: <TICKET-ID>-<kebab-case-summary>
(press enter to accept, or type your own)
```

**STOP and wait.** Then ask about any core gaps you couldn't detect (e.g. no test runner found).

---

## Phase 4 — Optional Modules

This is where forge is tailored to how *this* project actually operates. Go through each module below. For each, **lead with a recommendation grounded in the Phase 1 evidence**, then let the user choose one of:

- **Set up now** — configure it and install its (tailored) commands
- **Skip for later** — leave its generic commands in place; record `skipped` so a future `/install` re-offers it
- **Not applicable** — record `n/a` and don't re-offer (offer to remove its generic command files)

Use `AskUserQuestion` per module (or group them into one multi-question call). Frame the recommendation with the evidence, e.g.:

> I found `.github/workflows/release.yml` and 9 versioned `package.json` files. I can
> set up the **release** module (`/changelog` + `/release`) and parse that workflow so
> the commands match your existing process. Set it up now, skip for later, or is it
> not applicable?

**Re-run rule:** if `docs/workflow-config.md` already has a `## Modules` section, only offer modules currently marked `skipped` or missing. Don't re-offer `installed` (unless the user asks to reconfigure) or `n/a` modules. Briefly confirm the installed set at the top instead.

Each module's setup is: **read the reference example → ask the provider/config questions → generate the tailored command files → scaffold the config docs → record state.** The generalized commands ship on disk under `.claude/commands/`; "set up" means rewriting them provider-specifically using the example as the structural guide.

### Module: observability

- **Commands:** `logs.md`, `fix-logs.md`, `dashboard.md`
- **Reference examples:** `.claude/examples/logging/azure-kql-logs.md`, `azure-kql-fix-logs.md`, `azure-kql-dashboard.md`
- **Setup:**
  1. Ask which log provider is used (offer the detected one first): Azure App Insights / Datadog / CloudWatch / Grafana-Loki / Sentry / plain files / other.
  2. Read the matching reference example. If the provider **is** Azure App Insights, tailor directly from it. Otherwise, mirror its structure and depth but swap the query language, access mechanism, and dimension names for the chosen provider.
  3. Scaffold `docs/logging-strategy.md` from `.claude/examples/logging/logging-strategy-template.md`, filled in from the codebase (detected logger, dimensions, services). This doc is what `/fix-logs`, `/dashboard`, and the `logging` audit dimension measure against.
  4. Write the tailored `logs.md`, `fix-logs.md`, `dashboard.md`.
  5. Record provider under `## Observability` in the config.

### Module: audit

- **Commands:** `audit.md`, `audit-fix.md`
- **Setup:**
  1. Confirm the **target list** (from the monorepo/packages scan; for a single app, the app itself).
  2. Prune dimension rows that don't apply (e.g. drop `type-safety` for a dynamically-typed language, drop `accessibility` for non-UI projects, drop `logging` if the observability module wasn't set up).
  3. Write the tailored `audit.md`/`audit-fix.md` and record the target list under `## Audit` in the config.

### Module: release

- **Commands:** `changelog.md`, `release.md`
- **Reference examples:** `.claude/examples/release/changelog-git.md`, `release-monorepo.md`
- **Setup:**
  1. If a CI release workflow was found, **offer to read it** and align the commands with it (don't duplicate what CI already does).
  2. Detect the release-commit convention (`git log`), the PR-merge pattern, and the full set of versioned files (root + each package). Confirm the versioned-file list with the user — a wrong list ships a half-bumped release.
  3. Write the tailored `changelog.md`/`release.md` and record the convention + versioned-file list under `## Release` in the config.

### Module: secrets

- **Command:** `secret.md`
- **Reference example:** `.claude/examples/secrets/keeper.md`
- **Setup:**
  1. Ask which secrets manager is used (offer the detected one first): Keeper / 1Password / Vault / Doppler / AWS or GCP Secrets Manager / plain `.env` / other.
  2. Mirror the example's shape (gather → normalise → authenticate → resolve target → preview → approve → execute), swapping the CLI/API, auth flow, and path model. **Keep the production-secret rule** from the example: reading secret values is dev/test only; adding is allowed for any environment.
  3. Ask for the environment list and the service/scope list. Write the tailored `secret.md` and record the provider + scopes under `## Secrets` in the config.

---

## Phase 5 — Write / Update Files

### Fresh Install

1. **Create directories:** `.claude/docs/`, `.claude/commands/`, `.claude/agents/`, `.claude/examples/`, `.claude/temp/` as needed.
2. **Generate `docs/workflow-config.md`** (see the template below), including the `## Modules` section and a config section for each module set up now.
3. **Install core command/agent files:** for each shipped file, replace example values with detected ones:

   | Find (example value) | Replace with |
   |---|---|
   | `PROJ-1234` | Real ticket prefix (or `#123` for GitHub Issues) |
   | `npm run test` / `lint` / `format` / `format:check` / `build` | Real commands from the scan |
   | `npm audit`, `npm run test:coverage` | The package manager's equivalents |
   | `https://mycompany.atlassian.net` | Real Jira URL (if Jira) |
   | `~/AI/config/jira.env` | Real credentials path (if changed) |
   | `main` (PR base / diff base) | The detected default branch |
   | `gh pr create` | The hosting flow (GitHub `gh`, GitLab `glab`, Bitbucket web) |

   Agents that need **real adaptation** (not just string swaps) — keep their structure, severity classes, and workflow but rewrite the stack/framework examples to match the detected project: `test-writer`, `security-auditor`, `explainer`, `pr-sanity-check`, `doc-writer`, `pr-description`.

   **Generalize ticket wording:** in the core commands (`begin`, `research`, `cr`, `pr`, `next`, `branch`) and `pr-description`, replace any remaining tracker-specific phrasing so it matches the chosen system. For "Other" ticket trackers, generate `ticket-tracker.md` from the shipped Jira/GitHub templates.
4. **Module command files:** for each module **set up now**, write its tailored commands (Phase 4). For each **skipped** module, leave its generic commands as-is. For **n/a** modules, optionally remove their command files.
5. **Handle `CLAUDE.md`** (see below).

### Re-run / Update

When `docs/workflow-config.md` already exists:

1. Read it — get the installed version and the `## Modules` state.
2. For core files: compare each existing file against the shipped version, identify user customizations (content differing from what a prior install would have written), apply new improvements while **preserving customizations**. If you can't confidently tell a user edit from shipped content, show the diff and ask.
3. For modules: only act on ones the user chose to add/reconfigure this run (Phase 4). Don't touch `installed` modules unless asked.
4. **Present a summary of all changes before writing**, then **STOP and wait for confirmation.** Then write and update the version + `## Modules` state.

### `CLAUDE.md`

- **If none exists:** create `CLAUDE.md` at the project root with core coding principles adapted to the stack, testing philosophy, planning conventions (`.claude/temp/`), permissions, a **secrets & credentials safety rule** (never fetch/read production secret values — dev/test only; adding secrets to any environment is fine), and the Forge Workflow section.
- **If one exists:** ensure it has a `# Forge Workflow` section listing the entry-point commands, the working directories, and the workflow principles; add or update it. List the module commands that were set up.

### `docs/workflow-config.md` template

```markdown
# Workflow Configuration

## Project
- Language: [detected]
- Framework: [detected]
- Monorepo: [yes/no]
- Package manager: [detected]

## Commands
- Test: [cmd]
- Lint: [cmd]
- Format: [cmd]
- Format check: [cmd]
- Build: [cmd]

## Ticket Tracker
- System: [Jira / GitHub Issues / Other / None]
- Base URL / Project prefix / Credentials: [if applicable]

## Git
- Hosting: [GitHub / GitLab / Bitbucket]
- Default branch: [detected]
- Branch convention: [convention]

## Working Directories
- AI temp files: .claude/temp/
- AI docs: .claude/docs/

## Modules
- observability: [installed (provider: X) | skipped | n/a]
- audit:         [installed | skipped | n/a]
- release:       [installed | skipped | n/a]
- secrets:       [installed (provider: X) | skipped | n/a]

<!-- One config section per installed module: -->

## Observability   (only if installed)
- Provider: [Azure App Insights / Datadog / ...]
- Logging strategy: docs/logging-strategy.md
- Dashboards dir: [if any]

## Audit   (only if installed)
- Targets: [list of packages/services/apps]
- Output: .claude/audit/<date>/

## Release   (only if installed)
- Release-commit convention: [e.g. "RELEASE: vX.Y.Z"]
- Versioned files: [list]
- CI release workflow: [path, if aligned]

## Secrets   (only if installed)
- Provider: [Keeper / 1Password / ...]
- Environments: [list]
- Scopes/services: [list]

## Forge Workflow
- Version: 1.1.0
```

---

## Phase 6 — Verify & Recommend

Summarise what was done:

```
✓ Forge Workflow configured.

Core: N commands, M agents, config in docs/workflow-config.md
Modules:
  ✓ observability (Azure App Insights)  → /logs /fix-logs /dashboard
  ✓ audit                               → /audit /audit-fix
  – release  (skipped — re-run /install to add)
  – secrets  (n/a)
[Created / Updated] CLAUDE.md
```

Recommend `.gitignore` additions if missing:

```
.claude/temp/                  # Ephemeral work files
.claude/settings.local.json    # Personal settings
```

Suggest next steps: `/workflow` to see all commands; commit the workflow files so the team shares them; note that **re-running `/install` adds any skipped module later**.

---

## Explicit Exclusions

- Do **NOT** generate or modify `.claude/settings.json` or `.claude/settings.local.json` — the user manages those.
- Do **NOT** set up MCP servers — some agents reference optional MCP tools, but those are configured independently.
- Do **NOT** delete existing files the user has in `.claude/` (other than removing a module's own generic command files when the user marks it n/a and confirms).
- Do **NOT** write real secret values into the repo or the config.
- Do **NOT** fetch or read **production** secret values — reading credentials is dev/test only; adding secrets to any environment is fine.

## Arguments

$ARGUMENTS — optional module name(s) to jump straight to (e.g. `/install release`) to add or reconfigure just those. If empty, run the full flow (offering skipped modules on a re-run).
