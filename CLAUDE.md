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

## Infra & global config
Generated from [`vagarwalla/scaffold`](https://github.com/vagarwalla/scaffold). Personal global config and infrastructure — the global `CLAUDE.md`, DNS, accounts, deploy runbooks, setup scripts — live in **[`vagarwalla/infra`](https://github.com/vagarwalla/infra)**, the single source of truth.

If this project introduces anything infra-level (a new subdomain, a Supabase table convention, an env-var pattern, a deploy quirk, a reusable script), record it in `vagarwalla/infra` — not only here.
