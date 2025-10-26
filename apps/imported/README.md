# Imported (Complete App)

A ready-to-run Next.js app for **Mode 1 (Drop-in)** with:
- App Router on **port 3001**
- Tailwind CSS
- NextAuth (Credentials) + Prisma (SQLite)
- Login/Register pages and protected `/dashboard`
- Health endpoints (`/health`, `/api/health`)

## Setup

```bash
# from monorepo root
pnpm --filter imported install

# set env (copy example)
cd apps/imported
copy .env.example .env.local   # Windows (PowerShell: cp .env.example .env.local)

# initialize DB
pnpm --filter imported run db:generate
pnpm --filter imported run db:push
pnpm --filter imported run db:seed
```

Set a strong `NEXTAUTH_SECRET` in `.env.local`. Default DB path is `file:./prisma/shadowthrow.sqlite`.

## Run

```bash
pnpm --filter imported dev
# visit http://localhost:3001
# login with: admin@shadowthrow.dev / change-me
```

## Scripts
- `dev`, `build`, `start`
- `lint`, `typecheck`, `format`
- `db:generate`, `db:push`, `db:seed`

## Notes
- Credentials provider uses `User.passwordHash` for simple email/password.
- Update styling or components freely; Tailwind is preconfigured.
