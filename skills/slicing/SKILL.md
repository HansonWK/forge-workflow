---
name: slicing
description: Decide whether work should be split into several independently reviewable, independently mergeable PRs, and where to cut the slices. Use when planning non-trivial work (/plan, the planner), before opening a stack, and to improve subtask decomposition even for a single PR.
allowed-tools: Read, Grep, Glob, Bash
---

# Slicing (rubric)

Work out **whether** a piece of work should be split, and **where** the cuts go. Apply judgement.
Read `.claude/temp/<slug>/plan.md` and the project's conventions/architecture docs before deciding.

Splitting is not free. **Default to a single PR.** Split only when a reason below actually applies.

## The three altitudes

| Unit | Test it must pass | Becomes |
| --- | --- | --- |
| Subtask | small and committable | a commit |
| **Slice** | independently reviewable **and** mergeable; leaves the default branch green | a PR / stack entry |
| Ticket | delivers the whole change | the branch, or the stack |

Subtasks group into slices — a slice is usually several subtasks, never a fraction of one.

## Should this be split at all?

**Split when at least one is clearly true:**

- The change contains **distinct concerns** — a refactor plus a feature, a shared-lib change plus its consumers, a schema change plus the UI that uses it.
- The review burden is large enough that a reviewer will skim.
- One part is **ready now** and the rest needs more work, discussion, or a decision.
- One part is **higher risk** and you want it merged and observed on its own.
- It spans several modules/services and each part stands alone.

**Do not split when:**

- The parts are genuinely coupled — a slice that can't build, can't pass tests, or ships a half-migrated state to users.
- It's one cohesive change that happens to touch many files.
- The only motivation is PR size — size is a symptom, not the reason.
- You'd need stub code, dead flags, or "we'll fix it in the next PR" to make a slice stand up.

If in doubt, ask the developer — *"one PR or a stack?"* is cheap, and the ticket often answers it (see the `clarify` skill).

## Where to cut

Roughly in order of how often they apply:

1. **Refactor first, then feature.** Move/rename/extract with no behaviour change, then build on the new shape — the refactor slice reviews as "no behaviour change."
2. **Shared lib, then each consumer** — provided the lib change is backwards-compatible on its own.
3. **Producer → consumers**, matching the real data flow. See the schema caveat below.
4. **Add, switch, remove.** Introduce the new path, move callers over, delete the old — three slices, each safe alone; the middle one carries the risk.

**Anti-patterns:**

- Slicing **by file or folder** — those boundaries rarely match behaviour boundaries.
- Slicing **by layer when the layers are coupled** — a "backend PR" + "frontend PR" where neither works alone is one change in two boxes.
- A slice whose **tests can't pass alone** — if you must skip a test to make a slice green, the cut is wrong.

## The green-default-branch test

**Every slice must build, lint, and pass tests on its own**, and leave the default branch in a
deployable state. Run the `verify` skill against a slice before treating it as complete.

> ⚠️ **A shared schema/type change and its consumers usually can't be separated.** A slice that lands
> a new enum or entity value in shared types *ahead of* its consumers type-checks but can still fail
> validation at runtime downstream. Keep the schema change and its consumers in one slice unless the
> change is genuinely backwards-compatible.

## Recording slices

Slices live in `plan.md` alongside the subtasks they group — one self-contained block each, so
`/status`, `/next`, and `/resume` can read them:

```markdown
## Slice 1 — extract the shared filter
Independently mergeable: yes — pure refactor, no behaviour change.
- [ ] Subtask 1 …

## Slice 2 — use it in the card component
Depends on: Slice 1
- [ ] Subtask 3 …
```

State **why** each slice is independently mergeable. If you can't write that sentence, the cut is wrong.

## Output

Report: whether to split (and why), the proposed slices in merge order, what each contains, and their
dependencies. If not splitting, say so in one line — "keep it as one PR" is a valid, common result.
