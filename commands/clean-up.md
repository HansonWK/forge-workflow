---
description: Clean up finished work — one record per piece of work, then remove its worktree, work folder and spent reviews
argument-hint: [--dry-run]
---

# Clean-up

Use the `clean-up` skill.

- `$ARGUMENTS` is `--dry-run`: run Phase 0 and show the plan, move and delete nothing, and write only
  the ledger row.
- Empty: the whole flow, acting group by group on the developer's yes.

When the developer asks about past work ("we did xyz, can you find it?"), use the skill's Finding old
work instead.

## Rules

- Nothing is removed before its record is written and checked, or without a yes.
- Never touch `user/`, a ledger, or the never-touch list.
