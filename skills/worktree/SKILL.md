---
name: worktree
description: Open and finish git worktrees. The only route that creates one, so none outlives its work. Covers where they live, opening a branch or a detached read-only checkout, one branch per worktree, the exits that end one, kept checkouts, agent worktrees, and the builds and indexes a worktree must not keep. Use whenever a command, skill or agent needs a second checkout, and whenever an `isolation: "worktree"` agent returns.
allowed-tools: Read, Bash
---

# Worktree

A worktree is a second checkout sharing this repo's `.git`. Every command, skill and agent brief that
needs one opens it here and ends it through one of the exits below. Nothing makes a worktree ad hoc.

## Where

`<worktree folder>/<name>`, where `<worktree folder>` is `.claude/worktrees` unless `/install` set
another (`## Clean-up` in `docs/workflow-config.md`). It is gitignored. `<name>` is a filesystem-safe
form of the branch or purpose: `feature/x` → `feature-x`, `cr-feature-x`, `perf-<slug>`. Use
absolute paths into it (`git -C <path>`, `<path>/<file>`); shell state doesn't carry between calls.

## Open

```bash
git fetch origin
git worktree add -b <branch> <path> origin/<default branch>   # new branch, for work that commits
git worktree add <path> <existing branch>                     # an existing local branch
git worktree add --detach <path> <ref>                        # read-only or measuring
```

- **Work that commits needs a branch.** The commit guard refuses a detached HEAD, so open with `-b`
  or on an existing branch.
- **One branch for the worktree's whole life.** Never `git checkout` or `git switch` inside one, and
  never reuse one for a second branch or ref. If `<path>` already exists, finish that worktree first.
- **A branch is checked out in one place only.** If `git worktree add` says the branch is checked
  out elsewhere, name that checkout and stop. Never move the developer's checkout.
- **A read-only or measuring worktree** (a review, a merge-base baseline) is removed as soon as its
  result is written.
- `git worktree add` runs the project's `post-checkout` hook. <post-checkout note: what the hook does
  here and how a worktree skips it, or "none">

## Exits

Every worktree ends through one of these. A flow that names its exit takes it without offering the
others.

| Exit | What happens | When |
| --- | --- | --- |
| **Pushed / merged** | Remove the worktree once the branch is pushed and handed to `/pr`, or merged | The work is reviewable |
| **Leave the branch** | Remove the worktree, keep the local branch, push nothing, give the branch name | The flow ends without a PR |
| **Keep** | Leave it on disk, minus builds and indexes (below) | Coming back to it soon |
| **Abandon** | Remove the worktree and delete the branch | Nothing on it is wanted |

**Remove**, from the main checkout, never from inside the worktree:

```bash
git -C <path> status --short
[ -L <path>/.claude/temp ] && rm <path>/.claude/temp   # only if the project links temp into worktrees
git worktree remove <path>
git worktree list                                      # <path> is gone
```

- Plain `git worktree remove`, never `--force`. It deletes ignored files (installs, builds) with the
  worktree. If git refuses (uncommitted or untracked files), show `git status --short` and ask: keep
  the worktree, or discard those changes. Only the developer's discard adds `--force`.
- If `<path>/.claude/temp` is a real folder rather than a link, stop and ask: it holds files the main
  checkout doesn't have.
- **Abandon** asks first when the branch has commits not on its remote (`git log --oneline
  origin/<branch>..<branch>`, or every commit when it was never pushed), naming them. Then
  `git branch -D <branch>`.

## Kept checkouts

Checkouts kept on purpose. No exit removes them and `/clean-up` never sweeps them.

| Checkout | Branch | Why it stays |
| --- | --- | --- |
| <kept checkouts: none, or e.g. a `gh-pages` publishing checkout and the script that reuses it> | | |

## Agent worktrees

The harness removes an `isolation: "worktree"` agent's worktree only when the agent changed nothing.
Once it commits, the worktree stays. So:

- **The brief** ends: "Finish through the `worktree` skill: leave the worktree clean, never remove it
  from inside, and report its path, branch and `git status --short`."
- **The launching command**, when the agent returns: `git worktree list`; if the reported path is
  still there, Remove it as above (if git refuses, show the agent's changes and ask). Then
  `git branch -d <branch>` for the branch the harness made. If that refuses, the branch holds
  commits: name them and leave it.

## Builds and indexes

A removed worktree takes its ignored files with it. A worktree that **stays** (Keep, a kept checkout,
a flow stopped part-way, an agent worktree left behind) deletes them when its flow ends:

```bash
rm -rf <path>/node_modules <path>/<build output>
```

`<build output>` is the project's, e.g. `dist/ .next/ coverage/`. **Per-checkout indexes**
(<per-checkout indexes: none, or e.g. a code-graph index folder>) are never built in a worktree:
point the tool at the main checkout's index or skip it there, and delete any that exist when the
worktree closes.
