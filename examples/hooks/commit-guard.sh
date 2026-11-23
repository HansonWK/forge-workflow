#!/usr/bin/env bash
# PreToolUse hook (Bash and PowerShell): Claude commits only on a branch the workflow owns, files staged by name, never amending.
# Refuses `git commit` on the default branch, a detached HEAD or a branch outside OWNED_BRANCH,
# `git commit --amend` / `-a`, a commit message holding an apostrophe, `git add -A` / `--all` / `.`,
# and a `git push` that targets the default branch.
# Exit code 2 blocks the call and shows stderr to Claude.

# OWNED_BRANCH and OWNED_HINT: the branches the workflow owns, shared with push-branch.sh.
owned_file="$(dirname "$0")/../scripts/owned-branch.sh"
OWNED_BRANCH=
. "$owned_file" 2>/dev/null

block() {
  echo "Blocked: $1" >&2
  exit 2
}

# Input the guard can't read is refused, never waved through.
command -v node >/dev/null 2>&1 ||
  block "the commit guard needs node to read the hook input, and node isn't on PATH. Install node, or ask the developer to run the command."
input=$(cat)
{
  IFS= read -r -d '' parsed
  IFS= read -r -d '' tool
  IFS= read -r -d '' start_dir
  IFS= read -r -d '' cmd
} < <(printf '%s' "$input" | node -e '
  let s = "";
  process.stdin.on("data", (d) => (s += d)).on("end", () => {
    let j;
    try { j = JSON.parse(s); } catch {}
    if (!j || typeof j !== "object") return process.stdout.write("bad\0");
    process.stdout.write(["ok", j.tool_name, j.cwd, j.tool_input?.command].map((v) => v ?? "").join("\0") + "\0");
  });')
[ "$parsed" = ok ] || block "the commit guard couldn't read the hook input as JSON, so it can't check this command."
case "$tool" in Bash | PowerShell) ;; *) exit 0 ;; esac
[ -n "$cmd" ] || exit 0
start_dir=${start_dir:-${CLAUDE_PROJECT_DIR:-$PWD}}

# Heredoc and here-string bodies are data; code after a here-string's closing '@ is read. In PowerShell
# a backtick escapes the next character or continues the line, and a { } block holds commands. Quoted
# text stays one word: its spaces and separators are swapped for control bytes (decoded again for paths
# and messages), so a commit message never splits the command, `echo "git commit"` is not a commit, and
# `cd "/a b"` still finds "/a b".
# A heredoc or here-string opened (or, in PowerShell, closed) on a line with a git commit is that
# commit's message (`-F - <<EOF`, `-m "$(cat <<EOF`, `@'…'@ | git commit -F -`): keep its text.
commit_line='git.*[[:space:]]commit([[:space:]]|$)'
if [ "$tool" = PowerShell ]; then
  commit_heredocs=$(printf '%s\n' "${cmd//$'\r'/}" | awk -v re="$commit_line" '
    inside { if ($0 ~ /^["\047]@/) { inside = 0; if (keep || $0 ~ re) printf "%s", text } else text = text $0 "\n"; next }
    /@["\047][[:space:]]*$/ { inside = 1; keep = ($0 ~ re); text = "" }')
  body=$(printf '%s\n' "${cmd//$'\r'/}" | awk '
    inside { if ($0 ~ /^["\047]@/) { inside = 0; sub(/^["\047]@/, "_"); print } next }
    /@["\047][[:space:]]*$/ { sub(/@["\047][[:space:]]*$/, "_"); print; inside = 1; next }
    { print }' | perl -0pe 's/`\n/ /g; s/`["\x27]/_/g; s/`(.)/$1/g; s/[{}]/;/g')
else
  commit_heredocs=$(printf '%s\n' "${cmd//$'\\\n'/ }" | awk -v re="$commit_line" '
    marker != "" { if ($0 == marker) marker = ""; else if (keep) print; next }
    match($0, /<<-?[[:space:]]*["\047]?[A-Za-z_][A-Za-z0-9_]*/) {
      marker = substr($0, RSTART, RLENGTH); sub(/^<<-?[[:space:]]*["\047]?/, "", marker); keep = ($0 ~ re)
    }')
  body=$(printf '%s\n' "${cmd//$'\\\n'/ }" | awk '
    marker != "" { if ($0 == marker) marker = ""; next }
    match($0, /<<-?[[:space:]]*["\047]?[A-Za-z_][A-Za-z0-9_]*/) {
      marker = substr($0, RSTART, RLENGTH); sub(/^<<-?[[:space:]]*["\047]?/, "", marker)
    }
    { print }')
fi
# In PowerShell, '' inside a single-quoted string is one literal '.
words=$(printf '%s\n' "$body" | PS=$([ "$tool" = PowerShell ] && echo 1) perl -pe '
  my $sq = $ENV{PS} ? qr/\x27((?:[^\x27]|\x27\x27)*)\x27/ : qr/\x27([^\x27]*)\x27/;
  s/"([^"]*)"|$sq/my $q = defined $1 ? $1 : $2; $q =~ s{\x27\x27}{\x27}g if $ENV{PS}; $q =~ tr{ \t;&|()\n}{\x10-\x17}; length $q ? $q : "\x18"/ge')

decode() { printf '%s' "$1" | tr '\020\021\022\023\024\025\026\027' ' \t;&|()\n' | tr -d '\030'; }

# A path the guard can't work out (another variable, cd -) resolves to a folder that doesn't exist,
# and a commit there is refused.
resolve() {
  local p v f
  p=$(decode "$1")
  for v in CLAUDE_PROJECT_DIR HOME; do
    for f in "\${$v}" "\$env:$v" "\$$v"; do
      case "$p" in "$f" | "$f"/* | "$f"\\*) p=${!v}${p#"$f"}; break 2 ;; esac
    done
  done
  case "$p" in
    '' | '~') printf '%s' "$HOME" ;;
    '~/'* | '~\'*) printf '%s' "$HOME/${p#'~'?}" ;;
    /* | [A-Za-z]:[\\/]* | '\\'*) printf '%s' "$p" ;;
    *) printf '%s' "$2/$p" ;;
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
  git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 ||
    block "the commit guard can't find a git checkout at '$dir', so it can't check the branch. Commit from the checkout, with a plain path."
  [ -n "$OWNED_BRANCH" ] || block "the commit guard can't read $owned_file, so it can't tell which branches the workflow owns."
  branch=$(git -C "$dir" symbolic-ref -q --short HEAD)
  [ -n "$branch" ] || block "this checkout is on a detached HEAD. Claude commits only on a workflow branch ($OWNED_HINT): create one with git switch -c first."
  is_default "$branch" "$(default_branch "$dir")" &&
    block "'$branch' is the default branch, which Claude doesn't commit on: create a workflow branch ($OWNED_HINT) with git switch -c first."
  printf '%s' "$branch" | grep -Eq "$OWNED_BRANCH" ||
    block "'$branch' is not a branch the workflow owns ($OWNED_HINT). Claude commits only on those: suggest a correctly named branch to the developer instead."
}

# No apostrophe (straight ' or curly U+2019) anywhere in a commit message. The message is read as git
# gets it: -m / --message values shell-unquoted (quoting characters never count), -F / --file files,
# and the commit-line heredoc above. A message the guard can't read is allowed, and the written rule
# in CLAUDE.md covers it: one built from a variable or a pipe, a file the same command writes, a
# quoted -m that runs over several lines, an editor commit with no -m or -F.
curly=$'\xe2\x80\x99'
check_message() {
  local dir=$1 a f p kind v
  shift
  while [ $# -gt 0 ]; do
    a=$1 kind= v=
    shift
    case "$a" in
      --message=*) kind=m v=${a#*=} ;;
      --file=*) kind=F v=${a#*=} ;;
      --message) kind=m v=$1; shift ;;
      --file) kind=F v=$1; shift ;;
      --*) ;;
      -?*)
        # Short flags: -m, -F, -qm, -mText. A c, C, t, S or u before the m or F takes its own value.
        f=${a#-} p=${f%%[mF]*}
        if [ "$p" != "$f" ] && [[ $p != *[cCtSu]* ]]; then
          kind=${f:${#p}:1} v=${f:$((${#p} + 1))}
          [ -n "$v" ] || { v=$1; shift; }
        fi
        ;;
    esac
    case "$kind" in
      m) v=$(decode "$v" | perl -0pe 's/\$\([^)]*\)?|\$\{[^}]*\}?|\$[A-Za-z_][A-Za-z0-9_:]*|`[^`]*`?//g') ;;
      F) [ "$(decode "$v")" = - ] && v= || { f=$(resolve "$v" "$dir"); v=$([ -f "$f" ] && cat "$f"); } ;;
    esac
    case "$v" in *"'"* | *"$curly"*) kind=refuse ;; esac
    [ "$kind" = refuse ] && break
  done
  case "$kind$commit_heredocs" in refuse* | *"'"* | *"$curly"*)
    block "Commit messages may not contain apostrophes. Reword without them, for example 'agent's worktree' → 'agent worktree', 'don't' → 'do not'." ;;
  esac
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
    if [ "$target" = HEAD ]; then
      target=$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null)
      [ -n "$target" ] || block "the commit guard can't tell which branch HEAD is at '$dir', so it can't check git push $ref."
    fi
    is_default "$target" "$default" && block "git push $ref targets the default branch. Claude never pushes it: push the workflow branch and open a PR."
  done
  if [ ${#positional[@]} -le 1 ]; then
    branch=$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null)
    [ -n "$branch" ] || block "the commit guard can't tell which branch a bare git push at '$dir' would push. Name the remote and branch."
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
      check_message "$dir" "$@"
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
  # PowerShell names are case-insensitive, and Windows finds git.exe from git.
  case $(printf '%s' "${w[$i]}" | tr '[:upper:]' '[:lower:]') in
    cd | pushd | chdir | sl | set-location | push-location)
      i=$((i + 1))
      case $(printf '%s' "${w[$i]}" | tr '[:upper:]' '[:lower:]') in -path | -literalpath) i=$((i + 1)) ;; esac
      dir=$(resolve "${w[$i]}" "$dir")
      ;;
    git | */git | *'\'git | git.exe | */git.exe | *'\'git.exe) check_git "$dir" "${w[@]:$((i + 1))}" ;;
  esac
done < <(printf '%s\n' "$words" | perl -pe 's/&&|\|\||[;&|]/\n/g; s/[()]/ /g')

exit 0
