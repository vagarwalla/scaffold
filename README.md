# Scaffold

Personal project template — Next.js 16 + Supabase + Tailwind v4 + dark/light mode.

## What's included

- **Next.js 16** with App Router and TypeScript
- **Tailwind CSS v4** with PostCSS plugin
- **Supabase** client singleton (`src/lib/supabase.ts`)
- **Dark/light mode** via `next-themes` with FOUC prevention
- **Space Grotesk** font
- **Design tokens** matching the warm dark/cream aesthetic from jars/sf-recs
- **Theme toggle** component with sun/moon icons
- **ESLint** configured for Next.js + TypeScript
- **Example API route** with Supabase wired up

## Quick start

```bash
# Clone and rename
gh repo create vagarwalla/my-project --template vagarwalla/scaffold --private --clone
cd my-project

# Install deps
npm install

# Set up env
cp .env.example .env.local
# Fill in your Supabase URL and anon key

# Run
npm run dev
```

## Deploy to Vercel

```bash
vercel --prod
vercel domains add subdomain.vaidehiagarwalla.com
```

Then add CNAME in Namecheap: `subdomain` -> `cname.vercel-dns.com.`

## Likely project types

Projects spun up from this template tend to fall into a few buckets:

- **Personal full-stack web apps** — small Next.js + Supabase tools on `*.vaidehiagarwalla.com` subdomains (e.g. jars, sf-recs).
- **Nonprofit volunteering work** — website design/redesign and small web projects built pro bono for nonprofit organizations (landing pages, content sites, simple data/intake tools).
- **Other plausible work:**
  - **Marketing / informational sites** — single-page or small multi-page sites for events, portfolios, or community groups.
  - **Lightweight data dashboards** — Supabase-backed views for tracking, reporting, or admin (e.g. volunteer rosters, donation/inventory tracking).
  - **Reusable UI components & design-system pieces** — theme tokens, shared layout/components extracted from one project for reuse across others.

## Infra
Global config and infrastructure live in [`vagarwalla/infra`](https://github.com/vagarwalla/infra). New projects from this template should record infra-level changes there.
