---
description: Run the app or a service locally (deciding Claude-background vs your terminal)
argument-hint: [app/service to run]
---

# Run

Apply the **`run-local` skill** to start `$ARGUMENTS` locally, using the project's run commands. It
decides what Claude runs in the background (only when Claude needs the output *this* turn) versus what
you run in your own terminal (web / long-lived processes), and handles health checks and stopping.

## Rules

- Long-lived / web processes go to your terminal — background procs die at session end.
- Never start data-destroying prerequisites (e.g. an emulator `up` that wipes volumes) — hand them over.
