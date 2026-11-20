# Commit-guard hook (optional, recommended)

Forge's commit policy (the CLAUDE.md Working agreements): **approval means commit**. Claude commits
each approved subtask, staging files by name, only on a branch the workflow owns, and never amends or
force-pushes. It pushes only when the developer says push (`/pr` pushes when it opens the PR). This
hook enforces the parts a long context can forget, deterministically.

It's opt-in: `/install` offers it and only adds it with your explicit consent.

## What it refuses

A `PreToolUse` hook on the `Bash` tool. It refuses (exit 2, with the reason shown to Claude):

- `git commit` on the default branch, a detached HEAD, or a branch outside `OWNED_BRANCH`;
- `git commit --amend`, `git commit -a`;
- `git add -A`, `--all`, `.`;
- a `git push` that targets the default branch, including a bare `git push` while on it.

Everything else (status, diff, log, `git add <file>`, pushing a workflow branch) runs normally.
Quoted text and heredoc bodies are data, so a commit message that mentions `--amend` is fine.

## Install

1. Copy `commit-guard.sh` and `commit-guard.test.sh` from this folder to `.claude/hooks/` and make
   them executable.
2. Set `OWNED_BRANCH` (a regex) and `OWNED_HINT` (its plain-words form) at the top of the script
   from the branch convention in `docs/workflow-config.md`, keeping the task-type prefixes `/begin`
   uses and `audit/` if the audit module is installed. Add one branch of each kind to the test's
   first loop.
3. Run `bash .claude/hooks/commit-guard.test.sh`; it must print `all checks passed`.
4. Add the hook to `.claude/settings.json` (merge into any existing `hooks`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/commit-guard.sh", "onFailure": "block" }
        ]
      }
    ]
  }
}
```

## Notes

- It needs `node` (to read the hook input) and `perl`, both present wherever forge runs.
- The settings-hardening block (`examples/settings/hardening.md`) also denies pushing the default
  branch and force-pushing; the hook catches the forms a permission pattern can't, such as a bare
  `git push` on the default branch.
- A project upgrading from forge 1.x replaces its old hook, which refused every commit and push.
