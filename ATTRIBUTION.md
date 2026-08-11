# Attribution

forge-workflow builds on ideas and work from others. Where a resource shaped the workflow
meaningfully, it's credited below.

We credit two kinds of thing, in one table:

- **Attribution** — ideas or creative work we built on: LLM-provider blogs (Anthropic / OpenAI / …),
  blogs proposing a **novel** idea, or someone else's file we adapted (e.g. a `.md` from another
  developer). We credit the **origin** of an idea, not a blog that reconceptualizes it.
- **Resources** — references we consulted but aren't crediting as an idea: official docs, a project's
  own help files or wiki, API references. Linked, not credited.

How a shared resource gets classified (and traced to its origin) is encoded in the `attribution`
skill; `/attribution` records it here.

## Table

| Area / files | Attribution | Resources |
| --- | --- | --- |
| The skills architecture; lean, gotchas-first `CLAUDE.md`; rubrics over checklists; de-prescribe pass — `skills/*`, `commands/install.md` (CLAUDE.md generation) | Anthropic — [*The new rules of context engineering for Claude 5 generation models*](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models) (trust the model, cut repeated/obvious rules and role-priming, push depth into skills, keep `CLAUDE.md` light) | — |
| The verification loop — `skills/verify`, `skills/verify-acceptance`, `skills/verify-plan`, `/dev` self-verify | Anthropic — [*Building verification loops in Claude Code with Skills*](https://claude.com/blog/building-verification-loops-in-claude-code-with-skills) (generate → verify → self-fix, encoded as skills) | — |
| `skills/double-check`, `commands/double-check.md` | [citypaul — `double-check` skill](https://github.com/citypaul/.dotfiles) — adapted directly (cross-provider second opinion, adversarial brief, reconcile loop) | — |
| `skills/authoring`, `commands/customize.md` | [SWE-Skills-Bench: *Do Agent Skills Actually Help in Real-World Software Engineering?*](https://arxiv.org/abs/2603.15401) (arXiv 2603.15401) — encode decisions not principles, cut defaults, keep lean, measure; credited over the blogs restating it | — |
| `skills/clarify`, `commands/clarify.md` | [Matt Pocock — `grill-me` skill](https://www.aihero.dev/skills-grill-me) — adapted: interview in rounds across the "frontier" until nothing is assumed; renamed `clarify` so both can coexist | — |

## Provenance

The core workflow (the `/begin → … → /pr` loop and its agents) generalizes a private internal
workflow written by the author; forge de-brands and packages it for reuse. That's origin, not a
third-party dependency, so it isn't in the table above.

## Notes

- **Concept vs. article.** We credit the source of an idea, not a re-packaging of it. Example: a blog
  on building an "LLM wiki in Obsidian" is really a reconceptualization of Andrej Karpathy's LLM-wiki
  idea — so the credit would go to Karpathy, not the blog. (We only list a resource here if it
  genuinely shaped a file — that Obsidian blog didn't, so it isn't listed.)
- Tools the workflow *invokes* (e.g. OpenAI Codex in `double-check`) are credited inline in the
  relevant file, not here.
- If you shared a resource that shaped forge and it isn't credited here, please open an issue or PR.
