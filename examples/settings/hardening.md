# Settings hardening (optional, recommended)

A permissions block that keeps secrets out of the conversation, blocks force-pushes and pushes to
the default branch, lets the push script run and asks before every other push, pre-approves the
work folder, and makes Claude ask before it changes its own guardrails. `/install` offers it and
merges it into `.claude/settings.json` only with your explicit consent.

## The block

Merge into `.claude/settings.json`: add each entry to the matching `permissions` array (create the
array if missing), skip entries already present, and leave every other setting untouched.

```json
{
  "permissions": {
    "allow": [
      "Edit(.claude/temp/work/**)",
      "Edit(.claude/temp/ledger/**)",
      "Bash(bash .claude/scripts/push-branch.sh)",
      "Bash(bash .claude/scripts/push-branch.sh --dry-run)"
    ],
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.local)",
      "Bash(cat *.env*)",
      "Bash(printenv:*)",
      "Bash(env)",
      "Bash(git push --force*)",
      "Bash(git push * --force*)",
      "Bash(git push -f*)",
      "Bash(git push * -f*)",
      "Bash(git push * main)",
      "Bash(git push * main *)",
      "Bash(git push *:main)",
      "Bash(git push *:main *)",
      "Bash(git -C * push --force*)",
      "Bash(git -C * push * --force*)",
      "Bash(git -C * push -f*)",
      "Bash(git -C * push * -f*)",
      "Bash(git -C * push * main)",
      "Bash(git -C * push * main *)",
      "Bash(git -C * push *:main)",
      "Bash(git -C * push *:main *)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(git -C * push*)",
      "Edit(**/.claude/hooks/**)",
      "Edit(**/.claude/scripts/**)",
      "Edit(**/.claude/settings.json)",
      "Edit(**/.claude/settings.local.json)"
    ]
  }
}
```

## Notes

- `/install` replaces `main` in the push denies with the project's default branch.
- Claude Code asks before any `Edit`/`Write` under `.claude/` unless it's pre-approved, so the work
  folder and the tier ledger need the `allow` entries, or headless and `acceptEdits` runs stall.
- File rules are `Edit(...)` only: they cover every file-editing tool, `Write` included, and a
  `Write(...)` rule is never matched (`claude doctor` flags it).
- `.env.*` isn't denied wholesale: that would also lock out committed `.env.example` files.
- `ask` beats `allow`, so a broad `Edit(.claude/**)` allow still prompts for hooks and settings.
- Claude pushes through `.claude/scripts/push-branch.sh` (`examples/scripts/push-branch.md`), after
  the developer's yes in chat. Every other push asks, in auto mode too, and `deny` beats `ask`, so
  force-pushes and default-branch pushes are still refused outright. Without the push script, drop
  its two `allow` rules.
- The `.claude/scripts/**` ask keeps Claude from changing the push script it runs unprompted.
- A `git push` rule doesn't match `git -C <dir> push`, so the push ask and denies each have a `-C`
  form.
- The `ask` rules start with `**/` so they also cover worktrees kept under the project
  (e.g. `.claude/worktrees/<slug>/.claude/hooks/`), which a plain `.claude/hooks/**` misses.
- A `Read` deny also blocks `Edit` and `Write` on the path, so any step that must write a denied
  file (e.g. `/secret` with a plain `.env` provider) does it through the shell, never the Write tool.
