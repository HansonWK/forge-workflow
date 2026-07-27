---
description: Deep multi-dimension audit of a target (or all targets), producing actionable issue files
argument-hint: <target-name> | all
---

# Audit

Run a deep, multi-dimension audit of one target or every target, producing a folder of grouped, actionable issue files that `/audit-fix` can consume.

This is a **standalone** workflow. It is never called by `/begin` or `/next`. Use it:

- **`/audit all`** — an overnight sweep of the whole codebase; review the files in the morning.
- **`/audit <target>`** — a single target, e.g. a monthly per-service/per-package audit by its owner.

The orchestrator (this session) does light work — resolving scope, spawning agents, writing the index — so you can run this session on a **cheap model** and have each audit agent run on a strong one.

> Targets and their layout come from `docs/workflow-config.md` (`## Audit`). For a
> monorepo these are the service/package directories; for a single app the target is
> the app itself. `/install` (audit module) configures the target list, the output
> location, and prunes any dimensions that don't apply to this stack.

## Arguments

$ARGUMENTS — a single target name or `all`.

## Step 1: Resolve scope

Resolve the target list from `docs/workflow-config.md`. `all` → every configured target. A single name → just that target; if it doesn't match, list the valid targets and stop. Record the list. Frontend-only dimensions (e.g. `accessibility`) apply only to UI targets — skip them elsewhere.

## Step 2: Choose model(s)

Use `AskUserQuestion` to ask which model(s) to run the audit agents in (strongest available recommended). `multiSelect: true`. If more than one is chosen, run the full audit once per model and nest output under a `<model>/` subfolder so results can be compared.

## Step 3: Create output folders

Compute today's date as `YYYY-MM-DD` (`date +%F`). For each target create `.claude/audit/<date>/<target>/` (or `.../<target>/<model>/` when multiple models). Repo-level dimensions go in `.claude/audit/<date>/_repo/`.

## Step 4: Dimensions

Each dimension produces exactly one `.md` file, written by one agent. The agent reads the referenced doc(s) first so findings are measured against the project's actual rules, not generic advice. Prune rows that don't apply to the stack (that's an `/install` step).

| File (`<slug>.md`) | What it audits | Reference |
| ------------------ | -------------- | --------- |
| `dead-code` | Unused exports/files/vars, unreachable code, commented-out blocks, unused deps, handlers/entrypoints defined but never wired up | project structure docs |
| `code-quality` | Adherence to the project's coding guidelines | `CLAUDE.md` (coding guidelines) |
| `type-safety` | Escape hatches: untyped values, unsafe casts, suppressed type errors, missing return types (for typed languages) | `CLAUDE.md` |
| `potential-bugs` | Logic errors, off-by-one, unhandled null/undefined, incorrect async, date/timezone bugs, floating promises, wrong comparisons | — |
| `error-handling` | Swallowed errors, missing try/catch at boundaries, retry/backoff, idempotency and dead-letter handling for queue consumers, errors caught but not logged | `docs/logging-strategy.md` |
| `security` | OWASP Top 10, hardcoded secrets, missing input validation at trust boundaries, injection, authz gaps | the `security-review` skill |
| `performance` | N+1 patterns, unbatched calls to rate-limited upstreams, redundant fetches, missing caching, large payloads, sync work in loops | — |
| `logging` | Compliance with `docs/logging-strategy.md`: required dimensions, `reason` on decisions, logger naming, correct levels | the `logging-compliance` skill |
| `test-quality` | Coverage gaps on business logic **and** test quality: black-box vs implementation-coupled, misleading names, factory usage | `CLAUDE.md` (testing) |
| `schema-consistency` | Validation at trust boundaries, producer/consumer schema drift, enum/shape values not shared where they should be | `CLAUDE.md` |
| `dry-duplication` | Constants/lists/mapping logic duplicated across modules that belong in a shared place | `CLAUDE.md` |
| `documentation-drift` | Docs out of sync with the code | the target's own docs |
| `accessibility` | **UI targets only** — WCAG/ARIA/keyboard/contrast/semantics | `ai-accessibility` plugin if installed, else general WCAG review |
| `dependency-health` | **Repo-level, once per run** — dependency audit, outdated majors, known CVEs | — |

## Step 5: Fan out the audit agents

For each target, spawn one agent per applicable dimension. Run `dependency-health` **once** for the whole run, not per target.

- Use `subagent_type: general-purpose` with `model` set to the chosen alias. Optionally use a matching specialist agent (`security-auditor`, `ai-performance:performance-auditor`, `ai-accessibility:accessibility-auditor`) where one exists — but keep the `model` override so the run stays in the requested model.
- To stay resumable and bound concurrency, process **one target at a time**: spawn all of that target's dimension agents in parallel, wait, then move on.
- If an output file already exists (re-run), overwrite it.

Give each agent this brief (fill in placeholders):

```
You are auditing `<target>` for the `<dimension>` dimension only.

1. Read the reference doc(s) for this dimension: <refs from the table>.
2. Audit ONLY <target>'s source. For cross-cutting dimensions (dry-duplication,
   schema-consistency) also compare against shared libs and sibling targets.
3. Find real, specific issues — cite file:line. Do not invent issues to pad the
   list; an empty section is a valid, good result.
4. Classify each issue High / Medium / Low and estimate effort (S <1h, M 1-4h, L >4h).
5. Write findings to `<output-dir>/<dimension>.md` using the exact template below.

Return only a one-line summary: "<dimension>: H<n> M<n> L<n>".
```

### Output file template (every dimension file must follow this)

```markdown
# <Target> — <Dimension> Audit

- **Model**: <model> · **Date**: <date> · **Scope**: <paths audited>
- **Totals**: High <n> · Medium <n> · Low <n>
- **Estimated effort**: <rollup>
- **Suggested PR split**: <single PR | describe the groups>

## High

### [H1] <short title>
- **Location**: `path/to/file:123`
- **Issue**: <what is wrong>
- **Why it matters**: <impact / which rule or risk>
- **Fix**: <concrete, enough detail that /audit-fix needs no re-investigation>
- **Effort**: S | M | L
- **Verify**: <how to confirm it's fixed>

## Medium

### [M1] <short title>
... same fields ...

## Low

### [L1] <short title>
... same fields ...
```

If a section has no issues, keep the heading with `_None found._` underneath.

## Step 6: Write the run index

After all agents finish, write `.claude/audit/<date>/_index.md`:

- One row per target with High/Medium/Low totals across its dimension files.
- A "top priorities" list — the High issues most worth fixing first.
- The exact `/audit-fix <target> <dimension>` commands to action each non-empty file.

Then present the index path as a clickable link and a one-paragraph summary.

## Rules

- The orchestrator writes NO code and fixes NOTHING — it only audits and reports. Fixing is `/audit-fix`.
- Every issue must cite `file:line` and be independently actionable. No vague findings.
- Prefer fewer, real issues over a long padded list. An empty dimension file is a good outcome.
- Never commit, push, or branch — this command only writes to `.claude/audit/`.
- Keep each dimension in its own file; do not merge dimensions.
- Present all created paths as clickable absolute paths at the end.
