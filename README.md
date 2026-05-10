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
