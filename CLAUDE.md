# Project Name — subdomain.vaidehiagarwalla.com

Brief description of the project.

## Architecture
- **Framework**: Next.js 16 (App Router) with TypeScript + Tailwind CSS v4
- **Backend**: Supabase (shared project `xkwiugwafgcmcwlyzawq` / `bookbundle`)
- **Hosting**: Vercel, domain `subdomain.vaidehiagarwalla.com`
- **Database tables**:
  - `table_name` — description

## Key Decisions
- Decision 1
- Decision 2
- Light/dark mode with theme toggle (next-themes), preference stored in localStorage

## Database Schema
```sql
-- CREATE TABLE ...
```

## Environment Variables
- `NEXT_PUBLIC_SUPABASE_URL` — Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` — Supabase anon key

## File Structure
- `src/app/page.tsx` — Main UI
- `src/app/api/` — API routes
- `src/lib/supabase.ts` — Supabase client singleton
- `src/components/` — React components

## Definition of Done (runnable signal required)
Every plan or task in a project built from this scaffold MUST define DONE as an objective, machine-checkable signal — not prose. Do not start implementation until it is specified. Default for this stack:

- `npm run build` exits 0
- `npm run lint` passes clean
- The affected page/route renders correctly in the Vercel preview deploy (or local `npm run dev`)

Add task-specific checks on top (e.g. "API route returns 200 with seeded data"). Autonomous skills (`ce-work`, `lfg`, `executing-plans`) should run against this signal and not declare success until it passes.

## Long unattended runs — survive a usage limit

A session cut off by the account's usage limit does not restart itself, and cannot schedule anything once it is stopped. So **before** starting any long autonomous run (`lfg`, `ce-work`, `executing-plans`, a big refactor), arm an hourly check-back Routine that fires back into this session:

- `create_trigger({name: "resume after usage limit — <task>", cron_expression: "0 * * * *", initiation: "own_followup", prompt: "Check-back: if the previous turn stopped on a usage/session limit, resume the task and keep going. If the work is finished, delete this Routine and say nothing."})`
- Firings during the limited window do nothing; the first one after the limit resets continues the run with full conversation context.
- **The run's last step is `delete_trigger`** — an hourly Routine that outlives its task burns usage on nothing.

Patterns, gotchas and the account-level watchdog: [`docs/solutions/workflow-issues/resuming-sessions-after-usage-limits.md`](docs/solutions/workflow-issues/resuming-sessions-after-usage-limits.md).

## Infra & global config
Generated from [`vagarwalla/scaffold`](https://github.com/vagarwalla/scaffold). Personal global config and infrastructure — the global `CLAUDE.md`, DNS, accounts, deploy runbooks, setup scripts, and the `docs/` runbooks — live in **[`vagarwalla/scaffold`](https://github.com/vagarwalla/scaffold)** itself, the single source of truth. (`vagarwalla/infra` does not exist; this pointed at it until 2026-09-01.)

If this project introduces anything infra-level (a new subdomain, a Supabase table convention, an env-var pattern, a deploy quirk, a reusable script), record it in `vagarwalla/scaffold` — not only here.

## Reporting back to V

**V has ADHD. Summaries are short, bulleted and visual — a hard rule, not a style note.** A wall of prose does not get read, so a long summary is a failed handoff however good the work underneath it was.

- **Bullets. Five or fewer. One line each.** No preamble, no restating the request.
- **Lead with the picture.** Anything with a look — a page, a drawing, a chart, a layout — gets a rendered image (`SendUserFile`) or a live link *at the top*, before the words.
- **Link, don't describe.** PR, branch, compare URL, deployed page.
- **Any decision she has to make goes last, as one bullet.** If there is none, don't invent one.
- **Bad news still gets a bullet** — broken, skipped or uncertain things stay in the list rather than being softened into prose.
- Detail belongs in the commit message and the code comments, not in chat. She will ask if she wants more.

Canonical copy: `identity-refresh/CLAUDE.md` § How to work with me.
