#!/usr/bin/env bash
# Feeds sample git commands to commit-guard.sh, from a scratch repo on each branch, and checks each is allowed or blocked.
# Run: bash .claude/hooks/commit-guard.test.sh
# /install adds a branch of each kind the project's OWNED_BRANCH allows to the first loop.

guard="$(cd "$(dirname "$0")" && pwd)/commit-guard.sh"
repo=$(mktemp -d)
other=$(mktemp -d)
trap 'rm -rf "$repo" "$other"' EXIT
for r in "$repo" "$other"; do
  git -C "$r" init -q -b main
  git -C "$r" -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m init
done
failures=0

on() { git -C "$repo" switch -q -C "$1" 2>/dev/null || git -C "$repo" checkout -q -B "$1"; }

check() {
  expected=$1 command=$2 cwd=${3:-$repo}
  json=$(node -e 'process.stdout.write(JSON.stringify({ tool_name: "Bash", tool_input: { command: process.argv[1] }, cwd: process.argv[2] }))' "$command" "$cwd")
  printf "%s" "$json" | bash "$guard" 2>/dev/null
  code=$?
  actual=$([ "$code" = 2 ] && echo blocked || echo allowed)
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: expected $expected, got $actual on $(git -C "$cwd" symbolic-ref -q --short HEAD || echo detached): $command"
    failures=$((failures + 1))
  fi
}

for b in PROJ-1-x PROJ-1234-update-media-rules housekeeping-x bugfix-x spike-x refactor-x audit/web-dead-code-1; do
  on "$b"
  check allowed 'git commit -m "Add the article list"'
done

for b in main master release/1 hotfix-x feature-x proj-1-x PROJ-1; do
  on "$b"
  check blocked 'git commit -m "Add the article list"'
done

on PROJ-1-x
check allowed 'git add src/a.ts src/b.ts && git commit -m "Add the list; and its test"'
check allowed 'git add ./src/a.ts'
check allowed 'git status && git log --oneline -3'
check allowed 'echo "git commit --amend" && grep -n "git add -A" README.md'
check allowed "$(printf 'cat > notes.md <<%sEOF%s\ngit commit --amend\ngit add -A\nEOF' "'" "'")"
check allowed 'git commit -m "Allow a commit message with -a and --amend in it"'
check blocked 'git commit --amend -m "Fix"'
check blocked 'git commit --amend --no-edit'
check blocked 'git commit -am "Fix"'
check blocked 'git commit -a -m "Fix"'
check blocked 'git add -A'
check blocked 'git add --all'
check blocked 'git add .'
check blocked 'git add src && git add -A && git commit -m "Fix"'

check allowed 'git push -u origin PROJ-1-x'
check allowed 'git push'
check allowed 'git push origin HEAD'
check blocked 'git push origin main'
check blocked 'git push -u origin main'
check blocked 'git push origin HEAD:main'
check blocked 'git push origin PROJ-1-x:refs/heads/main'
on main
check blocked 'git push'
check blocked 'git push origin'
check blocked 'git push origin HEAD'

check blocked "git -C $repo commit -m \"Fix\"" /tmp
check blocked "cd $repo && git commit -m \"Fix\"" /tmp
check blocked "(cd $repo && git commit -m \"Fix\")" /tmp
check blocked 'git -c user.name=x commit -m "Fix"'
on PROJ-1-x
check allowed "git -C $repo commit -m \"Fix\"" "$other"
check blocked "git -C $other commit -m \"Fix\""
check blocked "cd $other && git commit -m \"Fix\""
check allowed "cd $other && cd $repo && git commit -m \"Fix\""

git -C "$repo" checkout -q --detach
check blocked 'git commit -m "Fix"'

if [ "$failures" -gt 0 ]; then
  echo "$failures commit-guard check(s) failed"
  exit 1
fi
echo "commit-guard: all checks passed"
