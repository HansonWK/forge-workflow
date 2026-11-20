# Settings hardening (optional, recommended)

A permissions block that keeps secrets out of the conversation, blocks force-pushes, and makes
Claude ask before it changes its own guardrails. `/install` offers it and merges it into
`.claude/settings.json` only with your explicit consent.

## The block

Merge into `.claude/settings.json`: add each entry to the matching `permissions` array (create the
array if missing), skip entries already present, and leave every other setting untouched.

```json
{
  "permissions": {
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.local)",
      "Bash(cat *.env*)",
      "Bash(printenv:*)",
      "Bash(env)",
      "Bash(git push --force*)",
      "Bash(git push * --force*)",
      "Bash(git push -f*)",
      "Bash(git push * -f*)"
    ],
    "ask": [
      "Edit(.claude/hooks/**)",
      "Write(.claude/hooks/**)",
      "Edit(.claude/settings.json)",
      "Write(.claude/settings.json)",
      "Edit(.claude/settings.local.json)",
      "Write(.claude/settings.local.json)"
    ]
  }
}
```

## Notes

- `.env.*` isn't denied wholesale: that would also lock out committed `.env.example` files.
- `ask` beats `allow`, so a broad `Edit(.claude/**)` allow still prompts for hooks and settings.
- A `Read` deny also blocks `Edit` and `Write` on the path, so any step that must write a denied
  file (e.g. `/secret` with a plain `.env` provider) does it through the shell, never the Write tool.
