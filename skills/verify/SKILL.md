---
name: verify
description: Close the deterministic verification loop on a change — build, typecheck, lint, and test, then self-fix failures and repeat until green. Use at the end of /dev before presenting.
allowed-tools: Read, Grep, Glob, Bash, Edit
---

# Verify (deterministic loop)

Check the change against the project's deterministic signals and **fix failures yourself** before
handing back to the human. Loop until green — this is autonomous, no approval gate.

## Loop

1. Run the project's checks (from `docs/workflow-config.md`), fastest first:
   build / typecheck → lint → format check → tests.
2. If anything fails, read the failure, fix the **cause** (not the symptom), and re-run. When a test
   fails, apply predict-then-verify from the `testing` skill — an unexpected failure is likely a real
   side effect, so fix the code, don't just edit the test.
3. Repeat until all checks pass, or until you hit something you cannot resolve safely.

## Stop and report (don't loop forever)

Stop and surface it to the user if: a fix would change behaviour beyond the subtask's scope; a test
encodes a product decision you can't make; the failure is environmental (missing service/creds); or
you've looped without progress. Report what's green, what's not, and why.

## Rules

- Never disable, skip, or delete a failing test to make the suite pass.
- Never commit or push — verification produces green working changes; the user commits.
- Report the final state (checks run, pass/fail) as input to `verify-acceptance` and `/present`.
