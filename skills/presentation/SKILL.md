---
name: presentation
description: Build a slide deck or a long-form page in the house style as a published Artifact, revise it with the developer on the live page until they say it is done, and export a self-contained HTML file only when asked. Use for /presentation, or when asked to create or extend a deck, a walkthrough, a write-up or a report page.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Artifact, ArtifactComments
---

# Presentation

One `.html` source file, scaffolded from a shell, published as an Artifact and revised live.

| File | What |
| --- | --- |
| `house-style.css` | The house style: colour, type and spacing tokens (light and dark) and the components below. `/install` replaces it with the project's own |
| `deck.html`, `page.html` | The shells. Each marks where the stylesheet goes with `/* @house-style */` |
| `build.mjs` | `new deck\|page <out.html> "<Title>"` scaffolds a source; `export <source.html>` writes `<name>.export.html` |

## 1. Pick the format

| Format | Choose when | Shell |
| --- | --- | --- |
| **Deck** (`--slides`) | Someone presents it live, one point per screen | `deck` |
| **Page** (`--page`) | People read it on their own: a write-up, a walkthrough, a report, a proposal | `page` |

A flag decides it. With neither, choose from the request and say the choice in one line with the
reason ("Deck — you're presenting it at the show-and-tell"). If the Artifact tool asks for a
quickstart first, run it with `intent: "other"` and `design_systems: false`, then build from the
house style, not the type it suggests.

## 2. Build and publish the first draft

1. Gather the content: the ticket, the plan, the diff, the docs. Real figures only.
2. Scaffold: `node .claude/skills/presentation/build.mjs new deck|page <out.html> "<Title>"`, into
   the work folder when there is one, else `.claude/temp/presentations/<slug>/<slug>.html`.
3. Write the copy (below) straight into the HTML, one component per slide or section.
   Deck order: **Title → body slides → optional method hinge (`#hinge`) → Closing**. Page order:
   **Header → summary → sections → What's next**.
4. Publish with the Artifact tool: `icon: "slides"` for a deck or `"document"` for a page, and a
   one-sentence `description`. Give the developer the link and the source path.

Leave animation tuning until the copy is agreed: copy changes far more often than styling.
**No Artifact tool:** run `export`, give the absolute path of the `.export.html`, and revise that
file instead.

## 3. Revise on the live Artifact

The developer gives changes in the terminal. When they say they left comments on the Artifact, read
them with `ArtifactComments`, make the changes, and reply in each thread once done. Never act on a
comment the developer didn't point you to.

- Edit the source and republish **the same file path**, so the link stays the same. Say in one line
  what changed.
- Keep revising until the developer says it's done. Never declare it finished yourself.
- **Export only when asked** (`build.mjs export <source>`). Give the absolute path, and offer to
  delete the Artifact; delete only on a yes.

## Body → component (from `house-style.css`)

| Content shape | Component |
| --- | --- |
| Points | `ul.clean` |
| Two things contrasted | `.panels` |
| Process steps | `ol.flow` |
| Commands or output | `pre.term` |
| Figures, old vs new | `.table-wrap` table, `.bar` for inline bars |
| Key → value pairs | `dl.kv` |
| The finding that matters | `.callout` |
| The command or skill a slide is about | `.cmd` in the eyebrow, with a `.tag` (`NEW`, `IMPROVED`) |

## Writing the copy

- **The headline is the point of the slide, not a label for it.** If someone who reads only the
  headline draws the wrong conclusion, rewrite it.
- **What / How / When is an outline, not a template.** Drop any line that doesn't apply.
- **Cut anything true of every deck.** It displaces the specific.
- **End on the concrete finding**: the bug it caught, the number it produced.
- **Order by weight**, not by the order the work shipped. Put a worked example right after the thing
  it illustrates.
- **Speaker notes (deck):** every slide has an `<aside class="notes">` saying what to **say**, not
  what's on screen; `N` toggles them. The last slide's notes say which slides to cut if time is short.
- **The closing slide or section is always "what's next"**: named follow-ups, then thanks/questions.

## Adding a slide

Insert one `<section class="slide">` between `#hinge` and the closing section. **Change no
JavaScript**: the counter, dots and nav derive from the `.slide` count. Republish to the same
Artifact; for a deck from an earlier conversation, find it with `Artifact action: "list"`, read it,
and publish with `url`.

## Rules

- **Inline everything.** No external hosts: the Artifact blocks them silently and the export must
  work offline. The house style uses system font stacks.
- **One idea per slide**, fitting 1280×720 and stacking cleanly at 400px wide.
- **Every slide or section is one self-contained `<section>`**, so two people adding slides don't
  collide.
- Colours come from the house-style tokens. Never invent a hex; to restyle one deck, override the
  tokens in its own `:root`.
- Sources and exports live under `.claude/temp/` (gitignored) unless the developer asks otherwise.

## Verify

Before each publish: `<section` opens and `</section>` closes balance, nav reaches the last slide,
every deck slide has a `.notes` aside, and the page's `<script>` passes `node --check`.
