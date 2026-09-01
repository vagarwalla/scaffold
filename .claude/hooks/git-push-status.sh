#!/usr/bin/env bash
# Say, at the end of every turn, whether anything is unpushed.
#
# The question "is everything pushed?" should not need asking. This answers it
# unprompted: one quiet line when the tree is clean and every branch is on the
# remote, a specific list when it is not.
#
# Deliberately cheap: local refs only, no `git fetch`, no network, no model
# call. That means it reports against the last known state of origin, which is
# the right trade — the thing being guarded is local work that never left this
# machine, and that is knowable without asking the server.
#
# Reads the Stop payload on stdin (unused), writes a systemMessage on stdout.
set -uo pipefail

# Not a repo, or a bare one: say nothing at all.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

say() {
  jq -nc --arg m "$1" '{systemMessage:$m, suppressOutput:true}'
  exit 0
}

branch=$(git branch --show-current 2>/dev/null)
[ -n "$branch" ] || branch="(detached HEAD)"

# Uncommitted work, staged or not. Counted, not listed: the point is to notice
# it, and `git status` is one keystroke away.
dirty=$(git status --porcelain 2>/dev/null | grep -c . || true)

detail=""
unpushed_branches=0

# What to compare a branch against when it has no upstream of its own. Resolved
# once: a stale branch left behind by a rebase usually has no upstream at all,
# which is precisely the case that looks like lost work and is not.
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
if [ -z "$base" ]; then
  for candidate in origin/main origin/master; do
    git rev-parse --verify --quiet "$candidate" >/dev/null 2>&1 && { base="$candidate"; break; }
  done
fi

# A branch matters here when it holds commits that exist on no remote at all —
# not merely when it is ahead of its own upstream. A branch with no upstream
# set is the case that actually loses work, and `--not --remotes` catches both.
behind=""
while IFS=$'\t' read -r name upstream track; do
  [ -n "$name" ] || continue

  # Behind is not a push problem, but it is the thing that turns the next push
  # into a rebase — and with several sessions committing to one repo it is the
  # normal state, not an edge case. pre-push-check.sh refuses on exactly this.
  case "$track" in
    *behind*)
      count=$(printf '%s' "$track" | sed -n 's/.*behind \([0-9]*\).*/\1/p')
      here=""
      [ "$name" = "$branch" ] && here=" ←"
      behind="${behind}
  ${name}${here} is behind ${upstream} by ${count:-?} — pull before committing more"
      ;;
  esac

  n=$(git rev-list --count "$name" --not --remotes 2>/dev/null || echo 0)
  [ "$n" -gt 0 ] 2>/dev/null || continue

  # A rebased or amended branch can carry commits that are patch-identical to
  # something already on the remote — the shape that looks alarming and is not.
  # `git cherry` computes patch ids, so only ask on a small number of commits.
  landed=""
  against="$upstream"
  [ -n "$against" ] || against="$base"
  if [ "$n" -le 20 ] && [ -n "$against" ]; then
    if [ "$(git cherry "$against" "$name" 2>/dev/null | grep -c '^+' || true)" = "0" ]; then
      landed=" — but its patches are already on ${against}, so this is a stale pointer, not lost work"
    fi
  fi

  unpushed_branches=$((unpushed_branches + 1))
  here=""
  [ "$name" = "$branch" ] && here=" ←"
  where="no upstream set"
  [ -n "$upstream" ] && where="→ $upstream"

  detail="${detail}
  ${name}${here} — ${n} unpushed, ${where}${landed}"
  # What is in it, so the branch name is not the only clue.
  while IFS= read -r subject; do
    [ -n "$subject" ] && detail="${detail}
      · ${subject}"
  done < <(git log --format='%s' -3 "$name" --not --remotes 2>/dev/null)
done < <(git for-each-ref --format='%(refname:short)%09%(upstream:short)%09%(upstream:track)' refs/heads/ 2>/dev/null)

repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)

if [ "$unpushed_branches" -eq 0 ] && [ "$dirty" -eq 0 ] && [ -z "$behind" ]; then
  say "✓ ${repo}: everything committed and pushed (${branch})"
fi

msg="git status — ${repo}"
if [ "$unpushed_branches" -gt 0 ]; then
  msg="${msg}

${unpushed_branches} branch(es) with commits on no remote:${detail}"
else
  msg="${msg}

All branches are on the remote."
fi
[ -n "$behind" ] && msg="${msg}

Behind the remote:${behind}"
[ "$dirty" -gt 0 ] && msg="${msg}

${dirty} uncommitted file(s) in the working tree (${branch})."

say "$msg"
