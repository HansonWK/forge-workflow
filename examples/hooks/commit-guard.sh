#!/usr/bin/env bash
# PreToolUse hook (Bash): Claude commits only on a branch the workflow owns, files staged by name, never amending.
# Refuses `git commit` on the default branch, a detached HEAD or a branch outside OWNED_BRANCH,
# `git commit --amend` / `-a`, `git add -A` / `--all` / `.`, and a `git push` that targets the default branch.
# Exit code 2 blocks the call and shows stderr to Claude.

# The branches /begin, /branch and /audit-fix create. /install fills both from the branch convention
# in docs/workflow-config.md.
OWNED_BRANCH='^([A-Z][A-Z0-9]+-[0-9]+-[a-z0-9][a-z0-9-]*|(bugfix|housekeeping|spike|refactor)-[a-z0-9][a-z0-9-]*|audit/[a-z0-9][a-z0-9-]*)$'
OWNED_HINT='<TICKET-ID>-<summary>, bugfix-, housekeeping-, spike- or refactor-<slug>, or audit/<slug>'

input=$(cat)
{
  IFS= read -r -d '' tool
  IFS= read -r -d '' start_dir
  IFS= read -r -d '' cmd
} < <(printf '%s' "$input" | node -e '
  let s = "";
  process.stdin.on("data", (d) => (s += d)).on("end", () => {
    let j = {};
    try { j = JSON.parse(s); } catch {}
    process.stdout.write([j.tool_name, j.cwd, j.tool_input?.command].map((v) => v ?? "").join("\0") + "\0");
  });')
[ "$tool" = Bash ] && [ -n "$cmd" ] || exit 0
start_dir=${start_dir:-${CLAUDE_PROJECT_DIR:-$PWD}}

block() {
  echo "Blocked: $1" >&2
  exit 2
}

# Heredoc bodies are data. Quoted text stays one word, with any separator inside it neutralised,
# so a commit message never splits the command and `echo "git commit"` is not a commit.
words=$(printf '%s\n' "${cmd//$'\\\n'/ }" | awk '
  marker != "" { if ($0 == marker) marker = ""; next }
  match($0, /<<-?[[:space:]]*["\047]?[A-Za-z_][A-Za-z0-9_]*/) {
    marker = substr($0, RSTART, RLENGTH); sub(/^<<-?[[:space:]]*["\047]?/, "", marker)
  }
  { print }' | perl -pe 's/"([^"]*)"|\x27([^\x27]*)\x27/my $q = defined $1 ? $1 : $2; $q =~ s{[;&|\s()]}{_}g; length $q ? $q : "_"/ge')

resolve() {
  case "$1" in
    '' | '~') printf '%s' "$HOME" ;;
    '~/'*) printf '%s' "$HOME/${1#'~/'}" ;;
    /*) printf '%s' "$1" ;;
    *) printf '%s' "$2/$1" ;;
  esac
}

default_branch() {
  local d
  d=$(git -C "$1" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
  printf '%s' "${d#origin/}"
}

is_default() {
  case "$1" in main | master | "${2:-main}") return 0 ;; esac
  return 1
}

check_branch() {
  dir=$1
  git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || return 0
  branch=$(git -C "$dir" symbolic-ref -q --short HEAD)
  [ -n "$branch" ] || block "this checkout is on a detached HEAD. Claude commits only on a workflow branch ($OWNED_HINT): create one with git switch -c first."
  is_default "$branch" "$(default_branch "$dir")" &&
    block "'$branch' is the default branch, which Claude doesn't commit on: create a workflow branch ($OWNED_HINT) with git switch -c first."
  printf '%s' "$branch" | grep -Eq "$OWNED_BRANCH" ||
    block "'$branch' is not a branch the workflow owns ($OWNED_HINT). Claude commits only on those: suggest a correctly named branch to the developer instead."
}

check_push() {
  dir=$1
  shift
  default=$(default_branch "$dir")
  positional=()
  for a in "$@"; do
    case "$a" in -*) ;; *) positional+=("$a") ;; esac
  done
  for ref in "${positional[@]:1}"; do
    target=${ref##*:}
    target=${target#refs/heads/}
    [ "$target" = HEAD ] && target=$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null)
    is_default "$target" "$default" && block "git push $ref targets the default branch. Claude never pushes it: push the workflow branch and open a PR."
  done
  if [ ${#positional[@]} -le 1 ] && git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$dir" symbolic-ref -q --short HEAD)
    is_default "$branch" "$default" && block "a bare git push on '$branch' pushes the default branch. Claude never pushes it."
  fi
}

check_git() {
  dir=$1
  shift
  while [ $# -gt 0 ]; do
    case "$1" in
      -C) dir=$(resolve "$2" "$dir"); shift 2 ;;
      -c) shift 2 ;;
      -*) shift ;;
      *) break ;;
    esac
  done
  sub=$1
  [ $# -gt 0 ] && shift
  case "$sub" in
    add)
      for a in "$@"; do
        if [[ $a =~ ^(--all|\.|\./|:/|-[a-zA-Z]*A[a-zA-Z]*)$ ]]; then
          block "git add $a stages everything. Stage the subtask's files by name."
        fi
      done
      ;;
    commit)
      for a in "$@"; do
        [[ $a == --amend* ]] && block "Claude never amends a commit. Make a new commit instead."
        if [[ $a =~ ^(--all|-[a-zA-Z]*a[a-zA-Z]*)$ ]]; then
          block "git commit $a stages every tracked change. Stage the subtask's files by name, then commit."
        fi
      done
      check_branch "$dir"
      ;;
    push) check_push "$dir" "$@" ;;
  esac
}

dir=$start_dir
while IFS= read -r segment; do
  read -ra w <<<"$segment"
  i=0
  while [ $i -lt ${#w[@]} ] && [[ ${w[$i]} =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do i=$((i + 1)); done
  [ $i -lt ${#w[@]} ] || continue
  case "${w[$i]}" in
    cd | pushd) dir=$(resolve "${w[$((i + 1))]}" "$dir") ;;
    git | */git) check_git "$dir" "${w[@]:$((i + 1))}" ;;
  esac
done < <(printf '%s\n' "$words" | perl -pe 's/&&|\|\||[;&|]/\n/g; s/[()]/ /g')

exit 0
