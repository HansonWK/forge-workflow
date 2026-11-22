# Forge Skills

Skills are the **single source of truth** for the workflow's reusable rubrics, methods, and
verifiers. A skill is a `SKILL.md` file (with frontmatter) under `skills/<name>/`, installed to
`.claude/skills/<name>/`. Commands and agents **call** skills instead of restating their content —
so the rubric for "how we review code" or "how we verify a change" lives in exactly one place.

## Why skills (and not just bigger commands)

- **Progressive disclosure** — a skill's depth loads only when it's invoked, keeping commands and
  `CLAUDE.md` light.
- **No duplication** — `/review`, `/cr`, and `/signoff`'s code-review check all use the one
  `code-review` skill; the `pr-sanity-check` agent calls the same skill when it runs in the background.
- **Verification loops** — `verify`, `verify-acceptance`, and `verify-plan` let Claude check its own
  work against deterministic signals *and* rubrics, and self-correct before the human gate.

## Conventions (important)

- **Explicit invocation.** Forge commands invoke skills **explicitly** (e.g. "Use the `code-review`
  skill"), not by relying on ambient description-triggering. This keeps the workflow reliable on
  **older model generations** where auto-triggering is less dependable. Skills are also written to
  read as plain guidance if simply loaded.
- **Rubrics, not rigid checklists.** Skills describe *what good looks like* and let the model apply
  judgement; hard gates (Critical/High blocks, approval STOP points, commit-on-approval) stay explicit.
- **De-branded.** Anything shipped here must stay free of employer-specific detail.

## Skills

**Method / rubric skills**

| Skill | What it holds | Called by |
| ----- | ------------- | --------- |
| `code-review` | code-review rubric (quality, correctness, security-lite, performance lens, tests) + a fresh-subagent second pass | `/signoff`, `/review`, `/cr`, `pr-sanity-check` agent |
| `security-review` | OWASP-focused security rubric | `/security`, `/signoff`, `/audit`, `security-auditor` agent |
| `testing` | black-box testing philosophy + predict-then-verify + when to add an e2e test | `/dev`, `test-writer` agent |
| `writing-plans` | planning conventions (ACs first, subtask sizing, complexity tiers and escalation, proofs, sign-off checks, the tier ledger) | `/begin`, `/plan`, `/next`, `planner` agent |
| `logging-compliance` | logging-strategy rubric (observability module) | `/fix-logs`, `/dev`, `/audit` |
| `authoring` | how to add/update workflow pieces (skill vs command vs agent; lean, decision-encoding) | `/customize` |
| `attribution` | classify resources (attribution vs resource) and record credits in `ATTRIBUTION.md` | `/attribution`; proactively when a resource is shared |
| `architecture` | keep code within the project's architecture (hexagonal / layered / vertical); reads `docs/architecture.md` | `/dev`, `code-review`; `/install` sets the pattern |
| `clarify` | interview the user in rounds when info/decisions are missing; can build guideline docs | `/clarify`; anywhere info is missing |
| `slicing` | whether/where to split work into independently mergeable PRs | `/slice`, `/plan`, `/pr` |
| `performance-review` | perf rubric — fast diff scan, deep audit, frontend baseline before/after | `/review`, `/signoff`, `/next`, `/performance`, `performance` agent |
| `explain` | describe how existing code works — never a review | `/explain`, `explainer` agent |
| `run-local` | run apps/services locally; who-runs-what (Claude bg vs your terminal) | `/run` |
| `presentation` | a deck or a page as a live Artifact, in the house style (`house-style.css`); export on request | `/presentation` |
| `recalibrate` | turn session corrections and the tier ledger into proposed workflow-file edits | `/recalibrate`; Claude on pushback |
| `work-page` | the live claude.ai page for one piece of work (plan, progress, sign-off, test on dev), its data scripts and the local fallback | `/begin`, `/present`, `/next`, `/signoff`, `/pr`, `/status`, `/resume` |
| `clean-up` | Phase 0 filing, the finished gate (merged, released, proven), one record per finished piece of work, what goes, never-touch, finding old work | `/clean-up`; suggested by `/release` and `/status` |
| `worktree` | the only route that opens a worktree: where, one branch per worktree, the exits that remove it, kept checkouts, agent worktrees, builds and indexes | `/cr`, `performance-review`, `clean-up`, `authoring` |

**Verification skills (close the loop)**

| Skill | What it does | Placement |
| ----- | ------------ | --------- |
| `verify` | build / typecheck / lint / test, self-fix until green | embedded at end of `/dev` |
| `verify-acceptance` | run the subtask's proof, keep the evidence, check its ACs; at sign-off, every AC | after `verify` in `/dev`; `/signoff` |
| `verify-plan` | critique the plan vs research + ACs (unproven ACs, tautological proofs, tiers) before `/present` | in `/begin`, `/plan` |
| `double-check` | independent second opinion from a *different* AI CLI (default Codex); reconcile every finding | `/double-check`; suggested by `/pr` for large PRs |
