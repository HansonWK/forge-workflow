# Push script (optional, recommended)

The one push Claude runs without a permission prompt. `push-branch.sh` pushes the current branch to
`origin` with `-u`, and nothing else. A workflow step that pushes (`/pr`) asks once in chat, and runs
it on the developer's yes. With the settings-hardening block, every other `git push` asks, and
force-pushes and default-branch pushes are denied.

It's opt-in: `/install` offers it alongside the commit guard and only adds it with your explicit
consent.

## What it refuses

It exits 1, with the reason, on:

- the default branch, a detached HEAD, or a branch outside `OWNED_BRANCH`;
- any argument but `--dry-run`, so there's no force, no other ref and no other remote;
- a missing `owned-branch.sh`.

Otherwise it prints the branch it pushed (or, with `--dry-run`, would push) and the remote's PR link,
if git printed one.

## Install

1. Copy `push-branch.sh`, `push-branch.test.sh` and `owned-branch.sh` from this folder to
   `.claude/scripts/` and make the first two executable. The commit guard installs the same
   `owned-branch.sh`; keep one copy.
2. Fill `OWNED_BRANCH` / `OWNED_HINT` in `owned-branch.sh` as `examples/hooks/commit-guard.md` step 2
   says, and add one branch of each kind to the test's first loop.
3. Run `bash .claude/scripts/push-branch.test.sh`; it must print `all checks passed`.
4. Merge the two `allow` rules into `.claude/settings.json` (the hardening block has them too):

```json
{
  "permissions": {
    "allow": [
      "Bash(bash .claude/scripts/push-branch.sh)",
      "Bash(bash .claude/scripts/push-branch.sh --dry-run)"
    ]
  }
}
```

## Notes

- The rules match those two commands exactly, so `push-branch.sh --force` still asks, and the
  script refuses it anyway. Claude runs it from the checkout's root, as the rules are written; it
  pushes the checkout it lives in.
- Keep the hardening block's `Edit(**/.claude/scripts/**)` ask: Claude runs this script without a
  prompt, so it mustn't change it without one.
- A step that must push a branch the script refuses (a release branch outside the convention) runs
  its own `git push`, which asks, and says so.
- Declined: `/install` writes `git push -u origin <branch>` where the commands run the script, and
  that push asks.
