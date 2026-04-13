# Forge Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an open-source npm package that installs an opinionated AI-assisted development workflow into any project's `.claude/` directory.

**Architecture:** Copy and generalize 16 commands, 10 agents from the source ngw-app-ts workflow. All files are markdown prompts for Claude — no code templating. An `/install` command uses Claude's LLM capabilities to scan the codebase, ask questions, and rewrite files with project-specific values. A `package.json` enables npm distribution.

**Tech Stack:** Markdown, npm (for distribution only), Claude Code slash commands

**Spec:** `docs/superpowers/specs/2026-03-23-forge-workflow-design.md`

**Source files:** `/Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/`

---

## File Structure

```
forge-workflow/
├── package.json                          # NEW — npm distribution metadata
├── bin/install.js                        # NEW — CLI entry point for npx forge-workflow install
├── README.md                             # NEW — project documentation
├── commands/
│   ├── install.md                        # NEW — the /install command
│   ├── begin.md                          # COPY+GENERALIZE from source
│   ├── branch.md                         # COPY+GENERALIZE from source
│   ├── cr.md                             # COPY+GENERALIZE from source
│   ├── dev.md                            # COPY+GENERALIZE from source
│   ├── next.md                           # COPY+GENERALIZE from source
│   ├── plan.md                           # COPY+GENERALIZE from source
│   ├── pr.md                             # COPY+GENERALIZE from source
│   ├── present.md                        # COPY (already generic)
│   ├── research.md                       # COPY (already generic)
│   ├── resume.md                         # COPY+GENERALIZE from source
│   ├── review.md                         # COPY (already generic)
│   ├── security.md                       # COPY (already generic)
│   ├── signoff.md                        # COPY (already generic)
│   ├── status.md                         # COPY+GENERALIZE from source
│   ├── ticket.md                         # COPY+GENERALIZE from source
│   └── workflow.md                       # COPY+UPDATE command list
├── agents/
│   ├── doc-writer.md                     # COPY (already generic)
│   ├── explainer.md                      # COPY+GENERALIZE from source
│   ├── performance.md                    # NEW — flesh out from empty stub
│   ├── planner.md                        # COPY+GENERALIZE from source
│   ├── pr-description.md                 # COPY+GENERALIZE from source
│   ├── pr-sanity-check.md               # COPY+GENERALIZE from source
│   ├── researcher.md                     # COPY+GENERALIZE from source
│   ├── security-auditor.md              # COPY+GENERALIZE from source
│   ├── test-writer.md                    # COPY+GENERALIZE from source
│   └── ticket-tracker.md                # NEW — generalized from agents/jira.md + commands/jira.md
└── docs/
    └── workflow-config.md                # EXAMPLE — ships as reference, /install generates the real one
```

---

### Task 1: Project Scaffolding

**Files:**
- Create: `package.json`
- Create: `commands/` directory
- Create: `agents/` directory
- Create: `docs/` directory

- [ ] **Step 1: Initialize git repo**

```bash
cd /Users/stuartwhyte/Work/forge-workflow
git init
```

- [ ] **Step 2: Create package.json**

```json
{
  "name": "forge-workflow",
  "version": "1.0.0",
  "description": "An opinionated AI-assisted development workflow for Claude Code. Install into your repo so every developer shares the same workflow.",
  "keywords": ["claude", "claude-code", "workflow", "ai", "development"],
  "author": "Stuart Whyte",
  "license": "MIT",
  "bin": {
    "forge-workflow": "./bin/install.js"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/stuartwhyte/forge-workflow.git"
  },
  "files": [
    "bin/",
    "commands/",
    "agents/",
    "docs/",
    "README.md"
  ]
}
```

- [ ] **Step 3: Create directory structure**

```bash
mkdir -p commands agents docs bin
```

- [ ] **Step 3b: Create bin/install.js CLI entry point**

This is the script that runs when a user executes `npx forge-workflow install`. It:
1. Copies all `commands/`, `agents/`, and `docs/` files into the target project's `.claude/` directory
2. Prints a message telling the user to run `/install` in Claude Code to complete setup

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const command = process.argv[2];
if (command !== 'install') {
  console.log('Usage: npx forge-workflow install');
  process.exit(1);
}

const sourceDir = path.join(__dirname, '..');
const targetDir = path.join(process.cwd(), '.claude');

const dirs = ['commands', 'agents', 'docs'];

// Create .claude directory if needed
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

let copied = 0;
for (const dir of dirs) {
  const src = path.join(sourceDir, dir);
  const dest = path.join(targetDir, dir);
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  const files = fs.readdirSync(src);
  for (const file of files) {
    fs.copyFileSync(path.join(src, file), path.join(dest, file));
    copied++;
  }
}

console.log(`\n✓ Copied ${copied} forge-workflow files to .claude/`);
console.log('\nNext step: Open Claude Code and run /install to configure the workflow for your project.\n');
```

- [ ] **Step 4: Create .gitignore**

```
node_modules/
.DS_Store
```

- [ ] **Step 5: Commit**

```bash
git add package.json .gitignore
git commit -m "chore: initialize forge-workflow package"
```

---

### Task 2: Copy Generic Commands (no changes needed)

These commands have no app-specific content and can be copied directly from source.

**Files:**
- Copy: `commands/present.md` from source `commands/present.md`
- Copy: `commands/research.md` from source `commands/research.md`
- Copy: `commands/review.md` from source `commands/review.md`
- Copy: `commands/security.md` from source `commands/security.md`
- Copy: `commands/signoff.md` from source `commands/signoff.md`
- Copy: `commands/plan.md` from source `commands/plan.md`

- [ ] **Step 1: Copy all 6 generic commands**

```bash
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/present.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/research.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/review.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/security.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/signoff.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/plan.md commands/
```

- [ ] **Step 2: Quick review each file for any missed app-specific references**

Read each file and verify no references to: ngw, persimmon, NG20, Azure, PIM, COINS, Zod, libs/types, apps/services. If any found, note them for generalization in a later task.

- [ ] **Step 3: Commit**

```bash
git add commands/
git commit -m "feat: add generic commands (present, research, review, security, signoff, plan)"
```

---

### Task 3: Copy and Generalize Ticket-Dependent Commands

These commands reference Jira/ticket patterns and need the `NG20-1234` pattern replaced with `PROJ-1234`, Jira URLs replaced with `https://mycompany.atlassian.net`, and `~/AI/config/jira.env` as the default credentials path.

**Files:**
- Copy+Edit: `commands/begin.md`
- Copy+Edit: `commands/branch.md`
- Copy+Edit: `commands/next.md`
- Copy+Edit: `commands/resume.md`
- Copy+Edit: `commands/status.md`
- Copy+Edit: `commands/ticket.md`

**Source:** `/Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/`

- [ ] **Step 1: Copy source files**

```bash
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/begin.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/branch.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/next.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/resume.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/status.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/ticket.md commands/
```

- [ ] **Step 2: Generalize begin.md**

Read the file. Replace:
- `NG20-1234` → `PROJ-1234`
- Any `persimmonplc.atlassian.net` → `https://mycompany.atlassian.net`
- References to `/jira` command → reference the `ticket-tracker` agent directly
- Any ngw-specific paths or terminology

- [ ] **Step 3: Generalize branch.md**

Same replacements as begin.md, plus:
- Branch convention should use `PROJ-1234` prefix as the example
- Remove any hardcoded JIRA_BASE_URL values

- [ ] **Step 4: Generalize next.md**

Replace ticket ID patterns. Remove any app-specific plan references.

- [ ] **Step 5: Generalize resume.md**

Replace Jira-specific status lookups with generic ticket-tracker agent references.

- [ ] **Step 6: Generalize status.md**

Replace:
- Jira API calls → ticket-tracker agent references
- `~/AI/config/jira.env` path kept as example default
- Remove any ngw-specific work status values that don't generalize
- Keep the dashboard format and status tracking

- [ ] **Step 7: Generalize ticket.md**

Replace Jira-specific ticket format with generic format. Keep the investigation-to-ticket conversion workflow.

- [ ] **Step 8: Verify no remaining app-specific references**

Search all 6 files for: ngw, persimmon, NG20, Azure, PIM, COINS, Bluestone, Zod, libs/types, apps/services, product-service, sales-service, search-service, content-service, portal-service, lead-service

- [ ] **Step 9: Commit**

```bash
git add commands/
git commit -m "feat: add generalized ticket-dependent commands (begin, branch, next, resume, status, ticket)"
```

---

### Task 4: Copy and Generalize Build-Dependent Commands

These commands reference `npm run test/lint/format` and need project-specific build commands replaced with example values.

**Files:**
- Copy+Edit: `commands/dev.md`
- Copy+Edit: `commands/pr.md`
- Copy+Edit: `commands/cr.md`

**Source:** `/Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/`

- [ ] **Step 1: Copy source files**

```bash
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/dev.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/pr.md commands/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/cr.md commands/
```

- [ ] **Step 2: Generalize dev.md**

Replace:
- Standardize all test/lint/format commands to `npm run test`, `npm run lint`, `npm run format:check` as shipped examples (these are the generic defaults that /install will replace with the real commands)
- If source has any non-npm commands (e.g., `npx nx test`), replace with the `npm run` equivalents
- Remove Zod schema consistency check section (libs/types specific)
- Remove `CLAUDE.md` reference → `claude.md` (lowercase, standard)
- Keep the predict-then-verify testing workflow

- [ ] **Step 3: Generalize pr.md**

Replace:
- npm script references (keep `npm run` as example values)
- Ticket linking format → use `PROJ-1234` example
- Fix step numbering gap (Step 3 → Step 5 in source)
- Remove any ngw-specific references

- [ ] **Step 4: Generalize cr.md**

Replace:
- `apps/services/` hardcoded path → remove or replace with generic "If the branch has changes in security-sensitive directories"
- Jira ticket ID pattern → `PROJ-1234`
- `~/AI/config/jira.env` references → ticket-tracker agent
- `.claude/temp/cr/` kept as the review output directory

- [ ] **Step 5: Verify no remaining app-specific references**

Search all 3 files for app-specific terms.

- [ ] **Step 6: Commit**

```bash
git add commands/
git commit -m "feat: add generalized build-dependent commands (dev, pr, cr)"
```

---

### Task 5: Update workflow.md

**Files:**
- Copy+Edit: `commands/workflow.md`

- [ ] **Step 1: Copy and rewrite workflow.md**

Copy from source, then update to reflect the final command list (16 commands, removing clear-down, changelog, logs, jira). Update descriptions to be generic. This is an informational reference — no functional logic.

- [ ] **Step 2: Commit**

```bash
git add commands/workflow.md
git commit -m "feat: add workflow command reference"
```

---

### Task 6: Copy Generic Agents

**Files:**
- Copy: `agents/doc-writer.md`

- [ ] **Step 1: Copy doc-writer.md**

```bash
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/doc-writer.md agents/
```

- [ ] **Step 2: Verify no app-specific references**

- [ ] **Step 3: Commit**

```bash
git add agents/doc-writer.md
git commit -m "feat: add doc-writer agent"
```

---

### Task 7: Copy and Generalize Framework-Dependent Agents

**Files:**
- Copy+Edit: `agents/explainer.md`
- Copy+Edit: `agents/test-writer.md`
- Copy+Edit: `agents/security-auditor.md`
- Copy+Edit: `agents/pr-sanity-check.md`
- Copy+Edit: `agents/pr-description.md`

**Source:** `/Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/`

- [ ] **Step 1: Copy source files**

```bash
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/explainer.md agents/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/test-writer.md agents/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/security-auditor.md agents/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/pr-sanity-check.md agents/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/pr-description.md agents/
```

- [ ] **Step 2: Generalize explainer.md**

Replace React/Next.js specific checks with generic examples. Keep the multi-level analysis structure. Ship with React/TypeScript as example framework (will be rewritten by /install).

- [ ] **Step 3: Generalize test-writer.md**

This needs the most substantial rewrite of any agent:
- Replace Jest v29.7.0 specifics with generic test runner examples
- Replace `@testing-library/react` with generic component testing references
- Replace Azure Functions context mocking with generic API handler examples
- Replace `@persimmonhomes/auth`, Brand enum, etc.
- Keep the black-box testing philosophy, AAA pattern, mock data factory patterns
- Ship with Jest/React as example (will be substantially rewritten by /install)

- [ ] **Step 4: Generalize security-auditor.md**

- Remove Azure Functions specific sections (authorizeRequest, shared auth library)
- Remove `@persimmonhomes/auth`, `@persimmonhomes/logger` references
- Remove specific service names (orchestrator, product-service, etc.)
- Keep OWASP framework, severity classification, blocking behavior
- Ship with general web app examples, plus React/Next.js as example framework sections

- [ ] **Step 5: Generalize pr-sanity-check.md**

- Remove `libs/types/` Zod schema consistency checks
- Remove specific schema file references (productMedia.ts, etc.)
- Replace project conventions with generic examples (ship with TypeScript examples)
- Keep multi-category review structure, issue classification, readiness scoring

- [ ] **Step 6: Generalize pr-description.md**

- Replace `https://persimmonplc.atlassian.net` → `https://mycompany.atlassian.net`
- Replace `NG20-1234` branch pattern → `PROJ-1234`
- Keep reviewer-first philosophy, size-based templates, risk assessment

- [ ] **Step 7: Verify no remaining app-specific references across all 5 agents**

- [ ] **Step 8: Commit**

```bash
git add agents/
git commit -m "feat: add generalized framework-dependent agents"
```

---

### Task 8: Copy and Generalize Planner and Researcher Agents

**Files:**
- Copy+Edit: `agents/planner.md`
- Copy+Edit: `agents/researcher.md`

- [ ] **Step 1: Copy source files**

```bash
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/planner.md agents/
cp /Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/researcher.md agents/
```

- [ ] **Step 2: Generalize planner.md**

- Make Memory MCP references optional ("If Memory MCP is available, ...")
- Make GitHub MCP references optional ("If GitHub MCP is available, ...")
- Replace any `libs/types/` or schema references
- Standardize terminology: "subtask" not "commit" for unit of work
- Keep atomic sizing, layered thinking, dependency ordering

- [ ] **Step 3: Generalize researcher.md**

- Same MCP treatment as planner
- Remove Zod schema identification in `libs/types/`
- Keep documentation discovery, pattern identification, gap reporting

- [ ] **Step 4: Commit**

```bash
git add agents/
git commit -m "feat: add generalized planner and researcher agents"
```

---

### Task 9: Create Ticket Tracker Agent

This is a new file combining functionality from the source `agents/jira.md` and `commands/jira.md` into a single agent that supports Jira (as shipped example) and documents how /install adapts it for GitHub Issues or other systems.

**Files:**
- Create: `agents/ticket-tracker.md`
- Reference: source `agents/jira.md` and source `commands/jira.md`

- [ ] **Step 1: Read source files**

Read both `/Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/agents/jira.md` and `/Users/stuartwhyte/Work/PH/ngw-app-ts/.claude/commands/jira.md` to understand the full Jira integration.

- [ ] **Step 2: Write ticket-tracker.md**

Create a new agent file that:
- Ships with Jira as the example implementation (fetch ticket, setup wizard, credentials)
- Uses `https://mycompany.atlassian.net` as example URL
- Uses `PROJ-1234` as example ticket pattern
- Uses `~/AI/config/jira.env` as example credentials path
- Documents that /install will adapt this for the chosen ticket system
- Includes a section header noting "GitHub Issues variant" that /install uses when rewriting
- Keeps: credential management, ticket fetching, acceptance criteria analysis, setup wizard flow
- Replaces: `persimmonplc.atlassian.net`, `NG20-*` pattern, hardcoded user path

- [ ] **Step 3: Commit**

```bash
git add agents/ticket-tracker.md
git commit -m "feat: add ticket-tracker agent (Jira example, adaptable by /install)"
```

---

### Task 10: Create Performance Agent

The source `performance.md` is empty. Create a general-purpose performance review agent.

**Files:**
- Create: `agents/performance.md`

- [ ] **Step 1: Write performance.md**

Create a performance review agent that:
- Analyzes code changes for performance implications
- Checks for common performance anti-patterns (N+1 queries, unnecessary re-renders, missing indexes, large bundle imports, synchronous blocking)
- Framework-agnostic core with example sections for web apps
- Uses severity classification (Critical/High/Medium/Low) consistent with other agents
- Ships with generic web performance examples (will be adapted by /install)

- [ ] **Step 2: Commit**

```bash
git add agents/performance.md
git commit -m "feat: add performance review agent"
```

---

### Task 11: Create Example workflow-config.md

**Files:**
- Create: `docs/workflow-config.md`

- [ ] **Step 1: Write workflow-config.md**

Create the example config file as documented in the spec. This ships as a reference showing the format — /install generates the real one in the user's project.

Add a comment at the top:

```markdown
# Workflow Configuration

> This is an example configuration. Run `/install` to generate one tailored to your project.
```

Then include all sections from the spec (Project, Commands, Ticket Tracker, Git, Working Directories, Forge Workflow version).

- [ ] **Step 2: Commit**

```bash
git add docs/workflow-config.md
git commit -m "feat: add example workflow-config.md"
```

---

### Task 12: Create the /install Command

This is the most important file in the package. It instructs Claude to scan the codebase, ask questions, and install/update the workflow files.

**Files:**
- Create: `commands/install.md`

- [ ] **Step 1: Write install.md — Phase 1 (Scan)**

The command must instruct Claude to:
- Read `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or equivalent to detect language/framework
- Detect test runner (look for jest.config, vitest.config, pytest.ini, etc.)
- Detect linter (eslint, pylint, golint configs)
- Detect formatter (prettier, black, gofmt configs)
- Detect package manager (npm, pnpm, yarn, pip, cargo, go)
- Run `git remote -v` to detect hosting (GitHub, GitLab, Bitbucket)
- Check for existing `.claude/` directory and `claude.md`
- Check for existing forge-workflow files (look for `.claude/docs/workflow-config.md`)
- Detect monorepo patterns (workspaces in package.json, nx.json, lerna.json)

- [ ] **Step 2: Write install.md — Phase 2 (Present & Ask)**

The command must instruct Claude to:
- Present scan findings: "I detected a [language]/[framework] project using [test runner], [linter], [formatter], hosted on [platform]."
- Ask about ticket tracker: "Will you use Jira, GitHub Issues, or another system?"
  - If Jira: run setup wizard — ask for email, instance URL, generate API token link (`https://id.atlassian.com/manage-profile/security/api-tokens`), save to `~/AI/config/jira.env`
  - If GitHub Issues: no additional setup needed
  - If other: Claude must generate a new `ticket-tracker.md` agent using the existing Jira and GitHub Issues sections as structural templates, adapting for the chosen system
- Ask about branch naming convention (suggest default: `<TICKET-ID>-<kebab-case-summary>`)
- Ask about any gaps Claude couldn't determine

- [ ] **Step 3: Write install.md — Phase 3 (Install/Update)**

**Fresh install path:**
1. Create `.claude/docs/` directory if it doesn't exist
2. Generate `.claude/docs/workflow-config.md` with all collected info
3. Read each shipped command/agent file, rewrite with project-specific values, write to `.claude/commands/` and `.claude/agents/`
4. Handle `claude.md`:
   - If none exists: create with core principles adapted to detected stack plus workflow entry points
   - If exists: append the following block:

```markdown
# Forge Workflow

This project uses forge-workflow for AI-assisted development.

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

**Example values mapping** — the install command must know which example values to find and replace:

| Example Value | Replaced With |
|---|---|
| `PROJ-1234` | Actual ticket prefix |
| `npm run test` | Actual test command |
| `npm run lint` | Actual lint command |
| `npm run format` / `format:check` | Actual format commands |
| `https://mycompany.atlassian.net` | Actual Jira instance URL |
| `~/AI/config/jira.env` | Credentials path |
| React/TypeScript/Jest examples in agents | Framework-specific equivalents |

**Update path** (when forge-workflow files already exist):
1. Read current version from `.claude/docs/workflow-config.md`
2. Compare against the package version being installed
3. Read each existing file and identify user customizations vs stale shipped content
4. Merge: preserve user changes while applying new workflow improvements
5. If Claude cannot confidently distinguish a user edit from shipped content, ask the user
6. Present a summary of what will change and ask for confirmation before writing
7. Update the version in `workflow-config.md`

**Explicit exclusions:**
- Do NOT generate or modify `.claude/settings.json` or `.claude/settings.local.json`
- Do NOT set up MCP servers (agents reference them optionally; users configure independently)

- [ ] **Step 4: Write install.md — Phase 4 (Verify)**

The command must instruct Claude to:
- List all files that were installed or updated
- Suggest adding `.claude/temp/` and `.claude/settings.local.json` to `.gitignore`
- Suggest running `/workflow` to see available commands
- Remind user to commit the workflow files so the team shares them

- [ ] **Step 5: Review install.md for completeness against spec**

Verify all spec requirements are covered: scan targets, question flow, Jira wizard, GitHub Issues path, "other" tracker generation, claude.md strategy (both create and append), versioning/update logic, .gitignore recommendations, settings.json exclusion, MCP exclusion, example values mapping.

- [ ] **Step 6: Commit**

```bash
git add commands/install.md
git commit -m "feat: add /install command"
```

---

### Task 13: Write README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

Structure:
1. **Header/tagline** — "Forge Workflow — An opinionated AI-assisted development workflow for Claude Code"
2. **Value proposition** — Lead with shared team workflow: committed to your repo, every developer uses the same workflow, changes go through PRs. Use the exact framing: "The package ships with sensible example values that make the files readable and understandable out of the box, and /install rewrites them with the real values. The examples serve as documentation of intent too."
3. **Quick Start** — Two paths: npm (`npx forge-workflow install`) and manual copy
4. **What You Get** — List of commands with one-line descriptions, grouped by workflow phase
5. **The Workflow** — Visual flow: `/begin → /research → /plan → /signoff → /next → /security → /pr`
6. **Ticket Tracker Integration** — Jira, GitHub Issues, or custom
7. **Customization** — How to evolve the workflow (ask Claude to update files, PR the changes)
8. **Recommended Settings** — Example `settings.json` with permissions and formatter hooks
9. **License** — MIT

- [ ] **Step 2: Review README for accuracy against implemented files**

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

### Task 14: Final Review and Cleanup

- [ ] **Step 1: Full grep for app-specific terms**

Search all files for: ngw, persimmon, NG20, Azure, PIM, COINS, Bluestone, Zod, libs/types, apps/services, product-service, sales-service, search-service, content-service, portal-service, lead-service, persimmonhomes, atlassian.net (except the example mycompany.atlassian.net)

- [ ] **Step 2: Verify file count matches spec**

Expected: 16 commands, 10 agents, 1 docs file, bin/install.js, package.json, README.md, .gitignore = 31 files total

- [ ] **Step 3: Read each command file and verify it references ticket-tracker agent (not /jira)**

- [ ] **Step 4: Read install.md end-to-end and verify it covers the full spec**

- [ ] **Step 5: Commit any fixes**

```bash
git add -A
git commit -m "chore: final cleanup and verification"
```
