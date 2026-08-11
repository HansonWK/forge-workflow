---
name: recalibrate
description: Turn the corrections, preferences, and friction from a session into concrete, proposed updates to the workflow files — routed to the right place — and promote team truths out of one developer's private memory into shared workfiles. Claude invokes it when it notices it got pushback on the workflow; the developer can also run /recalibrate.
allowed-tools: Read, Grep, Glob, Bash, Edit
---

# Recalibrate

Review the session for corrections, preferences, gaps, and friction, then **propose** specific edits
to the files that would prevent a repeat. Propose — the developer picks what lands.

**When Claude invokes this itself:** when it notices it got **pushback on the workflow** — a correction
a workfile should have prevented, a skill/command that misfired, or the same thing explained twice.
That's the signal to recalibrate. (Distinct from `/customize`, which the *user* runs to **author new**
workflow pieces or larger additions — e.g. their own logging/dashboard variant. Recalibrate makes a
*correction* stick; customize *adds* capability.)

## Routing is the hard part

| Destination | Scope | Committed |
| --- | --- | --- |
| session memory (`~/.claude/…/memory/`) | **one developer**, cross-session | no |
| `.claude/skills/<name>/SKILL.md` | team — the method | yes |
| `.claude/commands/<name>.md` | team — entry points | yes |
| `.claude/agents/<name>.md` | team — agent briefs | yes |
| `.claude/docs/` (incl. the guideline docs) | team — conventions / rules | yes |
| `CLAUDE.md` | team — global conventions & gotchas | yes |

**The test: is this true for everyone, or true for this developer?**

- *"I commit myself"* → memory
- *"Logs need a request-id dimension"* → the `logging-compliance` skill / `docs/logging-strategy.md`
- *"The ticket integration dies without credentials"* → that command/agent
- *"An unknown status defaults to active"* → the domain-rules / guideline doc

Routing to memory something that's true for everyone is the common failure — it helps one person and
leaves everyone else to rediscover it.

## Promote team truths out of memory

Read the memory index and check each entry against the test above. Anything that's a team fact —
branch conventions, where plans live, how to handle an auth failure — helps one person where it sits
and everyone if promoted. Propose promotion (memory → the matching shared workfile), and de-duplicate
where a rule already lives in both.

## What counts as a signal

| Category | Example | Usually lands in |
| --- | --- | --- |
| **Correction** | "no, that's the other way round" | skill / docs |
| **Preference** | "present options, don't rewrite" | memory |
| **Capability gap** | a skill failed with no fallback | the failing skill |
| **Missing knowledge** | something undocumented had to be rediscovered | docs / skill |
| **Process friction** | a workflow step wasted effort | the workflow file |

**Process friction is the easiest to miss** — nothing was "wrong" and nobody was corrected, but effort
was wasted (a health check polling a URL that can never return 200; a search repeated three ways).
Look for it explicitly.

Detection: explicit corrections ("actually…", "no, we…"), the developer editing or reverting your
output, a tool/skill failing, the same thing explained twice, and you asking something a workfile
should have answered.

## Propose, never apply

- **Show the diff and let the developer pick.** Prompt before changing any workflow file.
- **Never commit** — leave edits in the working tree.
- **Ambiguity → ask** (the `clarify` skill). A single incident is not a convention; encoding it as one is how workfiles fill with noise.
- Cap at ~7 suggestions per run.

## Subtract as well as add

If this only ever adds, workfiles grow every session until nobody reads them. Removals compete for the
same slots: **consolidate** (the same rule in three files), **delete** (guidance now wrong or describing
something removed), **demote** (a "team rule" that was one person's preference). Anything added must
change what Claude *does* (see the `authoring` skill).

## Verify what you changed

After the developer picks and you apply, re-read each touched file whole and check:

| Check | Catches |
| --- | --- |
| **Contradiction** | the new rule conflicts with one already in the file |
| Duplication | the point is already made elsewhere in the file |
| Role drift | the file now does two jobs |
| Bloat | length is burying the important parts |
| Stale surroundings | the change made neighbouring content wrong |

**Contradiction matters most** — it leaves the file actively misleading and is invisible in a diff;
you only catch it by reading the whole file. Output more proposals, not silent edits. Default this on
for shared workfiles; skip it for a one-line memory write.

## Scope

Say what window you actually reviewed. Long sessions get summarised, so earlier corrections may no
longer be visible — a reason to run this before a session gets very long.
