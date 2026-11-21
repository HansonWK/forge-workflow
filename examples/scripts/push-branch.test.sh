#!/usr/bin/env bash
# Runs push-branch.sh in a scratch clone of a scratch remote, on each branch and with each argument,
# and checks what it pushed or refused.
# Run: bash .claude/scripts/push-branch.test.sh
# /install adds a branch of each kind the project's OWNED_BRANCH allows to the first loop.

here="$(cd "$(dirname "$0")" && pwd)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
origin="$tmp/origin.git"
repo="$tmp/repo"
git init -q --bare -b main "$origin"
# The remote prints a PR link, as GitHub, GitLab and Bitbucket do.
printf '#!/bin/sh\nwhile read -r _ _ ref; do echo "To open a PR, visit:"; echo "    https://git.example.com/pull/new/${ref#refs/heads/}"; done\n' >"$origin/hooks/post-receive"
chmod +x "$origin/hooks/post-receive"
git clone -q "$origin" "$repo" 2>/dev/null
git -C "$repo" -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m init
git -C "$repo" push -q origin main 2>/dev/null
git -C "$repo" remote set-head origin main
mkdir -p "$repo/.claude/scripts"
cp "$here/push-branch.sh" "$here/owned-branch.sh" "$repo/.claude/scripts/"
script="$repo/.claude/scripts/push-branch.sh"
failures=0

fail() {
  echo "FAIL on $(git -C "$repo" symbolic-ref -q --short HEAD || echo detached): $1"
  failures=$((failures + 1))
}

on() {
  git -C "$repo" switch -q -C "$1" main 2>/dev/null || git -C "$repo" checkout -q -B "$1" main
  git -C "$repo" -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m "work on $1"
}

on_remote() { git -C "$origin" rev-parse -q --verify "refs/heads/$1" >/dev/null; }

# Runs the script from the checkout's root, as the allow rules do.
run() { out=$(cd "$repo" && bash .claude/scripts/push-branch.sh "$@" 2>&1); }

expect_refused() {
  local before
  before=$(git -C "$origin" for-each-ref)
  run "$@" && fail "expected a refusal: push-branch.sh $*"
  [[ $out == Refused:* ]] || fail "expected 'Refused:', got: $out"
  [ "$(git -C "$origin" for-each-ref)" = "$before" ] || fail "the remote changed after a refusal: push-branch.sh $*"
}

for b in PROJ-1-x housekeeping-x bugfix-x spike-x refactor-x audit/web-dead-code-1; do
  on "$b"
  run --dry-run || fail "--dry-run failed: $out"
  [[ $out == *"Dry run: would push $b to origin."* ]] || fail "--dry-run didn't say what it would push: $out"
  on_remote "$b" && fail "--dry-run pushed $b"
  git -C "$repo" rev-parse -q --abbrev-ref '@{u}' >/dev/null 2>&1 && fail "--dry-run set an upstream"
  run || fail "push failed: $out"
  [[ $out == *"Pushed $b to origin."* ]] || fail "didn't say what it pushed: $out"
  [[ $out == *"https://git.example.com/pull/new/$b"* ]] || fail "didn't print the PR link: $out"
  [[ $out == *"To open a PR"* ]] && fail "printed remote lines that aren't the link: $out"
  [ "$(git -C "$origin" rev-parse "refs/heads/$b")" = "$(git -C "$repo" rev-parse HEAD)" ] || fail "$b isn't on the remote"
  [ "$(git -C "$repo" rev-parse --abbrev-ref '@{u}')" = "origin/$b" ] || fail "no upstream origin/$b"
done

on PROJ-2-x
out=$(cd "$tmp" && bash "$script" 2>&1) || fail "the absolute-path form failed: $out"
on_remote PROJ-2-x || fail "the absolute-path form didn't push the script's own checkout"

on PROJ-3-x
for args in --force -f origin 'origin PROJ-3-x' 'HEAD:main' '--dry-run --force' '--force --dry-run' --dry-run=1 --no-verify; do
  read -ra a <<<"$args"
  expect_refused "${a[@]}"
done
expect_refused ''
on_remote PROJ-3-x && fail "PROJ-3-x was pushed by a refused call"

git -C "$repo" switch -q main
expect_refused
expect_refused --dry-run
git -C "$repo" switch -q -c develop
git -C "$repo" push -q origin develop 2>/dev/null
git -C "$repo" remote set-head origin develop
git -C "$repo" switch -q develop
expect_refused
[[ $out == *"default branch"* ]] || fail "develop wasn't refused as the default branch: $out"
git -C "$repo" remote set-head origin main

for b in master release/1 hotfix-x feature-x proj-1-x PROJ-1; do
  on "$b"
  expect_refused
  expect_refused --dry-run
done

on PROJ-5-x
git -C "$repo" checkout -q --detach
expect_refused

on PROJ-5-x
mv "$repo/.claude/scripts/owned-branch.sh" "$tmp/"
out=$(cd "$repo" && OWNED_BRANCH=. bash .claude/scripts/push-branch.sh 2>&1) && fail "pushed without owned-branch.sh"
mv "$tmp/owned-branch.sh" "$repo/.claude/scripts/"

if [ "$failures" -gt 0 ]; then
  echo "$failures push-branch check(s) failed"
  exit 1
fi
echo "push-branch: all checks passed"
