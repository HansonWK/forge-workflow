---
name: code-review
description: Review a code change (a branch diff or working changes) against a quality/correctness/security/performance/tests rubric, classify findings by severity, and report them. Use for /review, /cr, the /next review phase, and pre-PR checks.
allowed-tools: Read, Grep, Glob, Bash
---

# Code Review (rubric)

Review a change and report findings the developer can act on. This is a **rubric**, not a fixed
checklist — apply judgement, and weigh findings by real impact on this codebase. Read the project's
conventions first (`CLAUDE.md` / `CONTRIBUTING.md` / equivalent) and review changed code against
*those*, not generic ideals.

## Scope

Review the change set, not the whole repo: `git diff <base>...HEAD` (or working changes). Only flag
issues **in the changed code**, not pre-existing ones. Read related files (imports, tests) for
context.

## What good looks like (lenses)

- **Correctness** — logic holds; edge cases (null/undefined, empty, error paths) handled; async is
  correct; no off-by-one or wrong comparisons. Behavioural regressions when refactoring/extracting
  values are **Critical** — compare against every original usage.
- **Conventions** — matches the project's stated conventions and the surrounding code's idiom
  (naming, structure, immutability, types). Reads like the code around it.
- **Security (lite pass)** — no unvalidated trust-boundary input, injection, secrets in code, or
  broken authz. (Deep OWASP work is the `security-review` skill / `/security`.)
- **Performance (lens)** — no N+1s, unbatched calls to rate-limited upstreams, needless refetching,
  or sync work in hot loops. For UI: avoidable re-renders, oversized imports.
- **Tests** — new behaviour has tests; tests are black-box (assert behaviour/outputs, not internals);
  test names match their assertions. See the `testing` skill.
- **Schema/shape consistency** — new enum/shape values used in code exist in the shared
  schema/types; missing → **Critical** (breaks downstream validation).

## Severity (the gate)

- **Critical** — data loss, security holes, breaking changes without migration, behavioural
  regressions. Must be resolved before merge.
- **High** — bugs, missing error handling, architectural violations. Should be resolved.
- **Medium** — code smells, missing edge-case tests, minor perf. Note; fix if cheap.
- **Low** — style/preference. Note, don't block.

## Output

Report concisely: a one-line verdict (PASS / NEEDS ATTENTION / FAIL), counts by severity, and for
each finding `file:line`, the problem, and a concrete fix. Lead with Critical. Acknowledge what's
done well. Clear headings; emojis optional and matched to the project's style.

## Fix policy

- **Report first, always.** Do not edit files until the caller (a command or the user) has asked
  you to fix.
- **Read-only when reviewing another branch** (e.g. `/cr` worktree): produce a report only — never
  edit, format, or fix.
- When authorized to fix: resolve Critical/High, run the project's format+lint+tests, re-review
  until clean, and report exactly what changed.
