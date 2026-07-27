# Commit-guard hook (optional, recommended)

Forge's policy is **the user commits, not Claude**. That rule is stated once in `CLAUDE.md`, but on
long contexts or older model generations Claude can still run `git commit` without asking. This hook
enforces the rule **deterministically** — it's model-independent and survives large context.

It's opt-in: `/install` offers it and only adds it with your explicit consent. You commit yourself
(in your terminal, or via the `!` prefix), which is not a Claude tool call and so isn't blocked.

## What it does

A `PreToolUse` hook on the `Bash` tool inspects the command; if it's a `git commit` or `git push`,
it blocks the call and tells Claude to hand the commit back to you.

## Install

1. Save the script to `.claude/hooks/commit-guard.sh` and make it executable
   (`chmod +x .claude/hooks/commit-guard.sh`):

```bash
#!/usr/bin/env bash
# Blocks Claude from running `git commit` / `git push`. Commits are the user's action.
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
if printf '%s' "$cmd" | grep -qiE '(^|[;&|]|[[:space:]])git[[:space:]]+(commit|push)([[:space:]]|$)'; then
  echo "Blocked: 'git commit' / 'git push' is the user's action in this workflow. Suggest a commit message and ask the user to run it (they can use the ! prefix)." >&2
  exit 2   # exit code 2 tells Claude Code to block the tool call and surface stderr
fi
exit 0
```

2. Add the hook to `.claude/settings.json` (merge into any existing `hooks`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/commit-guard.sh" }
        ]
      }
    ]
  }
}
```

## Notes

- Blocks only `git commit` / `git push` — everything else (status, diff, log, add) runs normally.
- To bypass for a one-off, the user runs the commit themselves (terminal or `!` prefix).
- This complements the prose guardrail; it does not replace the approval STOP points in the commands.
