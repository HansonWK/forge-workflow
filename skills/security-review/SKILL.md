---
name: security-review
description: Security-audit a change set (or a target) against OWASP Top 10, secret exposure, dependency risk, and trust-boundary validation; classify by severity and block on Critical. Use for /security and the /audit security dimension.
allowed-tools: Read, Grep, Glob, Bash
---

# Security Review (rubric)

Audit code for security issues and report them with concrete, actionable fixes. Apply judgement —
weight by exploitability and blast radius in *this* system. Only flag issues in the reviewed code,
not pre-existing ones.

## Scope

Default to the branch change set (`git diff <base>...HEAD`), or a named target for a standalone
audit. Read the surrounding code to judge exploitability.

## What to look for

- **Injection** — SQL/NoSQL/command/template injection from untrusted input; unsafe
  deserialization; `dangerouslySetInnerHTML`/raw HTML without sanitization (XSS).
- **Trust-boundary validation** — every external input (request bodies, query params, messages,
  file uploads, third-party payloads) validated/sanitized before use.
- **AuthZ / AuthN** — missing or incorrect authorization checks; insecure session/token handling;
  privilege escalation paths; IDOR.
- **Secrets** — hardcoded keys/passwords/tokens; secrets logged or returned in responses; secrets
  committed. (Also: never *read* production secret values — dev/test only.)
- **Sensitive data** — PII/financial data logged, cached, or exposed; missing encryption in transit
  or at rest where required.
- **Dependencies** — new/updated deps with known CVEs. Run the project's audit command (e.g.
  `npm audit`, `pnpm audit`, `pip-audit`, `cargo audit`) when the manifest changed.
- **Config / infra** — overly permissive CORS, missing rate limits, debug/verbose errors leaking
  internals, insecure defaults.
- **Domain rules a linter won't catch** — e.g. "reject any migration that drops a column without a
  backfill step." Encode the project's real invariants.

## Severity (the gate)

- **Critical** — exploitable vulnerability or secret exposure. **Blocks merge.**
- **High** — likely-exploitable or significant weakness; resolve before PR.
- **Medium / Low** — defense-in-depth improvements; note.

## Output

Verdict (PASS / FAIL), counts by severity, and per finding: `file:line`, the vulnerability, its
impact, and a specific remediation. Start with a report to the user; fix Critical/High only when
asked, then re-audit to verify.
