#!/usr/bin/env bash
# Pushes the current branch to origin with -u, and nothing else: the one push Claude runs without a
# permission prompt, after the developer says yes in chat. Refuses the default branch, a detached
# HEAD, a branch outside OWNED_BRANCH (owned-branch.sh, shared with the commit guard), and any
# argument but --dry-run. Prints the branch and the remote's PR link, if git printed one.
# Run: bash .claude/scripts/push-branch.sh [--dry-run]

refuse() {
  echo "Refused: $1 Any other push goes through the permission prompt." >&2
  exit 1
}

dry_run=
if [ $# -eq 1 ] && [ "$1" = --dry-run ]; then
  dry_run=--dry-run
elif [ $# -gt 0 ]; then
  refuse "push-branch.sh takes no argument but --dry-run: it pushes the current branch to origin."
fi

here=$(cd "$(dirname "$0")" && pwd)
OWNED_BRANCH=
. "$here/owned-branch.sh" 2>/dev/null
[ -n "$OWNED_BRANCH" ] || refuse "can't read $here/owned-branch.sh, so it can't tell which branches the workflow owns."

branch=$(git -C "$here" symbolic-ref -q --short HEAD) ||
  refuse "this checkout is on a detached HEAD. Switch to a workflow branch ($OWNED_HINT) first."
default=$(git -C "$here" symbolic-ref -q --short refs/remotes/origin/HEAD)
case "$branch" in
  main | master | "${default#origin/}") refuse "'$branch' is the default branch, which Claude never pushes." ;;
esac
printf '%s' "$branch" | grep -Eq "$OWNED_BRANCH" ||
  refuse "'$branch' is not a branch the workflow owns ($OWNED_HINT)."

out=$(git -C "$here" push $dry_run -u origin "refs/heads/$branch:refs/heads/$branch" 2>&1) || {
  printf '%s\n' "$out" >&2
  exit 1
}
if [ -n "$dry_run" ]; then echo "Dry run: would push $branch to origin."; else echo "Pushed $branch to origin."; fi
printf '%s\n' "$out" | grep -Ei '^remote: +https?://.*(pull|merge_request)' | sed 's/^remote: *//'
exit 0
