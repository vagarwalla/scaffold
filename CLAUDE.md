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
