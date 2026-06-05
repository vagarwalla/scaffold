---
title: "Driving longer autonomous runs — orchestrator skills + a runnable DONE signal"
date: 2026-06-04
problem_type: workflow_issue
track: knowledge
category: workflow-issues
module: claude-code-workflow
tags:
  - "skills"
  - "autonomy"
  - "compound-engineering"
  - "superpowers"
  - "lfg"
applies_when: "You want Claude Code/Cursor to run more autonomous iterative cycles on a task instead of stopping and waiting for a reply every few turns."
---

# Driving longer autonomous runs — orchestrator skills + a runnable DONE signal

## Context

Working across several Claude Code / Cursor instances on small Next.js + Supabase
scaffold projects (personal apps, nonprofit sites, dashboards), each instance kept
stopping after a few turns and waiting for a human reply — turning the human into
the orchestrator and creating a "finish → respond → finish → respond" treadmill.
The instinct was to look for a turn-count setting. There isn't one that matters.

## Guidance

Longer autonomous runs come from **two things**, neither of which is a setting:

1. **Hand the plan to an orchestrator skill** — not a leaf skill, and not by stopping
   after planning.
   - **Leaf skills** do one job and stop: `test-driven-development`,
     `verification-before-completion`, `ce-code-review`. They do not loop or
     self-trigger; an orchestrator summons them.
   - **Orchestrator skills** are playbooks whose own instructions invoke other
     skills in sequence: `subagent-driven-development`, `executing-plans`, and
     especially `compound-engineering:lfg` (plan → work → review → test → commit →
     PR → watch-CI → fix-until-green).
   - This is why you "use" TDD/verification without ever typing them — an
     orchestrator pulls them in. Stopping after `writing-plans` means no
     orchestrator is running, so nothing sustains the run.

2. **Give it an objective, machine-checkable DONE signal.** A prose goal ("a working
   page") lets the model declare victory early. A runnable signal (`npm run build`
   exits 0, lint clean, page renders in the Vercel preview) does not. The success
   signal is what keeps the loop going to completion.

The `/loop` skill is the only one that creates literal repeated turns, and it only
fires when explicitly invoked — nothing auto-calls it. Use it for polling ("is CI
green yet"), not as the general autonomy mechanism.

## Why This Matters

Parallel instances are the right model for independent projects — that is not the
waste. The waste is each instance needing a human turn to progress. Move
high-confidence work to an orchestrator + a verifiable DONE signal and those
instances run unattended; you go from babysitting turns to reviewing finished PRs.

## When to Apply

- High-confidence / low-risk work (e.g. a nonprofit landing page, a dashboard view)
  → `lfg`, fire-and-forget.
- Ambiguous / design-heavy work → `brainstorming` + human in the loop.
- Repetitive polling → `/loop`.

Skill families do not mix cleanly — pick one lane:
- **Superpowers** (discipline-first): `brainstorming → writing-plans →
  executing-plans` / `subagent-driven-development`. Stricter gates, TDD.
- **Compound Engineering** (leverage-first): `ce-brainstorm → ce-plan → ce-work →
  ce-code-review`, capped by `lfg` (full hands-off) plus knowledge-compounding
  skills (`ce-compound`). Best for fire-and-forget on repos with a CI/build signal.

## Examples

Bake the DONE signal into the project template so every project inherits it
(`scaffold/CLAUDE.md`):

```markdown
## Definition of Done (runnable signal required)
- `npm run build` exits 0
- `npm run lint` passes clean
- The affected page/route renders correctly in the Vercel preview deploy
```

A project-level `CLAUDE.md` rule outranks skill defaults, so adding
"every plan must define DONE as a runnable command before implementation starts"
forces any skill (Superpowers or CE) to hold that line — better than editing skill
files, which get overwritten on plugin updates.

Kickoff that actually sustains a run (don't stop at the plan):

```
/ce-brainstorm <idea>   →   /ce-plan   →   /lfg   (review the PR it opens)
```
