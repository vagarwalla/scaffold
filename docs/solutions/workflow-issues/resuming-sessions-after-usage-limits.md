---
title: "Resuming a session that stopped on a usage limit — hourly check-back Routines"
date: 2026-09-01
problem_type: workflow_issue
track: knowledge
category: workflow-issues
module: claude-code-workflow
tags:
  - "routines"
  - "autonomy"
  - "usage-limits"
  - "claude-code-on-the-web"
applies_when: "A long-running or unattended Claude Code session gets cut off when the account hits its usage/session limit, and the work should pick back up by itself once the limit resets."
---

# Resuming a session that stopped on a usage limit

## Context

A web session running unattended (an `lfg`-style run, a long refactor, a
scheduled Routine) stops mid-task when the account hits its usage limit. Nothing
is broken and nothing is lost — the container holds the conversation — but the
run does not restart on its own when the limit resets hours later. It sits there
until a human notices and types "continue", which is exactly the babysitting
that autonomous runs are supposed to remove.

## Guidance

**Standing rule: any session doing long unattended work arms an hourly
check-back before it can be interrupted, and tears it down when the work is
done.**

The one constraint that shapes everything: **a session that has already been cut
off cannot schedule anything.** It is not running, so it cannot call
`send_later`. The reminder must either be armed *in advance* by that session, or
be owned by something outside it. Hence two patterns.

### A. Self check-in, armed up front (per-run — the default)

At the *start* of a long autonomous run, before doing the work, arm an hourly
self check-in with the `claude-code-remote` MCP tools:

```
create_trigger({
  name: "resume after usage limit — <task>",
  cron_expression: "0 * * * *",          // hourly; anchored to the creation minute
  initiation: "own_followup",
  prompt: "Check-back: if the previous turn stopped because of a usage/session limit, resume the task from where it left off and keep going. If the work is already finished, delete this Routine (delete_trigger) and say nothing."
})
```

Default targeting (no `persistent_session_id`, no `create_new_session_on_fire`)
fires back into *this* session, so the resumed turn keeps the whole
conversation — no standalone brief needed.

Behaviour once the limit is hit: firings during the limited window do nothing.
The first firing after the limit resets lands as a normal user turn and the
session continues. **The last thing the run does when it finishes is
`delete_trigger`** — otherwise it becomes an immortal hourly poke.

`send_later({delay_minutes: 60, …})` is the one-shot version: cheaper, but it
has to be re-armed each hour by a session that may be the one that is limited.
Prefer the recurring Routine for anything that might be cut off.

### B. Watchdog Routine (account-level — for many parallel sessions)

When several instances run in parallel, one hourly cloud Routine firing into a
**fresh** session can nurse all of them:

```
create_trigger({
  name: "usage-limit watchdog",
  cron_expression: "0 * * * *",
  create_new_session_on_fire: true,
  initiation: "own_initiative",
  prompt: "<standalone brief> Call list_sessions({mine: true}). For each active session whose last turn stopped on a usage/session limit, send_message('continue where you left off') to it. If none, exit without messaging or commenting. Never poke an archived or finished session."
})
```

The watchdog itself runs on the same account, so during a limited window it is
limited too — it simply no-ops and the next hour catches everything. That is
fine; it is the reason the interval is an hour and not a day.

### Gotchas

1. **Hourly is the floor.** The minimum Routine interval is normally one hour;
   a tighter cron is rejected. `0 * * * *` is anchored to the creation minute
   server-side, so Routines spread across the hour instead of stacking at :00.
2. **Cron is UTC** (see `claude-code-on-the-web.md` § Scheduled work).
3. **Connectors do not come along.** These patterns need the
   `claude-code-remote` MCP tools in the fired session. A Routine created from
   inside a session can only pass through what that session holds — create the
   watchdog from the claude.ai Routines UI if the tools come up missing.
4. **Tear it down.** Both patterns end with `delete_trigger`. An hourly Routine
   that outlives its task burns usage on nothing and makes the next limit
   arrive sooner.
5. **`/loop` is not this.** `/loop` creates repeated turns inside a session that
   is still running; it dies with the session. Only a stored Routine survives a
   container being reclaimed.

## Why This Matters

The point of a cloud session is that work happens while the laptop is shut. A
usage limit silently converts an unattended run back into one that needs a human
turn to progress — the same treadmill described in
`driving-longer-autonomous-runs-with-skills.md`, arriving through a different
door. An armed hourly check-back closes it: the run pauses at the limit and
restarts itself when the limit resets.
