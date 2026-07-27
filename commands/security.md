---
description: Run security audit on all branch changes before PR
---

# Security Audit

Comprehensive security audit of all changes on the current branch before opening a PR — one pass
over the cumulative change set.

## Prerequisites

- All subtasks complete (or uncommitted changes to audit); on a feature branch (not the default branch).

## Instructions

1. **Scope** — audit all changes vs the default branch (`git diff <base>...HEAD --name-only`). If
   there are no commits yet, audit uncommitted/staged changes.
2. **Audit** — dispatch the `security-auditor` agent (it applies the `security-review` skill), or
   apply the **`security-review` skill** directly on the change set.
3. **Handle findings**
   - **Critical** — must be fixed before PR. Show `file:line` and a fix.
   - **High** — should be fixed; present for a decision.
   - **Medium / Low** — note for awareness; can proceed.
4. **Report** — verdict (PASS / FAIL), counts by severity, and recommendations. If issues were
   fixed, re-run `/security` to verify.

## Rules

- Never skip Critical issues; audit the full change set, not individual commits.
- Only flag issues in changed code; give actionable fixes.
