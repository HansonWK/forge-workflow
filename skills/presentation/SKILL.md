---
name: presentation
description: Build a self-contained HTML slide deck from a content spec — offline, inline CSS/JS, keyboard nav, direction-aware transitions. Defaults to a Claude-style palette and asks if you have your own. Use when asked to create or extend a slide deck or walkthrough.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# Presentation

Generate a deck as one self-contained `.html` file.

## Order of work

**Content → design → animation.** Get the copy signed off before building — decks are rewritten far
more often for wrong content than for wrong styling.

1. Write or read the content spec (below). **Present the copy and get approval.**
2. **Palette.** Default to the Claude-style palette below, but **ask the user if they have a palette in
   mind** (brand colours, a hex set, a theme) and use that instead if so. If the project already
   defines brand colours in code/config, offer to pull from there. Pick the palette once and apply it
   consistently — never invent random hexes mid-deck.
3. Map each slide's body to a component type (below).
4. Assemble: **Title → body slides → optional section hinge → persistent Closing.**
5. Write the file; give the absolute path.

### Default palette (Claude-style, warm neutral)

Use these unless the user gives their own. Style light, and dark too if you support it.

| Token | Value | Use |
| --- | --- | --- |
| background | `#F0EEE6` | page / slide background |
| surface | `#FAF9F5` | cards / panels |
| text | `#1F1E1C` | body text |
| muted | `#6B6A65` | secondary text |
| accent | `#D97757` | headline accent word, bars, active dots |
| accent-2 | `#5A9BD5` | a second series, sparingly |

(A warm Claude-inspired default, not an official brand kit — swap freely.)

## Content spec

An ordered list of slides, each with `kicker` (short section label), `headline` (one idea, optional
`accent` word), and `body` (described so it maps to a component). Keep the spec in a `content.md` next
to the deck and update it whenever a slide changes — it's the copy source of truth.

## Body → component

| Content shape | Component |
| --- | --- |
| Points | a clean bulleted list |
| Two things contrasted | side-by-side panels |
| Old vs new | a two-column shift table |
| Before/after numbers | a table with inline bars |
| Process steps | a horizontal flow |
| Commands or output | a terminal block |
| Key → value pairs | a definition list |

Give each slide one clear component — a table, flow, panels, terminal, or list — so it reads as one idea.

## Adding a slide to an existing deck

Insert one `<section class="slide">` before the final closing section. **Change no JavaScript** — the
counter, progress dots, and nav are derived from the `.slide` count at runtime. Then add the matching
`## Slide N` block to `content.md`.

## Rules

- **Self-contained**: inline CSS and JS, system font stacks, no external hosts — must work offline.
- **One idea per slide**, fitting one screen. Use two slides rather than cramming.
- **Every slide is one self-contained `<section>`** so two people adding slides don't collide.
- Pick the palette once (default or the user's) and apply it consistently.
- Decks live in `.claude/temp/` (gitignored) — local artefacts, not committed, unless the user asks otherwise.

## Verify

Open the file and check: slide count matches `content.md`, `<section class="slide">` opens and closes
are balanced, and nav reaches the last slide.
