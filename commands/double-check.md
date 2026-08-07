---
description: Get an independent second opinion (a different AI CLI) on a PR, plan, or change set
argument-hint: [branch/PR, or "this" for current changes]
---

# Double-Check

Run an independent reviewer over finished work and reconcile findings until you agree.

## Instructions

Apply the **`double-check` skill** to the target in $ARGUMENTS (a branch, a PR, or the current
changes — default to the current branch vs the default branch). The skill picks an independent
verifier (default: OpenAI Codex — it offers `npm i -g @openai/codex` if missing), runs it **read-only**
with an adversarial brief, and runs a back-and-forth until both agents agree or the disagreement is
escalated to you.

## Rules

- Read-only verifier; never send secrets or code you can't share externally (it goes to the external provider).
- You own the final verdict — the second opinion sharpens it, it doesn't override it.
