#!/usr/bin/env bash
# Feeds sample Bash and PowerShell git commands to commit-guard.sh, from a scratch repo on each branch, and checks each is allowed or blocked.
# Run: bash .claude/hooks/commit-guard.test.sh
# /install adds a branch of each kind the project's OWNED_BRANCH allows to the first loop.

guard="$(cd "$(dirname "$0")" && pwd)/commit-guard.sh"
repo=$(mktemp -d)
other=$(mktemp -d)
tmp=$(mktemp -d)
spaced="$tmp/a b"
spaced_ok="$tmp/c d"
plain="$tmp/plain"
nonode="$tmp/bin"
trap 'rm -rf "$repo" "$other" "$tmp"' EXIT
mkdir -p "$spaced" "$spaced_ok" "$plain" "$nonode"
for r in "$repo" "$other" "$spaced" "$spaced_ok"; do
  git -C "$r" init -q -b main
  git -C "$r" -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m init
done
git -C "$spaced_ok" switch -q -c PROJ-2-x
for t in git perl awk tr cat grep; do ln -s "$(command -v "$t")" "$nonode/$t"; done
failures=0

on() { git -C "$repo" switch -q -C "$1" 2>/dev/null || git -C "$repo" checkout -q -B "$1"; }

check() {
  expected=$1 command=$2 cwd=${3:-$repo}
  json=$(node -e 'process.stdout.write(JSON.stringify({ tool_name: process.argv[3], tool_input: { command: process.argv[1] }, cwd: process.argv[2] }))' "$command" "$cwd" "${tool:-Bash}")
  printf "%s" "$json" | bash "$guard" 2>/dev/null
  code=$?
  actual=$([ "$code" = 2 ] && echo blocked || echo allowed)
  if [ "$actual" != "$expected" ]; then
    echo "FAIL (${tool:-Bash}): expected $expected, got $actual on $(git -C "$cwd" symbolic-ref -q --short HEAD || echo detached): $command"
    failures=$((failures + 1))
  fi
}

check_ps() { tool=PowerShell check "$@"; }

# Raw hook input, optionally with node left off PATH.
check_raw() {
  expected=$1 input=$2 path=${3:-$PATH}
  printf "%s" "$input" | PATH=$path "$BASH" "$guard" 2>/dev/null
  actual=$([ $? = 2 ] && echo blocked || echo allowed)
  if [ "$actual" != "$expected" ]; then
    echo "FAIL (raw input$([ "$path" = "$nonode" ] && echo ', no node')): expected $expected, got $actual: $input"
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

on PROJ-1-x
check_ps allowed 'git add src/a.ts; git commit -m "Add the list; and its test"'
check_ps allowed 'git status; git log --oneline -3'
check_ps allowed 'Write-Output "git commit --amend"; Select-String -Pattern "git add -A" README.md'
check_ps allowed "$(printf '$msg = @"\ngit commit --amend\ngit add -A\n"@\ngit commit -m $msg')"
check_ps allowed 'git commit -m "Say `"-a`" and --amend"'
check_ps allowed 'git push -u origin PROJ-1-x'
check_ps allowed "Set-Location $other; Set-Location $repo; git commit -m \"Fix\"" "$other"
check_ps blocked 'git commit --amend -m "Fix"'
check_ps blocked 'git commit -am "Fix"'
check_ps blocked 'git add -A'
check_ps blocked 'git add .'
check_ps blocked 'git add src && git add --all'
check_ps blocked "$(printf 'git add src/a.ts\r\ngit add -A\r\n')"
check_ps blocked "$(printf 'git commit `\n  --amend')"
check_ps blocked '& git commit -a -m "Fix"'
check_ps blocked 'git.exe add -A'
check_ps blocked 'Git commit --amend'
check_ps blocked '& "C:\Program Files\Git\cmd\git.exe" commit --amend'
check_ps blocked 'if ($true) { git add -A }'
check_ps blocked 'Get-ChildItem | ForEach-Object { git add -A }'
check_ps blocked 'git push origin main'
check_ps blocked 'git push origin HEAD:main'
check_ps blocked "git -C $other commit -m \"Fix\""
check_ps blocked "Set-Location $other; git commit -m \"Fix\""
check_ps blocked "Set-Location -Path $other; git commit -m \"Fix\""
check_ps blocked "sl $other; git commit -m \"Fix\""
check_ps blocked "Push-Location $other; git commit -m \"Fix\""
on main
check_ps blocked 'git commit -m "Fix"'
check_ps blocked 'git push'

status_json="{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git status\"},\"cwd\":\"$repo\"}"
check_raw allowed "$status_json"
check_raw blocked "$status_json" "$nonode"
check_raw blocked 'not json'
check_raw blocked ''
check_raw blocked '{"tool_name":"Bash","tool_input":{"command":"git commit --amend"'

on PROJ-1-x
check blocked "cd \"$spaced\" && git commit -m \"Fix\""
check blocked "git -C '$spaced' commit -m \"Fix\""
check allowed "cd \"$spaced_ok\" && git commit -m \"Fix\"" "$other"
check allowed "git -C \"$spaced_ok\" commit -m \"Fix\"" "$other"
check_ps blocked "Set-Location \"$spaced\"; git commit -m \"Fix\""
check_ps allowed "Set-Location -LiteralPath '$spaced_ok'; git commit -m \"Fix\"" "$other"

check blocked 'cd /no/such/dir && git commit -m "Fix"'
check blocked 'git -C /no/such/dir commit -m "Fix"'
check blocked 'cd "$SOME_DIR" && git commit -m "Fix"'
check blocked 'cd - && git commit -m "Fix"'
check blocked "cd $plain && git commit -m \"Fix\""
check blocked "git -C $plain push"
check_ps blocked 'Set-Location $env:SOME_DIR; git commit -m "Fix"'
CLAUDE_PROJECT_DIR=$repo check allowed 'cd "$CLAUDE_PROJECT_DIR" && git commit -m "Fix"' "$other"
CLAUDE_PROJECT_DIR=$repo check_ps allowed 'Set-Location $env:CLAUDE_PROJECT_DIR; git commit -m "Fix"' "$other"

git -C "$repo" checkout -q --detach
check blocked 'git commit -m "Fix"'
check blocked 'git push'
check blocked 'git push origin HEAD'

if [ "$failures" -gt 0 ]; then
  echo "$failures commit-guard check(s) failed"
  exit 1
fi
echo "commit-guard: all checks passed"
