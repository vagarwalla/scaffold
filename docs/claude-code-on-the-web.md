# Claude Code on the web — how the infra works

Notes for future me. Covers what runs where, what survives, and the two things
that are easy to get wrong. Applies to every repo in this account, not just
projects spun from this template.

## Where a session actually runs

A Claude Code web session does **not** run on my laptop. It runs in an isolated
container on Anthropic's infrastructure. The repo is cloned in fresh when the
container starts, and the container is reclaimed after a period of inactivity.

Consequences, in rough order of how often they bite:

- **Nothing persists between sessions except what is pushed to git.** Not
  `node_modules`, not a scratch file, not an uncommitted fix. If it matters, it
  gets committed and pushed before the session ends.
- **Every session starts from a cold container** — hence the SessionStart hook
  below.
- **My laptop is irrelevant to whether work happens.** It can be shut, asleep,
  or on a plane.

## Scheduled work (Routines)

A Routine is a stored schedule that fires a prompt. There are two kinds, and
the difference is the whole question of whether it runs while I am asleep:

| kind | where it runs | laptop shut? |
|---|---|---|
| **cloud** — the Routine stores an `environment_id` (`env_…`) | fresh container on Anthropic's infra | **runs fine** |
| **device-bound** — the Routine stores a `bound_device`; also anything the Cowork desktop app schedules locally | that machine | **does not run** |

To tell which one a Routine is, look at its stored config: an `environment_id`
and no `bound_device` means cloud.

A cloud Routine can fire in one of three shapes:

- **into a fresh session** — each firing starts from nothing. Use for scheduled
  work. The prompt must be completely self-contained: it will not have the
  conversation that created it.
- **into a specific existing session** — resumes that conversation.
- **into the session that created it** — a self check-in.

### Gotchas worth remembering

1. **A fresh-session Routine has no memory of the chat that created it.** Write
   the prompt as a standalone brief: repos, branches, file paths, what was
   already done, what "done" looks like. Assume the reader knows nothing.
2. **Connectors do not automatically come along.** A Routine created from
   inside a session can only pass through connectors that session itself holds,
   and may store none — in which case the fired session comes up with no
   `mcp__*` tools. That means **no GitHub tools**, and `gh`/`hub` are not
   installed in these containers, so it cannot open a PR. If a Routine needs to
   touch GitHub, either create it from the claude.ai Routines UI (which passes
   connectors properly) or give the prompt a fallback: push the branch, and
   hand back a `…/compare/<branch>?expand=1` link to click.
3. **Cron is UTC.** Convert local time first, and shift the day fields if the
   conversion crosses midnight. Pacific is UTC-7 in summer, UTC-8 in winter — a
   Routine set in August fires an hour off in November unless it is updated.
4. **Notifications are opt-in per Routine** (push / email), and only for
   fresh-session Routines.

### When a session stops on a usage limit

A session cut off by the account's usage limit does not restart itself, and —
because it is not running — it cannot schedule anything after the fact. So any
long unattended run **arms an hourly check-back Routine (`0 * * * *`) before it
starts**, and deletes it when the work is done. Full patterns, including the
account-level watchdog for parallel sessions, are in
[`solutions/workflow-issues/resuming-sessions-after-usage-limits.md`](solutions/workflow-issues/resuming-sessions-after-usage-limits.md).

## The SessionStart hook

`.claude/hooks/session-start.sh`, registered in `.claude/settings.json`. It
runs before the session starts and installs whatever the repo declares.

It is generic on purpose — it detects `package.json`, `requirements.txt` or
`pyproject.toml` rather than hard-coding a project, so the same file is
vendored unmodified into every repo. A repo with no manifest (stdlib-only
Python, or a docs repo) is a valid case: the hook correctly does nothing.

Two decisions inside it worth not re-litigating:

- **`npm install`, not `npm ci`.** The container is snapshotted after the hook
  completes, so the install is paid once and cached. `ci` deletes
  `node_modules` and refetches every time, discarding exactly that cache.
- **Guarded on `CLAUDE_CODE_REMOTE`.** On a local machine it exits immediately
  — a laptop already has a working setup and re-installing under my editor is
  rude.

It runs **synchronously**: the session waits for it. That trades a slower start
for the guarantee that nothing tries to run a test before the deps exist. To
prefer a faster start, make the first line of the script
`echo '{"async": true, "asyncTimeout": 300000}'` — at the cost of a race where
the agent may reach for a dependency mid-install.

**A hook only takes effect from a repo's default branch.** On a feature branch
it does nothing. Merge it before expecting it to help.

## Applying this to a new repo

```bash
mkdir -p .claude/hooks
curl -sSL https://raw.githubusercontent.com/vagarwalla/scaffold/main/.claude/hooks/session-start.sh \
  -o .claude/hooks/session-start.sh
chmod +x .claude/hooks/session-start.sh
```

Then add `.claude/settings.json` (copy from this repo), and **merge to the
default branch**.

**Check `.gitignore` first.** A bare `.claude` entry is a common default and it
silently swallows the hook — `git add` refuses the path, and if the add is
chained with `&&` the commit never runs, so the branch pushes empty and looks
fine. This repo's rule ignores the directory but un-ignores the two shared
files:

```gitignore
.claude/*
!.claude/hooks/
!.claude/settings.json
.claude/settings.local.json
```

Confirm with `git check-ignore -v .claude/hooks/session-start.sh` (no output
means it is trackable) and `git show --stat HEAD` after committing.

Verify the hook itself before trusting it:

```bash
rm -rf node_modules
CLAUDE_CODE_REMOTE=true CLAUDE_PROJECT_DIR=$PWD ./.claude/hooks/session-start.sh
env -u CLAUDE_CODE_REMOTE ./.claude/hooks/session-start.sh   # should skip
```

Currently vendored in: `scaffold` (canonical), `primer`, `sf-recs`,
`claude-context`.
