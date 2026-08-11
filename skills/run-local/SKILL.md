---
name: run-local
description: Launch the app or a service locally to reproduce a bug, verify a change, or click through it — and decide what Claude should run in the background versus what the developer should run in their own terminal. Use when starting something locally.
allowed-tools: Read, Grep, Glob, Bash
---

# Run locally

Use the project's real run commands (from `docs/workflow-config.md` / the README). This skill is about
the **discipline** — who runs what, and how to do it without wasting context or leaving dead links.

## Who runs what

**Split by who needs the output.**

| Situation | Who |
| --- | --- |
| Claude reads the output to answer the question this turn | **Claude**, background |
| Reproducing a bug from a service's logs | **Claude**, background |
| Developer wants to click around the app | **Developer** |
| Must outlive this turn | **Developer** |
| Interactive input (a login, a tunnel, Docker prompts) | **Developer** |

One request can produce both halves — Claude runs a service in the background to read its logs, and
hands the developer the command for the web app. Report both: what Claude started, and what they still
need to start.

> ⚠️ **Long-lived / web processes default to the developer's terminal.** Claude-owned background
> processes are killed when the session ends, so a link handed over is often dead by the time it's
> clicked. Only run one in the background when Claude itself needs the output *this turn*.

When handing over, prefix with `!` so the output returns to the conversation:

```
! <the project's run command>
```

## Cost

Background processes are effectively free — output goes to a file, not into context. **Reading is what
costs.** Never `Read` a running server's log; `tail -30` or `grep` for the specific line. Health-check
loops should print one summary line, not per-attempt output. Leaving something running between turns
costs nothing — don't stop and restart to "save tokens".

## Prerequisites — tell, don't start

If a run needs external services (a database, a queue, Docker emulators) and starting them could
**destroy local data** (some `up` scripts wipe volumes first), **never start them for the developer** —
stop and print the command for them to run. That's their call.

## Health checks

Poll a real **health URL**, not a bare port bind, when the process serves HTTP. First compile can take
30–120s — allow generously before declaring failure, and `tail` the log rather than assuming.

> ⚠️ Confirm the health URL actually returns success — an app that only serves `/app` returns 404 on
> `/`, so a loop waiting for 200 on `/` never succeeds against a perfectly healthy server.

## Stopping

> ⚠️ `lsof -ti :PORT` lists connected browser tabs too — piping that to `kill` can target the browser.
> Filter to listeners:

```bash
lsof -nP -iTCP:$PORT -sTCP:LISTEN -t
```

Killing a wrapper (`npx`, a task runner) can leave the real server child listening — kill the tree.
**Only stop what this run started.** If a port is already in use, identify it first and ask — use the
running instance or kill it — rather than assuming it's yours.
