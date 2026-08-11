---
name: presentation
description: (forge repo-internal) Build a self-contained HTML slide deck in the FORGE house style — molten metal on dark steel. Use to present Forge itself. Repo-internal; not shipped. (The shipped generic `presentation` skill defaults to a Claude palette instead.)
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# Presentation (Forge house style)

Build a deck as one self-contained `.html` file, themed as **a blade being forged** — dark steel,
molten orange-to-yellow glow, silver highlights, cooling-green accents.

## Order of work

**Content → design → animation.** Get the copy approved before building. Decks are rewritten far more
often for wrong content than wrong styling.

1. Write or read the content spec (`content.md` next to the deck) and **get the copy approved**.
2. Apply the Forge palette + design language below.
3. Map each slide's body to a component.
4. Assemble: **Title → body slides → Closing.**
5. Write the file; give the absolute path. Decks live in `.claude/temp/` (gitignored).

## Forge palette

| Token | Value | Use |
| --- | --- | --- |
| `--bg` | `#10171B` | dark-steel page background |
| `--bg-deep` | `#0A0F12` | vignette / depth |
| `--surface` | `#19232A` | panels / cards |
| `--edge` | `#C7D0D3` | thin silver highlight edge on metal panels |
| `--text` | `#E8EBEA` | body text (light grey) |
| `--muted` | `#93A0A5` | secondary text (silver-grey) |
| `--forge` | `#F0863C` | primary accent — molten orange |
| `--spark` | `#F6C445` | hot highlight — yellow |
| `--cool` | `#57B89A` | cooling-green accent (secondary series, "verified") |
| grid line | `rgba(78,150,150,.16)` | faint teal crosshair grid |

- **Molten gradient** for accent words, bars, and hot edges: `linear-gradient(90deg,#F0863C,#F6C445)`,
  with a soft orange glow (`text-shadow`/`box-shadow` in `--forge` at low alpha).
- **Background:** dark steel with a subtle radial forge-glow (orange, low alpha) behind the hero and a
  faint teal crosshair grid (from the reference image).

## Design language — "a blade being forged"

- **Sharp, uppercase titles** in a condensed stack (`"Arial Narrow","Roboto Condensed","Helvetica
  Neue",system-ui,sans-serif`), heavy weight, tight letter-spacing. The accent word glows molten.
- **Angular / beveled edges** (`clip-path` cutting a corner) on cards and the hero — blade geometry,
  not rounded.
- **Silver metal panels** — `--surface` with a 1px `--edge` top highlight and a hairline shadow below.
- **Cooling green** for positive / "verified" bits; molten orange-yellow for emphasis and heat.
- Imagery motif: forging (heat → hammer → shape). Keep it geometric — glows and edges, no clip-art.

## Body → component

| Content shape | Component |
| --- | --- |
| Points | a clean bulleted list |
| Two things contrasted | side-by-side panels |
| Old vs new | a two-column shift table |
| Before/after numbers | a table with inline molten bars |
| Process steps | a horizontal flow with glowing connectors |
| Commands or output | a terminal block |
| Key → value pairs | a definition list |

## Rules

- **Self-contained**: inline CSS and JS, system font stacks, no external hosts — must work offline.
- One idea per slide, one screen; every slide is one self-contained `<section class="slide">`.
- Keyboard nav (arrows), progress dots, slide counter; direction-aware transitions.
- Keep the palette consistent; the molten gradient is the only "hot" colour — don't over-use it.

## Verify

Open the file: slide count matches `content.md`, `<section class="slide">` opens/closes balance, nav
reaches the last slide.
