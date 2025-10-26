# ShadowThrow (Monorepo)

> PNPM workspace for ShadowThrow. Apps live in pps/.

## Quick Start
`ash
corepack enable
pnpm install
pnpm dev
`

## Apps
- pps/web â€” main Next.js app
- pps/imported â€” optional drop-in app

## Scripts
- pnpm dev, pnpm -r build, pnpm lint, pnpm format, pnpm typecheck

## Environment
Copy .env.example to .env.local and fill values.

## CI
GitHub Actions workflow in .github/workflows/ci.yml.
