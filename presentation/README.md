# Forge presentation (living)

The Forge intro deck — a self-contained HTML slide deck that shows what Forge is and why to use it.

- **Live:** https://hansonwk.github.io/forge-workflow/ (deployed from `main` by `.github/workflows/pages.yml`)
- **Source:** `index.html` — one self-contained file (inline CSS/JS, offline, keyboard nav).

This is a **living** showcase: update `index.html` in the same PRs that change the workflow, and it
redeploys on merge to `main`. (Not shipped to npm — this folder isn't in `package.json` `files`.)

To rebuild it in the Forge house style, use the repo-internal `/presentation` command; then copy the
result here as `index.html`.
