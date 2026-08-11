# Forge Skills

Skills are the **single source of truth** for the workflow's reusable rubrics, methods, and
verifiers. A skill is a `SKILL.md` file (with frontmatter) under `skills/<name>/`, installed to
`.claude/skills/<name>/`. Commands and agents **call** skills instead of restating their content —
so the rubric for "how we review code" or "how we verify a change" lives in exactly one place.

## Why skills (and not just bigger commands)

- **Progressive disclosure** — a skill's depth loads only when it's invoked, keeping commands and
  `CLAUDE.md` light.
- **No duplication** — `/review`, `/cr`, and the `/next` review phase all use the one `code-review`
  skill; the `pr-sanity-check` agent calls the same skill when it runs in the background.
- **Verification loops** — `verify`, `verify-acceptance`, and `verify-plan` let Claude check its own
  work against deterministic signals *and* rubrics, and self-correct before the human gate.

## Conventions (important)

- **Explicit invocation.** Forge commands invoke skills **explicitly** (e.g. "Use the `code-review`
  skill"), not by relying on ambient description-triggering. This keeps the workflow reliable on
  **older model generations** where auto-triggering is less dependable. Skills are also written to
  read as plain guidance if simply loaded.
- **Rubrics, not rigid checklists.** Skills describe *what good looks like* and let the model apply
  judgement; hard gates (Critical/High blocks, approval STOP points, never-commit) stay explicit.
- **De-branded.** Anything shipped here must stay free of employer-specific detail.

## Skills

**Method / rubric skills**

| Skill | What it holds | Called by |
| ----- | ------------- | --------- |
| `code-review` | code-review rubric (quality, correctness, security-lite, performance lens, tests) | `/review`, `/cr`, `/next`, `pr-sanity-check` agent |
| `security-review` | OWASP-focused security rubric | `/security`, `/audit`, `security-auditor` agent |
| `testing` | black-box testing philosophy + predict-then-verify | `/dev`, `test-writer` agent |
| `writing-plans` | planning conventions (subtask sizing, checklist vocab, acceptance criteria) | `/plan`, `planner` agent |
| `logging-compliance` | logging-strategy rubric (observability module) | `/fix-logs`, `/dev`, `/audit` |
| `authoring` | how to add/update workflow pieces (skill vs command vs agent; lean, decision-encoding) | `/customize` |
| `attribution` | classify resources (attribution vs resource) and record credits in `ATTRIBUTION.md` | `/attribution`; proactively when a resource is shared |
| `architecture` | keep code within the project's architecture (hexagonal / layered / vertical); reads `docs/architecture.md` | `/dev`, `code-review`; `/install` sets the pattern |
| `clarify` | interview the user in rounds when info/decisions are missing; can build guideline docs | `/clarify`; anywhere info is missing |
| `slicing` | whether/where to split work into independently mergeable PRs | `/slice`, `/plan`, `/pr` |
| `performance-review` | perf rubric — fast diff scan + deep audit | `/review`, `/performance`, `performance` agent |
| `explain` | describe how existing code works — never a review | `/explain`, `explainer` agent |
| `run-local` | run apps/services locally; who-runs-what (Claude bg vs your terminal) | `/run` |
| `presentation` | self-contained HTML slide deck (Claude-style palette default) | `/deck` |
| `recalibrate` | turn session corrections into proposed workflow-file edits | `/recalibrate`; Claude on pushback |

**Verification skills (close the loop)**

| Skill | What it does | Placement |
| ----- | ------------ | --------- |
| `verify` | build / typecheck / lint / test, self-fix until green | embedded at end of `/dev` |
| `verify-acceptance` | check the change against the subtask goal + acceptance criteria; self-correct | chained after `verify` |
| `verify-plan` | critique the plan vs research + AC (and draft ACs if missing) before signoff | in `/plan` |
| `double-check` | independent second opinion from a *different* AI CLI (default Codex); reconcile every finding | `/double-check`; suggested by `/pr` for large PRs |
