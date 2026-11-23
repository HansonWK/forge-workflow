# Commit-guard hook (optional, recommended)

Forge's commit policy (the CLAUDE.md Working agreements): **approval means commit**. Claude commits
each approved subtask, staging files by name, only on a branch the workflow owns, and never amends or
force-pushes. It pushes only through `.claude/scripts/push-branch.sh`, after the developer's yes to
a step that pushes (`/pr` asks once). This hook enforces the parts a long context can forget,
deterministically.

It's opt-in: `/install` offers it and only adds it with your explicit consent.

## What it refuses

A `PreToolUse` hook on the `Bash` and `PowerShell` tools. It refuses (exit 2, with the reason shown
to Claude):

- `git commit` on the default branch, a detached HEAD, or a branch outside `OWNED_BRANCH`;
- `git commit --amend`, `git commit -a`;
- a commit message holding an apostrophe (straight `'` or curly `’`), in the title or the body;
- `git add -A`, `--all`, `.`;
- a `git push` that targets the default branch, including a bare `git push` while on it;
- anything it can't check: hook input that isn't JSON, no `node` on PATH, a commit without
  `.claude/scripts/owned-branch.sh`, or a commit or push in a folder it can't resolve to a git
  checkout and branch (`cd "$SOME_VAR"`, `cd -`, a detached HEAD).

Everything else (status, diff, log, `git add <file>`, pushing a workflow branch) runs normally.
Quoted text, heredoc and here-string bodies are data, so a commit message that mentions `--amend` is
fine. Quoted paths keep their spaces, and `$CLAUDE_PROJECT_DIR` and `$HOME` (or `$env:…`) resolve.

## Install

1. Copy `commit-guard.sh` and `commit-guard.test.sh` from this folder to `.claude/hooks/` and make
   them executable, and `../scripts/owned-branch.sh` to `.claude/scripts/` (the push script shares it).
2. Set `OWNED_BRANCH` (a regex) and `OWNED_HINT` (its plain-words form) in `owned-branch.sh` from
   the branch convention in `docs/workflow-config.md`, keeping the task-type prefixes `/begin` uses
   and `audit/` if the audit module is installed. Add one branch of each kind to the test's first
   loop.
3. Run `bash .claude/hooks/commit-guard.test.sh`; it must print `all checks passed`.
4. Add the hook to `.claude/settings.json` (merge into any existing `hooks`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|PowerShell",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/commit-guard.sh\"",
            "onFailure": "block"
          }
        ]
      }
    ]
  }
}
```

## Notes

- The command uses `$CLAUDE_PROJECT_DIR`, so the hook still runs after Claude's shell has `cd`'d into
  the work folder or a subdirectory.
- It needs `node` (to read the hook input), `perl` and `bash`. On Windows, Git for Windows provides
  `bash` and `perl`; the hook runs through it for PowerShell commands too.
- For PowerShell it also reads `;` chains, `{ }` blocks, backtick escapes and line continuations,
  `& git` / `git.exe`, and `Set-Location` / `sl` / `Push-Location`, case-insensitively.
- **Apostrophes** are read in the message as git gets it: `-m` / `--message` values with the shell
  quoting removed (so `-m 'A title'` is fine), `-F` / `--file` files, and a heredoc or here-string
  opened on the commit line (`-F - <<'EOF'`, `-m "$(cat <<'EOF' … EOF)"`, `@'…'@ | git commit -F -`).
  PowerShell `''` inside single quotes counts as one. A message it can't read is allowed and left to
  the written rule in the Working agreements: one built from a variable or a pipe, a file the same
  command writes, a quoted `-m` running over several lines, an editor commit.
- The settings-hardening block (`examples/settings/hardening.md`) also denies pushing the default
  branch and force-pushing; the hook catches the forms a permission pattern can't, such as a bare
  `git push` on the default branch.
- A project upgrading from forge 1.x replaces its old hook, which refused every commit and push.
