---
name: verify-acceptance
description: Prove a change does what was asked — run the subtask's or group's proof from plan.md, keep the evidence in the proof folder, check the ACs it proves, self-correct genuine misses, and flag anything that needs a human decision. Use after `verify` in /dev, and as /signoff's acceptance check over every AC.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Verify Acceptance (proof loop)

Deterministic checks (the `verify` skill) prove the code *runs*; this proves it does *what was
asked*, with evidence the developer can read at the stop.

## What to prove

In priority order:

1. The subtask's **Proof** in `plan.md` — or, at the last subtask of a proof group, the group's.
   `none — <reason>`: nothing to run; say so.
2. The **ACs** it names under **Proves**.
3. **Fallback:** the subtask's Goal, when the plan has no proof and no AC.

## Loop

1. **Predict first.** Write down what the proof should show (the log line, the output, the screen)
   before running it, so the result is compared against something stated beforehand.
2. **Run it** — the kinds of proof this project can run are in `writing-plans`. Save the evidence in
   the proof folder under the subtask or group's key: the script (`3-proof.sh`), captured output or
   logs (`3-confirm.log`), screenshots (`P1-signup.png`). Write scripts so they can be rerun at the
   stop, on the PR's environment and on dev. Load any credentials with `node --env-file=<file>` or a
   sourced file inside the command, never by reading the file.
3. **Logs:** follow `/logs`' query rules — validate a query on a short window before relying on an
   empty result, and count successes alongside errors.
4. If the proof fails and the fix is within the subtask's scope, fix it and re-run (re-run `verify`
   if you touched code). If the failure shows a problem with the approach, that's an escalation
   (`writing-plans`): stop and report it.
5. If an AC can't be met without a product or scope decision, or is ambiguous, **stop and flag it**
   rather than guessing.

## Output

A short result for the stop: pass / fail, the one-line "Proved by" summary, and the evidence (a log
excerpt, script output, a screenshot path). Write the result under `## Proofs` in `status.md`
(`- 3: pass — <summary>`).

## At sign-off (the acceptance check)

Check every AC in `plan.md` against the branch: each one proven, with its proof named (the subtask or
group key and its evidence file), or the reason it can't be. Rerun a proof whose code changed since it
last passed. Tick each proven AC in `plan.md`.

## Rules

- Don't weaken or reinterpret a criterion to make it pass — meet it or flag it.
- A proof that can't fail proves nothing: never count "the file exists" or "it compiled".
- Don't commit: `/next` commits on the developer's approval.
